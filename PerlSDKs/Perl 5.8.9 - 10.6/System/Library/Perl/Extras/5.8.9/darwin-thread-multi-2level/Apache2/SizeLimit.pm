# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
package Apache2::SizeLimit;

use strict;
use warnings FATAL => 'all';

use mod_perl2;

use Apache2::RequestRec ();
use Apache2::RequestUtil ();
use Apache2::MPM ();
use APR::Pool ();
use ModPerl::Util ();

use Config;

use constant WIN32    => $^O eq 'MSWin32';
use constant SOLARIS  => $^O eq 'solaris';
use constant LINUX    => $^O eq 'linux';
use constant BSD_LIKE => $^O =~ /(bsd|aix)/i;

use Apache2::Const -compile => qw(OK DECLINED);

our $VERSION = '0.05';

our $CHECK_EVERY_N_REQUESTS = 1;
our $REQUEST_COUNT          = 1;
our $MAX_PROCESS_SIZE       = 0;
our $MIN_SHARE_SIZE         = 0;
our $MAX_UNSHARED_SIZE      = 0;
our $USE_SMAPS              = 1;

our ($HOW_BIG_IS_IT, $START_TIME);

BEGIN {

    die "Apache2::SizeLimit at the moment works only with non-threaded MPMs"
        if Apache2::MPM->is_threaded();

    # decide at compile time how to check for a process' memory size.
    if (SOLARIS && $Config{'osvers'} >= 2.6) {

        $HOW_BIG_IS_IT = \&solaris_2_6_size_check;

    }
    elsif (LINUX) {
        if ( eval { require Linux::Smaps } and Linux::Smaps->new($$) ) {
            $HOW_BIG_IS_IT = \&linux_smaps_size_check_first_time;
        }
        else {
            $USE_SMAPS = 0;
            $HOW_BIG_IS_IT = \&linux_size_check;
        }
    }
    elsif (BSD_LIKE) {

        # will getrusage work on all BSDs?  I should hope so.
        if ( eval { require BSD::Resource } ) {
            $HOW_BIG_IS_IT = \&bsd_size_check;
        }
        else {
            die "you must install BSD::Resource for Apache2::SizeLimit " .
                "to work on your platform.";
        }

#  Currently unsupported for mp2 because of threads...
#     }
#      elsif (WIN32) {
#
#         if ( eval { require Win32::API } ) {
#             $HOW_BIG_IS_IT = \&win32_size_check;
#         }
#          else {
#             die "you must install Win32::API for Apache2::SizeLimit " .
#                 "to work on your platform.";
#         }

    }
    else {

        die "Apache2::SizeLimit not implemented on $^O";

    }
}

sub linux_smaps_size_check_first_time {

    if ($USE_SMAPS) {
        $HOW_BIG_IS_IT = \&linux_smaps_size_check;
    } else {
        $HOW_BIG_IS_IT = \&linux_size_check;
    }

    goto &$HOW_BIG_IS_IT;
}

sub linux_smaps_size_check {

    my $s = Linux::Smaps->new($$)->all;
    return ($s->size, $s->shared_clean + $s->shared_dirty);
}

# return process size (in KB)
sub linux_size_check {
    my ($size, $resident, $share) = (0, 0, 0);

    my $file = "/proc/self/statm";
    if (open my $fh, "<$file") {
        ($size, $resident, $share) = split /\s/, scalar <$fh>;
        close $fh;
    }
    else {
        error_log("Fatal Error: couldn't access $file");
    }

    # linux on intel x86 has 4KB page size...
    return ($size * 4, $share * 4);
}

sub solaris_2_6_size_check {
    my $file = "/proc/self/as";
    my $size = -s $file
        or &error_log("Fatal Error: $file doesn't exist or is empty");
    $size = int($size / 1024); # in Kb
    return ($size, 0);
}

# rss is in KB but ixrss is in BYTES.
# This is true on at least FreeBSD, OpenBSD, NetBSD
# Philip M. Gollucci
sub bsd_size_check {

    my @results = BSD::Resource::getrusage();
    my $max_rss   = $results[2];
    my $max_ixrss = int ( $results[3] / 1024 );

    return ( $max_rss, $max_ixrss );
}

sub win32_size_check {

    # get handle on current process
    my $GetCurrentProcess =
        Win32::API->new( 'kernel32', 'GetCurrentProcess', [], 'I' );
    my $hProcess = $GetCurrentProcess->Call();

    # memory usage is bundled up in ProcessMemoryCounters structure
    # populated by GetProcessMemoryInfo() win32 call
    my $DWORD  = 'B32';    # 32 bits
    my $SIZE_T = 'I';      # unsigned integer

    # build a buffer structure to populate
    my $pmem_struct            = "$DWORD" x 2 . "$SIZE_T" x 8;
    my $pProcessMemoryCounters =
        pack $pmem_struct, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;

    # GetProcessMemoryInfo is in "psapi.dll"
    my $GetProcessMemoryInfo = Win32::API->new('psapi',
                                               'GetProcessMemoryInfo',
                                               [ 'I', 'P', 'I' ], 'I' );

    my $bool =
        $GetProcessMemoryInfo->Call($hProcess, $pProcessMemoryCounters,
                                    length $pProcessMemoryCounters);

    # unpack ProcessMemoryCounters structure
    my $PeakWorkingSetSize =
        (unpack $pmem_struct, $pProcessMemoryCounters)[2];

    # only care about peak working set size
    my $size = int($PeakWorkingSetSize / 1024);

    return ($size, 0);
}

sub exit_if_too_big {
    my $r = shift;

    #warn "Apache2::Size::Limit exit sub called";

    return Apache2::Const::DECLINED if $CHECK_EVERY_N_REQUESTS &&
        ($REQUEST_COUNT++ % $CHECK_EVERY_N_REQUESTS);

    $START_TIME ||= time;

    my ($size, $share) = $HOW_BIG_IS_IT->();
    my $unshared = $size - $share;

    my $kill_size     = $MAX_PROCESS_SIZE  && $size > $MAX_PROCESS_SIZE;
    my $kill_share    = $MIN_SHARE_SIZE    && $share < $MIN_SHARE_SIZE;
    my $kill_unshared = $MAX_UNSHARED_SIZE && $unshared > $MAX_UNSHARED_SIZE;

    if ($kill_size || $kill_share || $kill_unshared) {
        # wake up! time to die.
        if (WIN32 || ( getppid > 1 )) {
            # this is a child httpd
            my $e   = time - $START_TIME;
            my $msg = "httpd process too big, exiting at SIZE=$size/$MAX_PROCESS_SIZE KB ";
            $msg .= " SHARE=$share/$MIN_SHARE_SIZE KB " if $share;
            $msg .= " UNSHARED=$unshared/$MAX_UNSHARED_SIZE KB " if $unshared;
            $msg .= " REQUESTS=$REQUEST_COUNT LIFETIME=$e seconds";
            error_log($msg);

            $r->child_terminate();
        }
        else {    # this is the main httpd, whose parent is init?
            my $msg = "main process too big, SIZE=$size/$MAX_PROCESS_SIZE KB ";
            $msg .= " SHARE=$share/$MIN_SHARE_SIZE KB" if $share;
            $msg .= " UNSHARED=$unshared/$MAX_UNSHARED_SIZE KB" if $unshared;
            error_log($msg);
        }
    }

    return Apache2::Const::OK;
}

# setmax can be called from within a CGI/Registry script to tell the httpd
# to exit if the CGI causes the process to grow too big.
sub setmax {
    $MAX_PROCESS_SIZE = shift;
    my $r = shift || Apache2::RequestUtil->request();
    unless ($r->pnotes('size_limit_cleanup')) {
        $r->pool->cleanup_register(\&exit_if_too_big, $r);
        $r->pnotes('size_limit_cleanup', 1);
    }
}

sub setmin {
    $MIN_SHARE_SIZE = shift;
    my $r = shift || Apache2::RequestUtil->request();
    unless ($r->pnotes('size_limit_cleanup')) {
        $r->pool->cleanup_register(\&exit_if_too_big, $r);
        $r->pnotes('size_limit_cleanup', 1);
    }
}

sub setmax_unshared {
    $MAX_UNSHARED_SIZE = shift;
    my $r = shift || Apache2::RequestUtil->request();
    unless ($r->pnotes('size_limit_cleanup')) {
        $r->pool->cleanup_register(\&exit_if_too_big, $r);
        $r->pnotes('size_limit_cleanup', 1);
    }
}

sub handler {
    my $r = shift;

    if ($r->is_initial_req()) {
        # we want to operate in a cleanup handler
        if (ModPerl::Util::current_callback() eq 'PerlCleanupHandler') {
            exit_if_too_big($r);
        }
        else {
            $r->pool->cleanup_register(\&exit_if_too_big, $r);
        }
    }

    return Apache2::Const::DECLINED;
}

sub error_log {
    print STDERR "[", scalar(localtime time),
        "] ($$) Apache2::SizeLimit @_\n";
}

1;


=head1 NAME

Apache2::SizeLimit - Because size does matter.

=head1 Synopsis

This module allows you to kill off Apache httpd processes if they grow
too large.  You can choose to set up the process size limiter to check
the process size on every request:

  # in your startup.pl, or a <Perl> section:
  use Apache2::SizeLimit;
  # sizes are in KB
  $Apache2::SizeLimit::MAX_PROCESS_SIZE  = 12000; # 12MB
  $Apache2::SizeLimit::MIN_SHARE_SIZE    = 6000;  # 6MB
  $Apache2::SizeLimit::MAX_UNSHARED_SIZE = 5000;  # 5MB

  # in your httpd.conf:
  PerlCleanupHandler Apache2::SizeLimit

Or you can just check those requests that are likely to get big, such
as CGI requests.  This way of checking is also easier for those who
are mostly just running CGI scripts under
C<L<ModPerl::Registry|docs::2.0::api::ModPerl::Registry>>:

  # in your script:
  use Apache2::SizeLimit;
  # sizes are in KB
  Apache2::SizeLimit::setmax(12000);
  Apache2::SizeLimit::setmin(6000);
  Apache2::SizeLimit::setmax_unshared(5000);

This will work in places where you are using C<L<SetHandler
perl-script|docs::2.0::user::config::config/C_perl_script_>> or
anywhere you enable C<L<PerlOptions
+GlobalRequest|docs::2.0::user::config::config/C_GlobalRequest_>>.  If
you want to avoid turning on C<GlobalRequest>, you can pass an
C<L<Apache2::RequestRec|docs::2.0::api::Apache2::RequestRec>> object as
the second argument in these subs:

  my $r = shift; # if you don't have $r already
  Apache2::SizeLimit::setmax(12000, $r);
  Apache2::SizeLimit::setmin(6000, $r);
  Apache2::SizeLimit::setmax_unshared(5000, $r);

Since checking the process size can take a few system calls on some
platforms (e.g. linux), you may want to only check the process size
every N times.  To do so, put this in your startup.pl or CGI:

  $Apache2::SizeLimit::CHECK_EVERY_N_REQUESTS = 2;

This will only check the process size every other time the process
size checker is called.




=head1 Description

This module is highly platform dependent, please read the
L<Caveats|/Caveats> section.  It also does not work L<under threaded
MPMs|/Supported_MPMs>.

This module was written in response to questions on the mod_perl
mailing list on how to tell the httpd process to exit if it gets too
big.

Actually there are two big reasons your httpd children will grow.
First, it could have a bug that causes the process to increase in size
dramatically, until your system starts swapping.  Second, it may just
do things that requires a lot of memory, and the more different kinds
of requests your server handles, the larger the httpd processes grow
over time.

This module will not really help you with the first problem.  For that
you should probably look into
C<L<Apache2::Resource|docs::2.0::api::Apache2::Resource>> or some other
means of setting a limit on the data size of your program.  BSD-ish
systems have C<setrlimit()> which will croak your memory gobbling
processes.  However it is a little violent, terminating your process
in mid-request.

This module attempts to solve the second situation where your process
slowly grows over time.  The idea is to check the memory usage after
every request, and if it exceeds a threshold, exit gracefully.

By using this module, you should be able to discontinue using the
Apache configuration directive C<MaxRequestsPerChild>, although you
can use both if you are feeling paranoid.  Most users use the
technique shown in this module and set their C<MaxRequestsPerChild>
value to C<0>.





=head1 Shared Memory Options

In addition to simply checking the total size of a process, this
module can factor in how much of the memory used by the process is
actually being shared by copy-on-write.  If you don't understand how
memory is shared in this way, take a look at the extensive
documentation at http://perl.apache.org/docs/.

You can take advantage of the shared memory information by setting a
minimum shared size and/or a maximum unshared size.  Experience on one
heavily trafficked mod_perl site showed that setting maximum unshared
size and leaving the others unset is the most effective policy.  This
is because it only kills off processes that are truly using too much
physical RAM, allowing most processes to live longer and reducing the
process churn rate.





=head1 Caveats

This module is platform-dependent, since finding the size of a process
is pretty different from OS to OS, and some platforms may not be
supported.  In particular, the limits on minimum shared memory and
maximum shared memory are currently only supported on Linux and BSD.
If you can contribute support for another OS, please do.





=head2 Supported OSes

=over 4

=item linux

For linux we read the process size out of F</proc/self/statm>.  This
seems to be fast enough on modern systems. If you are worried about
performance, try setting the C<CHECK_EVERY_N_REQUESTS> option.

Since linux 2.6 F</proc/self/statm> does not report the amount of
memory shared by the copy-on-write mechanism as shared memory. Hence
decisions made on the basis of C<MAX_UNSHARED_SIZE> or C<MIN_SHARE_SIZE>
are inherently wrong.

To correct the situation there is a patch to the linux kernel that adds a
F</proc/self/smaps> entry for each process. At the time of this writing
the patch is included in the mm-tree (linux-2.6.13-rc4-mm1) and is expected
to make it into the vanilla kernel in the near future.

F</proc/self/smaps> reports various sizes for each memory segment of a
process and allows to count the amount of shared memory correctly.

If C<Apache2::SizeLimit> detects a kernel that supports F</proc/self/smaps>
and if the C<Linux::Smaps> module is installed it will use them instead of
F</proc/self/statm>. You can prevent C<Apache2::SizeLimit> from using
F</proc/self/smaps> and turn on the old behaviour by setting
C<$Apache2::SizeLimit::USE_SMAPS> to 0 before the first check.

C<Apache2::SizeLimit> also resets C<$Apache2::SizeLimit::USE_SMAPS> to 0
if it somehow decides not to use F</proc/self/smaps>. Thus, you can
check it to determine what is actually used.

NOTE: Reading F</proc/self/smaps> is expensive compared to
F</proc/self/statm>. It must look at each page table entry of a process.
Further, on multiprocessor systems the access is synchronized with
spinlocks. Hence, you are encouraged to set the C<CHECK_EVERY_N_REQUESTS>
option.

The following example shows the effect of copy-on-write:

  <Perl>
    require Apache2::SizeLimit;
    package X;
    use strict;
    use Apache2::RequestRec ();
    use Apache2::RequestIO ();
    use Apache2::Const -compile=>qw(OK);

    my $x= "a" x (1024*1024);

    sub handler {
      my $r = shift;
      my ($size, $shared) = $Apache2::SizeLimit::HOW_BIG_IS_IT->();
      $x =~ tr/a/b/;
      my ($size2, $shared2) = $Apache2::SizeLimit::HOW_BIG_IS_IT->();
      $r->content_type('text/plain');
      $r->print("1: size=$size shared=$shared\n");
      $r->print("2: size=$size2 shared=$shared2\n");
      return Apache2::Const::OK;
    }
  </Perl>

  <Location /X>
    SetHandler modperl
    PerlResponseHandler X
  </Location>

The parent apache allocates a megabyte for the string in C<$x>. The
C<tr>-command then overwrites all "a" with "b" if the handler is
called with an argument. This write is done in place, thus, the
process size doesn't change. Only C<$x> is not shared anymore by
means of copy-on-write between the parent and the child.

If F</proc/self/smaps> is available curl shows:

  r2@s93:~/work/mp2> curl http://localhost:8181/X
  1: size=13452 shared=7456
  2: size=13452 shared=6432

Shared memory has lost 1024 kB. The process' overall size remains unchanged.

Without F</proc/self/smaps> it says:

  r2@s93:~/work/mp2> curl http://localhost:8181/X
  1: size=13052 shared=3628
  2: size=13052 shared=3636

One can see the kernel lies about the shared memory. It simply doesn't count 
copy-on-write pages as shared.

=item Solaris 2.6 and above

For Solaris we simply retrieve the size of F</proc/self/as>, which
contains the address-space image of the process, and convert to KB.
Shared memory calculations are not supported.

NOTE: This is only known to work for solaris 2.6 and above. Evidently
the /proc filesystem has changed between 2.5.1 and 2.6. Can anyone
confirm or deny?

=item BSD

Uses C<BSD::Resource::getrusage()> to determine process size.  This is
pretty efficient (a lot more efficient than reading it from the
I</proc> fs anyway).

=item AIX?

Uses C<BSD::Resource::getrusage()> to determine process size.  Not
sure if the shared memory calculations will work or not.  AIX users?

=item Win32

Under mod_perl 1, SizeLimit provided basic functionality by using 
C<Win32::API> to access process memory information.  This worked 
because there was only one mod_perl thread.  With mod_perl 2, Win32 
runs a true threaded MPM, which unfortunately means that we can't 
tell the size of each interpreter.  Win32 support is disabled until 
a solution for this can be found.

=back

If your platform is not supported, and if you can tell us how to check
for the size of a process under your OS (in KB), then we will add it to
the list.  The more portable/efficient the solution, the better, of
course.




=head2 Supported MPMs

At this time, C<Apache2::SizeLimit> does not support use under threaded
MPMs.  This is because there is no efficient way to get the memory
usage of a thread, or make a thread exit cleanly.  Suggestions and
patches are welcome on L<the mod_perl dev mailing
list|maillist::dev>.





=head1 Copyright

mod_perl 2.0 and its core modules are copyrighted under
The Apache Software License, Version 2.0.





=head1 Author

Doug Bagley E<lt>doug+modperl bagley.orgE<gt>, channeling Procrustes.

Brian Moseley E<lt>ix maz.orgE<gt>: Solaris 2.6 support

Doug Steinwand and Perrin Harkins E<lt>perrin elem.comE<gt>: added
support for shared memory and additional diagnostic info

Matt Phillips E<lt>mphillips virage.comE<gt> and Mohamed Hendawi
E<lt>mhendawi virage.comE<gt>: Win32 support

Torsten Foertsch E<lt>torsten.foertsch gmx.netE<gt>: Linux::Smaps support

=cut

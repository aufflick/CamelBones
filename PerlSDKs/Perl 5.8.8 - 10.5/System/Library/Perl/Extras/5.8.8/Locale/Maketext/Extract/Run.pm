package Locale::Maketext::Extract::Run;
$Locale::Maketext::Lexicon::Extract::Run::VERSION = '0.01';

use strict;
use vars qw( @ISA @EXPORT_OK );

=head1 NAME

Locale::Maketext::Extract::Run - Module interface to xgettext.pl

=head1 SYNOPSIS

    use Locale::Maketext::Extract::Run 'xgettext';
    xgettext(@ARGV);

=cut

use Cwd;
use Config ();
use File::Find;
use Getopt::Long;
use Locale::Maketext::Extract;
use Exporter;

use constant HAS_SYMLINK => ($Config::Config{d_symlink} ? 1 : 0);

@ISA = 'Exporter';
@EXPORT_OK = 'xgettext';

sub xgettext { __PACKAGE__->run(@_) }

sub run {
    my $self = shift;
    local @ARGV = @_;

    my %opts;
    Getopt::Long::Configure("no_ignore_case");
    Getopt::Long::GetOptions( \%opts,
        'f|files-from:s@',
        'D|directory:s@',
        'u|use-gettext-style|unescaped',
        'g|gnu-gettext',
        'o|output:s@',
        'd|default-domain:s',
        'p|output-dir:s@',
        'h|help',
    ) or help();
    help() if $opts{h};

    my @po = @{$opts{o} || [($opts{d}||'messages').'.po']};

    foreach my $file (@{$opts{f}||[]}) {
        open FILE, $file or die "Cannot open $file: $!";
        while (<FILE>) {
            push @ARGV, $_ if -r and !-d;
        }
    }

    foreach my $dir (@{$opts{D}||[]}) {
        File::Find::find( {
            wanted      => sub {
                return if
                    ( -d ) ||
                    ( $File::Find::dir =~ m!\b(?:blib|autogen|var|m4|local|CVS|\.svn)\b! ) ||
                    ( /\.po$|\.bak$|~|,D|,B$/i ) ||
                    ( /^[\.#]/ );
                push @ARGV, $File::Find::name;
            },
            follow      => HAS_SYMLINK,
        }, $dir );
    }

    @ARGV = ('-') unless @ARGV;
    s!^\.[/\\]!! for @ARGV;

    my $cwd = getcwd();

    foreach my $dir (@{$opts{p}||['.']}) {
        foreach my $po (@po) {
            my $Ext = Locale::Maketext::Extract->new;
            $Ext->read_po($po) if -r $po and -s _;
            $Ext->extract_file($_) for grep !/\.po$/i, @ARGV;
            $Ext->compile($opts{u}) or next;

            chdir $dir;
            $Ext->write_po($po, $opts{g});
            chdir $cwd;
        }
    }
}

sub help {
    local $SIG{__WARN__} = sub {};
    { exec "perldoc $0"; }
    { exec "pod2text $0"; }
}

1;

=head1 COPYRIGHT (The "MIT" License)

Copyright 2003, 2004, 2005, 2006 by Audrey Tang E<lt>cpan@audreyt.orgE<gt>.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is fur-
nished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIT-
NESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE X
CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=cut

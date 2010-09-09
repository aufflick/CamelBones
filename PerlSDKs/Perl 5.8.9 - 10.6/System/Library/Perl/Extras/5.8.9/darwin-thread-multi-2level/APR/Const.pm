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
package APR::Const;

use ModPerl::Const ();
use APR ();
use XSLoader ();

our $VERSION = '0.009000';
our @ISA = qw(ModPerl::Const);

XSLoader::load(__PACKAGE__, $VERSION);

1;

=head1 NAME

APR::Const - Perl Interface for APR Constants






=head1 Synopsis

  # make the constants available but don't import them
  use APR::Const -compile => qw(constant names ...);
  
  # w/o the => syntax sugar
  use APR::Const ("-compile", qw(constant names ...));
  
  # compile and import the constants
  use APR::Const qw(constant names ...);







=head1 Description

This package contains constants specific to C<APR> features.

Refer to C<L<the Apache2::Const description
section|docs::2.0::api::Apache2::Const/Description>> for more
information.







=head1 Constants



=head2 C<:common>

  use APR::Const -compile => qw(:common);

The C<:common> group is for XXX constants.




=head3 C<APR::Const::SUCCESS>

=over

=item since: 2.0.00

=back





=head2 C<:error>

  use APR::Const -compile => qw(:error);

The C<:error> group is for XXX constants.




=head3 C<APR::Const::EABOVEROOT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EABSOLUTE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EACCES>

=over

=item since: 2.0.00

=back

Due to possible variants in conditions matching C<EACCES>, 
for checking error codes against this you most likely want to use the
C<L<APR::Status::is_EACCES|docs::2.0::api::APR::Status/C_is_EACCES_>>
function instead.



=head3 C<APR::Const::EAGAIN>

=over

=item since: 2.0.00

=back

The error I<Resource temporarily unavailable>, may be returned by many
different system calls, especially IO calls. Most likely you want to
use the
C<L<APR::Status::is_EAGAIN|docs::2.0::api::APR::Status/C_is_EAGAIN_>>
function instead.



=head3 C<APR::Const::EBADDATE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EBADF>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EBADIP>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EBADMASK>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EBADPATH>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EBUSY>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ECONNABORTED>

=over

=item since: 2.0.00

=back

Due to possible variants in conditions matching C<ECONNABORTED>, 
for checking error codes against this you most likely want to use the
C<L<APR::Status::is_ECONNABORTED|docs::2.0::api::APR::Status/C_is_ECONNABORTED_>>
function instead.





=head3 C<APR::Const::ECONNREFUSED>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ECONNRESET>

=over

=item since: 2.0.00

=back

Due to possible variants in conditions matching C<ECONNRESET>, for
checking error codes against this you most likely want to use the
C<L<APR::Status::is_ECONNRESET|docs::2.0::api::APR::Status/C_is_ECONNRESET_>>
function instead.





=head3 C<APR::Const::EDSOOPEN>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EEXIST>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EFTYPE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EGENERAL>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EHOSTUNREACH>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EINCOMPLETE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EINIT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EINPROGRESS>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EINTR>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EINVAL>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EINVALSOCK>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EMFILE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EMISMATCH>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENAMETOOLONG>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::END>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENETUNREACH>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENFILE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENODIR>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOENT>

=over

=item since: 2.0.00

=back

Due to possible variants in conditions matching C<ENOENT>, 
for checking error codes against this you most likely want to use the
C<L<APR::Status::is_ENOENT|docs::2.0::api::APR::Status/C_is_ENOENT_>>
function instead.




=head3 C<APR::Const::ENOLOCK>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOMEM>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOPOLL>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOPOOL>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOPROC>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOSHMAVAIL>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOSOCKET>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOSPC>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOSTAT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOTDIR>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOTEMPTY>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOTHDKEY>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOTHREAD>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOTIME>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOTIMPL>

Something is not implemented

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ENOTSOCK>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EOF>

=over

=item since: 2.0.00

=back


Due to possible variants in conditions matching C<EOF>, 
for checking error codes against this you most likely want to use the
C<L<APR::Status::is_EOF|docs::2.0::api::APR::Status/C_is_EOF_>>
function instead.



=head3 C<APR::Const::EPATHWILD>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EPIPE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EPROC_UNKNOWN>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ERELATIVE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ESPIPE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ESYMNOTFOUND>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::ETIMEDOUT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::EXDEV>

=over

=item since: 2.0.00

=back





=head2 C<:fopen>

  use APR::Const -compile => qw(:fopen);

The C<:fopen> group is for XXX constants.




=head3 C<APR::Const::FOPEN_BINARY>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FOPEN_BUFFERED>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FOPEN_CREATE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FOPEN_DELONCLOSE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FOPEN_EXCL>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FOPEN_PEND>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FOPEN_READ>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FOPEN_TRUNCATE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FOPEN_WRITE>

=over

=item since: 2.0.00

=back





=head2 C<:filepath>

  use APR::Const -compile => qw(:filepath);

The C<:filepath> group is for XXX constants.





=head3 C<APR::Const::FILEPATH_ENCODING_LOCALE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILEPATH_ENCODING_UNKNOWN>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILEPATH_ENCODING_UTF8>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILEPATH_NATIVE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILEPATH_NOTABOVEROOT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILEPATH_NOTABSOLUTE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILEPATH_NOTRELATIVE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILEPATH_SECUREROOT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILEPATH_SECUREROOTTEST>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILEPATH_TRUENAME>

=over

=item since: 2.0.00

=back





=head2 C<:fprot>

  use APR::Const -compile => qw(:fprot);

The C<:fprot> group is used by
C<L<$finfo-E<gt>protection|docs::2.0::api::APR::Finfo/C_protection_>>.




=head3 C<APR::Const::FPROT_GEXECUTE>

Execute by group

=over

=item since: 2.0.00

=back






=head3 C<APR::Const::FPROT_GREAD>

Read by group

=over

=item since: 2.0.00

=back




=head3 C<APR::Const::FPROT_GSETID>

Set group id

=over

=item since: 2.0.00

=back




=head3 C<APR::Const::FPROT_GWRITE>

Write by group

=over

=item since: 2.0.00

=back




=head3 C<APR::Const::FPROT_OS_DEFAULT>

use OS's default permissions

=over

=item since: 2.0.00

=back




=head3 C<APR::Const::FPROT_UEXECUTE>

Execute by user

=over

=item since: 2.0.00

=back




=head3 C<APR::Const::FPROT_UREAD>

Read by user

=over

=item since: 2.0.00

=back




=head3 C<APR::Const::FPROT_USETID>

Set user id

=over

=item since: 2.0.00

=back




=head3 C<APR::Const::FPROT_UWRITE>

Write by user

=over

=item since: 2.0.00

=back




=head3 C<APR::Const::FPROT_WEXECUTE>

Execute by others

=over

=item since: 2.0.00

=back




=head3 C<APR::Const::FPROT_WREAD>

Read by others

=over

=item since: 2.0.00

=back




=head3 C<APR::Const::FPROT_WSTICKY>

Sticky bit

=over

=item since: 2.0.00

=back




=head3 C<APR::Const::FPROT_WWRITE>

Write by others

=over

=item since: 2.0.00

=back










=head2 C<:filetype>

  use APR::Const -compile => qw(:filetype);

The C<:filetype> group is used by
C<L<$finfo-E<gt>filetype|docs::2.0::api::APR::Finfo/C_filetype_>>.




=head3 C<APR::Const::FILETYPE_BLK>

a file is a block device

=over

=item since: 2.0.00

=back






=head3 C<APR::Const::FILETYPE_CHR>

a file is a character device

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILETYPE_DIR>

a file is a directory

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILETYPE_LNK>

a file is a symbolic link

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILETYPE_NOFILE>

the file type is undedetermined.

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILETYPE_PIPE>

a file is a FIFO or a pipe.

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILETYPE_REG>

a file is a regular file.

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILETYPE_SOCK>

a file is a [unix domain] socket.

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FILETYPE_UNKFILE>

a file is of some other unknown type or the type cannot be determined.

=over

=item since: 2.0.00

=back










=head2 C<:finfo>

  use APR::Const -compile => qw(:finfo);

The C<:finfo> group is used by
C<L<stat()|docs::2.0::api::APR::Finfo/C_stat_>> and
C<L<$finfo-E<gt>valid|docs::2.0::api::APR::Finfo/C_valid_>>.




=head3 C<APR::Const::FINFO_ATIME>

Access Time

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_CSIZE>

Storage size consumed by the file

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_CTIME>

Creation Time

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_DEV>

Device

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_DIRENT>

an atomic unix apr_dir_read()

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_GPROT>

Group protection bits

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_GROUP>

Group id

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_ICASE>

whether device is case insensitive

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_IDENT>

device and inode

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_INODE>

Inode

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_LINK>

Stat the link not the file itself if it is a link

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_MIN>

type, mtime, ctime, atime, size

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_MTIME>

Modification Time

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_NAME>

name in proper case

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_NLINK>

Number of links

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_NORM>

All fields provided by an atomic unix apr_stat()

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_OWNER>

user and group

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_PROT>

all protections

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_SIZE>

Size of the file

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_TYPE>

Type

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_UPROT>

User protection bits

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_USER>

User id

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FINFO_WPROT>

World protection bits

=over

=item since: 2.0.00

=back









=head2 C<:flock>

  use APR::Const -compile => qw(:flock);

The C<:flock> group is for XXX constants.




=head3 C<APR::Const::FLOCK_EXCLUSIVE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FLOCK_NONBLOCK>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FLOCK_SHARED>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::FLOCK_TYPEMASK>

=over

=item since: 2.0.00

=back





=head2 C<:hook>

  use APR::Const -compile => qw(:hook);

The C<:hook> group is for XXX constants.




=head3 C<APR::Const::HOOK_FIRST>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::HOOK_LAST>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::HOOK_MIDDLE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::HOOK_REALLY_FIRST>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::HOOK_REALLY_LAST>

=over

=item since: 2.0.00

=back





=head2 C<:limit>

  use APR::Const -compile => qw(:limit);

The C<:limit> group is for XXX constants.




=head3 C<APR::Const::LIMIT_CPU>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::LIMIT_MEM>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::LIMIT_NOFILE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::LIMIT_NPROC>

=over

=item since: 2.0.00

=back





=head2 C<:lockmech>

  use APR::Const -compile => qw(:lockmech);

The C<:lockmech> group is for XXX constants.




=head3 C<APR::Const::LOCK_DEFAULT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::LOCK_FCNTL>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::LOCK_FLOCK>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::LOCK_POSIXSEM>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::LOCK_PROC_PTHREAD>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::LOCK_SYSVSEM>

=over

=item since: 2.0.00

=back





=head2 C<:poll>

  use APR::Const -compile => qw(:poll);

The C<:poll> group is used by
C<L<poll|docs::2.0::api::APR::Socket/C_poll_>>.




=head3 C<APR::Const::POLLERR>

=over

=item since: 2.0.00

=back

Pending error




=head3 C<APR::Const::POLLHUP>

=over

=item since: 2.0.00

=back

Hangup occurred




=head3 C<APR::Const::POLLIN>

=over

=item since: 2.0.00

=back

Can read without blocking




=head3 C<APR::Const::POLLNVAL>

=over

=item since: 2.0.00

=back

Descriptior invalid




=head3 C<APR::Const::POLLOUT>

=over

=item since: 2.0.00

=back

Can write without blocking





=head3 C<APR::Const::POLLPRI>

=over

=item since: 2.0.00

=back

Priority data available













=head2 C<:read_type>

  use APR::Const -compile => qw(:read_type);

The C<:read_type> group is for IO constants.




=head3 C<APR::Const::BLOCK_READ>

=over

=item since: 2.0.00

=back

the read function blocks





=head3 C<APR::Const::NONBLOCK_READ>

=over

=item since: 2.0.00

=back


the read function does not block










=head2 C<:shutdown_how>

  use APR::Const -compile => qw(:shutdown_how);

The C<:shutdown_how> group is for XXX constants.




=head3 C<APR::Const::SHUTDOWN_READ>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::SHUTDOWN_READWRITE>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::SHUTDOWN_WRITE>

=over

=item since: 2.0.00

=back





=head2 C<:socket>

  use APR::Const -compile => qw(:socket);

The C<:socket> group is for the
C<L<APR::Socket|docs::2.0::api::APR::Socket>> object constants, in
methods C<L<opt_get|docs::2.0::api::APR::Socket/C_opt_get_>> and
C<L<opt_set|docs::2.0::api::APR::Socket/C_opt_set_>>.

The following section discusses in detail each of the C<:socket>
constants.




=head3 C<APR::Const::SO_DEBUG>

Possible values:

XXX

=over

=item since: 2.0.00

=back

Turns on debugging information




=head3 C<APR::Const::SO_DISCONNECTED>

Queries the disconnected state of the socket.  (Currently only used on
Windows)

Possible values:

XXX

=over

=item since: 2.0.00

=back






=head3 C<APR::Const::SO_KEEPALIVE>

Keeps connections active

Possible values:

XXX

=over

=item since: 2.0.00

=back








=head3 C<APR::Const::SO_LINGER>

Lingers on close if data is present

=over

=item since: 2.0.00

=back







=head3 C<APR::Const::SO_NONBLOCK>

Turns blocking IO mode on/off for socket.

Possible values:

  1 nonblocking
  0 blocking

For example, to set a socket to a blocking IO mode:

  use APR::Socket ();
  use APR::Const    -compile => qw(SO_NONBLOCK);
  ...
  if ($socket->opt_get(APR::Const::SO_NONBLOCK)) {
      $socket->opt_set(APR::Const::SO_NONBLOCK => 0);
  }

You don't have to query for this option, before setting it. It was
done for the demonstration purpose.

=over

=item since: 2.0.00

=back









=head3 C<APR::Const::SO_RCVBUF>

Controls the C<ReceiveBufferSize> setting

Possible values:

XXX

=over

=item since: 2.0.00

=back








=head3 C<APR::Const::SO_REUSEADDR>

The rules used in validating addresses supplied to bind should allow
reuse of local addresses.

Possible values:

XXX

=over

=item since: 2.0.00

=back








=head3 C<APR::Const::SO_SNDBUF>

Controls the C<SendBufferSize> setting

Possible values:

XXX

=over

=item since: 2.0.00

=back





=head2 C<:status>

  use APR::Const -compile => qw(:status);

The C<:status> group is for the API that return status code, or set
the error variable XXXXXX.

The following section discusses in detail each of the available
C<:status> constants.




=head3 C<APR::Const::TIMEUP>

The operation did not finish before the timeout.

=over

=item since: 2.0.00

=back

Due to possible variants in conditions matching C<TIMEUP>, 
for checking error codes against this you most likely want to use the
C<L<APR::Status::is_TIMEUP|docs::2.0::api::APR::Status/C_is_TIMEUP_>>
function instead.














=head2 C<:table>

  use APR::Const -compile => qw(:table);

The C<:table> group is for C<overlap()> and C<compress()> constants.
See C<L<APR::Table|docs::2.0::api::APR::Table>> for details.




=head3 C<APR::Const::OVERLAP_TABLES_MERGE>

=over

=item since: 2.0.00

=back

See C<L<APR::Table::compress|docs::2.0::api::APR::Table/C_compress_>>
and C<L<APR::Table::overlap|docs::2.0::api::APR::Table/C_overlap_>>.





=head3 C<APR::Const::OVERLAP_TABLES_SET>

=over

=item since: 2.0.00

=back

See C<L<APR::Table::compress|docs::2.0::api::APR::Table/C_compress_>>
and C<L<APR::Table::overlap|docs::2.0::api::APR::Table/C_overlap_>>.





=head2 C<:uri>

  use APR::Const -compile => qw(:uri);

The C<:uri> group of constants is for manipulating URIs.




=head3 C<APR::Const::URI_ACAP_DEFAULT_PORT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::URI_FTP_DEFAULT_PORT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::URI_GOPHER_DEFAULT_PORT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::URI_HTTPS_DEFAULT_PORT>

=over

=item since: 2.0.00

=back






=head3 C<APR::Const::URI_HTTP_DEFAULT_PORT>

=over

=item since: 2.0.00

=back






=head3 C<APR::Const::URI_IMAP_DEFAULT_PORT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::URI_LDAP_DEFAULT_PORT>

=over

=item since: 2.0.00

=back






=head3 C<APR::Const::URI_NFS_DEFAULT_PORT>

=over

=item since: 2.0.00

=back






=head3 C<APR::Const::URI_NNTP_DEFAULT_PORT>

=over

=item since: 2.0.00

=back






=head3 C<APR::Const::URI_POP_DEFAULT_PORT>

=over

=item since: 2.0.00

=back






=head3 C<APR::Const::URI_PROSPERO_DEFAULT_PORT>

=over

=item since: 2.0.00

=back






=head3 C<APR::Const::URI_RTSP_DEFAULT_PORT>

=over

=item since: 2.0.00

=back







=head3 C<APR::Const::URI_SIP_DEFAULT_PORT>

=over

=item since: 2.0.00

=back









=head3 C<APR::Const::URI_SNEWS_DEFAULT_PORT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::URI_SSH_DEFAULT_PORT>

=over

=item since: 2.0.00

=back





=head3 C<APR::Const::URI_TELNET_DEFAULT_PORT>

=over

=item since: 2.0.00

=back







=head3 C<APR::Const::URI_TIP_DEFAULT_PORT>

=over

=item since: 2.0.00

=back








=head3 C<APR::Const::URI_UNP_OMITPASSWORD>

=over

=item since: 2.0.00

=back

See C<L<APR::URI::unparse|docs::2.0::api::APR::URI/C_unparse_>>.








=head3 C<APR::Const::URI_UNP_OMITPATHINFO>

=over

=item since: 2.0.00

=back

See C<L<APR::URI::unparse|docs::2.0::api::APR::URI/C_unparse_>>.








=head3 C<APR::Const::URI_UNP_OMITQUERY>

=over

=item since: 2.0.00

=back

See C<L<APR::URI::unparse|docs::2.0::api::APR::URI/C_unparse_>>.








=head3 C<APR::Const::URI_UNP_OMITSITEPART>

=over

=item since: 2.0.00

=back

See C<L<APR::URI::unparse|docs::2.0::api::APR::URI/C_unparse_>>.







=head3 C<APR::Const::URI_UNP_OMITUSER>

=over

=item since: 2.0.00

=back

See C<L<APR::URI::unparse|docs::2.0::api::APR::URI/C_unparse_>>.





=head3 C<APR::Const::URI_UNP_OMITUSERINFO>

=over

=item since: 2.0.00

=back








=head3 C<APR::Const::URI_UNP_REVEALPASSWORD>

=over

=item since: 2.0.00

=back

See C<L<APR::URI::unparse|docs::2.0::api::APR::URI/C_unparse_>>.







=head3 C<APR::Const::URI_WAIS_DEFAULT_PORT>

=over

=item since: 2.0.00

=back



=head2 Other Constants


=head3 C<APR::PerlIO::PERLIO_LAYERS_ARE_ENABLED>

=over

=item since: 2.0.00

=back

See C<L<APR::PerlIO::Constants|docs::2.0::api::APR::PerlIO/Constants>>)





=head1 See Also

L<mod_perl 2.0 documentation|docs::2.0::index>.




=head1 Copyright

mod_perl 2.0 and its core modules are copyrighted under
The Apache Software License, Version 2.0.




=head1 Authors

L<The mod_perl development team and numerous
contributors|about::contributors::people>.

=cut

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
package Apache2::Const;

use ModPerl::Const ();
use XSLoader ();

our $VERSION = do { require mod_perl2; $mod_perl2::VERSION };
our @ISA = qw(ModPerl::Const);

XSLoader::load(__PACKAGE__, $VERSION);

1;

=head1 NAME

Apache2::Const - Perl Interface for Apache Constants





=head1 Synopsis

  # make the constants available but don't import them
  use Apache2::Const -compile => qw(constant names ...);
  
  # w/o the => syntax sugar
  use Apache2::Const ("-compile", qw(constant names ...));
  
  # compile and import the constants
  use Apache2::Const qw(constant names ...);





=head1 Description

This package contains constants specific to C<Apache> features.

mod_perl 2.0 comes with several hundreds of constants, which you don't
want to make available to your Perl code by default, due to CPU and
memory overhead. Therefore when you want to use a certain constant you
need to explicitly ask to make it available.

For example, the code:

  use Apache2::Const -compile => qw(FORBIDDEN OK);

makes the constants C<Apache2::Const::FORBIDDEN> and C<Apache2::Const::OK> available
to your code, but they aren't imported. In which case you need to use
a fully qualified constants, as in:

  return Apache2::Const::OK;

If you drop the argument C<-compile> and write:

  use Apache2::Const qw(FORBIDDEN OK);

Then both constants are imported into your code's namespace and can be
used standalone like so:

  return OK;

Both, due to the extra memory requirement, when importing symbols, and
since there are constants in other namespaces (e.g.,
C<L<APR::|docs::2.0::api::APR::Const>> and
C<L<ModPerl::|docs::2.0::api::ModPerl::Const>>, and non-mod_perl
modules) which may contain the same names, it's not recommended to
import constants. I.e. you want to use the C<-compile> construct.

Finaly, in Perl C<=E<gt>> is almost the same as the comma operator. It
can be used as syntax sugar making it more clear when there is a
key-value relation between two arguments, and also it automatically
parses its lefthand argument (the key) as a string, so you don't need
to quote it.

If you don't want to use that syntax, instead of writing:

 use Apache2::Const -compile => qw(FORBIDDEN OK);

you could write:

 use Apache2::Const "-compile", qw(FORBIDDEN OK);

and for parentheses-lovers:

 use Apache2::Const ("-compile", qw(FORBIDDEN OK));




=head1 Constants




=head2 C<:cmd_how>

  use Apache2::Const -compile => qw(:cmd_how);

The C<:cmd_how> constants group is used in
C<L<Apache2::Module::add()|docs::2.0::api::Apache2::Module/C_add_>>
and
C<L<$cmds-E<gt>args_how|docs::2.0::api::Apache2::Command/C_args_how_>>.






=head3 C<Apache2::Const::FLAG>

One of I<On> or I<Off> (L<full
description|docs::2.0::user::config::custom/C_Apache2__FLAG_>).

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::ITERATE>

One argument, occuring multiple times (L<full
description|docs::2.0::user::config::custom/C_Apache2__ITERATE_>).



=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::ITERATE2>

Two arguments, the second occurs multiple times (L<full
description|docs::2.0::user::config::custom/C_Apache2__ITERATE2_>).

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::NO_ARGS>

No arguments at all (L<full
description|docs::2.0::user::config::custom/C__C_Apache2__NO_ARGS_>).

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::RAW_ARGS>

The command will parse the command line itself (L<full
description|docs::2.0::user::config::custom/C_Apache2__RAW_ARGS_>).

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::TAKE1>

One argument only (L<full
description|docs::2.0::user::config::custom/C_Apache2__TAKE1_>).

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::TAKE12>

One or two arguments (L<full
description|docs::2.0::user::config::custom/C_Apache2__TAKE12_>).

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::TAKE123>

One, two or three arguments (L<full
description|docs::2.0::user::config::custom/C_Apache2__TAKE123_>).

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::TAKE13>

One or three arguments (L<full
description|docs::2.0::user::config::custom/C_Apache2__TAKE13_>).

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::TAKE2>

Two arguments (L<full
description|docs::2.0::user::config::custom/C_Apache2__TAKE2_>).

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::TAKE23>

Two or three arguments (L<full
description|docs::2.0::user::config::custom/C_Apache2__TAKE23_>).

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::TAKE3>

Three arguments (L<full
description|docs::2.0::user::config::custom/C_Apache2__TAKE3_>).

=over

=item since: 2.0.00

=back















=head2 C<:common>

  use Apache2::Const -compile => qw(:common);

The C<:common> group is for XXX constants.




=head3 C<Apache2::Const::AUTH_REQUIRED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::DECLINED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::DONE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::FORBIDDEN>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::NOT_FOUND>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OK>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::REDIRECT>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::SERVER_ERROR>

=over

=item since: 2.0.00

=back





=head2 C<:config>

  use Apache2::Const -compile => qw(:config);

The C<:config> group is for XXX constants.




=head3 C<Apache2::Const::DECLINE_CMD>

=over

=item since: 2.0.00

=back







=head2 C<:conn_keepalive>

  use Apache2::Const -compile => qw(:conn_keepalive);

The C<:conn_keepalive> constants group is used by the
(C<L<$c-E<gt>keepalive|docs::2.0::api::Apache2::Connection/C_keepalive_>>)
method.




=head3 C<Apache2::Const::CONN_CLOSE>

The connection will be closed at the end of the current HTTP request.

=over

=item since: 2.0.00

=back




=head3 C<Apache2::Const::CONN_KEEPALIVE>

The connection will be kept alive at the end of the current HTTP request.

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::CONN_UNKNOWN>

The connection is at an unknown state, e.g., initialized but not open
yet.

=over

=item since: 2.0.00

=back






=head2 C<:context>

  use Apache2::Const -compile => qw(:context);

The C<:context> group is used by the
C<L<$parms-E<gt>check_cmd_context|docs::2.0::api::Apache2::CmdParms/C_check_cmd_context_>>
method.




=head3 C<Apache2::Const::NOT_IN_VIRTUALHOST>

The command is not in a E<lt>VirtualHostE<gt> block.

=over

=item since: 2.0.00

=back



=head3 C<Apache2::Const::NOT_IN_LIMIT>

The command is not in a E<lt>LimitE<gt> block.

=over

=item since: 2.0.00

=back






=head3 C<Apache2::Const::NOT_IN_DIRECTORY>

The command is not in a E<lt>DirectoryE<gt> block.

=over

=item since: 2.0.00

=back






=head3 C<Apache2::Const::NOT_IN_LOCATION>

The command is not in a E<lt>LocationE<gt>/E<lt>LocationMatchE<gt> block.

=over

=item since: 2.0.00

=back






=head3 C<Apache2::Const::NOT_IN_FILES>

The command is not in a E<lt>FilesE<gt>/E<lt>FilesMatchE<gt> block.

=over

=item since: 2.0.00

=back







=head3 C<Apache2::Const::NOT_IN_DIR_LOC_FILE>

The command is not in a E<lt>FilesE<gt>/E<lt>FilesMatchE<gt>, 
E<lt>LocationE<gt>/E<lt>LocationMatchE<gt> or 
E<lt>DirectoryE<gt> block.

=over

=item since: 2.0.00

=back






=head3 C<Apache2::Const::GLOBAL_ONLY>

The directive appears outside of any container directives.

=over

=item since: 2.0.00

=back






=head2 C<:filter_type>

  use Apache2::Const -compile => qw(:filter_type);

The C<:filter_type> group is for XXX constants.




=head3 C<Apache2::Const::FTYPE_CONNECTION>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::FTYPE_CONTENT_SET>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::FTYPE_NETWORK>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::FTYPE_PROTOCOL>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::FTYPE_RESOURCE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::FTYPE_TRANSCODE>

=over

=item since: 2.0.00

=back







=head2 C<:http>

  use Apache2::Const -compile => qw(:http);

The C<:http> group is for XXX constants.




=head3 C<Apache2::Const::HTTP_ACCEPTED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_BAD_GATEWAY>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_BAD_REQUEST>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_CONFLICT>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_CONTINUE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_CREATED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_EXPECTATION_FAILED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_FAILED_DEPENDENCY>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_FORBIDDEN>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_GATEWAY_TIME_OUT>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_GONE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_INSUFFICIENT_STORAGE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_INTERNAL_SERVER_ERROR>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_LENGTH_REQUIRED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_LOCKED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_METHOD_NOT_ALLOWED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_MOVED_PERMANENTLY>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_MOVED_TEMPORARILY>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_MULTIPLE_CHOICES>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_MULTI_STATUS>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_NON_AUTHORITATIVE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_NOT_ACCEPTABLE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_NOT_EXTENDED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_NOT_FOUND>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_NOT_IMPLEMENTED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_NOT_MODIFIED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_NO_CONTENT>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_OK>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_PARTIAL_CONTENT>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_PAYMENT_REQUIRED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_PRECONDITION_FAILED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_PROCESSING>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_PROXY_AUTHENTICATION_REQUIRED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_RANGE_NOT_SATISFIABLE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_REQUEST_ENTITY_TOO_LARGE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_REQUEST_TIME_OUT>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_REQUEST_URI_TOO_LARGE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_RESET_CONTENT>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_SEE_OTHER>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_SERVICE_UNAVAILABLE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_SWITCHING_PROTOCOLS>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_TEMPORARY_REDIRECT>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_UNAUTHORIZED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_UNPROCESSABLE_ENTITY>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_UNSUPPORTED_MEDIA_TYPE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_UPGRADE_REQUIRED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_USE_PROXY>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::HTTP_VARIANT_ALSO_VARIES>

=over

=item since: 2.0.00

=back





=head2 C<:input_mode>

  use Apache2::Const -compile => qw(:input_mode);

The C<:input_mode> group is used by
C<L<get_brigade|docs::2.0::api::Apache2::Filter/C_get_brigade_>>.






=head3 C<Apache2::Const::MODE_EATCRLF>

=over

=item since: 2.0.00

=back

See
C<L<Apache2::Filter::get_brigade()|docs::2.0::api::Apache2::Filter/C_get_brigade_>>.






=head3 C<Apache2::Const::MODE_EXHAUSTIVE>

=over

=item since: 2.0.00

=back

See
C<L<Apache2::Filter::get_brigade()|docs::2.0::api::Apache2::Filter/C_get_brigade_>>.





=head3 C<Apache2::Const::MODE_GETLINE>

=over

=item since: 2.0.00

=back

See
C<L<Apache2::Filter::get_brigade()|docs::2.0::api::Apache2::Filter/C_get_brigade_>>.





=head3 C<Apache2::Const::MODE_INIT>

=over

=item since: 2.0.00

=back

See
C<L<Apache2::Filter::get_brigade()|docs::2.0::api::Apache2::Filter/C_get_brigade_>>.





=head3 C<Apache2::Const::MODE_READBYTES>

=over

=item since: 2.0.00

=back

See
C<L<Apache2::Filter::get_brigade()|docs::2.0::api::Apache2::Filter/C_get_brigade_>>.





=head3 C<Apache2::Const::MODE_SPECULATIVE>

=over

=item since: 2.0.00

=back

See
C<L<Apache2::Filter::get_brigade()|docs::2.0::api::Apache2::Filter/C_get_brigade_>>.









=head2 C<:log>

  use Apache2::Const -compile => qw(:log);

The C<:log> group is for constants used by
C<L<Apache2::Log|docs::2.0::api::Apache2::Log>>.




=head3 C<Apache2::Const::LOG_ALERT>

=over

=item since: 2.0.00

=back

See C<L<Apache2::Log|docs::2.0::api::Apache2::Log/C_Apache2__LOG_ALERT_>>.





=head3 C<Apache2::Const::LOG_CRIT>

=over

=item since: 2.0.00

=back

See C<L<Apache2::Log|docs::2.0::api::Apache2::Log/C_Apache2__LOG_CRIT_>>.





=head3 C<Apache2::Const::LOG_DEBUG>

=over

=item since: 2.0.00

=back

See C<L<Apache2::Log|docs::2.0::api::Apache2::Log/C_Apache2__LOG_DEBUG_>>.





=head3 C<Apache2::Const::LOG_EMERG>

=over

=item since: 2.0.00

=back

See C<L<Apache2::Log|docs::2.0::api::Apache2::Log/C_Apache2__LOG_EMERG_>>.







=head3 C<Apache2::Const::LOG_ERR>

=over

=item since: 2.0.00

=back

See C<L<Apache2::Log|docs::2.0::api::Apache2::Log/C_Apache2__LOG_ERR_>>.






=head3 C<Apache2::Const::LOG_INFO>

=over

=item since: 2.0.00

=back

See C<L<Apache2::Log|docs::2.0::api::Apache2::Log/C_Apache2__LOG_INFO_>>.






=head3 C<Apache2::Const::LOG_LEVELMASK>

=over

=item since: 2.0.00

=back

See C<L<Apache2::Log|docs::2.0::api::Apache2::Log/C_Apache2__LOG_LEVELMASK_>>.





=head3 C<Apache2::Const::LOG_NOTICE>

=over

=item since: 2.0.00

=back

See C<L<Apache2::Log|docs::2.0::api::Apache2::Log/C_Apache2__LOG_NOTICE_>>.





=head3 C<Apache2::Const::LOG_STARTUP>

=over

=item since: 2.0.00

=back

See C<L<Apache2::Log|docs::2.0::api::Apache2::Log/C_Apache2__LOG_STARTUP_>>.





=head3 C<Apache2::Const::LOG_TOCLIENT>

=over

=item since: 2.0.00

=back

See C<L<Apache2::Log|docs::2.0::api::Apache2::Log/C_Apache2__LOG_TOCLIENT_>>.





=head3 C<Apache2::Const::LOG_WARNING>

=over

=item since: 2.0.00

=back

See C<L<Apache2::Log|docs::2.0::api::Apache2::Log/C_Apache2__LOG_WARNING_>>.





=head2 C<:methods>

  use Apache2::Const -compile => qw(:methods);

The C<:methods> constants group is used in conjunction with
C<L<$r-E<gt>method_number|docs::2.0::api::Apache2::RequestRec/C_method_number_>>.




=head3 C<Apache2::Const::METHODS>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_BASELINE_CONTROL>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_CHECKIN>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_CHECKOUT>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_CONNECT>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_COPY>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_DELETE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_GET>

=over

=item since: 2.0.00

=back

corresponds to the HTTP C<GET> method




=head3 C<Apache2::Const::M_INVALID>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_LABEL>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_LOCK>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_MERGE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_MKACTIVITY>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_MKCOL>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_MKWORKSPACE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_MOVE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_OPTIONS>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_PATCH>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_POST>

=over

=item since: 2.0.00

=back

corresponds to the HTTP C<POST> method



=head3 C<Apache2::Const::M_PROPFIND>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_PROPPATCH>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_PUT>

=over

=item since: 2.0.00

=back

corresponds to the HTTP C<PUT> method



=head3 C<Apache2::Const::M_REPORT>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_TRACE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_UNCHECKOUT>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_UNLOCK>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_UPDATE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::M_VERSION_CONTROL>

=over

=item since: 2.0.00

=back





=head2 C<:mpmq>

  use Apache2::Const -compile => qw(:mpmq);

The C<:mpmq> group is for querying MPM properties.




=head3 C<Apache2::Const::MPMQ_NOT_SUPPORTED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_STATIC>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_DYNAMIC>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_MAX_DAEMON_USED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_IS_THREADED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_IS_FORKED>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_HARD_LIMIT_DAEMONS>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_HARD_LIMIT_THREADS>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_MAX_THREADS>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_MIN_SPARE_DAEMONS>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_MIN_SPARE_THREADS>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_MAX_SPARE_DAEMONS>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_MAX_SPARE_THREADS>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_MAX_REQUESTS_DAEMON>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::MPMQ_MAX_DAEMONS>

=over

=item since: 2.0.00

=back






=head2 C<:options>

  use Apache2::Const -compile => qw(:options);

The C<:options> group contains constants corresponding to the
C<Options> configuration directive. For examples see:
C<L<$r-E<gt>allow_options|docs::2.0::api::Apache2::Access/C_allow_options_>>.




=head3 C<Apache2::Const::OPT_ALL>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OPT_EXECCGI>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OPT_INCLUDES>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OPT_INCNOEXEC>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OPT_INDEXES>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OPT_MULTI>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OPT_NONE>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OPT_SYM_LINKS>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OPT_SYM_OWNER>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OPT_UNSET>

=over

=item since: 2.0.00

=back





=head2 C<:override>

  use Apache2::Const -compile => qw(:override);

The C<:override> group contains constants corresponding to the
C<AllowOverride> configuration directive. For examples see:
C<L<$r-E<gt>allow_options|docs::2.0::api::Apache2::Access/C_allow_overrides_>>.




=head3 C<Apache2::Const::ACCESS_CONF>

F<*.conf> inside C<E<lt>DirectoryE<gt>> or C<E<lt>LocationE<gt>>

=over

=item since: 2.0.00

=back


=head3 C<Apache2::Const::EXEC_ON_READ>

Force directive to execute a command which would modify the
configuration (like including another file, or C<IFModule>)

=over

=item since: 2.0.00

=back




=head3 C<Apache2::Const::OR_ALL>

C<L<Apache2::Const::OR_LIMIT|/C_Apache2__OR_LIMIT_>> | 
C<L<Apache2::Const::OR_OPTIONS|/C_Apache2__OR_OPTIONS_>> | 
C<L<Apache2::Const::OR_FILEINFO|/C_Apache2__OR_FILEINFO_>> | 
C<L<Apache2::Const::OR_AUTHCFG|/C_Apache2__OR_AUTHCFG_>> | 
C<L<Apache2::Const::OR_INDEXES|/C_Apache2__OR_INDEXES_>>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OR_AUTHCFG>

F<*.conf> inside C<E<lt>DirectoryE<gt>> or C<E<lt>LocationE<gt>> and
F<.htaccess> when C<AllowOverride AuthConfig>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OR_FILEINFO>

F<*.conf> anywhere and F<.htaccess> when C<AllowOverride FileInfo>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OR_INDEXES>

F<*.conf> anywhere and F<.htaccess> when C<AllowOverride Indexes>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OR_LIMIT>

F<*.conf> inside C<E<lt>DirectoryE<gt>> or C<E<lt>LocationE<gt>> and
F<.htaccess> when C<AllowOverride Limit>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OR_NONE>

F<*.conf> is not available anywhere in this override

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OR_OPTIONS>

F<*.conf> anywhere and F<.htaccess> when C<AllowOverride Options>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::OR_UNSET>

Unset a directive (in C<Allow>)

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::RSRC_CONF>

F<*.conf> outside C<E<lt>DirectoryE<gt>> or C<E<lt>LocationE<gt>>

=over

=item since: 2.0.00

=back








=head2 C<:platform>

  use Apache2::Const -compile => qw(:platform);

The C<:platform> group is for constants that may
differ from OS to OS.




=head3 C<Apache2::Const::CRLF>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::CR>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::LF>

=over

=item since: 2.0.00

=back





=head2 C<:remotehost>

  use Apache2::Const -compile => qw(:remotehost);

The C<:remotehost> constants group is is used by the
C<L<$c-E<gt>get_remote_host|docs::2.0::api::Apache2::Connection/C_get_remote_host_>>
method.




=head3 C<Apache2::Const::REMOTE_DOUBLE_REV>

=over

=item since: 2.0.00

=back




=head3 C<Apache2::Const::REMOTE_HOST>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::REMOTE_NAME>

=over

=item since: 2.0.00

=back





=head3 C<Apache2::Const::REMOTE_NOLOOKUP>

=over

=item since: 2.0.00

=back





=head2 C<:satisfy>

  use Apache2::Const -compile => qw(:satisfy);

The C<:satisfy> constants group is used in conjunction with
C<L<$r-E<gt>satisfies|docs::2.0::api::Apache2::Access/C_satisfies_>>.




=head3 C<Apache2::Const::SATISFY_ALL>

=over

=item since: 2.0.00

=back

All of the requirements must be met.



=head3 C<Apache2::Const::SATISFY_ANY>

=over

=item since: 2.0.00

=back

any of the requirements must be met.




=head3 C<Apache2::Const::SATISFY_NOSPEC>

=over

=item since: 2.0.00

=back

There are no applicable satisfy lines





=head2 C<:types>

  use Apache2::Const -compile => qw(:types);

The C<:types> group is for XXX constants.




=head3 C<Apache2::Const::DIR_MAGIC_TYPE>

=over

=item since: 2.0.00

=back




=head2 C<:proxy>

  use Apache2::Const -compile => qw(:proxy);

The C<:proxy> constants group is used in conjunction with
C<L<$r-E<gt>proxyreq|docs::2.0::api::Apache2::RequestRec/C_proxyreq_>>.




=head3 C<Apache2::Const::PROXYREQ_NONE>

=over

=item since: 2.0.2

=back


=head3 C<Apache2::Const::PROXYREQ_PROXY>

=over

=item since: 2.0.2

=back



=head3 C<Apache2::Const::PROXYREQ_REVERSE>

=over

=item since: 2.0.2

=back


=head1 See Also

L<mod_perl 2.0 documentation|docs::2.0::index>.

L<HTTP Status Codes|docs::2.0::user::handlers::http/HTTP_Status_Codes>.


=head1 Copyright

mod_perl 2.0 and its core modules are copyrighted under
The Apache Software License, Version 2.0.




=head1 Authors

L<The mod_perl development team and numerous
contributors|about::contributors::people>.

=cut

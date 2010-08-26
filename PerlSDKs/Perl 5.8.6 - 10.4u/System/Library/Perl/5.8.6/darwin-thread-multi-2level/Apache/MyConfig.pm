#
# Configuration for mod_perl and Apache::...
#
package Apache::MyConfig;

%Setup = (
'APACHE_HEADER_INSTALL' => 1,
'APACHE_PREFIX' => '',
'APACHE_SRC' => '',
'APACI_ARGS' => '',
'APXS' => '/usr/sbin/apxs',
'Apache_Src' => '',
'DO_HTTPD' => 0,
'NO_HTTPD' => 1,
'PERL_ACCESS' => 1,
'PERL_AUTHEN' => 1,
'PERL_AUTHZ' => 1,
'PERL_CHILD_EXIT' => 1,
'PERL_CHILD_INIT' => 1,
'PERL_CLEANUP' => 1,
'PERL_CONNECTION_API' => 1,
'PERL_DEBUG' => '',
'PERL_DIRECTIVE_HANDLERS' => 1,
'PERL_DISPATCH' => 1,
'PERL_FILE_API' => 1,
'PERL_FIXUP' => 1,
'PERL_HANDLER' => 1,
'PERL_HEADER_PARSER' => 1,
'PERL_INIT' => 1,
'PERL_LOG' => 1,
'PERL_LOG_API' => 1,
'PERL_METHOD_HANDLERS' => 1,
'PERL_POST_READ_REQUEST' => 1,
'PERL_RESTART' => 1,
'PERL_SECTIONS' => 1,
'PERL_SERVER_API' => 1,
'PERL_SSI' => 1,
'PERL_STACKED_HANDLERS' => 1,
'PERL_STATIC_EXTS' => '',
'PERL_TABLE_API' => 1,
'PERL_TRACE' => 0,
'PERL_TRANS' => 1,
'PERL_TYPE' => 1,
'PERL_URI_API' => 1,
'PERL_USELARGEFILES' => 0,
'PERL_UTIL_API' => 1,
'PREP_HTTPD' => 0,
'SSL_BASE' => '',
'USE_APACI' => 0,
'USE_APXS' => 1
);
1;

__END__

=head1 NAME

Apache::MyConfig - build options access

=head1 SYNOPSIS

 use Apache::MyConfig;
 die unless $Apache::MyConfig::Setup{PERL_FILE_API};

=head1 DESCRIPTION

B<Apache::MyConfig> module provides access to the various hooks
and features set when mod_perl is built.  This circumvents the
need to set up a live server just to find out if a certain callback
hook is available.

Itterate through %Apache::MyConfig::Setup to get obtain build
information then see Appendix B of the Eagle book for more detail
on each key.


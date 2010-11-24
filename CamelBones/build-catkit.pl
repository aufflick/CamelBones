#!/usr/bin/perl

use lib './PAR';
use CPAN;
use CPAN::MyConfig;
use Data::Dumper;

my $sdk = $ENV{'SDKROOT'};
my $libdir = $ENV{'BUILD_DIR'} . '/../../ExtLibs';
my $version = sprintf("%vd", $^V);

CPAN::HandleConfig->load;
CPAN::Shell::setup_output;
CPAN::Index->reload;

install 'CGI::Simple';
install 'HTTP::Body';
install 'HTTP::Request::AsCGI';

install 'MooseX::Emulate::Class::Accessor::Fast';
install 'MooseX::Types::Moose';
install 'namespace::autoclean';
install 'aliased';
install 'MooseX::Role::WithOverloading';
install 'MooseX::Types';
install 'String::RewritePrefix';
install 'Getopt::Long::Descriptive';
install 'MooseX::Getopt';
install 'MooseX::MethodAttributes::Inheritable';
install 'MooseX::Types::Common::Numeric';
install 'Class::C3::Adopt::NEXT';
install 'Catalyst::Runtime';

install 'Catalyst::Engine::Apache';
install 'Catalyst';

install 'Cache::Cache';
install 'Log::Any';

if ($version eq '5.8.6') {
    # On 5.8.6, we don't want this to follow dependencies, which
    # would result in an attempt to build Apache::Request
    
    # Self-tests pass without Apache::Request, but installation
    # must be forced because the dependencies were skipped
    my $module = CPAN::Shell->expand('Module', 'HTML::Mason');

    if ($module->uptodate()) {
        print 'HTML::Mason is up to date (', $module->inst_version(), ").\n";

    } else {
        local $CPAN::Config->{'build_requires_install_policy'} = 'no';
        local $CPAN::Config->{'prerequisites_policy'} = 'ignore';

        force('install','HTML::Mason');
    }
} else {
    install 'HTML::Mason';
}

install 'Template';

install 'Catalyst::Plugin::Session';
install 'Catalyst::Plugin::Authentication';
install 'Catalyst::Plugin::Authorization::Roles';
install 'Catalyst::Plugin::Session::State::Cookie';

install 'HTML::TokeParser::Simple';
install 'MIME::Types';
install 'Catalyst::Plugin::Session::State::URI';

install 'HTTP::Server::Simple';
install 'WWW::Mechanize';

install 'Catalyst::Plugin::Authentication::Store::DBIC';

install 'Catalyst::Plugin::Scheduler';

install 'Catalyst::Plugin::Session';
install 'Catalyst::Plugin::Session::Store::Delegate';
install 'Catalyst::Plugin::Session::Store::DBIC';

install 'Image::Size';
install 'Data::FormValidator';
install 'Catalyst::Plugin::FormValidator';

install 'Catalyst::Plugin::DefaultEnd';

install 'Catalyst::Model::DBIC';

install 'Catalyst::Manual';
install 'Catalyst::Plugin::Static::Simple';

install 'Catalyst::Plugin::ConfigLoader';

install 'Catalyst::Action::RenderView';
install 'Catalyst::Devel';

install 'Catalyst::Model::DBIC::Schema';

install 'Crypt::PasswdMD5';
install 'Authen::Htpasswd';
install 'Catalyst::Plugin::Authentication::Store::Htpasswd';

install 'Catalyst::Plugin::Authorization::ACL';

install 'HTML::Scrubber';

install 'HTML::Element';
install 'Mail::Address';
install 'Email::Valid';

install 'HTML::Widget';

install 'Catalyst::Plugin::HTML::Widget';

install 'Locale::Maketext::Lexicon';
install 'Locale::Maketext::Simple';
install 'Catalyst::Plugin::I18N';

install 'Catalyst::Plugin::Pluggable';

install 'HTML::Prototype';
install 'Catalyst::Plugin::Prototype';

install 'Cache::FastMmap';
install 'Catalyst::Plugin::Session::Store::FastMmap';
install 'Catalyst::Plugin::Session::Store::File';

install 'Catalyst::Plugin::Singleton';

install 'Catalyst::Plugin::StackTrace';

install 'File::BaseDir';
install 'File::MimeInfo';
install 'File::Slurp';
install 'Catalyst::Plugin::Static';

install 'Catalyst::Plugin::SubRequest';

install 'RPC::XML';
install 'Catalyst::Plugin::XMLRPC';

install 'JSON';
install 'JSON::Any';

install 'Catalyst::View::JSON';
install 'Catalyst::View::Mason';
install 'Template::Timer';

install 'Catalyst::View::TT';

install 'Catalyst::View::TT::Layout';
install 'Test::Harness';

# Requires XML::LibXSLT, which does not install on 10.4 or 10.5
if ($version eq '5.8.9') {
    install 'Catalyst::View::XSLT';
}
install 'HTML::FillInForm';

install 'Catalyst::Plugin::FillInForm';

install 'Class::Factory::Util';
install 'DateTime::Format::Strptime';
install 'DateTime::Format::Builder';

install 'DateTime::Format::DBI';

# Date::Manip 6.11 requires Perl 5.10 according to its META.yml,
# and doesn't install correctly. Install 5.56 instead.
eval {
    require Date::Manip;
};
if ($@) {
    install 'SBECK/Date-Manip-5.56.tar.gz';
} else {
    print 'Date::Manip is up to date (', $Date::Manip::VERSION, ").\n";
}

install 'DateTime::Format::DateManip';

install 'Time::Zone';
install 'Date::Parse';
install 'DateTime::Format::DateParse';

install 'DateTime::Format::HTTP';
install 'DateTime::Format::Mail';
install 'DateTime::Format::MySQL';
install 'DateTime::Format::Pg';

install 'Mail::Sendmail';

install 'DBIx::Class::WebForm';
install 'Catalyst::Plugin::AutoCRUD';

{
    my $module = CPAN::Shell->expand('Module', 'Catalyst::Authentication::Credential::Facebook');

    if ($module->inst_version() eq '0.01') {
        print 'Catalyst::Authentication::Credential::Facebook is up to date (', $module->inst_version(), ").\n";
    } else {
        install 'Catalyst::Authentication::Credential::Facebook';
    }
}

install 'Catalyst::Plugin::Facebook';

print "\n\n";

1;

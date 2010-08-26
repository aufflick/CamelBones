#!/usr/bin/perl

use Config;
use CPAN;
use CPAN::Config;
use Data::Dumper;
use File::Path;

require 5.6.2;

my $kit = 'CatKit';
my @pre = qw(PAR DevKit DBIKit XMLKit MacPerlKit);

my $tmp = `pwd`;
chomp $tmp;
$tmp =~ s%/*$%/build%;

my $dist_libs = "$tmp/../../dist-libs";

my $version = sprintf('%vd', $^V);
my $arch = $Config{'archname'};

for $k ($kit, @pre) {
    mkpath("$tmp/$k/$version/$arch", 0, 0711) unless -d "$tmp/$k/$version/$arch";
    unshift @INC, "$tmp/$k/$version", "$tmp/$k/$version/$arch";
    $ENV{'PERL5LIB'} .= ":$tmp/$k/$version:$tmp/$k/$version/$arch";
}

$CPAN::Config->{'makepl_arg'} .= " LIB=$tmp/$kit/$version ";
$CPAN::Config->{'mbuildpl_arg'} = " --install_path lib=$tmp/$kit/$version --install_path arch=$tmp/$kit/$version/$arch ";

$CPAN::Config->{'make_install_make_command'} = 'make';
$CPAN::Config->{'mbuild_install_build_command'} = './Build';

my $sdk = $ENV{'SDK'};

if (defined $sdk && -d $sdk) {
    my $arch = ($sdk =~ m%u\.sdk/?$%) ? '-arch i386 -arch ppc' : '';
    $CPAN::Config->{'makepl_arg'} .= "CCFLAGS='-isysroot$sdk $arch ' LDDLFLAGS='$arch -bundle -undefined dynamic_lookup -Wl,-syslibroot,$sdk '";
}

$CPAN::Config->{'make_install_arg'} =~ s/UNINST=1//;
$CPAN::Config->{'mbuild_install_arg'} =~ s/--uninst=1//;

install 'CGI::Simple';
install 'HTTP::Body';
install 'HTTP::Request::AsCGI';

install 'Catalyst::Engine::Apache';
install 'Catalyst';

install 'Cache::Cache';

{
    local $CPAN::Config->{'prefer_installer'} = 'EUMM';
    install 'HTML::Mason';
}

# Template needs to be patched to properly build the Stash::XS version
eval {
    my $mod = CPAN::Shell->expand('Module', 'Template');
    if ($mod->uptodate()) {
        my $mod_ver = $mod->inst_version();
        print "Template is up to date ($mod_ver)\n";
    } else {
        $mod->get();
        my $dist = $mod->distribution();
        my $dist_dir = $dist->dir();

        rename "$dist_dir/xs/Makefile.PL", "$dist_dir/xs/Makefile.PL.in"
            or die "Could not rename xs/Makefile.PL: $!";
        open MAKE_IN, '<', "$dist_dir/xs/Makefile.PL.in"
            or die "Could not open xs/Makefile.PL.in: $!";
        open MAKE_OUT, '>', "$dist_dir/xs/Makefile.PL"
            or die "Could not open xs/Makefile.PL: $!";

        my $SDK = $ENV{'SDK'};
        my $ARCH = ($SDK =~ /u.sdk$/) ?
            '-arch i386 -arch ppc' : '';

        while (<MAKE_IN>) {
            if (/^\);$/) {
                print MAKE_OUT <<"EOPATCH";
    'CCFLAGS' => ' -isysroot$SDK $ARCH',
    'LDDLFLAGS' => => ' $Config{lddlflags} -L$Config{archlib}/CORE -lperl -Wl,-syslibroot,$SDK $ARCH',
EOPATCH
            }
            print MAKE_OUT $_;
        }

        close MAKE_IN
            or die "Could not close xs/Makefile.PL.in: $!";
        close MAKE_OUT
            or die "Could not close xs/Makefile.PL: $!";
    
        system "cat $dist_dir/xs/Makefile.PL";

        $dist->install();
    }
};

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

install 'Catalyst::Plugin::Breadcrumbs';
install 'HTML::Scrubber';

install 'HTML::Element';
install 'Mail::Address';
install 'Email::Valid';

# 623 out of 625 tests pass on Panther - close enough for an old OS version
if ($version eq '5.8.1') {
    my $hw = CPAN::Shell->expand('Module', 'HTML::Widget');
    if ($hw->uptodate()) {
        my $hw_ver = $hw->inst_version();
        print "HTML::Widget is up to date ($hw_ver)\n";
    } else {
        force 'install', 'HTML::Widget';
    }
} else {
    install 'HTML::Widget';
}

install 'Catalyst::Plugin::HTML::Widget';

# I18N::LangTags::Detect isn't available as a standalone outside of Perl >= 5.8.6
if ($version ne '5.8.1') {
    install 'Locale::Maketext::Lexicon';
    install 'Locale::Maketext::Simple';
    install 'I18N::LangTags::Detect';
    install 'Catalyst::Plugin::I18N';
}

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
install 'Catalyst::Engine::Test';
install 'Catalyst::Plugin::Static';

install 'Catalyst::Plugin::SubRequest';

install 'RPC::XML';
install 'Catalyst::Plugin::XMLRPC';

install 'JSON';
install 'JSON::Any';

# install 'Catalyst::View::JSON';
# JSON::Any fails to find JSON, so install a version that doesn't use it
{
    my $version = eval 'use Catalyst::View::JSON; $Catalyst::View::JSON::VERSION';
    $version eq '0.14' ?
        print "Catalyst::View::JSON is up to date (0.14).\n" :
        install 'M/MI/MIYAGAWA/Catalyst-View-JSON-0.14.tar.gz';
    ;
}

install 'Catalyst::View::Mason';
install 'Template::Timer';

# 30 out of 32 tests pass on Panther - close enough for an old OS version
if ($version eq '5.8.1') {
    my $cvt = CPAN::Shell->expand('Module', 'Catalyst::View::TT');
    if ($cvt->uptodate()) {
        my $cvt_ver = $cvt->inst_version();
        print "Catalyst::View::TT is up to date ($cvt_ver)\n";
    } else {
        force 'install', 'Catalyst::View::TT';
    }
} else {
    install 'Catalyst::View::TT';
}

install 'Catalyst::View::TT::Layout';
install 'Test::Harness';
install 'Catalyst::View::XSLT';

# 69 out of 72 tests pass on Panther - close enough for an old OS version
if ($version eq '5.8.1') {
    my $fif = CPAN::Shell->expand('Module', 'HTML::FillInForm');
    if ($fif->uptodate()) {
        my $fif_ver = $fif->inst_version();
        print "HTML::FillInForm is up to date ($fif_ver)\n";
    } else {
        force 'install', 'HTML::FillInForm';
    }
} else {
    install 'HTML::FillInForm';
}

install 'Catalyst::Plugin::FillInForm';

install 'Class::Factory::Util';
install 'DateTime::Format::Strptime';
install 'DateTime::Format::Builder';

install 'DateTime::Format::DBI';

install 'Date::Manip';
install 'DateTime::Format::DateManip';

install 'Time::Zone';
install 'Date::Parse';
install 'DateTime::Format::DateParse';

install 'DateTime::Format::HTTP';
install 'DateTime::Format::Mail';
install 'DateTime::Format::MySQL';
install 'DateTime::Format::Pg';

install 'Mail::Sendmail';

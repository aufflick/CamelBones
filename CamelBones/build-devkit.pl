#!/usr/bin/perl

use Config;
use CPAN;
use CPAN::Config;
use Data::Dumper;
use File::Path;

require 5.6.2;

my $kit = 'DevKit';
my @pre = qw( PAR );

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

# Get the latest versions of the build environment
install 'CPAN';
install 'URI';
install 'HTML::Tagset';
install 'HTML::Parser';
install 'Errno';
install 'Net::FTP';
install 'Digest::base';
install 'Digest::MD5';
install 'LWP';

install 'ExtUtils::CBuilder';
install 'ExtUtils::ParseXS';
install 'IO::Zlib';
install 'Archive::Tar';
install 'Regexp::Common';
install 'Pod::Escapes';
install 'Pod::Simple';
install 'Pod::Text';
install 'Pod::Readme';
install 'YAML';
install 'Module::Build';

install 'UNIVERSAL::isa';
install 'UNIVERSAL::can';
install 'Sub::Uplevel';

install 'Test::Builder::Tester';
install 'Test::Exception';
install 'Test::MockObject';
install 'Test::Tester';
install 'Test::NoWarnings';
install 'Test::Deep';
install 'Test::LongString';
install 'Test::use::ok';

install 'Test::Harness';
install 'TAPx::Parser';

install 'Storable';
install 'Object::Signature';

# 433 out of 435 tests pass on Panther - close enough for an old OS version
if ($version eq '5.8.1') {
    my $mod = CPAN::Shell->expand('Module', 'Set::Object');
    if ($mod->uptodate()) {
        my $mod_ver = $mod->inst_version();
        print "Set::Object is up to date ($mod_ver).\n";
    } else {
        force 'install', 'Set::Object';
    }
} else {
    install 'Set::Object';
}

install 'File::Modified';

install 'File::Spec'; # Module::Pluggable needs >= 3.00, Panther has 0.86
install 'Module::Pluggable';
install 'Path::Class';
install 'Text::SimpleTable';
install 'Tree::Simple';
install 'Tree::Simple::Visitor::FindByPath';
install 'version';
install 'Text::Balanced';

install 'Devel::StackTrace';

install 'Class::Accessor';
install 'Clone';
install 'IO::Scalar';
install 'Class::Data::Inheritable';
install 'Class::Trigger';
install 'Exception::Class';

install 'Params::Validate';
install 'DateTime::Locale';
install 'Class::Singleton';
install 'DateTime::TimeZone';
install 'DateTime';
install 'Class::Inspector';
install 'Data::UUID';
install 'Module::Find';

install 'Class::Container';
install 'Error';
install 'Digest::SHA1';

install 'URI::Find';
install 'Sub::Override';

install 'Carp::Assert';
install 'Carp::Assert::More';

install 'Set::Scalar';
install 'Set::Infinite';
install 'DateTime::Set';
install 'Set::Crontab';
install 'DateTime::Event::Cron';

install 'Carp::Clan';
install 'Algorithm::C3';
install 'Class::C3';
install 'Cwd';
install 'Class::Data::Accessor';
install 'Class::Accessor::Chained::Fast';
install 'Data::Page';

install 'UNIVERSAL::require';

install 'Lingua::EN::Inflect';
install 'UNIVERSAL::moniker';

install 'Lingua::EN::Inflect::Number';
install 'Data::Dump';

install 'Bit::Vector';
install 'Date::Calc';

install 'Data::Visitor';
install 'Config::Any';

install 'Module::ScanDeps';
install 'Module::CoreList';
install 'YAML::Tiny';
install 'Module::Install';

install 'File::Copy::Recursive';

install 'IO::LockedFile';
install 'IO::KQueue';

install 'Class::Throwable';

install 'Module::Pluggable::Fast';

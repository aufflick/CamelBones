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

# Get the latest versions of the build environment
if ($version ne '5.8.6') {
    # Mac::SystemDirectory uses /usr/bin/sw_vers in its self-tests, so
    # the tests for 5.8.8 fail when building on Snow Leopard. :-(
    if ($version eq '5.8.8') {
        my $module = CPAN::Shell->expand('Module', 'Mac::SystemDirectory');
        if ($module->uptodate()) {
            print 'Mac::SystemDirectory is up to date (', $module->inst_version(), ").\n";
        } else {
            force('install', 'Mac::SystemDirectory');
        }
    } else {
        install 'Mac::SystemDirectory';
    }

    install 'File::HomeDir';
}

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

# Regexp::Common fails a few self-tests, but install it anyway
# Just force the frakkin thing.
{
    my $module = CPAN::Shell->expand('Module', 'Regexp::Common');
    if ($module->uptodate()) {
        print 'Regexp::Common is up to date (', $module->inst_version(), ").\n";
    } else {
        force('install','Regexp::Common');
    }
}

install 'Pod::Escapes';
install 'Pod::Simple';
install 'Pod::Text';
install 'Pod::Readme';

install 'YAML';
install 'Test::Harness';
install 'YAML::Tiny';

# 1.54 does not install properly on 5.8.6 or 5.8.8
if ($version eq '5.8.9') {
    install 'ExtUtils::Install';
} else {
    eval {
        require ExtUtils::Install;
    };
    if ($@) {
        install 'YVES/ExtUtils-Install-1.52_03.tar.gz';
    } else {
        print 'ExtUtils::Install is up to date (', $ExtUtils::Install::VERSION, ").\n";
    }
}

install 'ExtUtils::Installed';

# Software::License tests require Class::C3, which isn't installed until later
# Just force the frakkin thing.
{
    my $module = CPAN::Shell->expand('Module', 'Software::License');
    if ($module->uptodate()) {
        print 'Software::License is up to date (', $module->inst_version(), ").\n";
    } else {
        force('install','Software::License');
    }
}

# A few tests fail
# Just force the frakkin thing.
{
    my $module = CPAN::Shell->expand('Module', 'Module::Build');
    if ($module->uptodate()) {
        print 'Module::Build is up to date (', $module->inst_version(), ").\n";
    } else {
        force('install','Module::Build');
    }
}

install 'Data::Section';
install 'Text::Template';

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

install 'Storable';
install 'Object::Signature';
install 'Set::Object';

install 'File::Modified';

install 'File::Spec';
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

install 'Attribute::Handlers';
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

install 'Tie::ToObject';
install 'Task::Weaken';

install 'Params::Util';
install 'Tree::DAG_Node';
install 'Test::Warn';
install 'Sub::Install';
install 'Package::DeprecationManager';
install 'Test::Requires';
install 'MRO::Compat';
install 'Try::Tiny';
install 'Package::Stash';
install 'Sub::Name';
install 'Data::OptList';
install 'Scope::Guard';
install 'Sub::Exporter';
install 'Devel::GlobalDestruction';
install 'Class::MOP';
install 'Moose';

install 'Sub::Identify';
install 'Variable::Magic';
install 'B::Hooks::EndOfScope';
install 'namespace::clean';
install 'Data::Visitor';

install 'Config::Any';

install 'Module::ScanDeps';
install 'Module::CoreList';
install 'Module::Install';

install 'File::Remove';
install 'Parse::CPAN::Meta';
install 'Devel::PPPort';
install 'common::sense';
install 'JSON::XS';
install 'JSON';
install 'File::Copy::Recursive';

install 'IO::LockedFile';
my $version = sprintf("%vd", $^V);

# IO::KQueue does not build on 10.4
if ($version ne '5.8.6') {
    install 'IO::KQueue';
}

install 'Class::Throwable';

install 'Module::Pluggable::Fast';

print "\n\n";

1;

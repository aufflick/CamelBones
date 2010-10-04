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

install 'Mac::Carbon';
install 'File::MMagic';
install 'AppConfig';

if ($version eq '5.8.6') {
    # Mac::SystemDirectory uses /usr/bin/sw_vers in its self-tests, so
    # the tests for 5.8.6 fail when building on Snow Leopard. :-(
    my $module = CPAN::Shell->expand('Module', 'Mac::SystemDirectory');
    if ($module->uptodate()) {
        print 'Mac::SystemDirectory is up to date (', $module->inst_version(), ").\n";
    } else {
        force('install', 'Mac::SystemDirectory');
    }

    install 'File::HomeDir';
}

print "\n\n";

1;

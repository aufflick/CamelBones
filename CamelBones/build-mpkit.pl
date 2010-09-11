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
    install 'File::HomeDir';
}

print "\n\n";

1;

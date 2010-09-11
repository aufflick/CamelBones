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

install 'Scalar::Util';
install 'IO::Compress::Base';
install 'Compress::Raw::Bzip2';
install 'IO::Compress::Bzip2';
install 'Compress::Raw::Zlib';
install 'IO::Compress::Gzip';

install 'Compress::Zlib';
install 'File::Which';
install 'Test::More';
install 'File::Temp';
install 'Archive::Zip';

install 'PAR::Dist';
install 'AutoLoader';
install 'Digest::SHA';

install 'PAR';

print "\n\n";

1;

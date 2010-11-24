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

install 'Compress::Raw::Zlib';
install 'Compress::Raw::Bzip2';

if ($version eq '5.10.0') {
    eval {
        require IO::Compress::Base;
    };
    if ($@) {
        # Later versions tickle an EU::MM bug in 5.10
        install 'P/PM/PMQS/IO-Compress-2.021.tar.gz';
    } else {
        print 'IO::Compress is up to date (', $IO::Compress::Base::VERSION, ").\n";
    }
} else {
    install 'IO::Compress::Base';
}

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

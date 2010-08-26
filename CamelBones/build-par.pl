#!/usr/bin/perl

use Config;
use CPAN;
use CPAN::Config;
use Data::Dumper;
use File::Path;

require 5.6.2;

my $kit = 'PAR';
my @pre = qw( );

my $tmp = `pwd`;
chomp $tmp;
$tmp =~ s%/*$%/build%;

my $version = sprintf('%vd', $^V);
my $arch = $Config{'archname'};

for my $k ( $kit, @pre ) {
    mkpath("$tmp/$k/$version/$arch", 0, 0711) unless -d "$tmp/%k/$version/$arch";
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
install 'Module::Signature';

install 'PAR';

1;

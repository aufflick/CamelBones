#!/usr/bin/perl

use Config;
use CPAN;
use CPAN::Config;
use Data::Dumper;
use File::Path;

require 5.6.2;

my $kit = 'XMLKit';
my @pre = qw( PAR DevKit );

my $tmp = `pwd`;
chomp $tmp;
$tmp =~ s%/*$%/build%;

my $dist_libs = "$tmp/../../dist-libs";

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

# XML::Parser needs to find libexpat
{
    my $arg = $CPAN::Config->{'makepl_arg'};
    $arg .= " EXPATLIBPATH='$dist_libs/expat/$version/lib' ";
    $arg .= " EXPATINCPATH='$dist_libs/expat/$version/include'";
    local $CPAN::Config->{'makepl_arg'} = $arg;

    install 'XML::Parser';
}

install 'XML::NamespaceSupport';
install 'XML::SAX';
install 'XML::LibXML::Common';

# install 'XML::LibXML';
# 1.63 fails its self-tests, so install 1.62
{
    my $version = eval 'use XML::LibXML; $XML::LibXML::VERSION';
    $version eq '1.62' ?
        print "XML::LibXML is up to date (1.62).\n" :
        install 'PAJAS/XML-LibXML-1.62.tar.gz';
    ;
}


# install 'XML::LibXML::Iterator'; # Fails self-tests
# install 'XML::LibXML::Tools'; # Fails self-tests
install 'XML::Simple';
install 'XML::Parser::PerlSAX';
install 'XML::RegExp';
install 'XML::DOM';
install 'XML::XPath';
# install 'XML::XPathScript'; # Fails self-tests
install 'XML::LibXSLT';
install "XML::Dumper";
install 'XML::Writer';


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

# XML::Parser needs libexpat, which does not exist in a standard location on Mac OS X 10.4
if (sprintf("%vd", $^V) eq '5.8.6') {
    my $arg = $CPAN::Config->{'makepl_arg'};
    $arg .= " EXPATLIBPATH='$libdir/lib' ";
    $arg .= " EXPATINCPATH='$libdir/include'";
    local $CPAN::Config->{'makepl_arg'} = $arg;
    install 'XML::Parser';
} else {
    install 'XML::Parser';
}

install 'XML::NamespaceSupport';
install 'XML::SAX';

# XML::LibXML needs to know where to find xml2-config
{
    my $arg = $CPAN::Config->{'makepl_arg'};
    $arg .= " XMLPREFIX=$sdk/usr";
    local $CPAN::Config->{'makepl_arg'} = $arg;
    install 'XML::LibXML';
}

install 'XML::NodeFilter';
install 'XML::LibXML::Iterator';
# install 'XML::LibXML::Tools'; # Fails self-tests
install 'XML::Simple';
install 'XML::Parser::PerlSAX';
install 'XML::RegExp';
# install 'XML::DOM'; # Fails self-tests
install 'XML::XPath';

install 'Readonly';
install 'XML::XPathScript'; # Fails self-tests

# XML::LibXSLT needs to know where to find xslt-config, and
# depends on a version of libxslt not found on 10.4 or 10.5
if ($version ne '5.8.6' && $version ne '5.8.8') {
    my $arg = $CPAN::Config->{'makepl_arg'};
    $arg .= " XSLTPREFIX=$sdk/usr";
    local $CPAN::Config->{'makepl_arg'} = $arg;
    install 'XML::LibXSLT';
}

install "XML::Dumper";
install 'XML::Writer';

print "\n\n";

1;



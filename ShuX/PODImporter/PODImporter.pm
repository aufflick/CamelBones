#
#  PODImporter.pm
#  PODImporter
#
#  Created by Sherm Pendley on 4/30/06.
#  Copyright 2006 Sherm Pendley. All rights reserved.
#

package PODImporter;

use CamelBones qw(:All);

use PODMetadataParser;

use strict;
use warnings;

class PODImporter {
	'super' => 'NSObject',
	'properties' => [ ],
};

sub getMetaData : Class Selector(getMetadata:forFile:ofType:withInterface:)
                  ArgTypes(@@@^v) ReturnType(c) {

    my ($class, $attributes, $pathToFile, $contentTypeUTI, $thisInterface) = @_;

    my $parser = new PODMetadataParser( 'input_encoding' => 'utf8' );
    my $encoding = '<:utf8';
    
    # Special-case encodings
    if ($pathToFile =~ /perlcn.pod$/) {
        $encoding = '<:encoding(euc-cn)';
    }
    if ($pathToFile =~ /perljp.pod$/) {
        $encoding = '<:encoding(euc-jp)';
    }
    if ($pathToFile =~ /perlko.pod$/) {
        $encoding = '<:encoding(euc-kr)';
    }
    if ($pathToFile =~ /perltw.pod$/) {
        $encoding = '<:encoding(big5)';
    }

    open(my $infile, $encoding, $pathToFile)
        or die "Could not open $pathToFile: $!";
    $parser->parse_from_filehandle($infile);
    
    # If an =encoding directive other than utf8 was found, re-run
    # with the requested encoding
    if ($encoding eq '<:utf8' && $parser->{'input_encoding'} ne 'utf8') {
        $encoding = '<:encoding(' . $parser->{'input_encoding'} . ')';

        close $infile;
        open($infile, $encoding, $pathToFile)
            or die "Could not open $pathToFile: $!";
        $parser->parse_from_filehandle($infile);
    }

    $attributes->setValue_forKey($parser->{'name'}, 'kMDItemTitle');
    $attributes->setValue_forKey($parser->{'text'}, 'kMDItemTextContent');
    $attributes->setValue_forKey($parser->{'name'}, 'kMDItemDisplayName');

    return 1;
}

1;

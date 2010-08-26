# ShuX version 3.0, Copyright 2006 Sherm Pendley.

use strict;
use warnings;

package MyDocument;

my $defaultStatusText = "ShuX Version 3.0";

use Fcntl qw(:seek);
use File::Path;
use ShuXParser;

use CamelBones qw(:All);

class MyDocument {
    'super' => 'NSDocument',
    'properties' => [ 'docSetName', 'docSetPath', 'arrayController',
					  'needParsing', 'cacheFile', 'docSetList',
					  'webView', 'statusTextField', 'statusSpinner',
                    ],
};

sub windowNibName : Selector(windowNibName) ReturnType(@) {
	return 'MyDocument';
}

sub windowControllerWillLoadNib : Selector(windowControllerWillLoadNib:)
        ArgTypes(@) {
    my ($self, $controller) = @_;
    
	my $defaults = NSUserDefaults->standardUserDefaults();
	if ($defaults->boolForKey('CascadeNewWindows')) {
        $controller->setShouldCascadeWindows(1);
    } else {
        $controller->setShouldCascadeWindows(0);
    }
}

sub windowControllerDidLoadNib : Selector(windowControllerDidLoadNib:)
        ArgTypes(@) {
	my ($self, $controller) = @_;

    $self->displayPod();
}

sub readFile : Selector(readFromFile:ofType:)
        ArgTypes(@@) ReturnType(c) {
 	my ($self, $filename, $type) = @_;

	my $cacheDir = NSUserDefaults->standardUserDefaults()->stringForKey('CacheDir');
	my $cfilename = $filename;
	$cfilename =~ s/(.pm|.pod|.pl)$/.html/;
	my $cacheFile = "$cacheDir/$cfilename";
	$cacheFile =~ s%//%/%g;
	$self->setCacheFile($cacheFile);
	if (-f $cacheFile) {
		if (-M $cacheFile > -M $filename) {
			$self->setNeedParsing(1);
		} else {
			$self->setNeedParsing(0);
		}
	} else {
		$self->setNeedParsing(1);
	}
	$self->setFileName($filename);

 	return 1;
}

sub displayName : Selector(displayName) ReturnType(@) {
	my ($self) = @_;
	my $displayName = $self->SUPER::displayName();
	if ($self->docSetName()) {
		$displayName .= ' ('.$self->docSetName().')';
	}
	return $displayName;
}

sub setDocSetName : Selector(setDocSetName:) ArgTypes(@) {
	my ($self, $newName) = @_;
	$self->{'docSetName'} = $newName;
	$self->windowControllers()->objectAtIndex(0)->window()->setTitle($self->displayName);
}


sub docSetChanged : Selector(docSetChanged:) IBAction {
	my ($self, $sender) = @_;
}

sub printPod : Selector(printPod:) IBAction {
    my ($self, $sender) = @_;
    $self->webView()->mainFrame()->frameView()->documentView()->print($sender);
}

## WebUIDelegate methods

sub webView_mouseDidMoveOverElement_modifierFlags : 
        Selector(webView:mouseDidMoveOverElement:modifierFlags:)
        ArgTypes(@@I) {
    my ($self, $sender, $element, $flags) = @_;

    my $text =  $element->valueForKey('WebElementLinkURL');
    if ($text) {
        my $string = $text->relativePath();
        $string =~ s%^/%%;

        my $fragment = $text->fragment();
        if ($fragment) {
            $self->statusTextField()->setStringValue($string . '#' . $fragment);
        } else {
            $self->statusTextField()->setStringValue($string);
        }
    } else {
        $self->statusTextField()->setStringValue($defaultStatusText);
    }
}

## WebPolicyDelegate methods

sub webView_decidePolicyForNavigationAction_request_frame_decisionListener :
        Selector(webView:decidePolicyForNavigationAction:request:frame:decisionListener:)
        ArgTypes(@@@@@) {
    my ($self, $webView, $navAction, $request, $frame, $listener) = @_;

    if ( defined $navAction->valueForKey('WebActionNavigationTypeKey')
        && $navAction->valueForKey('WebActionNavigationTypeKey')->intValue() == 0
        ) {

        my $url = $navAction->valueForKey('WebActionOriginalURLKey');
        
        if ($url->scheme() eq 'file') {
            my $path = $url->path();
            my $podPath = $self->pathForPod($path);
            if ($podPath && -f $podPath) {
                $self->readFromFile_ofType($podPath, '');
                $self->displayPod();
            }
        }
    }
    
    $listener->use();
}


## Private methods - not exported to Objective-C
sub parseFile {
    my ($self) = @_;

    $self->statusSpinner()->startAnimation($self);

	if ($self->needParsing()) {

		my $path = $self->cacheFile();
		$path =~ s%/[^/]*$%%;
		mkpath($path);

		my $parser = new ShuXParser( 'input_encoding' => 'utf8' );
		my $encoding = '<:utf8';

		# Special-case encodings
		if ($self->fileName() =~ /perlcn.pod$/) {
		    $encoding = '<:encoding(euc-cn)';
        }
		if ($self->fileName() =~ /perljp.pod$/) {
		    $encoding = '<:encoding(euc-jp)';
        }
		if ($self->fileName() =~ /perlko.pod$/) {
            $encoding = '<:encoding(euc-kr)';
        }
		if ($self->fileName() =~ /perltw.pod$/) {
            $encoding = '<:encoding(big5)';
        }

		open(my $infile, $encoding, $self->fileName())
		  or die "Could not open " . $self->fileName() . ". $!";
		open(my $outfile, '>:utf8', $self->cacheFile())
		  or die "Could not open " . $self->cacheFile() . ". $!";
		$parser->parse_from_filehandle($infile, $outfile);
		
		# If an =encoding directive other than utf8 was found, re-run
		# with the requested encoding
		if ($encoding eq '<:utf8' && $parser->{'input_encoding'} ne 'utf8') {
            $encoding = '<:encoding(' . $parser->{'input_encoding'} . ')';

            close $infile;
            open($infile, $encoding, $self->fileName())
              or die "Could not open " . $self->fileName() . ". $!";
            seek $outfile, 0, SEEK_SET;
            $parser->parse_from_filehandle($infile, $outfile);
		}
	}

    $self->statusSpinner()->stopAnimation($self);
}

sub pathForPod {
    my ($self, $pod) = @_;

	my $defaults = NSUserDefaults->standardUserDefaults();
	my @docSets = $defaults->valueForKey('docSets');
	my ($set) = grep { $_->valueForKey('name') eq $self->docSetName() } @docSets;

	foreach my $typeName (@$BrowserController::podTypeNames) {
		my $type = $BrowserController::podTypes->{$typeName};
		my $typePath = $set->valueForKey($type);
		my $arch = $set->valueForKey('arch');
		foreach my $searchPath ("$typePath/$arch", $typePath) {
		    foreach my $ext ('.pod', '.pm', '.pl') {
		        my $candidate = $searchPath . $pod . $ext;
		        if (-f $candidate) {
                    return $candidate;
                }
		    }
		}
	}
	
	return undef;
}

sub displayPod {
    my ($self) = @_;

    my $window = $self->windowControllers()->objectAtIndex(0)->window();
    $self->statusTextField()->setStringValue('Parsing POD');
    $window->display();

    $self->parseFile();

    $self->statusTextField()->setStringValue($defaultStatusText);
    $window->display();

    my $url = NSURL->fileURLWithPath($self->cacheFile());
    my $request = NSURLRequest->requestWithURL($url);

    my $mainFrame = $self->webView()->mainFrame();
	$mainFrame->loadRequest($request);
}

1;

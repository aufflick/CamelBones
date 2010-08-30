#!/usr/bin/perl

#
#  «FILENAME»
#  «PROJECTNAME»
#
#  Created by «FULLUSERNAME» on «DATE».
#  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.
#

package «FILEBASENAMEASIDENTIFIER»;
use CamelBones qw(:All);
use strict;
use warnings;

class «FILEBASENAMEASIDENTIFIER» {
    'super' => 'NSDocument',
    'properties' => [
                    ],
};


sub init : Selector(init) ReturnType(@) {
    my ($self) = @_;
    $self = $self->SUPER::init();

    if ($self) {
        # Add code here to perform any custom initialization for this object
    }
    
    return $self;
}

sub windowNibName : Selector(windowNibName) ReturnType(@) {
    # Default to returning the name of the .nib file to use with this document,
    # minus the .nib extension.
    #
    # If you need to use a custom NSWindowController, or more than one .nib per
    # document, delete this method and override makeWindowControllers instead.
	return 'MyDocument';
}


sub windowControllerDidLoadNib : Selector(windowControllerDidLoadNib:)
        ArgTypes(@) {
	my ($self, $controller) = @_;

    $self->SUPER::windowControllerDidLoadNib($controller);

    # This is where you add any code you want to run *after* the document's .nib
    # has been loaded and its connections established.
}


sub dataRepresentationOfType : Selector(dataRepresentationOfType:)
        ArgTypes(@) ReturnType(@) {
	my ($self, $type) = @_;
	
	# Data-based primitive method for saving document data. Create an NSData object
	# and return it here, and the Cocoa framework takes care of writing it to a
	# file.
	#
	# If you need more detailed control over the process - for instance, if you want
	# to write data to a file yourself, or use multi-file packages - delete this and
	# override one of the location-based primitive methods instead:
	#     writeToFile:ofType:
	#     fileWrapperRepresentationOfType:

 	return undef;
}


sub loadDataRepresentation_ofType : Selector(loadDataRepresentation:ofType:)
        ArgTypes(@@) ReturnType(c) {
 	my ($self, $data, $type) = @_;
 	
 	# Data-based primitive method for loading document data. Load your document data
 	# from the provided NSData object.
 	#
 	# If you need more detailed control over the process, delete this method and override
 	# one of the location-based primitive methods instead:
    #     readFromFile:ofType:
    #     loadFileWrapperRepresentation:ofType:

 	return 1;
}

# Happy Perl
1;

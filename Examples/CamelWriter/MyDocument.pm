# CamelWriter version 0.1, Copyright 2005 Sherm Pendley.

use strict;
use warnings;

package MyDocument;

use CamelBones qw(:All);

class MyDocument {
    'super' => 'NSDocument',
    'properties' => [
		'textView', 'aString',
                    ],
};

sub init : Selector(init) ReturnType(@) {
    my ($self) = @_;
    $self = $self->SUPER::init();
    
    # Add code here to perform any custom initialization for this object
    
    return $self;
}


# Respond to changes in the text by copying it
sub textDidChange : Selector(textDidChange:) ArgTypes(@) {
	my ($self, $notification) = @_;
	$self->setAString($self->textView()->textStorage());
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
	
    # This is where you add any code you want to run *after* the document's .nib
    # has been loaded and its connections established.

	$self->textView()->textStorage()->setAttributedString($self->aString());
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

	$self->setAString($self->textView()->textStorage());
	my $data = $self->aString()->RTFFromRange_documentAttributes(
		{'location'=>0, 'length'=>$self->aString()->length()},{});
 	return $data;
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
 	$self->setAString(NSAttributedString->alloc()->initWithRTF_documentAttributes(
		$data, undef));
 	return 1;
}

1;

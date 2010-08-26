use strict;
use warnings;

package MyWindowController;

use CamelBones qw(:All);

class MyWindowController {
	'super' => 'NSObject',
	'properties' => [ 'window', 'textView', 'windowController' ],
};

sub init : Selector(init) ReturnType(v) {
	my ($self) = @_;
    
    # Private ivars
    $self->{'_openPath'} = $ENV{'HOME'};

    $self->setWindowController(NSWindowController->alloc->initWithWindowNibName_owner("MainWindow", $self));
    $self->windowController()->window();

    return $self;
}

# Private methods - not exported to Objective-C
# This is forwarded from the menu action in MyApp
sub _openDocument {
    my ($self, $sender) = @_;
    
    # Get the shared NSOpenPanel instance
    my $openPanel = NSOpenPanel->openPanel();

    # Build a list of acceptable types
    my $fileTypes = NSMutableArray->alloc->initWithCapacity(1);
    $fileTypes->addObject("rtf");
    $fileTypes->addObject("rtfd");

    # Run it
    $openPanel->beginSheetForDirectory_file_types_modalForWindow_modalDelegate_didEndSelector_contextInfo(
        $self->{'_openPath'}, '', $fileTypes, $self->window(), $self, 'openPanelDidEnd:returnCode:contextInfo:', undef
    );
}

# Delegate methods
sub openPanelDidEnd_returnCode_contextInfo :
		Selector(openPanelDidEnd:returnCode:contextInfo:)
		ArgTypes(@i^v) ReturnType(v)
	{
    my ($self, $sheet, $returnCode, $context) = @_;
    my $selection = undef;
    if ($returnCode == 1) {
        # OK clicked
        $selection = $sheet->filenames()->objectAtIndex(0);
    }

    $sheet->close();
    
    if ($selection) {
        $self->{'_openPath'} = $sheet->directory();
        $self->textView()->readRTFDFromFile($selection);
        $self->textView()->scrollRangeToVisible(NSMakeRange(0,0));
    }
}

1;

use strict;
use warnings;

package MyWindowController;

use CamelBones qw(:All);

class MyWindowController {
	'super' => 'NSObject',
	'properties' => [
					 'window', 'drawer', 'sheet', 'message', 'windowController',
					 ],
};

sub init : Selector(init) ReturnType(@) {
	my ($self) = @_;

    $self->setWindowController(NSWindowController->alloc->initWithWindowNibName_owner("MainWindow", $self));
    $self->windowController()->window();

    return $self;
}

# Action methods

# The "Open Drawer" and "Open Sheet" buttons are in the main window
sub openDrawer :
		Selector(openDrawer:)
		IBAction
	{
    my ($self, $sender) = @_;
    $self->drawer()->open();
}

sub openSheet :
		Selector(openSheet:)
		IBAction
	{
    my ($self, $sender) = @_;

    my $nsApp = NSApplication->sharedApplication;
    $nsApp->beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(
		$self->sheet(),                         # This is the sheet

        $self->window(),                        # This is the window is will be attached to

        $self,									# This is the object to which a message will be sent
                                                # when the sheet is ended.

        'sheetDidEnd:returnCode:contextInfo:',	# ...and this is the message that will be sent

        undef									# In ObjC, this is an arbitrary pointer - it's not used by Cocoa,
                                                # just sent along with the message named in didEndSelector.
    );
}

# The "Close Drawer" button is in the drawer
sub closeDrawer :
		Selector(closeDrawer:)
		IBAction
	{
    my ($self, $sender) = @_;
    $self->drawer()->close();
}

# The "Cancel Sheet" and "Close Sheet" buttons are in the sheet

sub cancelSheet :
		Selector(cancelSheet:)
		IBAction
	{
    my ($self, $sender) = @_;

    my $nsApp = NSApplication->sharedApplication;
    $nsApp->endSheet_returnCode($self->sheet(), 0);
}

sub closeSheet :
		Selector(closeSheet:)
		IBAction
	{
    my ($self, $sender) = @_;

    my $nsApp = NSApplication->sharedApplication;
    $nsApp->endSheet_returnCode($self->sheet(), 1);
}

# Delegate methods

# This method is called in response to endSheet:returnCode:
sub sheetDidEnd_returnCode_contextInfo :
		Selector(sheetDidEnd:returnCode:contextInfo:)
		ArgTypes(@i^v) ReturnType(v)
	{
    my ($self, $sheet, $returnCode) = @_;
    my $nsApp = NSApplication->sharedApplication;

    if ($returnCode == 0) {
        $self->message()->setStringValue("Sheet cancelled");
    } elsif ($returnCode == 1) {
        $self->message()->setStringValue("Sheet closed");
    } else {
        $self->message()->setStringValue("Unknown return code");
    }

    $sheet->close();
}

1;

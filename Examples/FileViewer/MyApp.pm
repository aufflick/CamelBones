use strict;
use warnings;

package MyApp;

use CamelBones qw(:All);

use MyWindowController;

class MyApp {
	'super' => 'NSObject',
	'properties' => [ 'wc' ],
};

sub applicationWillFinishLaunching : Selector(applicationWillFinishLaunching:)
ArgTypes(@) ReturnType(v) {
    my ($self, $notification) = @_;

    # Create the new controller object
    $self->setWc(MyWindowController->alloc()->init());

    return 1;
}

# Menu actions
sub openDocument :
		Selector(openDocument:)
		IBAction
	{
    my ($self, $sender) = @_;
    $self->wc()->_openDocument($sender);
}

1;

use strict;
use warnings;

package MyController;

use CamelBones qw(:All);

use WindowController;

class MyController {
	'super' => 'NSObject',
	'properties' => [ 'wc' ],
};

sub applicationWillFinishLaunching : Selector(applicationWillFinishLaunching:)
ArgTypes(@) ReturnType(v) {

    my ($self, $notification) = @_;

    # Create the new controller object
    $self->setWc(WindowController->alloc()->init());

    return;
}

1;

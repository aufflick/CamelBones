# CustomView version 0.1, Copyright 2005 Sherm Pendley.

use strict;
use warnings;

package CustomView;

use CamelBones qw(:All);

use CustomViewWindowController;

class CustomView {
    'super' => 'NSObject',
    'properties' => [ 'wc' ],
};

sub applicationWillFinishLaunching : Selector(applicationWillFinishLaunching:)
        ArgTypes(@) ReturnType(v) {

    my ($self, $notification) = @_;

    # Create the new controller object
    $self->setWc(CustomViewWindowController->alloc()->init());

    return 1;
}

1;

# CustomView version 0.1, Copyright 2005 Sherm Pendley.

use strict;
use warnings;

use MyView;

package CustomViewWindowController;

use CamelBones qw(:All);

class CustomViewWindowController {
    'super' => 'NSObject',
    'properties' => [
                        'windowController',
                    ],
};

sub init : Selector(init) ReturnType(@) {
    my ($self) = @_;
    
    $self->setWindowController(
            NSWindowController->alloc()->initWithWindowNibName_owner("MainWindow", $self));
    $self->windowController()->window();

    return $self;
}

1;

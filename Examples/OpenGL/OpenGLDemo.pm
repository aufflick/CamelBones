# OpenGL version 0.1, Copyright 2007 Sherm Pendley.

use strict;
use warnings;

package OpenGLDemo;

use CamelBones qw(:All);

class OpenGLDemo {
    'super' => 'NSObject',
};

sub applicationWillFinishLaunching : Selector(applicationWillFinishLaunching:)
        ArgTypes(@) ReturnType(v) {

    my ($self, $notification) = @_;

    return 1;
}

1;

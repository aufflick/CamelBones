# ControllerInNib.pm Copyright 2005 Sherm Pendley

package ControllerInNib;

use strict;
use warnings;

use CamelBones qw(:All);

class ControllerInNib {
	'super' => 'NSObject',
};

sub sayHello : Selector(sayHello:) IBAction {
	warn "Hello, world";
}

1;

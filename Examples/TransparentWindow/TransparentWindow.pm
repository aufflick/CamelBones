# TransparentWindow version 0.1, Copyright 2005 Sherm Pendley.

use strict;
use warnings;

package TransparentWindow;

use CamelBones qw(:All);

class TransparentWindow {
    'super' => 'NSObject',
	'properties' => [ 'window' ],
};

sub changeTransparency : Selector(changeTransparency:) IBAction {
	my ($self, $sender) = @_;
	$self->window()->setAlphaValue($sender->floatValue());
	$self->window()->display();
}

1;

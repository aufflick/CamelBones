# TicTacToe version 0.1, Copyright 2004 Sherm Pendley.

use strict;
use warnings;

package TicTacToePlayer;

use CamelBones qw(:All);

class TicTacToePlayer {
	'super' => 'NSObject',
	'properties' => [
					 'color', 'name', 'image',
					 ],
};

sub init : Selector(initWithColor:name:) ArgTypes(@@) ReturnType(@) {
	my ($self, $color, $name) = @_;
	
	$self->setColor($color);
	$self->setName($name);
	$self->setImage(NSImage->imageNamed(lc $color));
	
    $self->image()->setScalesWhenResized(1);
    $self->image()->setSize(NSMakeSize(45.0,45.0));

	return $self;
}

1;

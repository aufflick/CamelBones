# TicTacToe version 0.1, Copyright 2004 Sherm Pendley.

use strict;
use warnings;

package TicTacToe;

use CamelBones qw(:All);

use TicTacToeWindowController;

class TicTacToe {
	'super' => 'NSObject',
	'properties' => [ 'wc' ],
};

sub applicationWillFinishLaunching : Selector(applicationWillFinishLaunching:)
ArgTypes(@) ReturnType(v) {
    my ($self, $notification) = @_;

    # Create the new controller object
    $self->setWc(TicTacToeWindowController->alloc()->init());
}

sub newGame : Selector(newGame:) IBAction {
	my ($self, $sender) = @_;
	$self->wc()->newGame($sender);
}

1;

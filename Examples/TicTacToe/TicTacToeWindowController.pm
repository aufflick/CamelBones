# TicTacToe version 0.1, Copyright 2004 Sherm Pendley.

use strict;
use warnings;

package TicTacToeWindowController;

use CamelBones qw(:All);

use TicTacToePlayer;

class TicTacToeWindowController {
	'super' => 'NSObject',
	'properties' => [
					 'window', 'windowController',
					 'gameMessage', 'buttonMatrix',
					 'green', 'purple',
					 ],
};

sub init : Selector(init) ReturnType(@) {
	my ($self) = @_;

    $self->{'turn'} = undef;
	$self->{'cells'} = [
						['', '', ''],
						['', '', ''],
						['', '', ''],
					   ];
	$self->setGreen(TicTacToePlayer->alloc()->initWithColor_name('green', 'Green Player'));
	$self->setPurple(TicTacToePlayer->alloc()->initWithColor_name('purple', 'Purple Player'));

    $self->setWindowController(NSWindowController->alloc->initWithWindowNibName_owner("MainWindow", $self));
    $self->windowController()->window();

	$self->newGame();

    return $self;
}

sub newGame : Selector(newGame:) IBAction {
	my ($self, $sender) = @_;
	$self->{'turn'} = int(rand(2)) ? 'green' : 'purple';
	for my $row (0..2) {
		for my $col (0..2) {
			$self->{'cells'}[$row][$col] = '';
			my $blank = undef;
			$self->buttonMatrix()->cellAtRow_column($row, $col)->setImage($blank);
		}
	}

	my $player = $self->valueForKey(lcfirst $self->{'turn'});
	$self->gameMessage()->setStringValue($player->name() . '\'s turn');
}

sub squareClicked : Selector(squareClicked:) IBAction {
	my ($self, $sender) = @_;
	my $row = $sender->selectedRow();
	my $col = $sender->selectedColumn();
	my $cell = $sender->cellAtRow_column($row, $col);

	if ($self->{'cells'}[$row][$col] ne '' || !defined $self->{'turn'}) {
		CamelBones::NSBeep();
		return;
	}

	my $turn = $self->{'turn'};
	my $player = $self->valueForKey($turn);

	$cell->setImage($player->image());
	$self->{'cells'}[$row][$col] = $turn;

	return if ($self->checkWin());
	return if ($self->checkDraw());

	if ($self->{'turn'} eq 'green') {
		$self->{'turn'} = 'purple';
	} else {
		$self->{'turn'} = 'green';
	}
	$player = $self->valueForKey($self->{'turn'});
	$self->gameMessage()->setStringValue($player->name() . '\'s turn');

}

sub checkWin {
	my ($self) = @_;
	my $cells = $self->{'cells'};
	my $turn = $self->{'turn'};
	my $player = $self->valueForKey($turn);
	
	if (
		($cells->[0][0] eq $turn && $cells->[0][1] eq $turn && $cells->[0][2] eq $turn) ||
		($cells->[1][0] eq $turn && $cells->[1][1] eq $turn && $cells->[1][2] eq $turn) ||
		($cells->[2][0] eq $turn && $cells->[2][1] eq $turn && $cells->[2][2] eq $turn) ||

		($cells->[0][0] eq $turn && $cells->[1][0] eq $turn && $cells->[2][0] eq $turn) ||
		($cells->[0][1] eq $turn && $cells->[1][1] eq $turn && $cells->[2][1] eq $turn) ||
		($cells->[0][2] eq $turn && $cells->[1][2] eq $turn && $cells->[2][2] eq $turn) ||

		($cells->[0][0] eq $turn && $cells->[1][1] eq $turn && $cells->[2][2] eq $turn) ||
		($cells->[0][2] eq $turn && $cells->[1][1] eq $turn && $cells->[2][0] eq $turn)
	) {
		$self->gameMessage()->setStringValue($player->name() . " wins!");
		$self->{'turn'} = undef;
		return 1;
	} else {
		return 0;
	}
}

sub checkDraw {
	my ($self) = @_;
	for my $row (0..2) {
		for my $col (0..2) {
			if ($self->{'cells'}[$row][$col] eq '') {
				return 0;
			}
		}
	}

	$self->gameMessage()->setStringValue("Game is a draw.");
	$self->{'turn'} = undef;
	return 1;
}

1;

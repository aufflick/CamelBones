#
#  TipController.pm
#  ShuX3
#
#  Created by Sherm Pendley on 3/14/05.
#  Copyright 2005 Sherm Pendley. All rights reserved.
#

package TipController;

use CamelBones qw(:All);

use strict;
use warnings;

class TipController {
	'super' => 'NSWindowController',
	'properties' => [ 'tips', 'arrayController', 'tipText' ],
};

sub initWithWindowNibName : Selector(initWithWindowNibName:) ArgTypes(@) ReturnType(@) {
	my ($self, $nibName) = @_;
	$self = $self->SUPER::initWithWindowNibName($nibName);
	$self->setTips([]);

	my $tipsFile = NSBundle->mainBundle()->pathForResource_ofType('Tips', 'txt');
	open(my $fh, '<', $tipsFile) or warn "Could not open $tipsFile: $!" && return;
	while (<$fh>) {
		chomp;
		next if (/^\s*$/);
		push @{$self->tips()}, {'value' => $_};
	}
	close $fh;

	return $self;
}

sub windowDidLoad : Selector(windowDidLoad) {
	my ($self) = @_;
	# my $count = @{$self->tips()};
	my $selected = int(rand() * @{$self->tips()});
	$self->arrayController()->setSelectionIndex($selected);
	$self->arrayController()->rearrangeObjects();
}

1;

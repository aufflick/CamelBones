# CustomView class
package CustomView;

use strict;
use warnings;

use CamelBones qw(:All);

class CustomView {
	'super' => 'NSView',
	'properties' => [ 'circle', 'diamond' ],
};

sub awakeFromNib : Selector(awakeFromNib) {
	my ($self) = @_;
	$self->setCircle(NSImage->imageNamed('circle'));
	$self->setDiamond(NSImage->imageNamed('diamond'));
	$self->setNeedsDisplay(1);
}


sub drawRect : Selector(drawRect:) ArgTypes({NSRect=ffff}) {
	# Wake up! Time to draw.
	my ($self, $rect) = @_;

	# Start with a clear background
	NSColor->clearColor()->set();
	# NSRectFill($self->frame());

	# If window transparency > 0.7, draw the circle. Otherwise the diamond.
	if ($self->window()->alphaValue() > 0.7) {
		$self->circle()->compositeToPoint_operation([0,0], NSCompositeSourceOver);
	} else {
		$self->diamond()->compositeToPoint_operation([0,0], NSCompositeSourceOver);
	}

	# Redraw the shadow
	$self->window()->invalidateShadow();
}

1;

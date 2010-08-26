# CustomWindow class

package CustomWindow;

use strict;
use warnings;

use CamelBones qw(:All);

class CustomWindow {
	'super' => 'NSWindow',
	'properties' => [ 'startLocation' ],
};

sub init : Selector(initWithContentRect:styleMask:backing:defer:)
ArgTypes({NSRect=ffff}IIc) ReturnType(@) {
	my ($self, $contentRect, $aStyle, $bufferingType, $flag) = @_;
	$self = $self->SUPER::initWithContentRect_styleMask_backing_defer(
		$contentRect, NSBorderlessWindowMask, NSBackingStoreBuffered, 0);
	$self->setBackgroundColor(NSColor->clearColor);
	# $self->setLevel(NSStatusWindowLevel);
	$self->setAlphaValue(0.8);
	$self->setOpaque(0);
	$self->setHasShadow(1);
	return $self;
}


# This window doesn't have a border, so we have to implement dragging
# to enable moving it around
sub mouseDragged : Selector(mouseDragged:) ArgTypes(@) {
	my ($self, $event) = @_;

	# Get the frames we're working with
	my $screenFrame = NSScreen->mainScreen()->frame();
	my $windowFrame = $self->frame();

	# Get mouse coordinates
	my $mouseLoc = $self->mouseLocationOutsideOfEventStream();
	my $currentLocation = $self->convertBaseToScreen($mouseLoc);

	my $newOrigin = {};
	$newOrigin->{'x'} = $currentLocation->getX() - $self->startLocation()->getX();
	$newOrigin->{'y'} = $currentLocation->getY() - $self->startLocation()->getY();

	# Don't let the window get dragged under the menu bar
	if ($newOrigin->{'y'} + $windowFrame->getHeight() > 
		$screenFrame->getY() + $screenFrame->getHeight()) {
		$newOrigin->{'y'} = ( $screenFrame->getY() +
							  $screenFrame->getHeight() -
							  $windowFrame->getHeight()
							 );
	}

	# Move the window
	$self->setFrameOrigin($newOrigin);
}

sub mouseDown : Selector(mouseDown:) ArgTypes(@) {
	my ($self, $event) = @_;

	my $windowFrame = $self->frame();
	my $loc = $self->convertBaseToScreen($event->locationInWindow());
	$loc->setX($loc->getX() - $windowFrame->getX());
	$loc->setY($loc->getY() - $windowFrame->getY());
	$self->setStartLocation($loc);
}

1;

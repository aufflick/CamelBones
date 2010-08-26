package MyView;

use CamelBones qw(:All);

use strict;
use warnings;

class MyView {
	'super' => 'NSView',
};

sub drawRect : Selector(drawRect:) ArgTypes({NSRect=ffff}) {
	my ($self, $rect) = @_;
	my $path = NSBezierPath->bezierPathWithOvalInRect($rect);
	NSColor->blueColor()->setFill();
	NSColor->blackColor()->setStroke();
	$path->fill();
	$path->stroke();
}

1;

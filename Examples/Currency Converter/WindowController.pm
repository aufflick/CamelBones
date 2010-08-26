use strict;
use warnings;

package WindowController;

use CamelBones qw(:All);

class WindowController {
	'super' => 'NSObject',
	'properties' => [
					 'rateField', 'dollarField',
					 'totalField', 'window',
					 'windowController',
					 ],
				 };

sub init : Selector(init) ReturnType(@) {
    # **NOT** a typical Perl constructor
    my ($self) = @_;

    $self->setWindowController(NSWindowController->alloc->initWithWindowNibName_owner("ConverterWindow", $self));
    $self->windowController()->window();

    return $self;
}

sub convertButtonClicked : Selector(convertButtonClicked:) ArgTypes(@) ReturnType(v) {
    my ($self, $sender) = @_;

    my $rate = $self->rateField()->floatValue;
    my $amount = $self->dollarField()->floatValue;
    my $total = $rate * $amount;

    $self->totalField()->setFloatValue($total);

    return 1;
}

1;

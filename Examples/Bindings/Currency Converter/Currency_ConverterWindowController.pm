# Currency Converter version 0.1, Copyright 2005 Sherm Pendley.

use strict;
use warnings;

package Currency_ConverterWindowController;

use CamelBones qw(:All);

class Currency_ConverterWindowController {
    'super' => 'NSObject',
    'properties' => [
					 'windowController',
					 'dollarsToConvert', 'exchangeRate', 'amountInOther',
                    ],
};

sub amountInOther : Selector(amountInOther) ReturnType(@) {
	my ($self) = @_;
	return $self->dollarsToConvert() * $self->exchangeRate();
}

sub init : Selector(init) ReturnType(@) {
    my ($self) = @_;
	$self = $self->SUPER::init();

	$self->setDollarsToConvert('0');
	$self->setExchangeRate('0');

    $self->setWindowController(
            NSWindowController->alloc()->initWithWindowNibName_owner("MainWindow", $self));
    $self->windowController()->window();

    return $self;
}

Currency_ConverterWindowController->setKeys_triggerChangeNotificationsForDependentKey(
    ['dollarsToConvert', 'exchangeRate'], 'amountInOther');

1;

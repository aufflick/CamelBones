# Currency Converter version 0.1, Copyright 2005 Sherm Pendley.

use strict;
use warnings;

package Currency_Converter;

use CamelBones qw(:All);

use Currency_ConverterWindowController;

class Currency_Converter {
    'super' => 'NSObject',
    'properties' => [ 'wc' ],
};

sub applicationWillFinishLaunching : Selector(applicationWillFinishLaunching:)
        ArgTypes(@) ReturnType(v) {

    my ($self, $notification) = @_;

    # Create the new controller object
    $self->setWc(Currency_ConverterWindowController->alloc()->init());

    return 1;
}

1;

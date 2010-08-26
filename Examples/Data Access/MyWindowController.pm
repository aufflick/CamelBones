use strict;
use warnings;

package MyWindowController;
use MyDatasource;

use CamelBones qw(:All);

class MyWindowController {
	'super' => 'NSObject',
	'properties' => [
					 'window', 'tableView',
					 'windowController',
					 ],
};

sub init : Selector(init) ArgTypes() ReturnType(@) {
    my ($self) = @_;

    $self->setWindowController(NSWindowController->alloc()->initWithWindowNibName_owner("MainWindow", $self));
    $self->windowController()->window();

    # Create the data source object
    my $ds = MyDatasource->alloc()->init();

    # Make it the data source for the table view object
    $self->tableView()->setDataSource($ds);

    return $self;
}

1;

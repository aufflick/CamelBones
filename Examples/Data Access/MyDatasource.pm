use strict;
use warnings;

package MyDatasource;

use CamelBones qw(:All);

class MyDatasource {
	'super' => 'NSObject'
};

sub init : Selector(init) ReturnType(@) {
    my ($self) = @_;

    # Initialize the "services" list
    $self->{'InternetServices'} = [];
    my $internetServices = $self->{'InternetServices'};

    # Read data from /etc/services
    open SVCS, "/etc/services";
    while (<SVCS>) {
        # Ignore comments and blank lines
        /^\s*\#/ && next;
        /^\s*$/ && next;

        # Get the service name, port, parameters, and comment for each service
        /^([^\s]+)\s*([^\s]+)\s*([^\#]*)\s*(\#.*)/;

        # Skip this row if there's nothing to show
        next unless ($1 || $2 || $3 || $4);

        # Make a new hash to hold the row
        my $row = {
            'service' => $1,
            'port' => $2,
            'param' => $3,
            'comment' => $4,
        };
        $row->{'param'} =~ s/\s*$//;
        $row->{'comment'} =~ s/^\#//;

        # Push the new row on the list
        push @$internetServices, $row;
    }
    close SVCS;

    return $self;
}

sub numberOfRowsInTableView :
		Selector(numberOfRowsInTableView:)
		ArgTypes(@) ReturnType(i)
	{
    my ($self) = @_;
    return scalar @{$self->{'InternetServices'}};
}

sub tableView_objectValueForTableColumn_row :
		Selector(tableView:objectValueForTableColumn:row:)
		ArgTypes(@@i) ReturnType(@)
	{
    my ($self, $tableView, $tableColumn, $row) = @_;
    return $self->{'InternetServices'}->[$row]->{$tableColumn->identifier};
}

sub tableView_setObjectValue_forTableColumn_row :
		Selector(tableView:setObjectValue:forTableColumn:row:)
		ArgTypes(@@@i) ReturnType(v)
	{
    my ($self, $tableView, $newValue, $tableColumn, $row) = @_;
    my $internetServices = $self->{'InternetServices'};
    $self->{'InternetServices'}->[$row]->{$tableColumn->identifier} = $newValue;
}

1;

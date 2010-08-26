use strict;
use warnings;

package MyWindowController;

use CamelBones qw(:All);

class MyWindowController {
	'super' => 'NSObject',
	'properties' => [
					 'window', 'browser', 'nameField',
					 'pathField', 'ownerField', 'windowController',
					 ],
};

sub init : Selector(init) ReturnType(@) {
    my ($self) = @_;

    # Private data
    $self->{'_columns'} = [];

    $self->setWindowController(NSWindowController->alloc->initWithWindowNibName_owner("MainWindow", $self));
    $self->windowController()->window();

    $self->updateLabels();

    return $self;
}

# Private method to update labels to reflect current selection
sub updateLabels {
    my ($self) = @_;
    my $browser = $self->browser();

    my $column = $browser->selectedColumn();
    my $row = $browser->selectedRowInColumn($column);

    my $fileName = $self->{'_columns'}->[$column]->[$row];
    my $pathToSelection = '/' . $browser->pathToColumn($column) . '/' . $fileName;

    if (-e $pathToSelection) {
        $self->nameField()->setStringValue($fileName);

        my ($dev, $inode, $mode, $nlink, $uid, $gid, $rdev,
            $size, $atime, $mtime, $ctime, $blksize, $blocks) = stat($pathToSelection);
        my $uname = getpwuid $uid;
        $self->ownerField()->setStringValue($uname);
    } else {
        $self->nameField()->setStringValue('');
        $self->ownerField()->setStringValue('');
    }
}

# Action method called in response to a click in a browser cell
sub browserSelectionChanged :
		Selector(browserSelectionChanged:)
		IBAction
	{
    my ($self, $browser) = @_;
    my $column = $browser->selectedColumn();
    my $row = $browser->selectedRowInColumn($column);
    my $pathToSelection = $browser->pathToColumn($column) . '/' . $self->{'_columns'}->[$column]->[$row];
    $self->pathField()->setStringValue($pathToSelection);
    $self->updateLabels();
}

# Delegate method called when the PathField text field changed
sub controlTextDidChange :
		Selector(controlTextDidChange:)
		ArgTypes(@) ReturnType(v)
	{
    my ($self, $notification) = @_;
    my $textField = $notification->object;
    my $browser = $self->browser();
    my $textValue = $textField->stringValue();

    $browser->setPath($textValue);

    my $lastColumn = $browser->lastColumn();

    my $columnPath = $browser->pathToColumn($lastColumn);
    my $remainder = $textValue;
    $remainder =~ s|^/?$columnPath/?||;

    my $rowsInLastColumn = scalar(@{$self->{'_columns'}->[$lastColumn]});
    for(my $row=0; $row < $rowsInLastColumn; $row++) {
        if ($self->{'_columns'}->[$lastColumn]->[$row] =~ /^$remainder/) {
            $browser->selectRow_inColumn($row, $lastColumn);
            last;
        }
    }
    $self->updateLabels();
}

# Delegate methods implemented to supply the browser with data
sub browser_numberOfRowsInColumn :
		Selector(browser:numberOfRowsInColumn:)
		ArgTypes(@i) ReturnType(i)
	{
    my ($self, $browser, $column) = @_;
    my ($rows, $path);

    $path = '/' . $browser->pathToColumn($column);

    # Get the number of entries in the _basePath folder
    opendir(DIR, $path);
    @{$self->{'_columns'}->[$column]} = readdir(DIR);
    splice(@{$self->{'_columns'}->[$column]}, 0, 2);
    closedir(DIR);

    $rows = scalar(@{$self->{'_columns'}->[$column]});

    return $rows;
}

sub browser_willDisplayCell_atRow_column :
		Selector(browser:willDisplayCell:atRow:column:)
		ArgTypes(@@ii) ReturnType(v)
	{
    my ($self, $browser, $cell, $row, $column) = @_;
    my $fullPath;

    # Set the cell's string label
    my $stringValue = $self->{'_columns'}->[$column]->[$row];
    $cell->setStringValue($stringValue);

    # Does this cell represent a file, or a folder?
    $fullPath = '/' . $browser->pathToColumn($column) . '/' . $stringValue;
 
    if (-d $fullPath) {
        # It's a folder
        $cell->setLeaf(0);
    } else {
        # It's something else - probably a file
        $cell->setLeaf(1);
    }
}

1;

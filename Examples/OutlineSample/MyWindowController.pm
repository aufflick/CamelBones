use strict;
use warnings;

package MyWindowController;

use CamelBones qw(:All);

class MyWindowController {
	'super' => 'NSObject',
	'properties' => [ 'window', 'outline', 'pathField', 'windowController' ],
};

sub init : Selector(init) ReturnType(@) {
	my ($self) = @_;

    # Private instance vars
    $self->{'_rootPath'} = '/';
    $self->{'_dirCache'} = NSMutableDictionary->alloc->initWithCapacity(5);

    $self->setWindowController(NSWindowController->alloc->initWithWindowNibName_owner("MainWindow", $self));
    $self->windowController()->window();
    
    $self->outline()->setDoubleAction('outlineDoubleClicked:');
    $self->outline()->setTarget($self);

    return $self;
}

# Action method called when a row is double-clicked
sub outlineDoubleClicked :
		Selector(outlineDoubleClicked:)
		IBAction
	{
    my ($self, $sender) = @_;
    my $selectedItem = $sender->itemAtRow($sender->clickedRow());

    my $newRoot = $selectedItem->string;
    $newRoot =~ s|^/+|/|;

    if (-d $newRoot) {
        $self->{'_rootPath'} = $newRoot;
        $self->{'_dirCache'}->removeAllObjects();
        $self->pathField()->setStringValue($newRoot);
        $sender->reloadData();
    }
}

# Delegate method called when the text field changed
sub controlTextDidEndEditing :
		Selector(controlTextDidEndEditing:)
		ArgTypes(@) ReturnType(v)
	{
    my ($self, $notification) = @_;
    my $textField = $notification->object;
    my $outline = $self->outline();

    my $newRoot = $textField->stringValue;
    if (-d $newRoot) {
        $self->{'_rootPath'} = $newRoot;
        $self->{'_dirCache'}->removeAllObjects();
        $outline->reloadData();
    }
}

# Delegate methods for the outline view
sub outlineView_shouldExpandItem :
		Selector(outlineView:shouldExpandItem:)
		ArgTypes(@@) ReturnType(c)
	{
    my ($self, $outline, $item) = @_;

    if (-r $item->string && -x $item->string) {
        return 1;
    } else {
        return 0;
    }
}

sub outlineView_shouldCollapseItem :
		Selector(outlineView:shouldCollapseItem:)
		ArgTypes(@@) ReturnType(c)
	{
    my ($self, $outline, $item) = @_;

    if (-r $item->string && -x $item->string) {
        return 1;
    } else {
        return 0;
    }
}

# Data source methods for the outline view
sub outlineView_child_ofItem :
		Selector(outlineView:child:ofItem:)
		ArgTypes(@i@) ReturnType(@)
	{
    my ($self,$outline, $childnum, $item) = @_;
    my $path = $self->{'_rootPath'};

    if (defined $item) {
        $path = $item->string;
    }

    my $pathKey = NSAttributedString->alloc->initWithString($path);
    my $child = $self->{'_dirCache'}->objectForKey($pathKey)->objectAtIndex($childnum);

    my $retVal = NSMutableAttributedString->alloc->initWithAttributedString($pathKey);
    $retVal->appendAttributedString(NSAttributedString->alloc->initWithString("/"));
    $retVal->appendAttributedString(NSAttributedString->alloc->initWithString($child));
    return $retVal;
}

sub outlineView_isItemExpandable :
		Selector(outlineView:isItemExpandable:)
		ArgTypes(@@) ReturnType(c)
	{
    my ($self, $outline, $item) = @_;

    if (-d $item->string) {
        return 1;
    } else {
        return 0;
    }
}

sub outlineView_numberOfChildrenOfItem :
		Selector(outlineView:numberOfChildrenOfItem:)
		ArgTypes(@@) ReturnType(i)
	{
    my ($self, $outline, $item) = @_;
    my $path = $self->{'_rootPath'};

    if (defined $item) {
        $path = $item->string;
    }

    my $pathKey = NSAttributedString->alloc->initWithString($path);
    my $contents = $self->{'_dirCache'}->objectForKey($pathKey);
    if (!defined $contents) {
        $contents = NSFileManager->defaultManager->directoryContentsAtPath($path);
        if (defined $contents) {
            $self->{'_dirCache'}->setObject_forKey($contents, $pathKey);
            return $contents->count;
        } else {
            return 0;
        }
    } else {
        return $contents->count;
    }
}

sub outlineView_objectValueForTableColumn_byItem :
		Selector(outlineView:objectValueForTableColumn:byItem:)
		ArgTypes(@@@) ReturnType(@)
	{
    my ($self, $outline, $column, $item) = @_;

    my $cell = $column->dataCell;
    my $color = NSColor->blackColor;
    if (-d $item->string) {
        unless (-r $item->string && -x $item->string) {
            $color = NSColor->redColor;
        }
    }
    $cell->setTextColor($color);

    my $columnTitle = $column->headerCell()->stringValue();
    if ($columnTitle eq 'Filename') {
        my $label = $item->string;
        $label =~ s/^\/*//;
        $label =~ s/.*\/([^\/]+)$/$1/;
        return $label;
    } elsif ($columnTitle eq 'Size') {
        my ($dev, $inode, $mode, $nlink, $uid, $gid, $rdev,
            $size, $atime, $mtime, $ctime, $blksize, $blocks) = stat($item->string);
        return "$size";
    } elsif ($columnTitle eq 'Owner') {
        my ($dev, $inode, $mode, $nlink, $uid, $gid, $rdev,
            $size, $atime, $mtime, $ctime, $blksize, $blocks) = stat($item->string);
        return getpwuid($uid);
    } else {
        return undef;
    }
}

1;

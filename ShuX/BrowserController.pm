#
#  BrowserController.pm
#  ShuX3
#
#  Created by Sherm Pendley on 3/13/05.
#  Copyright 2005 Sherm Pendley. All rights reserved.
#

package BrowserController;

use CamelBones qw(:All);
use File::Glob qw(:glob);

use strict;
use warnings;

our $sharedBrowserController;

class BrowserController {
	'super' => 'NSWindowController',
	'properties' => [ 'arrayController', 'browser', 'openButton', 'podPaths',
					  'gotoCombo', 'toolbarGotoCombo', 'gotoGlob', 'gotoHistory',
					  'docSetPopup', 'toolbarDocSetPopup',
					 ],
};

our $podTypeNames = [ 'PODs', 'Core', 'CPAN', 'Vendor' ];
our $podTypes = {
	'PODs' => 'podPath',
	'Core' => 'corePath',
	'CPAN' => 'cpanPath',
	'Vendor' => 'vendorPath'
   };


# Initialization

sub windowDidLoad : Selector(windowDidLoad) {
	my ($self) = @_;

	$self->setGotoGlob([]);
	$self->setGotoHistory([]);

	$self->browser()->setDoubleAction('openSelection:');
	$self->browser()->setTarget($self);

	my $toolbar = NSToolbar->alloc()->initWithIdentifier('browserToolbar');
	$toolbar->setAllowsUserCustomization(1);
	$toolbar->setAutosavesConfiguration(1);
	$toolbar->setDelegate($self);
	$self->window()->setToolbar($toolbar);

	$self->window()->makeFirstResponder($self->gotoCombo());

	my $podPaths = $self->docSetPopup()->selectedItem()->representedObject();
	$self->setPodPaths($podPaths);

	$sharedBrowserController = $self;
}


# Action methods

sub docSetChanged : Selector(docSetChanged:) IBAction {
	my ($self, $sender) = @_;
	my $podPaths = $self->docSetPopup()->selectedItem()->representedObject();
	$self->setPodPaths($podPaths);
	$self->browser()->loadColumnZero();
}

sub openSelection : Selector(openSelection:) IBAction {
	my ($self, $sender) = @_;
	unless ($self->browser()->selectedCell()->isLeaf()) { return; }

	my $filePath = $self->selectionToFilePath($self->browser());

	if ($filePath) {
		my $dc = NSDocumentController->sharedDocumentController();
		my $doc = $dc->openDocumentWithContentsOfFile_display($filePath, 1);
		$doc->setDocSetName($self->docSetPopup()->titleOfSelectedItem());
	}
}

sub selectionToFilePath : Selector(selectionToFilePath:) ArgTypes(@) ReturnType(@) {
	my ($self, $browser) = @_;

	my $filePath = $browser->path();
	unless ($filePath) { return undef; }

	$filePath =~ s%^/(\w+)/%%;

	my $type = $browser->pathToColumn(1);
	$type =~ s%^/%%;

	my $typePath = $self->podPaths()->valueForKey($podTypes->{$type});
	my $arch = $self->podPaths()->valueForKey('arch');

	foreach ( "$typePath/$filePath", "$typePath/$arch/$filePath" ) {
		-f $_ && return $_;
	}

	return undef;
}

# Data source methods

sub createRows : Selector(browser:createRowsForColumn:inMatrix:) ArgTypes(@i@) {
	my ($self, $browser, $column, $matrix) = @_;

	# For column 0, rows are hard-coded
	if ($column == 0) {
		foreach ( @$podTypeNames ) {
			my $cell = $matrix->prototype()->copy()->autorelease();
			$cell->setTitle($_);
			$cell->setLeaf(0);
			$matrix->addRowWithCells([$cell]);
		}
	} else {
		my $type = $browser->pathToColumn(1);
		$type =~ s%^/%%;
		my $typePath = $self->podPaths()->valueForKey($podTypes->{$type});
		my $arch = $self->podPaths()->valueForKey('arch');

		# Base directory, no arch
		my $dir = $browser->pathToColumn($column);
		$dir =~ s%^/$type%%;
		$dir =~ s%^/%%;

		# Begin with an empty column
		my $column = [];

		foreach ("$typePath/$dir", "$typePath/$arch/$dir") {
			next unless (-d $_);
			unless (opendir(DIR, $_)) { warn "Could not open $_: $!"; next; }
			while (my $filename = readdir(DIR)) {
				next if ($filename eq 'auto' || $filename eq $arch ||
						 $filename =~ /^\./ || $filename eq 'CORE');
				if (-d "$_/$filename") {
					my $cell = $matrix->prototype()->copy()->autorelease();
					$cell->setTitle($filename);
					$cell->setLeaf(0);
					push @$column, $cell;
					next;
				} else {
					my $cell = $matrix->prototype()->copy()->autorelease();
					$cell->setTitle($filename);
					$cell->setLeaf(1);
					push @$column, $cell;
				}
			}
			closedir(DIR);
		}

		my %seen;
	    map {
			$seen{$_->title()}++ || $matrix->addRowWithCells([$_]);
		}
		sort {
			lc($a->title()) cmp lc($b->title());
		} @$column;
	}

	return;
}

sub browserSelectionChanged : Selector(browserSelectionChanged:) IBAction {
	my ($self, $sender) = @_;
	if ($self->selectionToFilePath($sender)) {
		$self->openButton()->setEnabled(1);
	} else {
		$self->openButton()->setEnabled(0);
	}
}

# Toolbar delegate methods
sub toolbarItemForID : Selector(toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:) ArgTypes(@@c) ReturnType(@) {
	my ($self, $toolbar, $identifier, $insert) = @_;
	my $item = undef;
	if ($identifier eq 'docSetPopup') {
		$item = NSToolbarItem->alloc()->initWithItemIdentifier($identifier)->autorelease();
		$item->setView($self->toolbarDocSetPopup());
		$item->setLabel('Document Set');
		$item->setMinSize({'height'=>32, 'width'=>100});
		$item->setMaxSize({'height'=>32, 'width'=>5000});
	} elsif ($identifier eq 'gotoCombo') {
		$item = NSToolbarItem->alloc()->initWithItemIdentifier($identifier)->autorelease();
		$item->setView($self->toolbarGotoCombo());
		$item->setLabel('Enter POD name');
		$item->setMinSize({'height'=>32, 'width'=>100});
		$item->setMaxSize({'height'=>32, 'width'=>5000});
	}
	return $item;
}

sub toolbarAllowedIDs : Selector(toolbarAllowedItemIdentifiers:) ArgTypes(@) ReturnType(@) {
	my ($self, $toolbar) = @_;
	return [ 'gotoCombo', 'docSetPopup', ];
}

sub toolbarDefaultIDs : Selector(toolbarDefaultItemIdentifiers:) ArgTypes(@) ReturnType(@) {
	my ($self, $toolbar) = @_;
	return [ 'gotoCombo', 'docSetPopup', ];
}


# Toolbar combo box methods
sub numberOfItemsInComboBox : Selector(numberOfItemsInComboBox:) ArgTypes(@) ReturnType(i) {
	my ($self, $comboBox) = @_;
	if ($self->gotoGlob() && @{$self->gotoGlob()}) { return scalar(@{$self->gotoGlob()}); }
	if ($self->gotoHistory() && @{$self->gotoHistory()}) { return scalar(@{$self->gotoHistory()}); }
	return 0;
}


sub comboBoxObjectValue : Selector(comboBox:objectValueForItemAtIndex:) ArgTypes(@i) ReturnType(@) {
	my ($self, $comboBox, $index) = @_;
	my $value = undef;

	if (@{$self->gotoGlob()}) {
		$value = $self->gotoGlob()->[$index];

		foreach my $typeName (@$podTypeNames) {
			my $type = $podTypes->{$typeName};
			my $typePath = $self->podPaths()->valueForKey($type);
			my $arch = $self->podPaths()->valueForKey('arch');
			foreach my $searchPath ("$typePath/$arch", $typePath) {
				if ($searchPath) { $value =~ s/^$searchPath/$typeName/; }
			}
		}

		$value =~ s/\//::/g;

	} elsif (@{$self->gotoHistory()}) {
		$value = $self->gotoHistory()->[$index];
	}

	return $value;
}

sub controlTextDidEndEditing : Selector(controlTextDidEndEditing:) ArgTypes(@) {
	my ($self, $notification) = @_;
}

sub comboBoxWillDismiss : Selector(comboBoxWillDismiss:) ArgTypes(@) {
	my ($self, $notification) = @_;
	my $comboBox = $notification->object();
	my $index = $comboBox->indexOfSelectedItem();
	my $path = '';

	if (@{$self->gotoGlob()}) {
		$path = $self->gotoGlob()->[$index];
	}

	foreach my $typeName (@$podTypeNames) {
		my $type = $podTypes->{$typeName};
		my $typePath = $self->podPaths()->valueForKey($type);
		my $arch = $self->podPaths()->valueForKey('arch');
		foreach my $searchPath ("$typePath/$arch", $typePath) {
			if ($searchPath) {
				$path =~ s/^$searchPath/$typeName/;
			}
		}
	}

	$self->browser()->setPath('/'.$path);
	$self->browserSelectionChanged($self->browser());
	$self->window()->makeFirstResponder($self->browser());
	$comboBox->setStringValue('');
}

sub comboBoxWillPopUp : Selector(comboBoxWillPopUp:) ArgTypes(@) {
	my ($self, $notification) = @_;
	my $comboBox = $notification->object();

	if ($comboBox->stringValue() ne '') {
		my $text = $notification->object()->stringValue();
		$text =~ s/::/\//g;
		$text .= '*';

		my $list = [];

		foreach my $typeName (@$podTypeNames) {
			my $type = $podTypes->{$typeName};
			my $typePath = $self->podPaths()->valueForKey($type);
			my $arch = $self->podPaths()->valueForKey('arch');
			foreach my $searchPath ($typePath, "$typePath/$arch") {
				my @glob = grep { -f $_ } bsd_glob("$searchPath/$text");
				if (@glob) {
					push @$list, @glob;
				}
			}
		}

		$self->setGotoGlob($list);
	} else {
		$self->setGotoGlob([]);
	}

	$comboBox->reloadData();
}

1;

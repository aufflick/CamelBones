#
#  PrefController.pm
#  ShuX3
#
#  Created by Sherm Pendley on 3/12/05.
#  Copyright 2005-2006 Sherm Pendley. All rights reserved.
#

package PrefController;

use CamelBones qw(:All);

use strict;
use warnings;

use constant ChoosingPerl => 0;
use constant ChoosingStylesheet => 1;

our @panes = (
                { 'name' => 'Document Sets', 'pane' => 'prefstab.docsets' },
                { 'name' => 'View Defaults', 'pane' => 'prefstab.viewdefaults' },
                { 'name' => 'Stylesheet', 'pane' => 'prefstab.stylesheet' },
                { 'name' => 'App Startup', 'pane' => 'prefstab.startup' },
                { 'name' => 'Cache', 'pane' => 'prefstab.cache' },
            );

class PrefController {
	'super' => 'NSWindowController',
	'properties' => [ 'arrayController', 'docSetPopup', 'deleteButton', 
					  'nameField', 'podField', 'coreField', 'cpanField',
					  'vendorField', 'archField',
					  'accessoryView', 'typePopup', 'openPanel',
					  'tabView', 'panesList', 'webPref',
					  'canChooseStylesheet',
					 ],
};

sub windowDidLoad : Selector(windowDidLoad) {
    my ($self) = @_;

    $self->setWebPref(WebPreferences->standardPreferences());
    $self->webPref()->setAutosaves(1);
    $self->webPref()->setUserStyleSheetEnabled(1);
}

sub addDocSet : Selector(addDocSet:) IBAction {
	my ($self, $sender) = @_;
	my $arrayController = $self->arrayController();
	my $index = $arrayController->selectionIndex();
	$arrayController->insert($sender);
	$arrayController->setSelectionIndex($index);
	$self->prepFields();
	$self->window()->makeFirstResponder($self->nameField());
}

sub choosePerl : Selector(choosePerl:) IBAction {
	my ($self, $sender) = @_;

	my $panel = NSOpenPanel->openPanel();
	$panel->setMessage('Choose a perl. (Cmd-shift-G to type a path.)');
	$panel->setCanChooseFiles(1);
	$panel->setCanChooseDirectories(0);
	$panel->setAllowsMultipleSelection(0);
	$panel->setDelegate($self);
	$panel->setAccessoryView($self->accessoryView());
	$self->setOpenPanel($panel);
	my $undef = undef;
	$panel->beginSheetForDirectory_file_types_modalForWindow_modalDelegate_didEndSelector_contextInfo(
		$undef,
		$undef,
		$undef,
		$self->window(),
		$self,
		'choosePerlDidEnd:returnCode:contextInfo:',
		ChoosingPerl
	   );
}

sub typePopupChanged : Selector(typePopupChanged:) IBAction {
	my ($self, $sender) = @_;
	$self->openPanel()->validateVisibleColumns();
}

sub panelShouldShowFilename : Selector(panel:shouldShowFilename:) ArgTypes(@@) ReturnType(c) {
	my ($self, $panel, $filename) = @_;

    if ($panel->accessoryView()) {
        my $tag = $self->typePopup()->selectedItem()->tag();
        if ($tag == 2) { return 1; }
        if ($tag == 1 && $filename =~ m%/perl[^/]*$% ) { return 1; }
        if ($tag == 0 && $filename =~ m%/perl$% ) { return 1; }
        return 0;
    }
    
    return 1;
}

sub choosePerlDidEnd : Selector(choosePerlDidEnd:returnCode:contextInfo:)
        ArgTypes(@i^v) {
	my ($self, $panel, $code, $context) = @_;
            NSLog($self);
	if ($code) {
		my $dir = $panel->directory();
		my $perl = $panel->filename();
		my $version = `$perl -MConfig -e 'print \$Config{version}'`;
		my $config = {
			'name' => "Perl $version in $dir",
			'podPath' => `$perl -MConfig -e 'print \$Config{privlib}'`.'/pods' || '',
			'corePath' => `$perl -MConfig -e 'print \$Config{privlib}'` || '',
			'cpanPath' => `$perl -MConfig -e 'print \$Config{sitelib}'` || '',
			'vendorPath' => `$perl -MConfig -e 'print \$Config{vendorlib}'` || '',
			'arch' => `$perl -MConfig -e 'print \$Config{archname}'`
		   };
		$self->arrayController()->addObject($config);
		$self->arrayController()->setSelectedObjects([$config]);
		$self->prepFields();
	}
	return;
}

sub chooseStylesheet : Selector(chooseStylesheet:) IBAction {
	my ($self, $sender) = @_;

	my $panel = NSOpenPanel->openPanel();
	$panel->setMessage('Choose a CSS style sheet');
	$panel->setCanChooseFiles(1);
	$panel->setCanChooseDirectories(0);
	$panel->setAllowsMultipleSelection(0);
	$panel->setDelegate($self);
	my $undef = undef;
	$panel->setAccessoryView($undef);
	$self->setOpenPanel($panel);
	$panel->beginSheetForDirectory_file_types_modalForWindow_modalDelegate_didEndSelector_contextInfo(
		$undef,
		$undef,
		$undef,
		$self->window(),
		$self,
		'chooseStylesheetDidEnd:returnCode:contextInfo:',
		ChoosingStylesheet
	   );
}

sub chooseStylesheetDidEnd : Selector(chooseStylesheetDidEnd:returnCode:contextInfo:)
        ArgTypes(@i^v) {
	my ($self, $panel, $code, $context) = @_;
	if ($code) {
        my $stylesheet = $panel->filename();
        $self->webPref()->setUserStyleSheetLocation(NSURL->URLWithString($stylesheet));
        NSUserDefaults->standardUserDefaults()->setObject_forKey($stylesheet, 'Stylesheet');
	}
	return;
}

sub deleteDocSet : Selector(deleteDocSet:) IBAction {
	my ($self, $sender) = @_;
	my $title = $self->docSetPopup()->titleOfSelectedItem();
	if (($title && $title eq '* Default *') || $self->docSetPopup()->numberOfItems() <= 1) {
		# NSBeep();
	} else {
		$self->arrayController()->remove($sender);
		$self->arrayController()->setSelectionIndex(0);
	}
	$self->prepFields();
}

sub selectDocSet : Selector(selectDocSet:) IBAction {
	my ($self, $sender) = @_;
	$self->arrayController()->setSelectionIndex($sender->indexOfSelectedItem());
	$self->prepFields();
}

sub prepFields : Selector(prepFields) {
	my ($self) = @_;
	my $en = ($self->docSetPopup()->titleOfSelectedItem() ne '* Default *') ? 1 : 0;

	$self->deleteButton()->setEnabled($en);
	$self->nameField()->setEnabled($en);
	$self->podField()->setEnabled($en);
	$self->coreField()->setEnabled($en);
	$self->cpanField()->setEnabled($en);
	$self->vendorField()->setEnabled($en);
	$self->archField()->setEnabled($en);

	if ($en) {
		$self->window()->makeFirstResponder($self->podField());
	}
}

# Data source methods for the panes table view
sub numberOfRowsInTableView :
		Selector(numberOfRowsInTableView:)
		ArgTypes(@) ReturnType(i)
	{
    my ($self, $table) = @_;
    
    return scalar @panes;
}

sub tableView_objectValueForTableColumn_row :
		Selector(tableView:objectValueForTableColumn:row:)
		ArgTypes(@@i) ReturnType(@)
	{
    my ($self, $table, $column, $row) = @_;

    return $panes[$row]->{'name'};
}

# Respond to changes in table view selection by selecting the corresponding pane
sub tableViewSelectionDidChange :
        Selector(tableViewSelectionDidChange:)
        ArgTypes(@)
    {
    my ($self, $notification) = @_;
    my $index = $self->panesList()->selectedRow();
    $self->tabView()->selectTabViewItemWithIdentifier($panes[$index]->{'pane'});
}


# Do this at compile-time
our $transformer = MutableTransformer->alloc()->init();
NSValueTransformer->setValueTransformer_forName($transformer, 'MutableTransformer');

1;

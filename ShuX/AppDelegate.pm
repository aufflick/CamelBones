#
#  AppDelegate.pm
#  ShuX3
#
#  Created by Sherm Pendley on 3/12/05.
#  Copyright 2005-2006 Sherm Pendley. All rights reserved.
#

package AppDelegate;

use CamelBones qw(:All);
use Config;

use BrowserController;
use PrefController;

use strict;
use warnings;

our $sharedAppDelegate;

class AppDelegate {
	'super' => 'NSObject',
	'properties' => [ 'pc', 'bc' ],
};

sub applicationWillFinishLaunching : Selector(applicationWillFinishLaunching:) ArgTypes(@) {
	my ($self, $notification) = @_;

	# Register the default preferences
	my $defaults = NSUserDefaults->standardUserDefaults();
	$defaults->addSuiteNamed('org.dot-app.ShuX3');
	my $appDefaults = {
		'docSets' => [
			{ 'name' => '* Default *',
			  'podPath' => $Config{'privlib'}.'/pods',
			  'corePath' => $Config{'privlib'},
			  'cpanPath' => $Config{'sitelib'},
			  'vendorPath' => $Config{'vendorlib'},
			  'arch' => $Config{'archname'}
			 },
		   ],
		'AppleShowAllFiles' => 1,
		'ClearCacheOnExit' => 0,
		'ShowTip' => 1,
		'ShowIntro' => 1,
		'CacheDir' => NSHomeDirectory() . '/Library/Caches/ShuX',
		'StylesheetType' => 0,
    };
	$defaults->registerDefaults($appDefaults);

	$sharedAppDelegate = $self;
}

sub applicationDidFinishLaunching : Selector(applicationDidFinishLaunching:) ArgTypes(@) {
	my ($self, $notification) = @_;

	my $bc = BrowserController->alloc()->initWithWindowNibName('Browser');
	$bc->setWindowFrameAutosaveName('BrowserPanel');
	$bc->window();
	$bc->showWindow($self);
	$self->setBc($bc);

	my $defaults = NSUserDefaults->standardUserDefaults();
	if ($defaults->boolForKey('ShowIntro')) {
		my $intro = NSBundle->mainBundle()->pathForResource_ofType('intro', 'pod');
		NSDocumentController->sharedDocumentController()->openDocumentWithContentsOfFile_display($intro, 1);
	}

	$notification->object()->setServicesProvider($self);
    my $stylesheet = $defaults->stringForKey('Stylesheet');
    my $stylesheetType = $defaults->integerForKey('StylesheetType');
    if ($stylesheetType != 0 && defined $stylesheet && -f $stylesheet) {
        WebPreferences->standardPreferences()->setUserStyleSheetLocation(NSURL->URLWithString($stylesheet));
    }
}

sub applicationWillTerminate : Selector(applicationWillTerminate:) ArgTypes(@) {
	my ($self, $notification) = @_;
	my $defaults = NSUserDefaults->standardUserDefaults();
	if ($defaults->boolForKey('ClearCacheOnExit')) {
		$self->clearHTMLCache($notification);
	}
}

sub toggleDocSetWindow : Selector(toggleDocSetWindow:) IBAction {
	my ($self, $sender) = @_;
	my $bc = $self->bc()->window();
	if ($bc->isVisible()) {
		$bc->orderOut($self);
		$sender->setState(0);
	} else {
		$bc->orderFront($self);
		$sender->setState(1);
	}
}


sub showPreferences : Selector(showPreferences:) IBAction {
	my ($self, $sender) = @_;
	unless ($self->pc()) {
		$self->setPc(PrefController->alloc()->initWithWindowNibName('Preferences'));
		$self->pc()->window();
	}
	$self->pc()->showWindow($self);
}

sub openDonate : Selector(openDonate:) IBAction {
	my ($self, $sender) = @_;
	my $url = NSURL->URLWithString('https://sourceforge.net/donate/index.php?group_id=48040');
	NSWorkspace->sharedWorkspace()->openURL($url);
}

sub openIntro : Selector(openIntro:) IBAction {
	my ($self, $sender) = @_;
	my $intro = NSBundle->mainBundle()->pathForResource_ofType('intro', 'pod');
	NSDocumentController->sharedDocumentController()->openDocumentWithContentsOfFile_display($intro, 1);
}

sub clearHTMLCache : Selector(clearHTMLCache:) IBAction {
	my ($self, $sender) = @_;
	my $cacheDir = NSUserDefaults->standardUserDefaults()->stringForKey('CacheDir');
	system("rm -rv $cacheDir");
}

1;

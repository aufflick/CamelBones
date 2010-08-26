# ShuX version 3.0, Copyright 2005 Sherm Pendley.

use strict;
use warnings;

use CamelBones qw(:All);

use MyDocument;
use AppDelegate;

# Get a reference to the shared NSApplication object
our $nsApp = NSApplication->sharedApplication;

# Load the main menu Nib, making the NSApplication object its owner
NSBundle->loadNibNamed_owner("MainMenu", $nsApp);

# Start the NSApplication object's run loop
$nsApp->run;

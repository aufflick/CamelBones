#
#   main.m
#   ÇPROJECTNAMEÈ
#
#   Created by ÇFULLUSERNAMEÈ on ÇDATEÈ.
#   Copyright ÇYEARÈ ÇORGANIZATIONNAMEÈ. All rights reserved.
#

use strict;
use warnings;

use CamelBones qw(:All);
use MyDocument;

# Get a reference to the shared NSApplication object
our $nsApp = NSApplication->sharedApplication();

# Load the main menu Nib, making the NSApplication object its owner
NSBundle->loadNibNamed_owner("MainMenu", $nsApp);

# Start the NSApplication object's run loop
$nsApp->run;

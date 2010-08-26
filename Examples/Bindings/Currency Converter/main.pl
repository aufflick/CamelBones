# Currency Converter version 0.1, Copyright 2005 Sherm Pendley.

use strict;
use warnings;

use CamelBones qw(:All);

use Currency_Converter;

# Get a reference to the shared NSApplication object
our $nsApp = NSApplication->sharedApplication;

# Load the main menu Nib, making the NSApplication object its owner
NSBundle->loadNibNamed_owner("MainMenu", $nsApp);

# Create the top-level controller object
our $app = new Currency_Converter;

# Make the controller the delegate of the application
$nsApp->setDelegate($app);

# Start the NSApplication object's run loop
$nsApp->run;

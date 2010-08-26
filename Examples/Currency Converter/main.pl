use strict;
use warnings;

use CamelBones qw(:All);

use MyController;

# Get a reference to the shared NSApplication object
our $nsApp = NSApplication->sharedApplication;

# Load the main menu Nib, making the NSApplication object its owner
NSBundle->loadNibNamed_owner("MainMenu", $nsApp);

# Create the top-level controller object
our $controller = MyController->alloc()->init();

# Make the controller the delegate of the application
$nsApp->setDelegate($controller);

# Start the NSApplication object's run loop
$nsApp->run;

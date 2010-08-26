package Class::Autouse::Parent;

# The package Class::Autouse::Parent can be inherited from to implement
# a parent class. That is, a class who's primary job is to load a series
# classes below it.

use strict;
use Class::Autouse ();

use vars qw{$VERSION};
BEGIN {
	$VERSION = '1.27';
}

# Maintain flags for "is the class in the process of loading"
my %LOADING = ();

sub import {
	# If the parent value is ourselves, we were just
	# 'use'd, not 'base'd.
	my $parent = $_[0] ne __PACKAGE__ ? shift : return 1;

	# Don't load if already loading
	return 1 if $LOADING{$parent};

	# Autoload in our children
	$LOADING{parent} = 1;
	Class::Autouse->autouse_recursive( $parent );
	delete $LOADING{parent};

	1;
}

1;

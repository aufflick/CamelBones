# -*- Mode: cperl -*-

use Test;
BEGIN { plan tests => 11; }

package PerlObject;
use CamelBones qw(:All);
class 'PerlObject';

sub sayOK : Selector(sayOK:) ArgTypes(i) {
    my ($this, $arg) = @_;
    Test::ok($arg);
}

sub initNewPerlObject : Selector(initNewPerlObject) ArgTypes() ReturnType(@) {
    my $self = shift;
    $self = $self->SUPER::init();
    return $self;
}

package PerlObjectToo;
use CamelBones qw(:All);
class PerlObjectToo {'super' => 'PerlObject'} ;


package PerlObjectThree;
use CamelBones qw(:All);
class PerlObjectThree {
    'super' => 'PerlObject',
    'properties' => [ 'foo', 'bar', 'baz' ],
};

package PerlObjectFour;
use CamelBones qw(:All);
class PerlObjectFour {
    'super' => 'PerlObject',
    'properties' => {
        'foo' => 'NSObject',
        'bar' => undef,
    },
};

package main;

my $perlObject = PerlObject->alloc()->initNewPerlObject();
$perlObject->sayOK(1);

# Check that Perl method is correctly registered
if ($perlObject->respondsToSelector('sayOK:')) {
    $perlObject->sayOK(2);
} else {
    $perlObject->sayOK(0);
}

# Verify that bogus method returns false
if ($perlObject->respondsToSelector('bogus:')) {
    $perlObject->sayOK(0);
} else {
    $perlObject->sayOK(3);
}


# Check for inheritance
$perlObject = PerlObjectToo->alloc()->initNewPerlObject();
$perlObject->sayOK(4);



# Test properties
$perlObject = PerlObjectThree->alloc()->initNewPerlObject();
$perlObject->sayOK(5);


# Do accessors exist?
if ($perlObject->respondsToSelector('foo')) {
    $perlObject->sayOK(6);
} else {
    $perlObject->sayOK(0);
}
if ($perlObject->respondsToSelector('setBar:')) {
    $perlObject->sayOK(7);
} else {
    $perlObject->sayOK(0);
}


# Test properties as hash ref
$perlObject = PerlObjectFour->alloc()->initNewPerlObject();
$perlObject->sayOK(8);


# Do accessors exist?
if ($perlObject->respondsToSelector('foo')) {
    $perlObject->sayOK(9);
} else {
    $perlObject->sayOK(0);
}
if ($perlObject->respondsToSelector('setBar:')) {
    $perlObject->sayOK(10);
} else {
    $perlObject->sayOK(0);
}


# Try to set/get a property
$perlObject->setValue_forKey('Hello', 'foo');
if ($perlObject->valueForKey('foo') eq 'Hello') {
	$perlObject->sayOK(11);
} else {
	$perlObject->sayOK(0);
}

1;

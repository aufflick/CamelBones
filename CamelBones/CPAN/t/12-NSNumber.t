use Test;

BEGIN { plan tests => 21 };
use CamelBones qw(:All);

# Can we create a number with a char?
my $testNumber = NSNumber->numberWithChar(5);
if (defined $testNumber) {
    ok(1);
} else {
    ok(0);
}

# It should be able to return a bool, a char, a short, and a long
if ($testNumber->boolValue()) {
    ok(2);
} else {
    ok(0);
}

if ($testNumber->charValue() == 5) {
    ok(3);
} else {
    ok(0);
}

if ($testNumber->shortValue() == 5) {
    ok(4);
} else {
    ok(0);
}

if ($testNumber->longValue() == 5) {
    ok(5);
} else {
    ok(0);
}

# It should also be able to return a reasonable float or long
if ( abs ($testNumber->floatValue() - 5.0) < 0.00001 ) {
    ok(6);
} else {
    ok(0);
}

if ( abs ($testNumber->doubleValue() - 5.0) < 0.00001 ) {
    ok(7);
} else {
    ok(0);
}

# Can we create a number with a short?
$testNumber = NSNumber->numberWithShort(5);
if (defined $testNumber) {
    ok(8);
} else {
    ok(0);
}

# It should be able to return a bool, a char, a short, and a long
if ($testNumber->boolValue()) {
    ok(9);
} else {
    ok(0);
}

if ($testNumber->charValue() == 5) {
    ok(10);
} else {
    ok(0);
}

if ($testNumber->shortValue() == 5) {
    ok(11);
} else {
    ok(0);
}

if ($testNumber->longValue() == 5) {
    ok(12);
} else {
    ok(0);
}

# It should also be able to return a reasonable float or long
if ( abs ($testNumber->floatValue() - 5.0) < 0.00001 ) {
    ok(13);
} else {
    ok(0);
}

if ( abs ($testNumber->doubleValue() - 5.0) < 0.00001 ) {
    ok(14);
} else {
    ok(0);
}

# Can we create a number with a long?
$testNumber = NSNumber->numberWithLong(5);
if (defined $testNumber) {
    ok(15);
} else {
    ok(0);
}

# It should be able to return a bool, a char, a short, and a long
if ($testNumber->boolValue()) {
    ok(16);
} else {
    ok(0);
}

if ($testNumber->charValue() == 5) {
    ok(17);
} else {
    ok(0);
}

if ($testNumber->shortValue() == 5) {
    ok(18);
} else {
    ok(0);
}

if ($testNumber->longValue() == 5) {
    ok(19);
} else {
    ok(0);
}

# It should also be able to return a reasonable float or long
if ( abs ($testNumber->floatValue() - 5.0) < 0.00001 ) {
    ok(20);
} else {
    ok(0);
}

if ( abs ($testNumber->doubleValue() - 5.0) < 0.00001 ) {
    ok(21);
} else {
    ok(0);
}

1;

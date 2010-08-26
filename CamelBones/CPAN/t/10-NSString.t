use Test;

BEGIN { plan tests => 4 };
use CamelBones qw(:All);

# Can we create a string?
my $testString = NSString->stringWithString("Hello, world!");
if (defined $testString) {
    ok(1);
} else {
    ok(0);
}

# It should be tied to a Perl string
if ($testString eq 'Hello, world!') {
    ok(2);
} else {
    ok(0);
}

# Create one as an object
$CamelBones::ReturnStringsAsObjects = 1;
my $stringObject = NSString->stringWithString("Hello, world!");
if (defined $stringObject) {
    ok(3);
} else {
    ok(0);
}

# Compare what it returns to a constant
if ($stringObject->cString() eq 'Hello, world!') {
    ok(4);
} else {
    ok(0);
}

1;

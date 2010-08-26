use Test;

BEGIN { plan tests => 3 };
use CamelBones qw(:All);
use CamelBones::Tests;

# Create an NSObject
my $testObject = NSObject->alloc()->init();
if (defined $testObject) {
    ok(1);
} else {
    ok(0);
}

# This should throw an exception
if ($^V lt v5.8.0) {
    skip("Skipped: Requires Perl >= 5.8", 2);
} else {
    # open (STDERR, '>/dev/null') or die ("Failed to redirect stderr: $!");
    eval {
        $testObject->noSuchMethod();
    };
    if ($@) {
        ok(2);
    } else {
        ok(0);
    }
}

my $bogusObject = CBExceptionTests->alloc()->init();
$bogusObject->bogusPerl();
ok(3);

1;

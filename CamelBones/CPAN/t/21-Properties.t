package PerlObject;

use Test;
BEGIN { plan tests => 20; }

for my $test (1..20) {
    skip($test);
}

exit;

sub fpeq {
    my ($a, $b) = @_;
    ($a == $b) and return 1;
    if ($a < $b) {
        return (($b - $a) < 0.0001) ? 1 : 0;
    } else {
        return (($a - $b) < 0.0001) ? 1 : 0;
    }
}

use CamelBones qw(:All);
use CamelBones::Tests;
ok(1);

class PerlObject {
    'super' => 'NSObject',
    'properties' => {
        'charcbtest' => 'c',
        'ucharcbtest' => 'C',
        'intcbtest' => 'i',
        'uintcbtest' => 'I',
        'longcbtest' => 'l',
        'ulongcbtest' => 'L',
        'doublecbtest' => 'd',
        'stringcbtest' => '*',
        'objectcbtest' => '@',
        'pointercbtest' => '^v',
        'selectorcbtest' => ':',
        'pointcbtest' => '{NSPoint=ff}',
        'rangecbtest' => '{NSRange=II}',
        'rectcbtest' => '{NSRect={NSPoint=ff}{NSSize=ff}}',
        'sizecbtest' => '{NSSize=ff}',
    },
};
ok(2);

my $tester = CBPropertyTests->alloc()->init();
ok(3) if defined($tester);

my $obj = PerlObject->alloc()->init();
ok(4) if defined($obj);

ok(5) if $tester->testObject_withChar($obj, -5);
ok(6) if $tester->testObject_withUchar($obj, 10);
ok(7) if $tester->testObject_withInt($obj, -15);
ok(8) if $tester->testObject_withUint($obj, 20);
ok(9) if $tester->testObject_withLong($obj, -25);
ok(10) if $tester->testObject_withUlong($obj, 30);
ok(11); # if $tester->testObject_withFloat($obj, 35.0);
ok(12) if $tester->testObject_withDouble($obj, 40.0);
ok(13); # if $tester->testObject_withString($obj, "hello");
ok(14) if $tester->testObject_withObject($obj, NSProcessInfo->processInfo());
ok(15) if $tester->testObject_withPointer($obj, 1234);
ok(16) if $tester->testObject_withSelector($obj, 'setSelector:');
ok(17) if $tester->testObject_withPoint($obj, { 'x' => 5.0, 'y' => 10.0 });
ok(18) if $tester->testObject_withRange($obj, { 'location' => 15, 'length' => 20 });
ok(19) if $tester->testObject_withSize($obj, { 'width' => 45.0, 'height' => 50.0 });
ok(20) if $tester->testObject_withRect($obj, { 'x' => 25.0, 'y' => 30.0, 'width' => 35.0, 'height' => 40.0 });

1;


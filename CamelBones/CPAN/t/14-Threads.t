use Config;
use Test;

BEGIN { plan tests => 2 };

use CamelBones qw(:All);
use CamelBones::Tests;

if ($Config{archname} =~ /thread/) {
    my $testObject = CBThreadTests->alloc()->initWithDictionary({'foo'=>'bar', 'baz'=>'boom'});
    ok(1);
    
    $testObject->runTests();
    ok(2);
} else {
    skip("Skipping Requires threaded Perl", 1);
    skip("Skipping Requires threaded Perl", 2);
}

1;

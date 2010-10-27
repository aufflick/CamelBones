use Test;

BEGIN { plan tests => 4 };
use CamelBones qw(:All);

# Can we create an dictionary of NSStrings?
my $testDictionary = NSDictionary->dictionaryWithDictionary({'a' => 'foo','b' => 'bar'});
if (defined $testDictionary) {
    ok(1);
} else {
    ok(0);
}

# Can we join() them?
if ($testDictionary->allValues()->componentsJoinedByString('') eq 'foobar') {
    ok(2);
} else {
    ok (0);
}

# Can we create an empty array?
$testDictionary = NSDictionary->dictionaryWithDictionary({});
if (defined $testDictionary) {
    ok(3);
} else {
    ok(0);
}

# Can we create a dictionary of empty arrays?
$testDictionary = NSDictionary->dictionaryWithDictionary({ 'foo' => [], 'bar' => []});
if (defined $testDictionary) {
    ok(4);
} else {
    ok(0);
}

use Test;

BEGIN { plan tests => 2 };
use CamelBones qw(:All);

# Can we create an array of NSStrings?
my $testArray = NSArray->arrayWithArray(['a','b','c']);
if (defined $testArray) {
    ok(1);
} else {
    ok(0);
}


# Can we join() them?
if ($testArray->componentsJoinedByString('') eq 'abc') {
    ok(2);
} else {
    ok (0);
}


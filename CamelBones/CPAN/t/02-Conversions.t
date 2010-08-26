use Test;
BEGIN { plan tests => 5 };

use CamelBones qw(:All);
ok(1);

use CamelBones::Tests;
ok(2);

$CamelBones::ShowUnhandledTypeWarnings = 1;

my $undef = undef;

ok(cbt_isNil($undef) ? 3 : 0);

ok(cbt_isNil(undef) ? 4 : 0);

ok(cbt_isNil("Not nil") ? 0 : 5);

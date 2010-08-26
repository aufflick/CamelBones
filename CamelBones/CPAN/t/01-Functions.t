use Test;
BEGIN { plan tests => 8 };

use CamelBones qw(:All);
ok(1);

use CamelBones::Tests;
ok(2);

ok("-5" eq cbt_char2string(-5) ? 3 : 0);

ok("5" eq cbt_uchar2string(5) ? 4 : 0);

ok("-30000" eq cbt_int2string(-30000) ? 5 : 0);

ok("50000" eq cbt_uint2string(50000) ? 6 : 0);

ok("-5000000" eq cbt_long2string(-5000000) ? 7 : 0);

ok("5000000" eq cbt_ulong2string(5000000) ? 8 : 0);


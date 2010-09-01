use Test;
BEGIN {
    $|++;
    plan tests => 56;
};

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

my $tester = CBStructureTests->alloc()->init();
ok(2) if (defined $tester);
ok(3) if (ref $tester->point() eq 'CamelBones::NSPoint');
ok(4) if (ref $tester->range() eq 'CamelBones::NSRange');
ok(5) if (ref $tester->rect() eq 'CamelBones::NSRect');
ok(6) if (ref $tester->size() eq 'CamelBones::NSSize');

ok(7) if fpeq($tester->pointX(), 0.0);
ok(8) if fpeq($tester->pointY(), 0.0);

$tester->setPoint({'x' => 5.0, 'y' => 10.0});
ok(9) if fpeq($tester->pointX(), 5.0);
ok(10) if fpeq($tester->pointY(), 10.0);
ok(11) if fpeq($tester->point()->getX(), 5.0);
ok(12) if fpeq($tester->point()->getY(), 10.0);

$tester->setPoint([25.0, 20.0]);
ok(13) if fpeq($tester->pointX(), 25.0);
ok(14) if fpeq($tester->pointY(), 20.0);
ok(15) if fpeq($tester->point()->getX(), 25.0);
ok(16) if fpeq($tester->point()->getY(), 20.0);

ok(17) if ($tester->rangeLocation() == 0);
ok(18) if ($tester->rangeLength() == 0);

$tester->setRange({'location' => 5, 'length' => 10});
ok(19) if ($tester->rangeLocation() == 5);
ok(20) if ($tester->rangeLength() == 10);
ok(21) if ($tester->range()->getLocation() == 5);
ok(22) if ($tester->range()->getLength() == 10);

$tester->setRange([15, 20]);
ok(23) if ($tester->rangeLocation() == 15);
ok(24) if ($tester->rangeLength() == 20);
ok(25) if ($tester->range()->getLocation() == 15);
ok(26) if ($tester->range()->getLength() == 20);

ok(27) if fpeq($tester->rectX(), 0.0);
ok(28) if fpeq($tester->rectY(), 0.0);
ok(29) if fpeq($tester->rectWidth(), 0.0);
ok(30) if fpeq($tester->rectHeight(), 0.0);

$tester->setRect({'x' => 5.0, 'y' => 10.0, 'width' => 15.0, 'height' => 20.0});
ok(31) if fpeq($tester->rectX(), 5.0);
ok(32) if fpeq($tester->rectY(), 10.0);
ok(33) if fpeq($tester->rectWidth(), 15.0);
ok(34) if fpeq($tester->rectHeight(), 20.0);

ok(35) if fpeq($tester->rect()->getX(), 5.0);
ok(36) if fpeq($tester->rect()->getY(), 10.0);
ok(37) if fpeq($tester->rect()->getWidth(), 15.0);
ok(38) if fpeq($tester->rect()->getHeight(), 20.0);

$tester->setRect([25.0, 30.0, 35.0, 40.0]);
ok(39) if fpeq($tester->rectX(), 25.0);
ok(40) if fpeq($tester->rectY(), 30.0);
ok(41) if fpeq($tester->rectWidth(), 35.0);
ok(42) if fpeq($tester->rectHeight(), 40.0);

ok(43) if fpeq($tester->rect()->getX(), 25.0);
ok(44) if fpeq($tester->rect()->getY(), 30.0);
ok(45) if fpeq($tester->rect()->getWidth(), 35.0);
ok(46) if fpeq($tester->rect()->getHeight(), 40.0);

ok(47) if fpeq($tester->sizeWidth(), 0.0);
ok(48) if fpeq($tester->sizeHeight(), 0.0);

$tester->setSize({'width' => 5.0, 'height' => 10.0});
ok(49) if fpeq($tester->sizeWidth(), 5.0);
ok(50) if fpeq($tester->sizeHeight(), 10.0);
ok(51) if fpeq($tester->size()->getWidth(), 5.0);
ok(52) if fpeq($tester->size()->getHeight(), 10.0);

$tester->setSize([15.0, 20.0]);
ok(53) if fpeq($tester->sizeWidth(), 15.0);
ok(54) if fpeq($tester->sizeHeight(), 20.0);
ok(55) if fpeq($tester->size()->getWidth(), 15.0);
ok(56) if fpeq($tester->size()->getHeight(), 20.0);

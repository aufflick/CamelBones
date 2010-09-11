#!/usr/bin/perl

package CBCommon;

use Config;
use Cwd 'abs_path';

my $CamelBonesPath = $ENV{'CAMELBONES_PATH'};

my $CamelBones = "$CamelBonesPath/CamelBones.framework";

$CamelBones = abs_path($CamelBones);
$CamelBonesPath = abs_path($CamelBonesPath);

our %opts = (
    VERSION           => '1.1.1',

    PREREQ_PM         => {},

    AUTHOR         => 'Sherm Pendley <sherm.pendley@gmail.com>',

    XSOPT           => "-typemap $CamelBones/Resources/typemap",

    LIBS              => [ '-lobjc' ],
    INC               => "-F$CamelBonesPath -ObjC ",
    dynamic_lib         => {
                        'OTHERLDFLAGS' =>
                            " -framework Foundation -framework AppKit -framework CamelBones -F$CamelBonesPath -lobjc "
                        },
);

1;

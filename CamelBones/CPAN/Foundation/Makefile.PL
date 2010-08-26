use 5.006;

my %local_opts;
BEGIN {
    require "../cb_common.pl";
    %local_opts = (
        'NAME' => 'CamelBones::Foundation',
    );
    for (keys %CBCommon::opts) {
        $local_opts{$_} = $CBCommon::opts{$_};
    }
}

use ExtUtils::MakeMaker;
WriteMakefile(
    %local_opts
);

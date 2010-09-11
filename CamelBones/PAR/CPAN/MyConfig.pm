use Config;
use File::Path;

require 5.6.2;

my $kit = $ENV{'CB_PARKIT'};
my @pre = split(" ", $ENV{'CB_PARKIT_PREREQ'});

my $tmp = $ENV{'BUILD_DIR'};
my $version = sprintf('%vd', $^V);
my $arch = $Config{'archname'};

for my $k ( $kit, @pre ) {
    unshift @INC, "$tmp/$k/Library/Perl/$version", "$tmp/$k/Library/Perl/$version/$arch", "$tmp/$k/Library/Perl/Updates/$version", "$tmp/$k/Library/Perl/Updates/$version/$arch", "$tmp/$k/System/Library/Perl/$version", "$tmp/$k/System/Library/Perl/$version/$arch";
    $ENV{'PERL5LIB'} .= ":$tmp/$k/Library/Perl/$version:$tmp/$k/Library/Perl/$version/$arch:$tmp/$k/Library/Perl/Updates/$version:$tmp/$k/Library/Perl/Updates/$version/$arch:$tmp/$k/System/Library/Perl/$version:$tmp/$k/System/Library/Perl/$version/$arch";
}

my $destdir = "$tmp/$kit";

$CPAN::Config = {
    'applypatch' => q[],
    'auto_commit' => q[0],
    'build_cache' => q[100],
    'build_dir' => qq[$tmp/.cpan/build],
    'build_dir_reuse' => q[0],
    'build_requires_install_policy' => q[ask/yes],
    'bzip2' => q[/usr/bin/bzip2],
    'cache_metadata' => q[1],
    'check_sigs' => q[0],
    'colorize_output' => q[0],
    'commandnumber_in_prompt' => q[1],
    'connect_to_internet_ok' => q[1],
    'cpan_home' => qq[$tmp/.cpan],
    'curl' => q[/usr/bin/curl],
    'ftp' => q[/usr/bin/ftp],
    'ftp_passive' => q[1],
    'ftp_proxy' => q[],
    'getcwd' => q[cwd],
    'gpg' => q[],
    'gzip' => q[/usr/bin/gzip],
    'halt_on_failure' => q[0],
    'histfile' => qq[$tmp/.cpan/histfile],
    'histsize' => q[100],
    'http_proxy' => q[],
    'inactivity_timeout' => q[0],
    'index_expire' => q[1],
    'inhibit_startup_message' => q[0],
    'keep_source_where' => qq[$tmp/.cpan/sources],
    'load_module_verbosity' => q[v],
    'lynx' => q[],
    'make' => q[/usr/bin/make],
    'make_arg' => q[],
    'make_install_arg' => qq[UNINST=0 DESTDIR=$destdir],
    'make_install_make_command' => q[make],
    'makepl_arg' => q[],
    'mbuild_arg' => q[],
    'mbuild_install_arg' => qq[--uninst 0 --destdir $destdir],
    'mbuild_install_build_command' => q[./Build],
    'mbuildpl_arg' => q[],
    'ncftp' => q[],
    'ncftpget' => q[],
    'no_proxy' => q[],
    'pager' => q[/usr/bin/less],
    'patch' => q[/usr/bin/patch],
    'perl5lib_verbosity' => q[v],
    'prefer_installer' => q[MB],
    'prefs_dir' => qq[$tmp/.cpan/prefs],
    'prerequisites_policy' => q[ask],
    'scan_cache' => q[atstart],
    'shell' => q[/bin/bash],
    'show_unparsable_versions' => q[0],
    'show_upload_date' => q[0],
    'show_zero_versions' => q[0],
    'tar' => q[/usr/bin/tar],
    'tar_verbosity' => q[v],
    'term_is_latin' => q[1],
    'term_ornaments' => q[1],
    'test_report' => q[0],
    'trust_test_report_history' => q[0],
    'unzip' => q[/usr/bin/unzip],
    'urllist' => [q[ftp://mirror.nyi.net/CPAN/], q[ftp://mirror.hiwaay.net/CPAN/], q[ftp://mirror.its.uidaho.edu/cpan/] ],
    'use_sqlite' => q[0],
    'wget' => q[],
    'yaml_load_code' => q[0],
    'yaml_module' => q[YAML],
};

1;

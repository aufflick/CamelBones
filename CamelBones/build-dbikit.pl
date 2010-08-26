#!/usr/bin/perl

use Config;
use CPAN;
use CPAN::Config;
use Data::Dumper;
use File::Path;

require 5.6.2;

my $kit = 'DBIKit';
my @pre = qw( PAR DevKit );

my $tmp = `pwd`;
chomp $tmp;
$tmp =~ s%/*$%/build%;

my $dist_libs = "$tmp/../../dist-libs";

my $version = sprintf('%vd', $^V);
my $arch = $Config{'archname'};

for $k ($kit, @pre) {
    mkpath("$tmp/$k/$version/$arch", 0, 0711) unless -d "$tmp/$k/$version/$arch";
    unshift @INC, "$tmp/$k/$version", "$tmp/$k/$version/$arch";
    $ENV{'PERL5LIB'} .= ":$tmp/$k/$version:$tmp/$k/$version/$arch";
}

$CPAN::Config->{'makepl_arg'} .= " LIB=$tmp/$kit/$version ";
$CPAN::Config->{'mbuildpl_arg'} = " --install_path lib=$tmp/$kit/$version --install_path arch=$tmp/$kit/$version/$arch ";

$CPAN::Config->{'make_install_make_command'} = 'make';
$CPAN::Config->{'mbuild_install_build_command'} = './Build';

my $sdk = $ENV{'SDK'};

if (defined $sdk && -d $sdk) {
    my $arch = ($sdk =~ m%u\.sdk/?$%) ? '-arch i386 -arch ppc' : '';
    $CPAN::Config->{'makepl_arg'} .= "CCFLAGS='-isysroot$sdk $arch ' LDDLFLAGS='$arch -bundle -undefined dynamic_lookup -Wl,-syslibroot,$sdk '";
}

$CPAN::Config->{'make_install_arg'} =~ s/UNINST=1//;
$CPAN::Config->{'mbuild_install_arg'} =~ s/--uninst=1//;

# DBI installs without special care
install 'DBI';

# Custom build params for DBD::Pg
{
    # How to connect for tests
    local $ENV{'DBI_DSN'} = 'dbi:Pg:dbname=test';
    local $ENV{'DBI_USER'} = '';
    local $ENV{'DBI_PASS'} = '';
    
    # Where to find headers & libs
    local $ENV{'POSTGRES_INCLUDE'} = "$dist_libs/postgresql/$version/include";
    local $ENV{'POSTGRES_LIB'} = "$dist_libs/postgresql/$version/lib";

    # Compiler & linker flags
    my $arg = $CPAN::Config->{'makepl_arg'};
    $arg =~ s/CCFLAGS='/CCFLAGS='-DPGDEFPORT=5432 /;
    $arg =~ s/LDDLFLAGS='/LDDLFLAGS='-lkrb5 -lssl /;
    local $CPAN::Config->{'makepl_arg'} = $arg;

    install 'DBD::Pg';
}

# DBD::mysql needs to know where to find headers & libraries
{
    # Compiler & linker flags
    my $arg = $CPAN::Config->{'makepl_arg'};
    $arg .= " --cflags='-I$dist_libs/mysql/$version/include' ";
    $arg .= " --libs='-L$dist_libs/mysql/$version/lib -lmysqlclient -lz'";
    local $CPAN::Config->{'makepl_arg'} = $arg;

    install 'DBD::mysql';
}

# install 'DBD::SQLite';
# 1.13 causes failures in Class::DBI self-tests, so install 1.12
{
    my $sqlite_version = eval 'use DBD::SQLite; $DBD::SQLite::VERSION';
    $sqlite_version eq '1.12' ?
        print "DBD::SQLite is up to date (1.12).\n" :
        install 'MSERGEANT/DBD-SQLite-1.12.tar.gz';
    ;
}

# These install transparently
install 'DBIx::ContextualFetch';
install 'Ima::DBI';
install 'Class::DBI';

# Custom build params for Class::DBI::Pg
{
    # How to connect for tests
    local $ENV{'DB_NAME'} = 'test';
    local $ENV{'DB_USER'} = 'sherm';
    local $ENV{'DB_PASS'} = '';
    
    install 'Class::DBI::Pg';
}

install 'Class::DBI::mysql';
install 'Class::DBI::SQLite';

install 'SQL::Abstract';
install 'SQL::Abstract::Limit';

# 1296 out of 1297 tests pass on Panther - close enough for an old OS version
if ($version eq '5.8.1') {
    my $module = CPAN::Shell->expand('Module', 'DBIx::Class');
    if ($module->uptodate()) {
        my $module_ver = $module->inst_version();
        print "DBIx::Class is up to date ($module_ver).\n";
    } else {
        force 'install', 'DBIx::Class';
    }
} else {
    install 'DBIx::Class';
}

install 'DBIx::Class';
install 'DBIx::Class::Loader';
install 'DBIx::Class::Schema::Loader';

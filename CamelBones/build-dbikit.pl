#!/usr/bin/perl

use lib './PAR';
use CPAN;
use CPAN::MyConfig;
use Data::Dumper;

my $sdk = $ENV{'SDKROOT'};
my $libdir = $ENV{'BUILD_DIR'} . '/../../ExtLibs';
my $version = sprintf("%vd", $^V);

CPAN::HandleConfig->load;
CPAN::Shell::setup_output;
CPAN::Index->reload;

install 'DBI';

# Custom build params for DBD::Pg
{
    # How to connect for tests
    local $ENV{'DBI_DSN'} = 'dbi:Pg:dbname=test';
    local $ENV{'DBI_USER'} = '';
    local $ENV{'DBI_PASS'} = '';
    
    # Where to find headers & libs
    local $ENV{'POSTGRES_INCLUDE'} = "$libdir/include";
    local $ENV{'POSTGRES_LIB'} = "$libdir/lib";

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
    $arg .= " --cflags='-I$libdir/include/mysql' ";
    $arg .= " --libs='-L$libdir/lib/mysql -lmysqlclient -lz'";
    local $CPAN::Config->{'makepl_arg'} = $arg;

    install 'DBD::mysql';
}

install 'DBD::SQLite';
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
install 'Data::Dumper::Concise';
install 'Math::Base36';
install 'Context::Preserve';
install 'Class::Accessor::Grouped';
install 'Class::C3::Componentised';

# 4164 subtests, all of them pass, but "Result: FAIL"???
# Just force the frakkin thing.
{
    my $module = CPAN::Shell->expand('Module', 'DBIx::Class');
    if ($module->uptodate()) {
        print 'DBIx::Class is up to date (', $module->inst_version(), ").\n";
    } else {
        force('install','DBIx::Class');
    }
}

# Apparently, one of the tests are buggy on 5.10.0 ... :-(
if ($version eq '5.10.0') {
    my $module = CPAN::Shell->expand('Module', 'DBIx::Class::Loader');
    if ($module->uptodate()) {
        print 'DBIx::Class::Loader is up to date (', $module->inst_version(), ").\n";
    } else {
        force('install', 'DBIx::Class::Loader');
    }
} else {
    install 'DBIx::Class::Loader';
}
install 'Class::Unload';
install 'Lingua::EN::Inflect::Phrase';
install 'Lingua::EN::Tagger';
install 'DBIx::Class::Schema::Loader';

print "\n\n";

1;

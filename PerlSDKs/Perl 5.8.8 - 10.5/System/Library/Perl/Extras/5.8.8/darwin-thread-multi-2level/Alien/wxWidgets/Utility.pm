package Alien::wxWidgets::Utility;

=head1 NAME

Alien::wxWidgets::Utility - INTERNAL: do not use

=cut

use strict;
use base qw(Exporter);
use Config;

BEGIN {
    if( $^O eq 'MSWin32' && $Config{_a} ne $Config{lib_ext} ) {
        print STDERR <<EOT;
\$Config{_a} is '$Config{_a}' and \$Config{lib_ext} is '$Config{lib_ext}':
they need to be equal for the build to succeed. If you are using ActivePerl
with MinGW/GCC, please:

- install ExtUtils::FakeConfig
- set PERL5OPT=-MConfig_m
- rerun Build.PL
EOT
        exit 1;
    }
}

our @EXPORT_OK = qw(awx_capture awx_cc_is_gcc awx_cc_version awx_cc_abi_version
                    awx_sort_config awx_grep_config awx_smart_config);

my $quotes = $^O =~ /MSWin32/ ? '"' : "'";

sub awx_capture {
    qx!$^X -e ${quotes}open STDERR, q[>&STDOUT]; exec \@ARGV${quotes} -- $_[0]!;
}

sub awx_cc_is_gcc {
    my( $cc ) = @_;

    return    scalar( awx_capture( "$cc --version" ) =~ m/gcc/i ) # 3.x
           || scalar( awx_capture( "$cc" ) =~ m/gcc/i );          # 2.95
}

sub awx_cc_abi_version {
    my( $cc ) = @_;
    my $ver = awx_cc_version( $cc );
    return 0 unless $ver > 0;
    return '3.4' if $ver >= 3.4;
    return '3.2' if $ver >= 3.2;
    return $ver;
}

sub awx_cc_version {
    my( $cc ) = @_;
    return 0 unless awx_cc_is_gcc( $cc );

    my $ver = awx_capture( "$cc --version" );

    $ver =~ m/(\d+\.\d+)(?:\.\d+)?/ or return 0;

    return $1;
}

sub awx_compiler_kind {
    my( $cc ) = @_;

    return 'gcc' if awx_cc_is_gcc( $cc );
    return 'cl'  if $^O =~ /MSWin32/ and $cc =~ /^cl/i;

    return 'nc'; # as in 'No Clue'
}

# sort a list of configurations by version, debug/release, unicode/ansi, mslu
sub awx_sort_config {
    # comparison functions treating undef as 0 or ''
    # numerico comparison
    my $make_cmpn = sub {
        my $k = shift;
        sub { exists $a->{$k} && exists $b->{$k} ? $a->{$k} <=> $b->{$k} :
              exists $a->{$k}                    ? 1                     :
              exists $b->{$k}                    ? -1                    :
                                                   0 }
    };
    # string comparison
    my $make_cmps = sub {
        my $k = shift;
        sub { exists $a->{$k} && exists $b->{$k} ? $a->{$k} cmp $b->{$k} :
              exists $a->{$k}                    ? 1                     :
              exists $b->{$k}                    ? -1                    :
                                                   0 }
    };
    # reverse comparison
    my $rev = sub { my $cmp = shift; sub { -1 * &$cmp } };
    # compare by different criteria, using the first nonzero as tie-breaker
    my $crit_sort = sub {
        my @crit = @_;
        sub {
            foreach ( @crit ) {
                my $cmp = &$_;
                return $cmp if $cmp;
            }

            return 0;
        }
    };

    my $cmp = $crit_sort->( $make_cmpn->( 'version' ),
                            $rev->( $make_cmpn->( 'debug' ) ),
                            $make_cmpn->( 'unicode' ),
                            $make_cmpn->( 'mslu' ) );

    return reverse sort $cmp @_;
}

sub awx_grep_config {
    my( $cfgs ) = shift;
    my( %a ) = @_;
    # compare to a numeric range or value
    # low extreme included, high extreme excluded
    # if $a{key} = [ lo, hi ] then range else low extreme
    my $make_cmpr = sub {
        my $k = shift;
        sub {
            return 1 unless exists $a{$k};
            ref $a{$k} ? $a{$k}[0] <= $_->{$k} && $_->{$k} < $a{$k}[1] :
                         $a{$k}    <= $_->{$k};
        }
    };
    # compare for numeric equality
    my $make_cmpn = sub {
        my $k = shift;
        sub { exists $a{$k} ? $a{$k} == $_->{$k} : 1 }
    };
    # compare for string equality
    my $make_cmps = sub {
        my $k = shift;
        sub { exists $a{$k} ? $a{$k} eq $_->{$k} : 1 }
    };

    # note tha if the criteria was not supplied, the comparison is a noop
    my $wver = $make_cmpr->( 'version' );
    my $ckind = $make_cmps->( 'compiler_kind' );
    my $cver = $make_cmpn->( 'compiler_version' );
    my $tkit = $make_cmps->( 'toolkit' );
    my $deb = $make_cmpn->( 'debug' );
    my $uni = $make_cmpn->( 'unicode' );
    my $mslu = $make_cmpn->( 'mslu' );
    my $key = $make_cmps->( 'key' );

    grep { &$wver  } grep { &$ckind } grep { &$cver  }
    grep { &$tkit  } grep { &$deb   } grep { &$uni   }
    grep { &$mslu  } grep { &$key   }
         @{$cfgs}
}

# automatically add compiler data unless the key was supplied
sub awx_smart_config {
    my( %args ) = @_;
    # the key already identifies the configuration
    return %args if $args{key};

    my $cc = $ENV{CXX} || $ENV{CC} || $Config{cc};
    my $kind = awx_compiler_kind( $cc );
    my $version = awx_cc_abi_version( $cc );

    $args{compiler_kind} ||= $kind;
    $args{compiler_version} ||= $version;

    return %args;
}

# allow to remap srings in the configuration; useful when building
# archives
my @prefixes;

BEGIN {
    if( $ENV{ALIEN_WX_PREFIXES} ) {
        my @kv = split /,\s*/, $ENV{ALIEN_WX_PREFIXES};

        while( @kv ) {
            my( $match, $repl ) = ( shift( @kv ) || '', shift( @kv ) || '' );

            push @prefixes, [ $match, $^O eq 'MSWin32' ?
                                          qr/\Q$match\E/i :
                                          qr/\Q$match\E/, $repl ];
        }
    }
}

sub _awx_remap {
    my( $string ) = @_;
    return $string if ref $string;
    return $string if $Alien::wxWidgets::dont_remap;

    foreach my $prefix ( @prefixes ) {
        my( $str, $rx, $repl ) = @$prefix;

        $string =~ s{$rx(\S*)}{$repl$1}g;
    }

    return $string;
}

1;

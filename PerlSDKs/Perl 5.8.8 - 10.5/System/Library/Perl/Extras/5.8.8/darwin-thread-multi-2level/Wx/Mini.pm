package Wx::Mini; # for RPM

package Wx;

use strict;

our( $VERSION, $XS_VERSION );
our $alien_key = 'mac_2_8_4_dbg_uni_gcc_3_4';

{
    my $VAR1;
    $Wx::dlls = $VAR1 = {
          'stc' => 'libwx_macud_stc-2.8.dylib',
          'fl' => 'libwx_macud_fl-2.8.dylib',
          'gl' => 'libwx_macud_gl-2.8.dylib',
          'mono' => 'libwx_macud-2.8.dylib',
          'gizmos' => 'libwx_macud_gizmos-2.8.dylib',
          'ogl' => 'libwx_macud_ogl-2.8.dylib',
          'plot' => 'libwx_macud_plot-2.8.dylib',
          'xrc' => 'libwx_macud_svg-2.8.dylib',
          'svg' => undef
        };
;
}

$VERSION = '0.74'; # bootstrap will catch wrong versions
$XS_VERSION = $VERSION;
$VERSION = eval $VERSION;

#
# XSLoader/DynaLoader wrapper
#
our( $wx_path );

sub wxPL_STATIC();
sub wx_boot($$) {
  local $ENV{PATH} = $wx_path . ';' . $ENV{PATH} if $wx_path;
  if( $_[0] eq 'Wx' || !wxPL_STATIC ) {
    if( $] < 5.006 ) {
      require DynaLoader;
      no strict 'refs';
      push @{"$_[0]::ISA"}, 'DynaLoader';
      $_[0]->bootstrap( $_[1] );
    } else {
      require XSLoader;
      XSLoader::load( $_[0], $_[1] );
    }
  } else {
    no strict 'refs';
    my $t = $_[0]; $t =~ tr/:/_/;
    &{"_boot_$t"}( $_[0], $_[1] );
  }
}

sub _alien_path {
  return if defined $wx_path;
  return unless length 'usr';
  foreach ( @INC ) {
    if( -d "$_/Alien/wxWidgets/usr" ) {
      $wx_path = "$_/Alien/wxWidgets/usr/lib";
      last;
    }
  }
}

_alien_path();

sub _start {
    wx_boot( 'Wx', $XS_VERSION );

    _boot_Constant( 'Wx', $XS_VERSION );
    _boot_GDI( 'Wx', $XS_VERSION );

    Load();
}

1;

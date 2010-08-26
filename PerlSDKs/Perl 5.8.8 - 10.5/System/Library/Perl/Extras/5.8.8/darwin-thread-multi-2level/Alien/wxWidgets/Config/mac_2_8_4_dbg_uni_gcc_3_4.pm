package Alien::wxWidgets::Config::mac_2_8_4_dbg_uni_gcc_3_4;

use strict;

our %VALUES;

{
    no strict 'vars';
    %VALUES = %{
$VAR1 = {
          'defines' => '-D_FILE_OFFSET_BITS=64 -D_LARGE_FILES -D__WXDEBUG__ -D__WXMAC__ ',
          'include_path' => '-I/usr/lib/wx/include/mac-unicode-debug-2.8 -I/usr/include/wx-2.8 ',
          'alien_package' => 'Alien::wxWidgets::Config::mac_2_8_4_dbg_uni_gcc_3_4',
          'version' => '2.008004',
          'alien_base' => 'mac_2_8_4_dbg_uni_gcc_3_4',
          'c_flags' => '-UWX_PRECOMP ',
          '_libraries' => {
                            'stc' => {
                                       'link' => '-lwx_macud_stc-2.8',
                                       'dll' => 'libwx_macud_stc-2.8.dylib'
                                     },
                            'fl' => {
                                      'link' => '-lwx_macud_fl-2.8',
                                      'dll' => 'libwx_macud_fl-2.8.dylib'
                                    },
                            'gl' => {
                                      'link' => '-lwx_macud_gl-2.8',
                                      'dll' => 'libwx_macud_gl-2.8.dylib'
                                    },
                            'mono' => {
                                        'link' => '-lwx_macud-2.8',
                                        'dll' => 'libwx_macud-2.8.dylib'
                                      },
                            'gizmos' => {
                                          'link' => '-lwx_macud_gizmos-2.8',
                                          'dll' => 'libwx_macud_gizmos-2.8.dylib'
                                        },
                            'ogl' => {
                                       'link' => '-lwx_macud_ogl-2.8',
                                       'dll' => 'libwx_macud_ogl-2.8.dylib'
                                     },
                            'plot' => {
                                        'link' => '-lwx_macud_plot-2.8',
                                        'dll' => 'libwx_macud_plot-2.8.dylib'
                                      },
                            'xrc' => {
                                       'link' => '-lwx_macud_gizmos_xrc-2.8',
                                       'dll' => 'libwx_macud_gizmos_xrc-2.8.dylib'
                                     },
                            'svg' => {
                                       'link' => '-lwx_macud_svg-2.8',
                                       'dll' => 'libwx_macud_svg-2.8.dylib'
                                     }
                          },
          'compiler' => 'g++',
          'link_flags' => '',
          'linker' => 'g++',
          'config' => {
                        'compiler_version' => '3.4',
                        'compiler_kind' => 'gcc',
                        'mslu' => 0,
                        'toolkit' => 'mac',
                        'unicode' => 1,
                        'debug' => 1,
                        'build' => 'mono'
                      },
          'prefix' => '/usr'
        };
    };
}

my $key = substr __PACKAGE__, 1 + rindex __PACKAGE__, ':';

sub values { %VALUES, key => $key }

sub config {
   +{ %{$VALUES{config}},
      package       => __PACKAGE__,
      key           => $key,
      version       => $VALUES{version},
      }
}

1;

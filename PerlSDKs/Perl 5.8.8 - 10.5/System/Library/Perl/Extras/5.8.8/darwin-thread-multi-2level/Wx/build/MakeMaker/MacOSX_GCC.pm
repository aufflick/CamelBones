package Wx::build::MakeMaker::MacOSX_GCC;

use strict;
use base 'Wx::build::MakeMaker::Any_wx_config';
use Wx::build::Utils qw(write_string);

sub configure_core {
  my $this = shift;
  my %config = $this->SUPER::configure_core( @_ );

  $config{depend}{'$(INST_STATIC)'} .= ' wxPerl';
  $config{depend}{'$(INST_DYNAMIC)'} .= ' wxPerl';
  $config{clean}{FILES} .= " wxPerl cpp/wxPerl.osx/build cpp/wxPerl.osx/wxPerl.c cpp/wxPerl.osx/wxPerl.r";

  return %config;
}

sub const_config {
    my $text = shift->SUPER::const_config( @_ );

    $text =~ s{^(LD(?:DL)?FLAGS\s*=.*?)-L/usr/local/lib/?}{$1}mg;

    return $text;
}

sub install_core {
  my $this = shift;
  my $text = $this->SUPER::install_core( @_ );

  $text =~ m/^(install\s*:+)/m and
    $text .= "\n\n$1 install_wxperl\n\n";

  return $text;
}

sub postamble_core {
  my $this = shift;
  my $text = $this->SUPER::postamble_core( @_ );
  my $wx_config = $ENV{WX_CONFIG} || 'wx-config';
  my $rfile;

  if( Alien::wxWidgets->version < 2.006 ) {
    my $rsrc = join ' ', grep { /wx/ } split ' ', `$wx_config --rezflags`;
    $rfile = sprintf <<EOR, $rsrc;
	echo '#include <Carbon.r>' > cpp/wxPerl.osx/wxPerl.r
	cat %s >> cpp/wxPerl.osx/wxPerl.r
EOR
  } else {
    $rfile = <<EOE;
	echo '#include <Carbon.r>' > cpp/wxPerl.osx/wxPerl.r
EOE
  }

  write_string( 'cpp/wxPerl.osx/wxPerl.c', sprintf <<EOT, $this->{INSTALLARCHLIB} );
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int main( int argc, char **argv )
{
    argv[0] = "%s/auto/Wx/wxPerl.app/Contents/MacOS/wxPerl";
    execv( argv[0], argv );
    perror( "wxPerl: execv" );
    exit( 1 );
}
EOT

  $text .= sprintf <<'EOT', $rfile;

wxPerl : Makefile
%s	cd cpp/wxPerl.osx && xcodebuild -project wxPerl.xcode LD=/usr/bin/cc
	cp -p $(PERL) `find cpp -name wxPerl.app`/Contents/MacOS/wxPerl
	mkdir -p $(INST_ARCHLIB)/auto/Wx
	cp -rp `find cpp -name wxPerl.app` $(INST_ARCHLIB)/auto/Wx
	$(CC) $(RC_CFLAGS) cpp/wxPerl.osx/wxPerl.c -o wxPerl

install_wxperl :
	mkdir -p $(DESTINSTALLBIN)
	cp -p wxPerl $(DESTINSTALLBIN)

EOT

  return $text;
}

1;

# local variables:
# mode: cperl
# end:

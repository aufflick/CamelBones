#############################################################################
## Name:        lib/Wx/DemoModules/wxHtmlDynamic.pm
## Purpose:     Dynamically generated HTML (via Wx::FsHandler)
## Author:      Mattia Barbon
## Modified by:
## Created:     18/04/2002
## RCS-ID:      $Id: wxHtmlDynamic.pm,v 1.1.1.1 2006/08/14 20:00:47 mbarbon Exp $
## Copyright:   (c) 2002, 2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

use Wx::Html;
use Wx::FS;

package Wx::DemoModules::wxHtmlDynamic;

use strict;
use base qw(Wx::Panel);

use Wx qw(:sizer);

sub new {
  my( $class, $parent ) = @_;
  my $panel = $class->SUPER::new( $parent, -1 );

  Wx::FileSystem::AddHandler( Wx::DemoModules::wxHtmlDynamic::FSHandler->new );

  my $sizer = Wx::BoxSizer->new( wxVERTICAL );
  my $htmlwin = Wx::HtmlWindow->new( $panel, -1 );

  $sizer->Add( $htmlwin, 1, wxGROW );
  $panel->SetSizer( $sizer );
  $htmlwin->LoadPage( "my://foo.bar/baz" );

  return $panel;
}

sub add_to_tags { 'windows/html' }
sub title { 'Dynamic html' }

package Wx::DemoModules::wxHtmlDynamic::FSHandler;

use strict;
use base qw(Wx::PlFileSystemHandler);

use IO::Scalar;

sub new {
  my $class = shift;
  my $this = $class->SUPER::new( @_ );

  return $this;
}

sub CanOpen {
  my $file = $_[1];

  return scalar( $file =~ m{^my://} );
}

# no findfirst/findnext, not needed for this example

my @f;

sub OpenFile {
  my( $this, $fs, $location ) = @_;
  my $loc = $location;

  $loc =~ s{^my://}{};

  my $text = join '',
    map { qq{<a href="my://$_">}.( $loc ne $_ ? $_ : 'Here' ).qq{</a><br>} }
    ( 'foo.bar/baz', 'Here, there, everywhere',
      'Somewhere else', 'A galaxy far, far away' );

  my $string = <<EOT;
<html>
<head>
  <title>$loc</title>
</head>
<body>
<h1>$loc</h1>

Something useful here<br><br>

Links:<br>
$text

</body>
</html>
EOT

  my $f = Wx::PlFSFile->new( IO::Scalar->new( \$string ),
                             $location, 'text/html', '' );
  return $f;
}

1;

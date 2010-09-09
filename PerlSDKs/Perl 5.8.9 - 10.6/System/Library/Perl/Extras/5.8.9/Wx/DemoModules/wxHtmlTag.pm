#############################################################################
## Name:        lib/Wx/DemoModules/wxHtmlTag.pm
## Purpose:     wxPerl demo hlper for wxHtmlWindow custom tags
## Author:      Mattia Barbon
## Modified by:
## Created:     20/12/2003
## RCS-ID:      $Id: wxHtmlTag.pm 2189 2007-08-21 18:15:31Z mbarbon $
## Copyright:   (c) 2003-2004, 2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

use Wx::Html;

package Wx::DemoModules::wxHtmlTag::Handler;

use strict;
use base 'Wx::PlHtmlTagHandler';
use Wx::Calendar;

sub new {
  my $class = shift;
  my $this = $class->SUPER::new;

  return $this;
}

sub GetSupportedTags {
  return 'WXPERLCTRL';
}

sub HandleTag {
  my( $this, $htmltag ) = @_;
  my $parser = $this->GetParser;
  my $htmlwin = $parser->GetWindow;
  my $calendar = Wx::CalendarCtrl->new( $htmlwin, -1 );
  my $cell = Wx::HtmlWidgetCell->new( $calendar );
  my $cnt = $parser->GetContainer;
  $cnt->InsertCell( $cell );

  return 1;
}

package Wx::DemoModules::wxHtmlTag;

use strict;
use base 'Wx::HtmlWindow';

sub new {
  my $class = shift;
  my $this = $class->SUPER::new( $_[0], -1 );

  $this->GetParser->AddTagHandler( Wx::DemoModules::wxHtmlTag::Handler->new );
  $this->SetPage( <<EOT );
<html>
<head><title>Title</title></head>
<body>
  <h1>Heading</h1>

  <wxperlctrl />

Some text
</body>
</html>
EOT

  return $this;
}

sub add_to_tags { 'windows/html' }
sub title { 'Custom tags' }

1;

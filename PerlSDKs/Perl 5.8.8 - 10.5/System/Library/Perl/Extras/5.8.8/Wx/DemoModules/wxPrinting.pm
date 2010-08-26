#############################################################################
## Name:        lib/Wx/DemoModules/wxPrinting.pm
## Purpose:     Printing demo
## Author:      Mattia Barbon
## Modified by:
## Created:     12/09/2001
## RCS-ID:      $Id: wxPrinting.pm,v 1.1.1.1 2006/08/14 20:00:47 mbarbon Exp $
## Copyright:   (c) 2001, 2003, 2005-2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

use Wx::Print;

package Wx::DemoModules::wxPrinting;

use strict;
use base qw(Wx::Panel);

use Wx qw(:sizer);
use Wx::Event qw(EVT_BUTTON);

sub new {
  my $class = shift;
  my $this = $class->SUPER::new( @_ );

  my $top = Wx::BoxSizer->new( wxVERTICAL );
  my $canvas = Wx::DemoModules::wxPrinting::Canvas->new( $this, -1 );

  my $preview = Wx::Button->new( $this, -1, "Preview" );
  my $print = Wx::Button->new( $this, -1, "Print" );

  my $buttons = Wx::BoxSizer->new( wxHORIZONTAL );
  $buttons->Add( $preview, 0, wxALL, 5 );
  $buttons->Add( $print, 0, wxALL, 5 );

  $top->Add( $canvas, 1, wxGROW );
  $top->Add( $buttons, 0, wxGROW );

  $this->SetSizer( $top );
  $this->SetAutoLayout( 1 );

  $this->{CANVAS} = $canvas;

  EVT_BUTTON( $this, $preview, \&OnPreview );
  EVT_BUTTON( $this, $print, \&OnPrint );

  return $this;
}

sub canvas { $_[0]->{CANVAS} }

use Wx qw(wxTheApp);

sub OnPreview {
  my( $this, $event ) = @_;

  my $prev = Wx::DemoModules::wxPrinting::Printout->new( $this->canvas, "Preview" );
  my $print = Wx::DemoModules::wxPrinting::Printout->new( $this->canvas, "Print" );
  my $preview = Wx::PrintPreview->new( $prev, $print );
  my $frame = Wx::DemoModules::wxPrinting::PreviewFrame->new( $preview, wxTheApp->GetTopWindow,
                                     "Printing Demo Preview", [-1, -1], [600, -1] );
  $frame->Initialize();

  $frame->Show( 1 );
}

sub OnPrint {
  my( $this, $event ) = @_;

  my $printer = Wx::Printer->new;
  my $printout = Wx::DemoModules::wxPrinting::Printout->new( $this->canvas, "Print" );
  $printer->Print( $this, $printout, 1 );

  $printout->Destroy;
}

sub add_to_tags { qw(misc) }
sub title { 'Printing' }

package Wx::DemoModules::wxPrinting::PreviewFrame;

use strict;
use base 'Wx::PlPreviewFrame';

sub Initialize {
    Wx::LogMessage( 'Wx::DemoModules::wxPrinting::PreviewFrame::Initialize' );

    $_[0]->SUPER::Initialize;
}

sub CreateControlBar {
    Wx::LogMessage( 'Wx::DemoModules::wxPrinting::PreviewFrame::CreateControlBar' );

    $_[0]->SetPreviewControlBar
      ( Wx::DemoModules::wxPrinting::ControlBar->new( $_[0]->GetPrintPreview, $_[0] ) );
    $_[0]->GetPreviewControlBar->CreateButtons;
}

package Wx::DemoModules::wxPrinting::ControlBar;

use strict;
use base 'Wx::PlPreviewControlBar';

sub new {
    Wx::LogMessage( 'Wx::DemoModules::wxPrinting::ControlBar::new' );

    $_[0]->SUPER::new( $_[1], 0xffffffff, $_[2], [0, 0], [400, 40] );
}

sub CreateButtons {
    Wx::LogMessage( 'Wx::DemoModules::wxPrinting::ControlBar::CreateButtons' );

    shift->SUPER::CreateButtons;
}

package Wx::DemoModules::wxPrinting::Printout;

use strict;
use base qw(Wx::Printout);

sub new {
  my $class = shift;
  my $canvas = shift;
  my $this = $class->SUPER::new( @_ );

  $this->{CANVAS} = $canvas;

  return $this;
}

sub GetPageInfo {
  my $this = shift;

  Wx::LogMessage( "GetPageInfo" );

  return ( 1, 2, 1, 2 );
}

sub HasPage {
  my $this = shift;

  Wx::LogMessage( "HasPage: %d", $_[0] );

  return $_[0] == 1 || $_[0] == 2;
}

sub OnBeginDocument {
  my $this = shift;

  Wx::LogMessage( "OnBeginDocument: %d, %d", @_ );

  return $this->SUPER::OnBeginDocument( @_ );
}

sub OnEndDocument {
  my $this = shift;

  Wx::LogMessage( "OnEndDocument" );

  return $this->SUPER::OnEndDocument();
}

sub OnBeginPrinting {
  my $this = shift;

  Wx::LogMessage( "OnBeginPrinting" );

  return $this->SUPER::OnBeginPrinting();
}

sub OnEndPrinting {
  my $this = shift;

  Wx::LogMessage( "OnEndPrinting" );

  return $this->SUPER::OnEndPrinting();
}

sub OnPrintPage {
  my( $this, $page ) = @_;
  my $dc = $this->GetDC();

  # we need to set the appropriate scale
  my( $x_size, $y_size ) = ( $Wx::DemoModules::wxPrinting::Canvas::x_size,
                             $Wx::DemoModules::wxPrinting::Canvas::y_size );

  my( $xmargin, $ymargin ) = ( 50, 50 );
  # total size ( borders on top/bottom, left/right )
  my( $xsize, $ysize ) = ( $x_size + 2 * $xmargin, $y_size + 2 * $ymargin );

  # dc size
  my( $xdc, $ydc ) = $dc->GetSizeWH();

  # calculate the scale
  my( $xscale, $yscale ) = ( $xdc / $xsize, $ydc / $ysize );
  my $scale = ( $xscale < $yscale ) ? $xscale : $yscale;
  # center the image
  my( $xoff, $yoff ) = ( ( $xdc - ( $scale * $x_size ) ) / 2.0,
                         ( $ydc - ( $scale * $y_size ) ) / 2.0 );

  # set the DC origin / scale
  $dc->SetUserScale( $scale, $scale );
  $dc->SetDeviceOrigin( $xoff, $yoff );

  if( $page == 1 ) { $this->{CANVAS}->OnDraw( $dc ); }
  if( $page == 2 ) { } # empty page
}

package Wx::DemoModules::wxPrinting::Canvas;

use strict;
use base qw(Wx::ScrolledWindow);

use Wx qw(wxCURSOR_PENCIL wxWHITE);
use Wx::Event qw(EVT_MOTION EVT_LEFT_DOWN EVT_LEFT_UP);

use vars qw($x_size $y_size);

( $x_size, $y_size ) = ( 800, 800 );

sub new {
  my $class = shift;
  my $this = $class->SUPER::new( @_ );

  $this->SetScrollbars( 1, 1, $x_size, $y_size );
  $this->SetBackgroundColour( wxWHITE );
  $this->SetCursor( Wx::Cursor->new( wxCURSOR_PENCIL ) );

  EVT_MOTION( $this, \&OnMouseMove );
  EVT_LEFT_DOWN( $this, \&OnButton );
  EVT_LEFT_UP( $this, \&OnButton );

  return $this;
}

use Wx qw(:font);
use Wx qw(:colour :pen);

sub OnDraw {
  my $this = shift;
  my $dc = shift;
#  my $font = Wx::Font->new( 20, wxSCRIPT, wxSLANT, wxBOLD );

#  $dc->SetFont( $font );
  $dc->DrawRotatedText( "Draw Here", 200, 200, 35 );

  $dc->DrawEllipse( 20, 20, 50, 50 );
  $dc->DrawEllipse( 20, $y_size - 50 - 20, 50, 50 );
  $dc->DrawEllipse( $x_size - 50 - 20, 20, 50, 50 );
  $dc->DrawEllipse( $x_size - 50 - 20, $y_size - 50 - 20, 50, 50 );

  $dc->SetPen( Wx::Pen->new( wxRED, 5, 0 ) );
  # wxGTK does not like DrawLines in this context
  foreach my $i ( @{$this->{LINES}} ) {
    my $prev;

    foreach my $j ( @$i ) {
      if( $j != ${$i}[0] ) {
        $dc->DrawLine( @$prev, @$j );
#       $dc->DrawLines( $i );
      }
      $prev = $j;
    }
  }
}

sub OnMouseMove {
  my( $this, $event ) = @_;

  return unless $event->Dragging;

  my $dc = Wx::ClientDC->new( $this );
  $this->PrepareDC( $dc );
  my $pos = $event->GetLogicalPosition( $dc );
  my( $x, $y ) = ( $pos->x, $pos->y );

  push @{$this->{CURRENT_LINE}}, [ $x, $y ];
  my $elems = @{$this->{CURRENT_LINE}};

  $dc->SetPen( Wx::Pen->new( wxRED, 5, 0 ) );
  $dc->DrawLine( @{$this->{CURRENT_LINE}[$elems-2]},
                 @{$this->{CURRENT_LINE}[$elems-1]} );

}

sub OnButton {
  my( $this, $event ) = @_;

  my $dc = Wx::ClientDC->new( $this );
  $this->PrepareDC( $dc );
  my $pos = $event->GetLogicalPosition( $dc );
  my( $x, $y ) = ( $pos->x, $pos->y );

  if( $event->LeftUp ) {
    push @{$this->{CURRENT_LINE}}, [ $x, $y ];
    push @{$this->{LINES}}, $this->{CURRENT_LINE};
    $this->ReleaseMouse();
  } else {
    $this->{CURRENT_LINE} = [ [ $x, $y ] ];
    $this->CaptureMouse();
  }

  $dc->SetPen( Wx::Pen->new( wxRED, 5, 0 ) );
  $dc->DrawLine( $x, $y, $x, $y );
}

1;

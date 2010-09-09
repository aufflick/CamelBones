#############################################################################
## Name:        lib/Wx/DemoModules/wxGrid.pm
## Purpose:     wxPerl demo helper for wxGrid
## Author:      Mattia Barbon
## Modified by:
## Created:     08/12/2001
## RCS-ID:      $Id: wxGrid.pm 2378 2008-04-26 04:21:45Z mdootson $
## Copyright:   (c) 2001, 2003, 2005-2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

package Wx::DemoModules::wxGrid;

use strict;
use base qw(Wx::Grid);

use Wx::Event qw(EVT_GRID_CELL_LEFT_CLICK EVT_GRID_CELL_RIGHT_CLICK
    EVT_GRID_CELL_LEFT_DCLICK EVT_GRID_CELL_RIGHT_DCLICK
    EVT_GRID_LABEL_LEFT_CLICK EVT_GRID_LABEL_RIGHT_CLICK
    EVT_GRID_LABEL_LEFT_DCLICK EVT_GRID_LABEL_RIGHT_DCLICK
    EVT_GRID_ROW_SIZE EVT_GRID_COL_SIZE EVT_GRID_RANGE_SELECT
    EVT_GRID_CELL_CHANGE EVT_GRID_SELECT_CELL);

use Wx qw(wxRED wxBLUE wxGREEN);

sub new {
  my $class = shift;
  my $this = $class->SUPER::new( $_[0], -1 );

  $this->CreateGrid( 100, 100 );

  my $attr1 = Wx::GridCellAttr->new;
  $attr1->SetBackgroundColour( wxRED );
  my $attr2 = Wx::GridCellAttr->new;
  $attr2->SetTextColour( wxGREEN );

  $this->SetColAttr( 2, $attr1 );
  $this->SetRowAttr( 3, $attr2 );

  $this->SetCellValue( 1, 1, "First" );
  $this->SetCellValue( 2, 2, "Second" );
  $this->SetCellValue( 3, 3, "Third" );
  $this->SetCellValue( 3, 1, "I'm green" );
  $this->SetCellValue( 5, 1, "I will overflow because the cells to my right are empty.");
  $this->SetCellValue( 6, 1, "I can stop overflow on an individual cell basis..");
  $this->SetCellOverflow(6,1,0);
  

  EVT_GRID_CELL_LEFT_CLICK( $this, c_log_skip( "Cell left click" ) );
  EVT_GRID_CELL_RIGHT_CLICK( $this, c_log_skip( "Cell right click" ) );
  EVT_GRID_CELL_LEFT_DCLICK( $this, c_log_skip( "Cell left double click" ) );
  EVT_GRID_CELL_RIGHT_DCLICK( $this, c_log_skip( "Cell right double click" ) );
  EVT_GRID_LABEL_LEFT_CLICK( $this, c_log_skip( "Label left click" ) );
  EVT_GRID_LABEL_RIGHT_CLICK( $this, c_log_skip( "Label right click" ) );
  EVT_GRID_LABEL_LEFT_DCLICK( $this, c_log_skip( "Label left double click" ) );
  EVT_GRID_LABEL_RIGHT_DCLICK( $this, c_log_skip( "Label right double click" ) );

  EVT_GRID_ROW_SIZE( $this, sub {
                       Wx::LogMessage( "%s %s", "Row size", GS2S( $_[1] ) );
                       $_[1]->Skip;
                     } );
  EVT_GRID_COL_SIZE( $this, sub {
                       Wx::LogMessage( "%s %s", "Col size", GS2S( $_[1] ) );
                       $_[1]->Skip;
                     } );

  EVT_GRID_RANGE_SELECT( $this, sub {
                           Wx::LogMessage( "Range %sselect (%d, %d, %d, %d)",
                                           ( $_[1]->Selecting ? '' : 'de' ),
                                           $_[1]->GetLeftCol, $_[1]->GetTopRow,
                                           $_[1]->GetRightCol,
                                           $_[1]->GetBottomRow );
                           $_[0]->ShowSelections;
                           $_[1]->Skip;
                         } );
  EVT_GRID_CELL_CHANGE( $this, c_log_skip( "Cell content changed" ) );
  EVT_GRID_SELECT_CELL( $this, c_log_skip( "Cell select" ) );

  return $this;
}

sub ShowSelections {
    my $this = shift;

    my @cells = $this->GetSelectedCells;
    if( @cells ) {
        Wx::LogMessage( "Cells %s selected", join ', ',
                                                  map { "(" . $_->GetCol .
                                                        ", " . $_->GetRow . ")"
                                                       } @cells );
    } else {
        Wx::LogMessage( "No cells selected" );
    }

    my @tl = $this->GetSelectionBlockTopLeft;
    my @br = $this->GetSelectionBlockBottomRight;
    if( @tl && @br ) {
        Wx::LogMessage( "Blocks %s selected",
                        join ', ',
                        map { "(" . $tl[$_]->GetCol .
                              ", " . $tl[$_]->GetRow . "-" .
                              $br[$_]->GetCol . ", " .
                              $br[$_]->GetRow . ")"
                            } 0 .. $#tl );
    } else {
        Wx::LogMessage( "No blocks selected" );
    }

    my @rows = $this->GetSelectedRows;
    if( @rows ) {
        Wx::LogMessage( "Rows %s selected", join ', ', @rows );
    } else {
        Wx::LogMessage( "No rows selected" );
    }

    my @cols = $this->GetSelectedCols;
    if( @cols ) {
        Wx::LogMessage( "Columns %s selected", join ', ', @cols );
    } else {
        Wx::LogMessage( "No columns selected" );
    }
}

# pretty printer for Wx::GridEvent
sub G2S {
  my $event = shift;
  my( $x, $y ) = ( $event->GetCol, $event->GetRow );

  return "( $x, $y )";
}

# prety printer for Wx::GridSizeEvent
sub GS2S {
  my $event = shift;
  my $roc = $event->GetRowOrCol;

  return "( $roc )";
}

# creates an anonymous sub that logs and skips any grid event
sub c_log_skip {
  my $text = shift;

  return sub {
    Wx::LogMessage( "%s %s", $text, G2S( $_[1] ) );
    $_[0]->ShowSelections;
    $_[1]->Skip;
  };
}

sub tags { [ 'controls/grid'  => 'wxGrid' ] }
sub add_to_tags { 'controls/grid' }
sub title { 'Simple' }

1;

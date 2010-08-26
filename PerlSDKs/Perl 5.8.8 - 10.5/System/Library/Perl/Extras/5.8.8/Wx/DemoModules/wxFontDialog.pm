#############################################################################
## Name:        lib/Wx/DemoModules/wxFontDialog.pm
## Purpose:     wxPerl demo helper for Wx::FontDialog
## Author:      Mattia Barbon
## Modified by:
## Created:     11/02/2001
## RCS-ID:      $Id: wxFontDialog.pm,v 1.1 2006/08/26 15:26:28 mbarbon Exp $
## Copyright:   (c) 2001, 2003, 2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

package Wx::DemoModules::wxFontDialog;

use strict;
use base qw(Wx::DemoModules::lib::BaseModule Class::Accessor::Fast);

use Wx qw(:id);

sub commands {
    my( $self ) = @_;

    return ( { label       => 'Font dialog',
               action      => \&font_dialog,
               },
               );
}

sub font_dialog {
  my( $this ) = @_;
  my $dialog = Wx::FontDialog->new( $this, Wx::FontData->new );

  if( $dialog->ShowModal == wxID_CANCEL ) {
    Wx::LogMessage( "User cancelled the dialog" );
  } else {
    my $data = $dialog->GetFontData;
    my $font = $data->GetChosenFont;

    if( $font ) {
      Wx::LogMessage( "Font: %s", $font->GetFaceName );
      Wx::LogMessage( "Native font info: %s",
                      $data->GetChosenFont->GetNativeFontInfo->ToString );
    }

    my $colour = $data->GetColour;

    if( $colour->Ok ) {
        Wx::LogMessage( "Colour: (%d, %d, %d)",
                        $colour->Red, $colour->Green, $colour->Blue );
    } else {
        Wx::LogMessage( 'No colour' );
    }
  }

  $dialog->Destroy;
}

sub add_to_tags { qw(dialogs) }
sub title { 'wxFontDialog' }

1;

#############################################################################
## Name:        lib/Wx/DemoModules/wxFontPickerCtrl.pm
## Purpose:     wxPerl demo helper for Wx::FontPickerCtrl
## Author:      Mattia Barbon
## Modified by:
## Created:     01/11/2006
## RCS-ID:      $Id: wxFontPickerCtrl.pm,v 1.1 2006/11/01 17:59:43 mbarbon Exp $
## Copyright:   (c) 2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

package Wx::DemoModules::wxFontPickerCtrl;

use strict;
use base qw(Wx::DemoModules::lib::BaseModule Class::Accessor::Fast);

use Wx qw(wxITALIC_FONT wxSWISS_FONT);
use Wx::Event qw(EVT_FONTPICKER_CHANGED);

__PACKAGE__->mk_accessors( qw(picker) );

sub commands {
    my( $self ) = @_;

    return ( { label       => 'Set italic font',
               action      => sub { $self->picker->SetFont( wxITALIC_FONT ) },
               },
               );
}

sub create_control {
    my( $self ) = @_;

    my $fp = Wx::FontPickerCtrl->new( $self, -1, wxSWISS_FONT, [-1, -1],
                                        [-1, -1], $self->style );
    EVT_FONTPICKER_CHANGED( $self, $fp, \&on_change );

    return $self->picker( $fp );
}

sub on_change {
    my( $self, $event ) = @_;
    my $f = $event->GetFont;

    Wx::LogMessage( "Font changed (%s)",
                    $f->GetNativeFontInfo->ToUserString );
}

sub tags { [ 'controls/picker' => 'Picker controls' ] }
sub add_to_tags { qw(controls/picker) }
sub title { 'wxFontPickerCtrl' }

defined &Wx::FontPickerCtrl::new ? 1 : 0;

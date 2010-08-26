#############################################################################
## Name:        lib/Wx/DemoModules/wxColourPickerCtrl.pm
## Purpose:     wxPerl demo helper for Wx::ColourPickerCtrl
## Author:      Mattia Barbon
## Modified by:
## Created:     01/11/2006
## RCS-ID:      $Id: wxColourPickerCtrl.pm,v 1.1 2006/11/01 17:59:43 mbarbon Exp $
## Copyright:   (c) 2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

package Wx::DemoModules::wxColourPickerCtrl;

use strict;
use base qw(Wx::DemoModules::lib::BaseModule Class::Accessor::Fast);

use Wx qw(wxRED wxBLUE);
use Wx::Event qw(EVT_COLOURPICKER_CHANGED);

__PACKAGE__->mk_accessors( qw(picker) );

sub commands {
    my( $self ) = @_;

    return ( { label       => 'Set blue colour',
               action      => sub { $self->picker->SetColour( wxBLUE ) },
               },
             { label       => 'Set magenta colour',
               action      => sub { $self->picker->SetColour( 'magenta' ) },
               },
               );
}

sub create_control {
    my( $self ) = @_;

    my $cp = Wx::ColourPickerCtrl->new( $self, -1, wxRED, [-1, -1],
                                        [-1, -1], $self->style );
    EVT_COLOURPICKER_CHANGED( $self, $cp, \&on_change );

    return $self->picker( $cp );
}

sub on_change {
    my( $self, $event ) = @_;
    my $c = $event->GetColour;

    Wx::LogMessage( "Colour changed (%d, %d, %d)", $c->Red,
                    $c->Green, $c->Blue );
}

sub tags { [ 'controls/picker' => 'Picker controls' ] }
sub add_to_tags { qw(controls/picker) }
sub title { 'wxColourPickerCtrl' }

defined &Wx::ColourPickerCtrl::new ? 1 : 0;

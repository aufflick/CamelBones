#############################################################################
## Name:        lib/Wx/DemoModules/wxGridSizer.pm
## Purpose:     wxPerl demo helper for Wx::GridSizer
## Author:      Mattia Barbon
## Modified by:
## Created:     03/07/2002
## RCS-ID:      $Id: wxGridSizer.pm,v 1.1.1.1 2006/08/14 20:00:44 mbarbon Exp $
## Copyright:   (c) 2002, 2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

package Wx::DemoModules::wxGridSizer;

use strict;
use base qw(Wx::Frame);
use Wx qw(:sizer wxDefaultPosition wxDefaultSize
          wxDEFAULT_DIALOG_STYLE wxRESIZE_BORDER);

sub new {
    my( $class, $parent ) = @_;
    my $self = $class->SUPER::new( undef, -1, "Wx::GridSizer",
                                   wxDefaultPosition, wxDefaultSize,
                                   wxDEFAULT_DIALOG_STYLE|wxRESIZE_BORDER );

    # top level sizer
    my $tsz = Wx::GridSizer->new( 5, 5, 1, 1, );

    for my $i ( 1 .. 25 ) {
        my $grow = ( $i % 2 ) * wxGROW;

        $tsz->Add( Wx::Button->new( $self, -1, "Button $i" ),
                   0, $grow|wxALL, 2 );
    }

    # tell we want automatic layout
    $self->SetAutoLayout( 1 );
    $self->SetSizer( $tsz );
    # size the window optimally and set its minimal size
    $tsz->Fit( $self );
    $tsz->SetSizeHints( $self );

    return $self;
}

sub add_to_tags { qw(sizers) }
sub title { 'wxGridSizer' }

1;

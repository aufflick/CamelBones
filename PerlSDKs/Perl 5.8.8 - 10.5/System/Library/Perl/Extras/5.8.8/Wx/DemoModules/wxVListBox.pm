#############################################################################
## Name:        lib/Wx/DemoModules/wxVListBox.pm
## Purpose:     wxPerl demo helper for Wx::VListBox
## Author:      Mattia Barbon
## Modified by:
## Created:     30/09/2006
## RCS-ID:      $Id: wxVListBox.pm,v 1.1 2006/10/01 13:10:13 mbarbon Exp $
## Copyright:   (c) 2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

use Wx::Html;

package Wx::DemoModules::wxVListBox;

use strict;
use base qw(Wx::DemoModules::lib::BaseModule Class::Accessor::Fast);

use Wx qw(wxLB_MULTIPLE);
use Wx::Event qw(EVT_LISTBOX EVT_LISTBOX_DCLICK);

__PACKAGE__->mk_accessors( qw(htmllistbox) );

sub styles {
    my( $self ) = @_;

    return ( [ wxLB_MULTIPLE, 'Multiple selection' ],
             );
}

sub create_control {
    my( $self ) = @_;

    my $listbox = Wx::DemoModules::wxVListBox::Custom->new
        ( $self, -1, [-1, -1], [400, 400], $self->style );

    EVT_LISTBOX( $self, $listbox, \&OnListBox );
    EVT_LISTBOX_DCLICK( $self, $listbox, \&OnListBoxDoubleClick );

    return $self->htmllistbox( $listbox );
}

sub OnListBox {
    my( $self, $event ) = @_;

    if( $event->GetInt == -1 ) {
        Wx::LogMessage( "List box has no selections any more" );
        return;
    }

    Wx::LogMessage( "ListBox click item is '%d'", $event->GetInt ) ;
}

sub OnListBoxDoubleClick {
    my( $self, $event ) = @_;

    Wx::LogMessage( "ListBox double click item is '%d'", $event->GetInt ) ;
}

sub add_to_tags { qw(controls) }
sub title { 'wxVListBox' }

package Wx::DemoModules::wxVListBox::Custom;

use strict;
use base qw(Wx::PlVListBox);

use Wx qw(:brush);

sub new {
    my( $class, @args ) = @_;
    my $self = $class->SUPER::new( @args );

    $self->SetItemCount( 150 );

    return $self;
}

sub OnMeasureItem {
    my( $self, $item ) = @_;

    return ( ( $item % 3 ) / 2 + 1.5 ) * 25;
}

my @colors = ( Wx::Colour->new( 255, 128, 128 ),
               Wx::Colour->new( 128, 255, 128 ),
               Wx::Colour->new( 128, 128, 255 ),
               );

sub OnDrawItem {
    my( $self, $dc, $rect, $item ) = @_;

    $dc->SetBrush( Wx::Brush->new( $colors[ $item % 3 ], wxSOLID ) );
    $dc->DrawRectangle( $rect->x, $rect->y, $rect->width, $rect->height );

    if( $self->IsSelected( $item ) ) {
        $dc->DrawText( "Selected!", $rect->x + 3, $rect->y + 3 );
    } else {
        $dc->DrawText( $item, $rect->x + 3, $rect->y + 3 );
    }
}

1;

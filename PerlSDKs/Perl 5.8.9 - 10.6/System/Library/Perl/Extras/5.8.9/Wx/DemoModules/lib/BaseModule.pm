#############################################################################
## Name:        lib/Wx/DemoModules/lib/BaseModule.pm
## Purpose:     wxPerl demo helper base class
## Author:      Mattia Barbon
## Modified by:
## Created:     25/08/2006
## RCS-ID:      $Id: BaseModule.pm 2189 2007-08-21 18:15:31Z mbarbon $
## Copyright:   (c) 2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

package Wx::DemoModules::lib::BaseModule;

use strict;
use base qw(Wx::Panel Class::Accessor::Fast);

use Wx qw(:sizer);
use Wx::Event qw(EVT_CHECKBOX EVT_BUTTON EVT_SIZE);

__PACKAGE__->mk_accessors( qw(style control_sizer) );

sub new {
    my( $class, $parent ) = @_;
    my $self = $class->SUPER::new( $parent );

    my $sizer = Wx::BoxSizer->new( wxHORIZONTAL );

    $self->style( 0 );

    # styles
    if( $self->styles ) {
        my $box = Wx::StaticBox->new( $self, -1, 'Styles' );
        my $stysizer = Wx::StaticBoxSizer->new( $box, wxVERTICAL );

        $self->add_styles( $stysizer );
        $sizer->Add( $stysizer, 0, wxGROW|wxALL, 5 );
    }

    # commands
    if( $self->commands ) {
        my $box = Wx::StaticBox->new( $self, -1, 'Commands' );
        my $cmdsizer = Wx::StaticBoxSizer->new( $box, wxVERTICAL );

        $self->add_commands( $cmdsizer );
        $sizer->Add( $cmdsizer, 0, wxGROW|wxALL, 5 );
    }

    # the control (for Mac, the box must be created before the control)
    my $box = Wx::StaticBox->new( $self, -1, 'Control' );
    if( my $control = $self->create_control ) {
        my $ctrlsz = Wx::StaticBoxSizer->new( $box, wxVERTICAL );

        $self->control_sizer( $ctrlsz );
        $ctrlsz->Add( $control, 0,
                      wxALL|wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL,
                      5 );
        $sizer->Add( $ctrlsz, 1, wxGROW|wxALL, 5 );
    } else {
        $box->Destroy;
    }

    $self->SetSizerAndFit( $sizer );

    return $self;
}

sub add_styles {
    my( $self, $sizer ) = @_;

    foreach my $style ( $self->styles ) {
        my $cbox = Wx::CheckBox->new( $self, -1, $style->[1] );
        EVT_CHECKBOX( $self, $cbox, sub {
                          my( $self, $event ) = @_;

                          if( $event->GetInt ) {
                              $self->style( $self->style | $style->[0] );
                          } else {
                              $self->style( $self->style & ~$style->[0] );
                          }
                          $self->recreate_control;
                      } );
        $sizer->Add( $cbox, 0, wxGROW|wxALL, 3 );
    }
}

sub add_commands {
    my( $self, $sizer ) = @_;

    foreach my $command ( $self->commands ) {
        if( $command->{with_value} ) {
            my $sz = Wx::BoxSizer->new( wxHORIZONTAL );
            my $but = Wx::Button->new( $self, -1, $command->{label} );
            my @val = map { Wx::TextCtrl->new( $self, -1, '' ) }
                          ( 1 .. $command->{with_value} );
            $sz->Add( $but, 1, wxRIGHT, 5 );
            $sz->Add( $_, 1 ) foreach @val;
            EVT_BUTTON( $self, $but, sub {
                            $command->{action}->( map { $_->GetValue } @val );
                        } );
            $sizer->Add( $sz, 0, wxGROW|wxALL, 3 );
        } else {
            my $but = Wx::Button->new( $self, -1, $command->{label} );
            EVT_BUTTON( $self, $but, $command->{action} );
            $sizer->Add( $but, 0, wxGROW|wxALL, 3 );
        }
    }
}

sub recreate_control {
    my( $self ) = @_;

    if( $self->control_sizer ) {
        # work with 2.5.3 amd 2.6.3 (and hopefully other versions)
        if( $self->control_sizer->GetChildren ) {
            my $window = $self->control_sizer->GetItem( 0 )->GetWindow;
            $self->control_sizer->Detach( 0 );
            $window->Destroy;
        }

        $self->control_sizer->Add
          ( $self->create_control, 0, 
            wxALL|wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL, 5 );
        $self->Layout;
    }
}

sub styles { }
sub commands { }
sub create_control { }

1;

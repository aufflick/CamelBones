#############################################################################
## Name:        lib/Wx/DemoModules/wxBookCtrl.pm
## Purpose:     wxPerl demo helper for Wx::*book
## Author:      Mattia Barbon
## Modified by:
## Created:     01/10/2006
## RCS-ID:      $Id: wxBookCtrl.pm,v 1.1 2006/11/01 17:59:43 mbarbon Exp $
## Copyright:   (c) 2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

# base class
package Wx::DemoModules::wxBookCtrl;

use strict;
use base qw(Wx::DemoModules::lib::BaseModule Class::Accessor::Fast);

use Wx qw(:bookctrl wxNOT_FOUND wxYES_NO wxYES wxICON_QUESTION);

__PACKAGE__->mk_accessors( qw(bookctrl) );

sub styles {
    my( $self ) = @_;

    return ( [ wxBK_TOP, 'Top' ],
             [ wxBK_BOTTOM, 'Bottom' ],
             [ wxBK_LEFT, 'Left' ],
             [ wxBK_RIGHT, 'Right' ],
             );
}

sub commands {
    my( $self ) = @_;

    return ( { label       => 'Select page',
               with_value  => 1,
               action      => sub { $self->bookctrl->SetSelection( $_[0] ) },
               },
             { label       => 'Set page text',
               with_value  => 2,
               action      => sub { $self->bookctrl
                                      ->SetPageText( $_[0], $_[1] ) },
               },
             { label       => 'Set page image',
               with_value  => 2,
               action      => sub { $self->bookctrl
                                      ->SetPageImage( $_[0], $_[1] ) },
               },
             { label       => 'Clear',
               action      => sub { $self->bookctrl->DeleteAllPages },
               },
             { label       => 'Append',
               with_value  => 1,
               action      => sub { $self->on_add_page( @_ ) },
               },
               );
}

sub on_add_page {
    my( $self, $string ) = @_;

    $self->add_page( $self->bookctrl, $string );
}

sub add_page {
    my( $self, $bookctrl, $string ) = @_;
    my $count = $bookctrl->GetPageCount;
    my $page = Wx::DemoModules::wxBookCtrl::Page->new( $bookctrl, $count );

    $bookctrl->AddPage( $page, $string, 0, $count );
}

sub populate_control {
    my( $self, $book ) = @_;
    my( @labels ) = qw(First Second Third Fourth);

    my $imagelist = Wx::ImageList->new( 16, 16 );
    foreach my $art ( qw(wxART_GO_BACK wxART_GO_FORWARD wxART_GO_UP
                         wxART_GO_DOWN wxART_PRINT wxART_HELP
                         wxART_TIP) ) {
        $imagelist->Add( Wx::ArtProvider::GetBitmap( $art, 'wxART_OTHER_C',
                                                     [16, 16] ) );
    }

    $book->AssignImageList( $imagelist );

    foreach my $i ( 0 .. $#labels ) {
        $self->add_page( $book, $labels[$i] );
    }
}

sub OnPageChanged {
    my( $self, $event ) = @_;

    Wx::LogMessage( "Notebook selection is %d", $event->GetSelection );
}

sub OnPageChanging {
    my( $self, $event ) = @_;
    my( $oldSelection ) = $event->GetOldSelection;

    if( $oldSelection == 2 ) {
        my $text = <<EOT;
This demonstrates how a program may prevent the
page change from taking place - if you select
[No] the current page will stay the third one
EOT
        if( Wx::MessageBox( $text, 'What to do?',
                            wxICON_QUESTION|wxYES_NO, $self ) != wxYES ) {
            $event->Veto();
            return;
        }
    }

    Wx::LogMessage( "Notebook selection is being changed from %d",
                    $oldSelection );
}

sub tags { [ 'controls/book' => 'Book controls' ] }

package Wx::DemoModules::wxBookCtrl::Page;

use strict;
use base qw(Wx::Panel);

sub new {
    my( $class, $parent, $index ) = @_;
    my $self = $class->SUPER::new( $parent );

    Wx::StaticText->new
        ( $self, -1, sprintf( "This is page %d of the Notebook control",
                              $index ),
          [-1, -1], [250, 200] );

    return $self;
}

package Wx::DemoModules::wxNotebook;

use strict;
use base qw(Wx::DemoModules::wxBookCtrl);

use Wx::Event qw(EVT_NOTEBOOK_PAGE_CHANGED EVT_NOTEBOOK_PAGE_CHANGING);

sub create_control {
    my( $self ) = @_;

    my $nb = Wx::Notebook->new( $self, -1, [-1, -1],
                                [-1, -1], $self->style );
    $self->populate_control( $nb );

    EVT_NOTEBOOK_PAGE_CHANGED( $self, $nb, $self->can( 'OnPageChanged' ) );
    EVT_NOTEBOOK_PAGE_CHANGING( $self, $nb, $self->can( 'OnPageChanging' ) );

    return $self->bookctrl( $nb );
}

sub add_to_tags { qw(controls/book) }
sub title { 'wxNotebook' }
sub file { __FILE__ }

package Wx::DemoModules::wxChoicebook;

use strict;
use base qw(Wx::DemoModules::wxBookCtrl);

use Wx::Event qw(EVT_CHOICEBOOK_PAGE_CHANGED EVT_CHOICEBOOK_PAGE_CHANGING);

sub create_control {
    my( $self ) = @_;

    my $nb = Wx::Choicebook->new( $self, -1, [-1, -1],
                                  [-1, -1], $self->style );
    $self->populate_control( $nb );

    EVT_CHOICEBOOK_PAGE_CHANGED( $self, $nb, $self->can( 'OnPageChanged' ) );
    EVT_CHOICEBOOK_PAGE_CHANGING( $self, $nb, $self->can( 'OnPageChanging' ) );

    return $self->bookctrl( $nb );
}

sub add_to_tags { qw(controls/book) }
sub title { 'wxChoicebook' }
sub file { __FILE__ }

package Wx::DemoModules::wxListbook;

use strict;
use base qw(Wx::DemoModules::wxBookCtrl);

use Wx::Event qw(EVT_LISTBOOK_PAGE_CHANGED EVT_LISTBOOK_PAGE_CHANGING);

sub create_control {
    my( $self ) = @_;

    my $nb = Wx::Listbook->new( $self, -1, [-1, -1],
                                [-1, -1], $self->style );
    $self->populate_control( $nb );

    EVT_LISTBOOK_PAGE_CHANGED( $self, $nb, $self->can( 'OnPageChanged' ) );
    EVT_LISTBOOK_PAGE_CHANGING( $self, $nb, $self->can( 'OnPageChanging' ) );

    return $self->bookctrl( $nb );
}

sub add_to_tags { qw(controls/book) }
sub title { 'wxListbook' }
sub file { __FILE__ }

package Wx::DemoModules::wxTreebook;

use strict;
use base qw(Wx::DemoModules::wxBookCtrl);

use Wx::Event qw(EVT_TREEBOOK_PAGE_CHANGED EVT_TREEBOOK_PAGE_CHANGING);

sub create_control {
    my( $self ) = @_;

    my $nb = Wx::Treebook->new( $self, -1, [-1, -1],
                                [-1, -1], $self->style );
    $self->populate_control( $nb );

    EVT_TREEBOOK_PAGE_CHANGED( $self, $nb, $self->can( 'OnPageChanged' ) );
    EVT_TREEBOOK_PAGE_CHANGING( $self, $nb, $self->can( 'OnPageChanging' ) );

    return $self->bookctrl( $nb );
}

sub add_to_tags { qw(controls/book) }
sub title { 'wxTreebook' }
sub file { __FILE__ }

package Wx::DemoModules::wxToolbook;

use strict;
use base qw(Wx::DemoModules::wxBookCtrl);

use Wx::Event qw(EVT_TOOLBOOK_PAGE_CHANGED EVT_TOOLBOOK_PAGE_CHANGING);

sub create_control {
    my( $self ) = @_;

    my $nb = Wx::Toolbook->new( $self, -1, [-1, -1],
                                [-1, -1], $self->style );
    $self->populate_control( $nb );

    EVT_TOOLBOOK_PAGE_CHANGED( $self, $nb, $self->can( 'OnPageChanged' ) );
    EVT_TOOLBOOK_PAGE_CHANGING( $self, $nb, $self->can( 'OnPageChanging' ) );

    return $self->bookctrl( $nb );
}

sub add_to_tags { qw(controls/book) }
sub title { 'wxToolbook' }
sub file { __FILE__ }

1;

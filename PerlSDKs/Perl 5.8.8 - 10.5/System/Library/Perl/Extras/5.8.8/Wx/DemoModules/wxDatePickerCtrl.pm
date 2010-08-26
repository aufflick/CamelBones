#############################################################################
## Name:        lib/Wx/DemoModules/wxDatePickerCtrl.pm
## Purpose:     wxPerl demo helper for Wx::DatePickerCtrl
## Author:      Mattia Barbon
## Modified by:
## Created:     18/03/2005
## RCS-ID:      $Id: wxDatePickerCtrl.pm,v 1.2 2006/11/01 17:59:43 mbarbon Exp $
## Copyright:   (c) 2005-2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

use Wx::Calendar;

package Wx::DemoModules::wxDatePickerCtrl;

use strict;
use base qw(Wx::Panel);

use Wx qw(:sizer :datepicker);
use Wx::Event qw(EVT_DATE_CHANGED);

sub new {
  my $class = shift;
  my $this = $class->SUPER::new( $_[0], -1 );

  my $sizer = Wx::BoxSizer->new( wxVERTICAL );

  #                                    8 Jan 1979
  my $date = Wx::DateTime->newFromDMY( 8, 0, 1979, 1, 1, 1, 1 );

  my $calendar = Wx::DatePickerCtrl->new( $this, -1, $date );
  $calendar->SetRange( $date, Wx::DateTime->new );

  my $textctrl = Wx::TextCtrl->new( $this, -1, $date->FormatDate );

  $sizer->Add( $calendar, 0, wxALL, 10 );
  $sizer->Add( $textctrl, 0, wxGROW|wxALL, 10 );

  EVT_DATE_CHANGED( $this, $calendar,
                    sub {
                        $textctrl->SetValue
                          ( $_[1]->GetDate->FormatDate );
                    } );

  $this->SetSizer( $sizer );

  return $this;
}

sub add_to_tags { qw(controls/picker) }
sub title { 'wxDatePickerCtrl' }

1;

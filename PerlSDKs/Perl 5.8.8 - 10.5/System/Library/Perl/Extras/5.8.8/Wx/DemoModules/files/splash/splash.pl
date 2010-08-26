#!/usr/bin/perl -w
#############################################################################
## Name:        lib/Wx/DemoModules/files/splash/splash.pl
## Purpose:     Show how to use splash screens
## Author:      Mattia Barbon
## Modified by:
## Created:     05/06/2002
## RCS-ID:      $Id: splash.pl,v 1.1.1.1 2006/08/14 20:00:52 mbarbon Exp $
## Copyright:   (c) 2002-2004, 2006 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

use Wx::Perl::SplashFast ( 'logo.jpg', 10000 );
use Wx;

my $app = Wx::SimpleApp->new;
sleep 5; # emulate the delay for a loooong initialization
my $frame = Wx::Frame->new( undef, -1, "Close me!" );
$frame->SetIcon( Wx::GetWxPerlIcon() );
$frame->Show;
$app->MainLoop;

exit 0;

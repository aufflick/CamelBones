#############################################################################
## Name:        build/Wx/build/Config/nmake.mak
## Purpose:     extracts some flag information from makevc.env
## Author:      Mattia Barbon
## Modified by:
## Created:     29/10/2000
## RCS-ID:      $Id: nmake.mak,v 1.3 2004/10/19 20:28:05 mbarbon Exp $
## Copyright:   (c) 2000 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

NOPCH=1
WXUSINGDLL=1

!include $(WXWIN)\src\makevc.env

version:
	echo $(WXVERSION)$(wxRELEASE_NUMBER)

wxdir:
    echo $(WXWIN)

cxxflags:
    echo $(CPPFLAGS) -D__WXMSW__

linkflags:
    echo $(LINKFLAGS)

libs:
    echo $(LIBS)

# this one is for import library ( not in wx-config )
implib:
   echo $(WXLIB)

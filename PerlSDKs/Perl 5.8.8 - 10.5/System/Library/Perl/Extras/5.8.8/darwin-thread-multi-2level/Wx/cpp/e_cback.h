/////////////////////////////////////////////////////////////////////////////
// Name:        cpp/e_cback.h
// Purpose:     callback helper class for events
// Author:      Mattia Barbon
// Modified by:
// Created:     29/10/2000
// RCS-ID:      $Id: e_cback.h,v 1.8 2005/02/26 11:31:02 mbarbon Exp $
// Copyright:   (c) 2000-2001, 2005 Mattia Barbon
// Licence:     This program is free software; you can redistribute it and/or
//              modify it under the same terms as Perl itself
/////////////////////////////////////////////////////////////////////////////

#ifndef _WXPERL_E_CBACK_H
#define _WXPERL_E_CBACK_H

#if WXPERL_W_VERSION_GE( 2, 5, 4 )
typedef void (wxObject::* wxPliObjectEventFunction)(wxEvent&);

#define wxPliCastEvtHandler( e ) \
    ((wxObjectEventFunction)(wxPliObjectEventFunction) e)
#else
#define wxPliCastEvtHandler( e ) \
    ((wxObjectEventFunction) e)
#endif

class wxPliEventCallback : public wxObject
{
public:
    wxPliEventCallback( SV* method, SV* self );
    ~wxPliEventCallback();

    void Handler( wxEvent& event );
private:
    SV* m_method;
    SV* m_self;
};

#endif // _WXPERL_E_CBACK_H

// Local variables: //
// mode: c++ //
// End: //

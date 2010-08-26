# Makefile for CamelBones - a Cocoa/Perl bridge.

# Include autoconf-generated variables
include GNUmakefile.conf

# Get the files list
include GNUmakefile.files

# Get the Perl info
include GNUmakefile.perl

ifdef GNUSTEP_ROOT
    include GNUmakefile.gnustep
else
    include GNUmakefile.macosx
endif

ifeq ("$(HAVE_LIBAVCALL)", "-NO-")
	include GNUmakefile.ffcall
endif


# -*- Mode: makefile; -*-

PERL_ARCHLIB = $(shell $(PERL) -MConfig -e 'print $$Config{archlib}')
PERL_PRIVLIB = $(shell $(PERL) -MConfig -e 'print $$Config{privlib}')
PERL_ARCH_VER = $(shell $(PERL) -MConfig -e 'print $$Config{archname}."-".$$Config{version}')

# Uncomment the following to use a static libperl.a
# libCamelBones_OBJ_FILES += \
#	$(PERL_ARCHLIB)/CORE/libperl.a

# Additional library paths usually needed to link against libperl
PERL_LIB_DIRS = -L$(PERL_ARCHLIB)/CORE/
PERL_LIBS = $(LIBPERL)

PERL_CFLAGS := $(shell eval `perl -V:ccflags | sed "s/-arch ppc//" | sed "s/-arch i386//"`; echo $$ccflags) -I $(PERL_ARCHLIB)/CORE

# Object files linked to the dylib
PERL_OBJ = \
	$(PERL_ARCHLIB)/auto/DynaLoader/DynaLoader.a


#if defined(__cplusplus) && !defined(PERL_OBJECT)
#define is_cplusplus
#endif

#ifdef is_cplusplus
extern "C" {
#endif

#include <EXTERN.h>
#include <perl.h>
#ifdef PERL_OBJECT
#define NO_XSLOCKS
#include <XSUB.h>
#include "win32iop.h"
#include <fcntl.h>
#include <perlhost.h>
#endif
#ifdef is_cplusplus
}
#  ifndef EXTERN_C
#    define EXTERN_C extern "C"
#  endif
#else
#  ifndef EXTERN_C
#    define EXTERN_C extern
#  endif
#endif

EXTERN_C void xs_init (pTHXo);

EXTERN_C void boot_DynaLoader (pTHXo_ CV* cv);
EXTERN_C void boot_CamelBones (pTHXo_ CV* cv);
EXTERN_C void boot_CamelBones__Foundation (pTHXo_ CV* cv);
EXTERN_C void boot_CamelBones__AppKit (pTHXo_ CV* cv);

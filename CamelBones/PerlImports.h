//
//  PerlImports.h
//  CamelBones
//
//  Copyright (c) 2004 Sherm Pendley. All rights reserved.
//

#ifdef STRINGIFY
#undef STRINGIFY
#endif

#ifdef _
#undef _
#endif

#define PERL_NO_GET_CONTEXT     /* we want efficiency */ 
#include "EXTERN.h"
#ifdef PERL_TIGER
#define HAS_BOOL
#endif
#include "perl.h"
#include "XSUB.h"

extern PerlInterpreter *_CBPerlInterpreter;

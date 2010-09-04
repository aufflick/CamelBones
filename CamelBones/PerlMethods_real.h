//
//  PerlMethods.h
//  CamelBones
//
//  Copyright (c) 2004 Sherm Pendley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PerlImports.h"

// Get information about a Perl object
extern NSString* REAL_CBGetMethodNameForSelector(void* sv, SEL selector);
extern NSString* REAL_CBGetMethodArgumentSignatureForSelector(void* sv, SEL selector);
extern NSString* REAL_CBGetMethodReturnSignatureForSelector(void* sv, SEL selector);

// IMPs registered as native methods
extern id REAL_CBPerlIMP(id self, SEL _cmd, ...);
extern void REAL_CBPerlIMP_stret(void* returnBuffer, id self, SEL _cmd, ...);
#ifdef __i386__
extern double REAL_CBPerlIMP_fpret(id self, SEL _cmd, ...);
#endif

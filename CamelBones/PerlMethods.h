//
//  PerlMethods.h
//  CamelBones
//
//  Copyright (c) 2004 Sherm Pendley. All rights reserved.
//

#import <Foundation/Foundation.h>

// Get information about a Perl object
extern NSString* (*CBGetMethodNameForSelector)(void* sv, SEL selector);
extern NSString* (*CBGetMethodArgumentSignatureForSelector)(void* sv, SEL selector);
extern NSString* (*CBGetMethodReturnSignatureForSelector)(void* sv, SEL selector);

// IMPs registered as native methods
extern id (*CBPerlIMP)(id self, SEL _cmd, ...);
extern void (*CBPerlIMP_stret)(void* returnBuffer, id self, SEL _cmd, ...);
#ifdef __i386__
extern double (*CBPerlIMP_fpret)(id self, SEL _cmd, ...);
#endif

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

// IMP registered as a native method
extern id REAL_CBPerlIMP(id self, SEL _cmd, ...);


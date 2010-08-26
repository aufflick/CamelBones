//
//  Wrappers.h
//  CamelBones
//
//  Copyright (c) 2004 Sherm Pendley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PerlImports.h"

// Create a Perl object that "wraps" an Objective-C object
extern void* REAL_CBCreateWrapperObject(id obj);
extern void* REAL_CBCreateWrapperObjectWithClassName(id obj, NSString* className);

// Create a new Perl object blessed into the specified package
extern void* REAL_CBCreateObjectOfClass(NSString *className);


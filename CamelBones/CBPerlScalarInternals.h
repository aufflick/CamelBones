//
//  CBPerlScalarInternals.h
//  Camel Bones - a bare-bones Perl bridge for Objective-C
//  Originally written for ShuX
//
//  Copyright (c) 2002 Sherm Pendley. All rights reserved.

#import "CBPerlScalar.h"

@interface CBPerlScalar (Internals)

+ (CBPerlScalar *) scalarWithSV: (void *)newSV;
- (CBPerlScalar *) initScalarWithSV: (void *)newSV;

- (void *)getSV;

@end

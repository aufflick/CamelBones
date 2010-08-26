//
//  CBPerlArrayInternals.h
//  Camel Bones - a bare-bones Perl bridge for Objective-C
//  Originally written for ShuX
//
//  Copyright (c) 2002 Sherm Pendley. All rights reserved.
//

#import "PerlImports.h"

// Private methods
@interface CBPerlArray (CBPerlArrayPrivate)

+ (id) arrayWithAV: (AV*)theAV;
- (id) initWithAV: (AV*)theAV;

@end

//
//  CBPerlHashInternals.h
//  Camel Bones - a bare-bones Perl bridge for Objective-C
//  Originally written for ShuX
//
//  Copyright (c) 2002 Sherm Pendley. All rights reserved.
//

#import "PerlImports.h"

// Private methods
@interface CBPerlHash (CBPerlHashPrivate)

+ (id) dictionaryWithHV: (HV*)theHV;
- (id) initWithHV: (HV*)theHV;

- (SV *) keyWithId: (id)theId;

@end

@interface CBPerlHashKeyEnumerator (CBPerlHashKeyEnumeratorPrivate)

+ (id) enumeratorWithHV:(HV*)theHV;
- (id) initEnumeratorWithHV:(HV*)theHV;

@end

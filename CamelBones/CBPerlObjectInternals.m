//
//  CBPerlObjectInternals.m
//  Camel Bones - a bare-bones Perl bridge for Objective-C
//  Originally written for ShuX
//
//  Copyright (c) 2002 Sherm Pendley. All rights reserved.

#import "CBPerlObjectInternals.h"
#import "PerlImports.h"
#import "Conversions_real.h"

@implementation CBPerlObject (Internals)

+ (CBPerlObject *) objectWithSV: (void *)newSV {
    return [[[CBPerlObject alloc] initObjectWithSV: newSV] autorelease];
}

- (CBPerlObject *) initObjectWithSV: (void *)newSV {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    self = [super init];

    // Is it an object reference?
    if (self && sv_isobject((SV*)newSV)) {
        HV *stash;
        char *packageName;

        // Store the object and its reference
        _mySV = newSV;
        _myHV = SvRV((SV*)newSV);

        // Increment the reference count to keep Perl from releasing it
        SvREFCNT_inc((SV *)_mySV);

        // Find the class name
        stash = SvSTASH((HV*)_myHV);
        packageName = HvNAME(stash);
        className = [[NSString alloc] initWithUTF8String: packageName];
        return self;
    }

    return nil;
}

- (void *)getSV {
    return (void*)_mySV;
}

- (void *)getHV {
    return (void*)_myHV;
}

@end

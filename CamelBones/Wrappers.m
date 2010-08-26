//
//  Wrappers.m
//  CamelBones
//
//  Copyright (c) 2004 Sherm Pendley. All rights reserved.
//

#import "Wrappers_real.h"
#import "PerlImports.h"

// Create a Perl object that wraps an Objective-C object
// The wrapper will be blessed into the "NSObject" package.
void* REAL_CBCreateWrapperObject(id obj) {
    return (void*)REAL_CBCreateWrapperObjectWithClassName(obj, [obj className]);
}

// Create a Perl object that wraps an Objective-C object.
// The wrapper will be blessed into className.
void* REAL_CBCreateWrapperObjectWithClassName(id obj, NSString* className) {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV *sv = REAL_CBCreateObjectOfClass(className);
    const char *key = "NATIVE_OBJ";
    hv_store((HV*)SvRV(sv), key, strlen(key), newSViv((int)obj), 0);
    return (void*)sv;
}

// Create a new Perl object blessed into the specified package
void* REAL_CBCreateObjectOfClass(NSString *className) {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    HV *hv = newHV();
    SV *ret = newRV_inc((SV *)hv);
    sv_bless(ret, gv_stashpv([className UTF8String], 0));
    return (void*)ret;
}


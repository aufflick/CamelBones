//
//  CBPerlScalar.m
//  Camel Bones - a bare-bones Perl bridge for Objective-C
//  Originally written for ShuX
//
//  Copyright (c) 2002 Sherm Pendley. All rights reserved.
//

#import "CBPerlArray.h"
#import "CBPerlArrayInternals.h"
#import "CBPerlHash.h"
#import "CBPerlHashInternals.h"
#import "CBPerlObject.h"
#import "CBPerlObjectInternals.h"
#import "CBPerlScalar.h"
#import "CBPerlScalarInternals.h"

@implementation CBPerlScalar (Overrides)

SV *_sv;

// Returns an autoreleased handle to a Perl scalar named varName.
// Returns nil of no such scalar exists.
+ (CBPerlScalar *) namedScalar: (NSString *)varName {
    return [[[CBPerlScalar alloc] initNamedScalar: varName] autorelease];
}

// Returns an autoreleased handle to a Perl scalar named varName, creating a
// new scalar if necessary with the default value def. If def is nil, a newly-
// created scalar will be initialized to Perl's undef.
// Returns nil if the named object does not exist, and could not be created
+ (CBPerlScalar *) namedScalar: (NSString *)varName withDefaultString: (NSString *)def {
    return [[[CBPerlScalar alloc] initNamedScalar: varName withDefaultString: def] autorelease];
}
+ (CBPerlScalar *) namedScalar: (NSString *)varName withDefaultInteger: (long)def {
    return [[[CBPerlScalar alloc] initNamedScalar: varName withDefaultInteger: def] autorelease];
}
+ (CBPerlScalar *) namedScalar: (NSString *)varName withDefaultDouble: (double)def {
    return [[[CBPerlScalar alloc] initNamedScalar: varName withDefaultDouble: def] autorelease];
}

// Returns an autoreleased handle to a Perl scalar named varName, creating a
// new scalar if necessary, that refers to target. If target is nil, the newly-
// created scalar will be initialized to Perl's undef.
// Returns nil if the named object does not exist, and could not be created
+ (CBPerlScalar *) namedReference: (NSString *)varName toArray: (CBPerlArray *)target {
    return [[[CBPerlScalar alloc] initNamedReference: varName toArray: target] autorelease];
}
+ (CBPerlScalar *) namedReference: (NSString *)varName toHash: (CBPerlHash *)target {
    return [[[CBPerlScalar alloc] initNamedReference: varName toHash: target] autorelease];
}
+ (CBPerlScalar *) namedReference: (NSString *)varName toObject: (CBPerlObject *)target {
    return [[[CBPerlScalar alloc] initNamedReference: varName toObject: target] autorelease];
}
+ (CBPerlScalar *) namedReference: (NSString *)varName toNativeObject: (NSObject *)target {
    return [[[CBPerlScalar alloc] initNamedReference: varName toNativeObject: target] autorelease];
}

// Returns a handle to a Perl scalar named varName.
// Returns nil of no such scalar exists.
- (CBPerlScalar *) initNamedScalar: (NSString *)varName {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV *newSV = get_sv([varName UTF8String], FALSE);

    if (newSV != NULL) {
        self = [super init];
        _sv = newSV;
        return self;
    } else {
        return nil;
    }
}

// Returns a handle to a Perl scalar named varName, creating a
// new scalar if necessary with the default value def. If def is nil, a newly-
// created scalar will be initialized to Perl's undef.
// Returns nil if the named object does not exist, and could not be created
- (CBPerlScalar *) initNamedScalar: (NSString *)varName withDefaultString: (NSString *)def {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV *newSV = get_sv([varName UTF8String], FALSE);

    if (newSV != NULL) {
        self = [super init];
        _sv = newSV;
        return self;
    } else {

        newSV = get_sv([varName UTF8String], TRUE);
        if (newSV != NULL) {
            _sv = newSV;
            sv_setpv_mg(_sv, [def UTF8String]);
            return self;
        } else {
            return nil;
        }
    }
}
- (CBPerlScalar *) initNamedScalar: (NSString *)varName withDefaultInteger: (long)def {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV *newSV = get_sv([varName UTF8String], FALSE);

    if (newSV != NULL) {
        self = [super init];
        _sv = newSV;
        return self;
    } else {

        newSV = get_sv([varName UTF8String], TRUE);
        if (newSV != NULL) {
            _sv = newSV;
            sv_setiv_mg(_sv, def);
            return self;
        } else {
            return nil;
        }
    }
}
- (CBPerlScalar *) initNamedScalar: (NSString *)varName withDefaultDouble: (double)def {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV *newSV = get_sv([varName UTF8String], FALSE);

    if (newSV != NULL) {
        self = [super init];
        _sv = newSV;
        return self;
    } else {

        newSV = get_sv([varName UTF8String], TRUE);
        if (newSV != NULL) {
            _sv = newSV;
            sv_setnv_mg(_sv, def);
            return self;
        } else {
            return nil;
        }
    }
}

// Returns a handle to a Perl scalar named varName, creating a
// new scalar if necessary, that refers to target. If target is nil, the newly-
// created scalar will be initialized to Perl's undef.
// Returns nil if the named object does not exist, and could not be created
- (CBPerlScalar *) initNamedReference: (NSString *)varName toArray: (NSArray *)target {
    // TODO
    return nil;
}
- (CBPerlScalar *) initNamedReference: (NSString *)varName toHash: (NSDictionary *)target {
    // TODO
    return nil;
}
- (CBPerlScalar *) initNamedReference: (NSString *)varName toObject: (CBPerlObject *)target {
    // TODO
    return nil;
}
- (CBPerlScalar *) initNamedReference: (NSString *)varName toNativeObject: (NSObject *)target {
    // TODO
    return nil;
}

    // Query the scalar's properties
- (BOOL) isInteger {
    return (SvIOK(_sv) ? TRUE : FALSE);
}
- (BOOL) isFloat {
    return (SvNOK(_sv) ? TRUE : FALSE);
}
- (BOOL) isString {
    return (SvPOK(_sv) ? TRUE : FALSE);
}

- (BOOL) isRef {
    return (SvROK(_sv) ? TRUE : FALSE);
}
- (BOOL) isArrayRef {
    // TODO
    return FALSE;
}
- (BOOL) isHashRef {
    // TODO
    return FALSE;
}
- (BOOL) isObjectRef {
    // TODO
    return FALSE;
}

- (BOOL) isTrue {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    return (SvTRUE(_sv) ? TRUE : FALSE);
}
- (BOOL) isDefined {
    // TODO
    return FALSE;
}


- (int) refType {
    return (int)SvTYPE(SvRV(_sv));
}


// Get/set this variable with NSStrings
- (NSString *) getString {
    // TODO
    return nil;
}
- (void) setToString: (NSString *)newValue {
    // TODO
}

// Get/set this variable with ints and floats
- (long) getInt {
    // TODO
    return 0;
}
- (void) setToInt: (long)newValue {
    // TODO
}
- (double) getFloat {
    // TODO
    return 0.0;
}
- (void) setToFloat: (double)newValue {
    // TODO
}

// Get/set reference target
- (id) dereference {
    // TODO
    if (SvROK(_sv)) {
        // Figure out to what the reference points
        // and return the right kind of object
        return nil;
    } else {
        return nil;
    }
}
- (void) setTargetToArray: (NSArray *)target {
    // TODO
}
- (void) setTargetToHash: (NSDictionary *)target {
    // TODO
}
- (void) setTargetToObject: (CBPerlObject *)target {
    // TODO
}
- (void) setTargetToNativeObject: (NSObject *)target {
    // TODO
}
- (void) setTargetToPointer: (void *)target {
    // TODO
}

// String-oriented regex search/replace functions
- (void) replace: (NSString *)pattern with:(NSString *)newString {
    // TODO
}
- (void) replace: (NSString *)pattern with:(NSString *)newString usingFlags:(NSString *)flags {
    // TODO
}

// Simple boolean test of a pattern match
// Similar to "m/foo/" in Perl.
- (BOOL) matches: (NSString *)pattern {
    // TODO
    return NO;
}
- (BOOL) matches: (NSString *)pattern usingFlags:(NSString *)flags {
    // TODO
    return NO;
}

// More advanced pattern match that returns sub-patterns in an array
// Similar to "m/([a-zA-Z]+)\s*([a-zA-Z]+)" in perl.
- (NSArray *) getMatches: (NSString *)pattern {
    // TODO
    return nil;
}
- (NSArray *) getMatches: (NSString *)pattern usingFlags:(NSString *)flags {
    // TODO
    return nil;
}

@end

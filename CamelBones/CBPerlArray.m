//
//  CBPerlArray.m
//  Camel Bones - a bare-bones Perl bridge for Objective-C
//  Originally written for ShuX
//
//  Copyright (c) 2002 Sherm Pendley. All rights reserved.
//

#import "CBPerlArray.h"
#import "CBPerlArrayInternals.h"
#import "PerlImports.h"
#import "Conversions_real.h"

@implementation CBPerlArray (Overrides)

#ifdef GNUSTEP
- (id) initWithCapacity: (unsigned int) anInt
{
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    _myArray = newAV();
    if (!_myArray) {
      [self release];
      self = nil;
    }

    return self;
}
#endif /* GNUSTEP */

// Workaround for a bug. This method is not documented *anywhere*, but
// it's called if an object of this class is used with NSUserDefaults
- (void)getObjects:(id*)objects inRange:(NSRange)range {
	[self getObjects:objects range:range];
}


// Required primitive methods
- (unsigned)count {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    return av_len((AV*)_myArray)+1;
}
- (id)objectAtIndex:(unsigned)index {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV **svp;
    svp = av_fetch((AV*)_myArray, index, 0);
    return svp ? REAL_CBDerefSVtoID(*svp) : nil;
}

- (void)addObject:(id)anObject {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV *obj = REAL_CBDerefIDtoSV(anObject);
    av_push((AV*)_myArray, obj);

    // Retain the original if a wrapper was stored
	if (sv_isobject(obj) && sv_derived_from(obj, "NSObject")) {
		[anObject retain];
	}
}
- (void)insertObject:(id)anObject atIndex:(unsigned)index {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    unsigned i;
    unsigned lastIndex;
    SV **svp;

    lastIndex = av_len((AV*)_myArray);
    av_extend((AV*)_myArray, lastIndex+2);
    for(i=lastIndex; i>=index; i--) {
        svp = av_fetch((AV*)_myArray, i, 0);
        if (svp) {
            av_store((AV*)_myArray, i+1, *svp);
        }
    }
    svp = av_store((AV*)_myArray, index, REAL_CBDerefIDtoSV(anObject));

    if (svp && sv_isobject(*svp) && sv_derived_from(*svp, "NSObject")) {
        [anObject retain];
    }
}
- (void)removeLastObject {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV *obj = av_pop((AV*)_myArray);
    if (sv_isobject(obj) && sv_derived_from(obj, "NSObject")) {
        id anObject = REAL_CBDerefSVtoID(obj);
        [anObject autorelease];
    }
}
- (void)removeObjectAtIndex:(unsigned)index {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV **svp;
    int i;
    int lastIndex;
    
    svp = av_fetch((AV*)_myArray, index, 0);
    if (svp && sv_isobject(*svp) && sv_derived_from(*svp, "NSObject")) {
        id anObject = REAL_CBDerefSVtoID(*svp);
        [anObject autorelease];
    }

    lastIndex = av_len((AV*)_myArray);
    for(i=index; i<lastIndex; i++) {
        svp = av_fetch((AV*)_myArray, i+1, 0);
        if (svp) {
            av_store((AV*)_myArray, i, *svp);
        }
    }
}

- (void)replaceObjectAtIndex:(unsigned)index withObject:(id)anObject {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV **svp;
    SV *obj;
    
    svp = av_fetch((AV*)_myArray, index, 0);
    if (svp && sv_isobject(*svp) && sv_derived_from(*svp, "NSObject")) {
        id oldObject = REAL_CBDerefSVtoID(*svp);
        if ([oldObject respondsToSelector:@selector(autorelease)]) {
            [oldObject autorelease];
        }
    }

    obj = REAL_CBDerefIDtoSV(anObject);
    av_store((AV*)_myArray, index, obj);

    if (sv_isobject(obj) && sv_derived_from(obj, "NSObject")) {
        [anObject retain];
    }
}

// Destructor
- (void) dealloc {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    if (NULL != _myArray) {
    
        if (SvREFCNT((SV *)_myArray) > 0) {
            SvREFCNT_dec((SV *)_myArray);
        }
    }
    [super dealloc];
}

// Extended methods

// Convenience creation methods returning autoreleased instances
+ (id) arrayNamed: (NSString *)varName isReference: (BOOL)isRef create: (BOOL)shouldCreate {
    return [[[CBPerlArray alloc] initArrayNamed:varName isReference:isRef create:shouldCreate] autorelease];
}
+ (id) arrayNamed: (NSString *)varName isReference: (BOOL)isRef {
    return [[[CBPerlArray alloc] initArrayNamed:varName isReference:isRef] autorelease];
}
+ (id) arrayNamed: (NSString *)varName {
    return [[[CBPerlArray alloc] initArrayNamed:varName] autorelease];
}
+ (id) newArrayNamed: (NSString *)varName {
    return [[[CBPerlArray alloc] initNewArrayNamed:varName] autorelease];
}
+ (id) arrayReferenceNamed: (NSString *)varName {
    return [[[CBPerlArray alloc] initArrayReferenceNamed:varName] autorelease];
}
+ (id) newArrayReferenceNamed: (NSString *)varName {
    return [[[CBPerlArray alloc] initNewArrayReferenceNamed:varName] autorelease];
}

// Designated initializer
- (id) initArrayNamed: (NSString *)varName isReference: (BOOL)isRef create: (BOOL)shouldCreate {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    self = [super init];
    if (nil != self) {
        if (isRef) {
            [self release];
            return nil;
        } else {
            _myArray = (void*)get_av([varName UTF8String], (YES == shouldCreate) ? 1 : 0);
            if (NULL == _myArray) {
                [self release];
                return nil;
            }
            SvREFCNT_inc((SV *)_myArray);
        }
    }
    return self;
}

// Convenience initializers - these all expand to calls to the designated initializer above
- (id) initArrayNamed: (NSString *)varName isReference: (BOOL)isRef {
    return [self initArrayNamed:varName isReference:isRef create:NO];
}
- (id) initArrayNamed: (NSString *)varName {
    return [self initArrayNamed:varName isReference:NO create:NO];
}
- (id) initNewArrayNamed: (NSString *)varName {
    return [self initArrayNamed:varName isReference:NO create:YES];
}
- (id) initArrayReferenceNamed: (NSString *)varName {
    return [self initArrayNamed:varName isReference:YES create:NO];
}
- (id) initNewArrayReferenceNamed: (NSString *)varName {
    return [self initArrayNamed:varName isReference:YES create:YES];
}

@end


// Private methods
@implementation CBPerlArray (CBPerlArrayPrivate)

+ (id) arrayWithAV: (AV*)theAV {
    return [[[CBPerlArray alloc] initWithAV:theAV] autorelease];
}

- (id) initWithAV: (AV*)theAV {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    self = [super init];
    if (nil != self) {
        _myArray = (void*)theAV;
        SvREFCNT_inc((SV*)_myArray);
    }
    return self;
}

@end

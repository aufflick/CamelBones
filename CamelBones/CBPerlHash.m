//
//  CBPerlHash.m
//  Camel Bones - a bare-bones Perl bridge for Objective-C
//  Originally written for ShuX
//
//  Copyright (c) 2002 Sherm Pendley. All rights reserved.
//

#import "CBPerlHash.h"
#import "CBPerlHashInternals.h"
#import "Conversions_real.h"

@implementation CBPerlHash (Overrides)

// Required primitive methods
- (unsigned)count {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    return HvKEYS((HV *)_myHash);
}
- (NSEnumerator *)keyEnumerator {
    return [CBPerlHashKeyEnumerator enumeratorWithHV:(HV *)_myHash];
}
- (id)objectForKey:(id)aKey {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV *theKey;
    HE *theEntry;
    SV *theValue;

    // Create the key SV
    theKey = [self keyWithId:aKey];

    // Get the hash entry
    theEntry = hv_fetch_ent((HV *)_myHash, theKey, 0, 0);

    // If the entry was found, get and return its value
    if (NULL != theEntry) {
        theValue = HeVAL(theEntry);

        if (NULL != theValue) {
            return REAL_CBDerefSVtoID(theValue);
        }
    }
    
    return nil;
}

- (void)removeObjectForKey:(id)aKey {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV *theKey;
    HE *theEntry;
    SV *theValue;

    // Get the key and value SVs
    theKey = [self keyWithId:aKey];
    theEntry = hv_fetch_ent((HV *)_myHash, theKey, 0, 0);
    theValue = theEntry ? HeVAL(theEntry) : NULL;

    // If it's a wrapped Cocoa object, autorelease it
    if (sv_isobject(theValue) && sv_derived_from(theValue, "NSObject")) {
        [[self objectForKey:aKey] autorelease];
    }

    // Delete the entry
    hv_delete_ent((HV *)_myHash, theKey, 0, 0);
}

- (void)setObject:(id)anObject forKey:(id)aKey {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV *theKey;
    SV *theObject;
    
    // Remove the old value if there is one
    [self removeObjectForKey:aKey];

    // Create the key and object SVs
    theKey = [self keyWithId:aKey];
    theObject = REAL_CBDerefIDtoSV(anObject);

    // If it gets wrapped as a Cocoa object, retain it
    if (sv_isobject(theObject) && sv_derived_from(theObject, "NSObject")) {
        [anObject retain];
    }

    // Store it
    hv_store_ent((HV *)_myHash, theKey, theObject , 0);
}

// Destructor
- (void) dealloc {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    if (NULL != _myHash) {
        if (SvREFCNT((SV *)_myHash) > 0) {
            SvREFCNT_dec((SV *)_myHash);
        }
    }
    [super dealloc];
}

// Extended methods

// Convenience creation methods returning autoreleased instances
+ (id) dictionaryNamed: (NSString *)varName isReference: (BOOL)isRef create: (BOOL)shouldCreate {
    return [[[CBPerlHash alloc] initDictionaryNamed:varName isReference:isRef create:shouldCreate] autorelease];
}
+ (id) dictionaryNamed: (NSString *)varName isReference: (BOOL)isRef {
    return [[[CBPerlHash alloc] initDictionaryNamed:varName isReference:isRef] autorelease];
}
+ (id) dictionaryNamed: (NSString *)varName {
    return [[[CBPerlHash alloc] initDictionaryNamed:varName] autorelease];
}
+ (id) newDictionaryNamed: (NSString *)varName {
    return [[[CBPerlHash alloc] initNewDictionaryNamed:varName] autorelease];
}
+ (id) dictionaryReferenceNamed: (NSString *)varName {
    return [[[CBPerlHash alloc] initDictionaryReferenceNamed:varName] autorelease];
}
+ (id) newDictionaryReferenceNamed: (NSString *)varName {
    return [[[CBPerlHash alloc] initNewDictionaryReferenceNamed:varName] autorelease];
}

// Designated initializer
- (id) initDictionaryNamed: (NSString *)varName isReference: (BOOL)isRef create: (BOOL)shouldCreate {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    self = [super init];
    if (nil != self) {
        if (isRef) {
            [self release];
            return nil;
        } else {
            _myHash = (void*)get_hv([varName UTF8String], (YES == shouldCreate) ? 1 : 0);
            if (NULL == _myHash) {
                [self release];
                return nil;
            }
            SvREFCNT_inc((SV *)_myHash);
        }
    }
    return self;
}

// Convenience initializers - these all expand to calls to the designated initializer above
- (id) initDictionaryNamed: (NSString *)varName isReference: (BOOL)isRef {
    return [self initDictionaryNamed:varName isReference:isRef create:NO];
}
- (id) initDictionaryNamed: (NSString *)varName {
    return [self initDictionaryNamed:varName isReference:NO create:NO];
}
- (id) initNewDictionaryNamed: (NSString *)varName {
    return [self initDictionaryNamed:varName isReference:NO create:YES];
}
- (id) initDictionaryReferenceNamed: (NSString *)varName {
    return [self initDictionaryNamed:varName isReference:YES create:NO];
}
- (id) initNewDictionaryReferenceNamed: (NSString *)varName {
    return [self initDictionaryNamed:varName isReference:YES create:YES];
}

@end

// Private methods
@implementation CBPerlHash (CBPerlHashPrivate)

+ (id) dictionaryWithHV: (HV*)theHV {
    return [[[CBPerlHash alloc] initWithHV:theHV] autorelease];
}
- (id) initWithHV: (HV*)theHV {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    self = [super init];
    if (nil != self) {
        _myHash = (void*)theHV;
        SvREFCNT_inc((SV*)_myHash);
    }
    return self;
}

- (SV *) keyWithId: (id)theId {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV *theKey;

    // Create the key SV
    theKey = sv_newmortal();
    if ([theId respondsToSelector: @selector(UTF8String)]) {
        sv_setpv(theKey, [theId UTF8String]);
    } else if ([theId respondsToSelector: @selector(hash)]) {
        sv_setiv(theKey, [theId hash]);
    } else {
        sv_setiv(theKey, (int)theId);
    }
    
    return theKey;
}

@end


// Key enumerator public methods
@implementation CBPerlHashKeyEnumerator (Overrides)

- (NSArray *)allObjects {
    NSMutableArray *objects;
    id nextObject;
    
    objects  = [NSMutableArray array];
    while ((nextObject = [self nextObject])) {
        [objects addObject: nextObject];
    }
    
    return objects;
}

- (id)nextObject {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    HE *nextEntry;
    SV *nextKey;
    
    nextEntry = hv_iternext((HV*)_myHash);
    if (NULL != nextEntry) {
        nextKey = HeSVKEY_force(nextEntry);
        return REAL_CBDerefSVtoID(nextKey);
    } else {
        return nil;
    }
}

// Destructor
- (void) dealloc {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    if (NULL != _myHash) {
        if (SvREFCNT((SV *)_myHash) > 0) {
            SvREFCNT_dec((SV *)_myHash);
        }
    }
    [super dealloc];
}

@end


// Key enumerator private methods
@implementation CBPerlHashKeyEnumerator (CBPerlHashKeyEnumeratorPrivate)

+ (id) enumeratorWithHV:(HV*)theHV {
    return [[[CBPerlHashKeyEnumerator alloc] initEnumeratorWithHV:theHV] autorelease];
}
- (id) initEnumeratorWithHV:(HV*)theHV {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    self = [super init];
    if (nil != self) {
        _myHash = (void*)theHV;
        SvREFCNT_inc((SV*)_myHash);

        hv_iterinit((HV*)_myHash);
    }
    return self;
}

@end

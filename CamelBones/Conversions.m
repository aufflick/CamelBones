//
//  Conversions.m
//  CamelBones
//
//  Copyright (c) 2004 Sherm Pendley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Conversions_real.h"
#import "PerlImports.h"
#import "Wrappers_real.h"

#import "CBPerlObject.h"
#import "CBPerlObjectInternals.h"
#import "CBPerlArray.h"
#import "CBPerlArrayInternals.h"
#import "CBPerlHash.h"
#import "CBPerlHashInternals.h"
#import "CBPerl.h"

#ifdef GNUSTEP

#import <GNUstepBase/GSObjCRuntime.h>

#else

#import <objc/objc-runtime.h>
#import <objc/objc-class.h>

#endif /* GNUSTEP */

id REAL_CBDerefSVtoID(void* sv) {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

#ifdef GNUSTEP
    const char *svType;
    unsigned int svSize;
    int svOffset;
#endif

    // Basic sanity check
    if (!sv) {
        NSLog(@"Warning: NULL passed to CBDerefSVtoID");
        return nil;
    }

    // Check to see if it's an object reference
    if (sv_isobject((SV*)sv)) {

		HV *hv = (HV *)SvRV((SV*)sv);

        // If this is a registered NSObject subclass, or a placeholder,
		// pass the native object
        if (sv_derived_from(sv, "NSObject")
			|| sv_derived_from(sv, "CamelBones::PlaceHolder")
			) {
            SV **nativeSvp = hv_fetch(hv, "NATIVE_OBJ", strlen("NATIVE_OBJ"), 0);
            SV *nativeSV = nativeSvp ? *nativeSvp : NULL;

            if (nativeSV) {
                return (id) SvIV(nativeSV);
            }
		}

		// Otherwise create a new native object to pass
		char *className = sv_reftype(SvRV((SV*)sv), 1);

		// The class callback should register the class if needed
		Class thisClass = objc_getClass(className);

        if (nil != thisClass) {
			id newWrapper = class_createInstance(thisClass, 0);
#ifdef GNUSTEP
			GSObjCFindVariable(newWrapper, "_sv", &svType, &svSize, &svOffset);
			GSObjCSetVariable(newWrapper, svOffset, svSize, (const void*)sv);
#else
			object_setInstanceVariable(newWrapper, "_sv", (void *)sv);
#endif /* GNUSTEP */
			hv_store(hv, "NATIVE_OBJ", strlen("NATIVE_OBJ"), sv, 0);

			return newWrapper;

		} else {
			return nil;
		}

	// Then check to see if it's some other kind of reference
    } else if (SvROK((SV*)sv)) {
        SV *target;

        // Get the value referred to, and dereference it
        target = SvRV((SV*)sv);
        return REAL_CBDerefSVtoID(target);

	// It's not a reference - check for floats
    } else if (SvNOK((SV*)sv)) {
        return [NSNumber numberWithDouble: SvNV((SV*)sv)];

	// and ints
    } else if (SvIOK((SV*)sv)) {
        return [NSNumber numberWithLong: SvIV((SV*)sv)];

	// and strings
    } else if (SvPOK((SV*)sv)) {
        return [NSString stringWithUTF8String: SvPV((SV*)sv, PL_na)];

	// and arrays
    } else if (SvTYPE((AV*)sv) == SVt_PVAV) {
        return [CBPerlArray arrayWithAV: (AV*)sv];

	// and finally hashes
    } else if (SvTYPE((HV*)sv) == SVt_PVHV) {
        return [CBPerlHash dictionaryWithHV: (HV*)sv];

	// Last-ditch effort - check for undef
    } else if (!SvOK((SV*)sv)) {
		return nil;
	}

    // WTF?

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowUnhandledTypeWarnings"]) {
        NSLog(@"Warning: Unhandled SV type passed to CBDerefSVtoID");
    }
    return nil;
}

void* REAL_CBDerefIDtoSV(id target) {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

#ifdef GNUSTEP
    const char *svType;
    unsigned int svSize;
    int svOffset;
#endif /* GNUSTEP */

    // Basic sanity checking first
    if (target == nil) {
        return &PL_sv_undef;
    }

#ifdef GNUSTEP
    // Check first for a wrapped Perl object or variable
    BOOL i = GSObjCFindVariable(target, "_sv", &svType, &svSize, &svOffset);

    // Check first for a bridged Perl class
    if (i) {
        SV *thisNewSV;

        // It's a Perl class - check to see if the Perl object has been created yet
	GSObjCGetVariable(target, svOffset, svSize, (void*)&thisNewSV);

        if (!thisNewSV) {
	    // No Perl object yet, so create one
	    NSString *stringObj = [NSString stringWithUTF8String: target->class_pointer->name];
	    thisNewSV = REAL_CBCreateWrapperObjectWithClassName(target, stringObj);
	    GSObjCSetVariable(target, svOffset, svSize, (const void*)&thisNewSV);
        }

	SvREFCNT_inc(thisNewSV);
	return thisNewSV;

#else
    // Check first for a wrapped Perl object or variable
    struct objc_ivar *i = class_getInstanceVariable(target->isa, "_sv");
    
    // Check first for a bridged Perl class
    if (i) {
        SV *thisNewSV;

        // It's a Perl class - check to see if the Perl object has been created yet
        object_getInstanceVariable(target, "_sv", (void*)&thisNewSV);

        if (!thisNewSV) {
	    // No Perl object yet, so create one
	    NSString *stringObj = [NSString stringWithUTF8String: target->isa->name];
	    thisNewSV = REAL_CBCreateWrapperObjectWithClassName(target, stringObj);
	    object_setInstanceVariable(target, "_sv", thisNewSV);
        }

	SvREFCNT_inc(thisNewSV);
	return thisNewSV;
#endif

	// Some types of objects may get special handling
    } else if ([target isKindOfClass: [NSString class]]
	       && [[[CBPerl sharedPerl] valueForKey: @"CamelBones::ReturnStringsAsObjects"]
	               intValue] == 0) {
    	const char *u = [(NSString *)target UTF8String];
    	int len = strlen(u);
        SV *newSV = newSVpv(u, len);
        SvUTF8_on(newSV);
        return (void*)newSV;
    }

    // If it's a descendant of NSObject, create and return a wrapper
    else if ([target isKindOfClass: [NSObject class]]) {
        return REAL_CBCreateWrapperObject(target);
    }

    // WTF?
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowUnhandledTypeWarnings"]) {
        NSLog(@"Warning: CBDerefIDtoSV called with unknown object target type");
    }

    return (void*)&PL_sv_undef;
}

Class REAL_CBClassFromSV(void* sv) {
    return(NSClassFromString(REAL_CBDerefSVtoID(sv)));
}

void* REAL_CBSVFromClass(Class c) {
    return(REAL_CBDerefIDtoSV(NSStringFromClass(c)));
}

SEL REAL_CBSelectorFromSV(void* sv) {
    return(NSSelectorFromString(REAL_CBDerefSVtoID(sv)));
}

void* REAL_CBSVFromSelector(SEL aSel) {
    return(REAL_CBDerefIDtoSV(NSStringFromSelector(aSel)));
}

void REAL_CBPoke(void *address, void *object, unsigned length) {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

	// Check if object is blessed
	if (sv_isobject((SV*)object)) {
		void *src = NULL;

		// What's it got in its pockets, precious?
		if (sv_derived_from((SV*)object, "NSObject")) {
			HV *hv = (HV *)SvRV((SV*)object);
			SV **nativeSvp = hv_fetch(hv, "NATIVE_OBJ", strlen("NATIVE_OBJ"), 0);
			SV *nativeSV = nativeSvp ? *nativeSvp : NULL;
			
			if (nativeSV) {
				src = (void*)SvIV(nativeSV);
				memcpy(address, &src, sizeof(void*));
			}
			return;
		} else if (sv_derived_from((SV*)object, "CamelBones::NSPoint")) {
			SV *target = SvRV((SV*)object);
			src = (void*)SvPV_nolen(target);
			memcpy(address, src, sizeof(NSPoint));
			return;
		} else if (sv_derived_from((SV*)object, "CamelBones::NSRange")) {
			SV *target = SvRV((SV*)object);
			src = (void*)SvPV_nolen(target);
			memcpy(address, src, sizeof(NSRange));
			return;
		} else if (sv_derived_from((SV*)object, "CamelBones::NSRect")) {
			SV *target = SvRV((SV*)object);
			src = (void*)SvPV_nolen(target);
			memcpy(address, src, sizeof(NSRect));
			return;
		} else if (sv_derived_from((SV*)object, "CamelBones::NSSize")) {
			SV *target = SvRV((SV*)object);
			src = (void*)SvPV_nolen(target);
			memcpy(address, src, sizeof(NSSize));
			return;
		}

		NSLog(@"Unknown object type passed to CBPoke");
		return;

	} else {

		// No references, ints, or floats allowed!
		if (SvPOK((SV*)object)) {
			void *src = (void*)SvPV_nolen((SV*)object);
			memcpy(address, src, length);
			return;
		}
	}

	NSLog(@"Invalid arguments to CBPoke");
}

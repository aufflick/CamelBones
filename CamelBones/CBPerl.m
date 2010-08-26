//
//  CBPerl.m
//  Camel Bones - a bare-bones Perl bridge for Objective-C
//  Originally written for ShuX
//
//  Copyright (c) 2002 Sherm Pendley. All rights reserved.
//


#import "AppMain.h"
#import "Conversions_real.h"
#import "Globals_real.h"
#import "Runtime_real.h"

#import "CBPerl.h"
#import "CBPerlArray.h"
#import "CBPerlHash.h"
#import "CBPerlObject.h"
#import "CBPerlScalar.h"

#import "PerlImports.h"
#include "perlxsi.h"

static id _sharedPerl = nil;
PerlInterpreter *_CBPerlInterpreter;

@interface CBPerl (DummyThread)
- (void) dummyThread: (id)dummy;
@end

@implementation CBPerl (Overrides)

+ (CBPerl *) sharedPerl {
    // Is there a shared perl object already?
    if (_sharedPerl) {
        // Yes, return it
        return _sharedPerl;
    } else {
        // No
        
        // Detect platform type and initialize CBPerl
        [CBPerl stubInit];
        
        // Now create a shared Perl and autorelease it
        _sharedPerl = [[CBPerl alloc] init];
        return _sharedPerl;
    }
}

+ (CBPerl *) sharedPerlXS {
    // Is there a shared perl object already?
    if (_sharedPerl) {
        // Yes, return it
        return _sharedPerl;
    } else {
        // No, create one and autorelease it
        _sharedPerl = [[CBPerl alloc] initXS];
        return _sharedPerl;
    }
}

- (id) init {
    char *emb[] = { "", "-e", "0" };

    // Is there a shared perl object already?
    if (_sharedPerl) {
        // Yes, retain and return it
        return [_sharedPerl retain];

    } else {
        // No, create one and retain it
        if ((self = [super init])) {
            NSArray *bundles;
            NSEnumerator *e;
            NSBundle *obj;
            NSString *perlArchname;
            NSString *perlVersion;

            _CBPerlInterpreter = perl_alloc();
            perl_construct(_CBPerlInterpreter);
            perl_parse(_CBPerlInterpreter, xs_init, 3, emb, (char **)NULL);
            perl_run(_CBPerlInterpreter);
            _sharedPerl = self;

			// Get Perl's archname and version
			[self useModule: @"Config"];
			perlArchname = [self eval: @"$Config{'archname'}"];
			perlVersion = [self eval: @"$Config{'version'}"];

            // Are we threaded?
            if ([perlArchname rangeOfString:@"thread"].location != NSNotFound) {
                // Yes - start a dummy Cocoa thread
                [NSThread detachNewThreadSelector:@selector(dummyThread:) toTarget:self withObject:nil];

                // Now tell Perl to use threads.pm
                [self useModule:@"threads"];
            }

			// Add bundled resource folders to @INC
            bundles = [NSBundle allFrameworks];
            e = [bundles objectEnumerator];
            while ((obj = [e nextObject])) {
            	[self useBundleLib:obj withArch: perlArchname forVersion: perlVersion];
            }
            
            bundles = [NSBundle allBundles];
            e = [bundles objectEnumerator];
            while ((obj = [e nextObject])) {
            	[self useBundleLib:obj withArch: perlArchname forVersion: perlVersion];
            }
            
			[self useBundleLib:[NSBundle mainBundle] withArch: perlArchname forVersion: perlVersion];

            // Create Perl wrappers for all registered Objective-C classes
            REAL_CBWrapRegisteredClasses();
            
            // Export globals into Perl's name space
            REAL_CBWrapAllGlobals();

			// When bundles are loaded, we want to hear about it
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bundleDidLoad:)
												  name:NSBundleDidLoadNotification object:nil];

			// Register the class handler
			REAL_CBRegisterClassHandler();

            return [_sharedPerl retain];

        } else {
            // Wonder what happened here?
            return nil;

        }
    }
}

- (id) initXS {
    // Is there a shared perl object already?
    if (_sharedPerl) {
        // Yes, retain and return it
        return [_sharedPerl retain];

    } else {
        // No, create one and retain it
        if ((self = [super init])) {
            NSArray *bundles;
            NSEnumerator *e;
            NSBundle *obj;
            NSString *perlArchname;
            NSString *perlVersion;

            NSAutoreleasePool *p;
            
            // Set up housekeeping
            p = [[NSAutoreleasePool alloc] init];
            _sharedPerl = self;
            _CBPerlInterpreter = PERL_GET_CONTEXT;

			// Get Perl's archname and version
			[self useModule: @"Config"];
			perlArchname = [self eval: @"$Config{'archname'}"];
			perlVersion = [self eval: @"$Config{'version'}"];

            // Are we threaded?
            if ([perlArchname rangeOfString:@"thread"].location != NSNotFound) {
                // Yes - start a dummy Cocoa thread
                [NSThread detachNewThreadSelector:@selector(dummyThread:) toTarget:self withObject:nil];

                // Now tell Perl to use threads.pm
                [self useModule:@"threads"];
            }

			// Add bundled resource folders to @INC
            bundles = [NSBundle allFrameworks];
            e = [bundles objectEnumerator];
            while ((obj = [e nextObject])) {
            	[self useBundleLib:obj withArch: perlArchname forVersion: perlVersion];
            }
            
            bundles = [NSBundle allBundles];
            e = [bundles objectEnumerator];
            while ((obj = [e nextObject])) {
            	[self useBundleLib:obj withArch: perlArchname forVersion: perlVersion];
            }
            
            // Create Perl wrappers for all registered Objective-C classes
            REAL_CBWrapRegisteredClasses();
            
            // Export globals into Perl's name space
            REAL_CBWrapAllGlobals();

			// When bundles are loaded, we want to hear about it
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bundleDidLoad:)
												  name:NSBundleDidLoadNotification object:nil];

            [p release];

			// Register the class handler
			REAL_CBRegisterClassHandler();

            return [_sharedPerl retain];

        } else {
            // Wonder what happened here?
            return nil;

        }
    }
}

- (void) useBundleLib: (NSBundle *)aBundle
		withArch: (NSString *)perlArchName
		forVersion: (NSString *)perlVersion {

	NSString *bundleFolder;
	
	bundleFolder = [aBundle resourcePath];

	[self useLib: bundleFolder];
	[self useLib: [NSString stringWithFormat: @"%@/Resources", bundleFolder]];

	if (perlArchName != nil) {
		[self useLib: [NSString stringWithFormat: @"%@/Resources/%@", bundleFolder, perlArchName]];
	}
	
	if (perlArchName != nil && perlVersion != nil) {
		[self useLib: [NSString stringWithFormat: @"%@/Resources/%@", bundleFolder, perlVersion]];
		[self useLib: [NSString stringWithFormat: @"%@/Resources/%@/%@", bundleFolder, perlVersion, perlArchName]];
	}
}

- (id) eval: (NSString *)perlCode {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    SV *result = eval_pv([perlCode UTF8String], FALSE);

    // Check for an error
    if (SvTRUE(ERRSV)) {
        [NSException raise:CBPerlErrorException format:@"Perl exception: %s", SvPV(ERRSV, PL_na)];
        return nil;
    }

    if (result == &PL_sv_undef || result == NULL) {
        return nil;
    }

    return REAL_CBDerefSVtoID(result);
}

// Standard KVC methods
- (id) valueForKey:(NSString*)key {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;
    SV* sv;
    if ([key hasPrefix:@"@"]) {
        sv = (SV*)get_av([key UTF8String], TRUE);
    } else if ([key hasPrefix:@"%"]) {
        sv = (SV*)get_hv([key UTF8String], TRUE);
    } else {
        sv = get_sv([key UTF8String], TRUE);
    }
    return REAL_CBDerefSVtoID(sv);
}

- (void) setValue:(id)value forKey:(NSString*)key {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;
    SV* newVal = REAL_CBDerefIDtoSV(value);
    SV* sv = get_sv([key UTF8String], TRUE);
    sv_setsv_mg(sv, newVal);
}

- (long) varAsInt: (NSString *)perlVar {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;
    
    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));

    return SvIV(get_sv([perlVar UTF8String], TRUE));
}

- (void) setVar: (NSString *)perlVar toInt: (long)newValue {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));

    sv_setiv_mg(get_sv([perlVar UTF8String], TRUE), newValue);
}

- (double) varAsFloat: (NSString *)perlVar {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));

    return SvNV(get_sv([perlVar UTF8String], TRUE));
}

- (void) setVar: (NSString *)perlVar toFloat: (double)newValue {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));

    sv_setnv_mg(get_sv([perlVar UTF8String], TRUE), newValue);
}

- (NSString *) varAsString: (NSString *)perlVar {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));

    STRLEN n_a;
    return [NSString stringWithUTF8String: SvPV(get_sv([perlVar UTF8String], TRUE), n_a)];
}

- (void) setVar: (NSString *)perlVar toString: (NSString *)newValue {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));

    sv_setpv_mg(get_sv([perlVar UTF8String], TRUE), [newValue UTF8String]);
}

- (void) useLib: (NSString *)libPath {
	NSFileManager *manager;
	BOOL isDir;

	manager = [NSFileManager defaultManager];
	if ([manager fileExistsAtPath:libPath isDirectory:&isDir] && isDir) {
	    [_sharedPerl eval: [NSString stringWithFormat: @"use lib '%@';", libPath]];
	}
}

- (void) useModule: (NSString *)moduleName {
    [_sharedPerl eval: [NSString stringWithFormat: @"use %@;", moduleName]];
}

- (void) useWarnings {
    [_sharedPerl eval: @"use warnings;"];
}

- (void) noWarnings {
    [_sharedPerl eval: @"no warnings;"];
}

- (void) useStrict {
    [self useStrict: nil];
}

- (void) useStrict: (NSString *)options {
    if (options) {
        [_sharedPerl eval: [NSString stringWithFormat: @"use strict '%@';", options]];
    } else {
        [_sharedPerl eval: @"use strict;"];
    }
}

- (void) noStrict {
    [self noStrict: nil];
}

- (void) noStrict: (NSString *)options {
    if (options) {
        [_sharedPerl eval: [NSString stringWithFormat: @"no strict '%@';", options]];
    } else {
        [_sharedPerl eval: @"no strict;"];
    }
}

- (CBPerlScalar *) namedScalar: (NSString *)varName {
    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));

    return [CBPerlScalar namedScalar: varName];
}

- (CBPerlArray *) namedArray: (NSString *)varName {
    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));

    return [CBPerlArray arrayNamed: varName];
}

- (CBPerlHash *) namedHash: (NSString *)varName {
    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));

    return [CBPerlHash dictionaryNamed: varName];
}

- (CBPerlObject *) namedObject: (NSString *)varName {
    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));

    return [CBPerlObject namedObject: varName];
}

- (void) exportArray: (NSArray *)array toPerlArray: (NSString *)arrayName {
    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));
}
- (void) exportDictionary: (NSDictionary *)dictionary toPerlHash: (NSString *)hashName {
    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));
}
- (void) exportObject: (id)object toPerlObject: (NSString *)objectName {
    NSLog(@"Warning: %@ has been deprecated and will soon be removed. Use KVC methods valueForKey: and setValue:forKey: instead.", NSStringFromSelector(_cmd));
}


// A bundle was loaded - wrap its classes
- (void) bundleDidLoad: (NSNotification *)notification {
	NSArray *classes = [[notification userInfo] valueForKey:@"NSLoadedClasses"];

	// Add the bundle's Resource dir to @INC
	NSString *perlArchname = [self eval: @"$Config{'archname'}"];
	NSString *perlVersion = [self eval: @"$Config{'version'}"];

	// Add bundle's resource folder to @INC
	NSBundle *bundle = [notification object];
	[self useBundleLib:bundle  withArch: perlArchname forVersion: perlVersion];
            
	REAL_CBWrapNamedClasses(classes);
}

- (void) dummyThread: (id)dummy {
    return;
}

@end

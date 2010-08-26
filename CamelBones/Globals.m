//
//  Globals.m
//  CamelBones
//
//  Copyright (c) 2002 Sherm Pendley. All rights reserved.
//

#import "Globals_real.h"
#import "Wrappers_real.h"
#import "Conversions_real.h"
#import "PerlImports.h"
#import "CBPerlArray.h"

#import "config.h"
#ifdef HAVE_DLFCN_H
#import <dlfcn.h>
#else
CFBundleRef b;
#endif

void REAL_CBWrapAllGlobals(void) {
    NSBundle *thisBundle;
    NSString *plistPath;

    NSArray *exports;
    NSEnumerator *e;
    NSString *thisExport;

    CBPerlArray *foundationISA;
    CBPerlArray *foundationEXPORT;
    CBPerlArray *appkitISA;
    CBPerlArray *appkitEXPORT;

    // Fill out the Foundation package's ISA and EXPORT arrays
    foundationISA = [CBPerlArray newArrayNamed:@"CamelBones::Foundation::Globals::ISA"];
    [foundationISA addObject:@"Exporter"];
    foundationEXPORT = [CBPerlArray newArrayNamed:@"CamelBones::Foundation::Globals::EXPORT"];

    // Fill out the AppKit package's ISA and EXPORT arrays
    appkitISA = [CBPerlArray newArrayNamed:@"CamelBones::AppKit::Globals::ISA"];
    [appkitISA addObject:@"Exporter"];
    appkitEXPORT = [CBPerlArray newArrayNamed:@"CamelBones::AppKit::Globals::EXPORT"];

    // Get a handle on the CamelBones framework bundle
    thisBundle = [NSBundle bundleForClass:NSClassFromString(@"CBPerl")];

    // Get the Foundation exports plist and loop over the entries
    plistPath = [thisBundle pathForResource:@"FoundationGlobalStrings" ofType:@"plist"];
    exports = [NSArray arrayWithContentsOfFile:plistPath];
    e = [exports objectEnumerator];
    while ((thisExport = [e nextObject])) {
        // Try to make a wrapper
        if (REAL_CBWrapString([thisExport UTF8String], "CamelBones::Foundation::Globals")) {
            // If successful, make the wrapper exportable
            [foundationEXPORT addObject:[thisExport substringFromIndex:1]];
        }
    }

    // Get the AppKit exports plist and loop over the entries
    plistPath = [thisBundle pathForResource:@"AppKitGlobalStrings" ofType:@"plist"];
    exports = [NSArray arrayWithContentsOfFile:plistPath];
    e = [exports objectEnumerator];
    while ((thisExport = [e nextObject])) {
        // Try to make a wrapper
        if (REAL_CBWrapString([thisExport UTF8String], "CamelBones::AppKit::Globals")) {
            // If successful, make the wrapper exportable
            [appkitEXPORT addObject:[thisExport substringFromIndex:1]];
        }
    }
}

BOOL REAL_CBWrapString(const char *varName, const char *pkgName) {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    void *address;
    SV *mySV;

#ifdef HAVE_DLFCN_H
    address = dlsym( NULL, varName );
#else
	if (NULL == b) { b = CFBundleGetMainBundle(); }
	address = CFBundleGetDataPointerForName(b, (CFStringRef)[NSString stringWithFormat:@"%c", varName]);
#endif

    if (address) {
        mySV = REAL_CBDerefIDtoSV(*(NSString**)address);
        newCONSTSUB(gv_stashpv(pkgName, 0), (char *)varName+1, mySV);
      
        return TRUE;
    } else {
        return FALSE;
    }

}

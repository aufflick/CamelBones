#import "AppMain.h"
#import "CBPerl.h"
#import "Conversions.h"
#import "Structs.h"
#import "Runtime.h"
#import "NativeMethods.h"
#import "PerlMethods.h"
#import "Globals.h"
#import "Wrappers.h"

#include <dlfcn.h>
#define CBResolve(name)                         \
    name = dlsym(b, "REAL_" #name);             \
    if (!name) NSLog(fmt, #name);

@implementation CBPerl (DylibInit)
+ (void) dylibInit: (const char*) archver {
    NSBundle *theBundle;
    NSEnumerator *e;

    // Get the framework with the identifier we're interested in
    e = [[NSBundle allFrameworks] objectEnumerator];
    while ((theBundle = [e nextObject]) != nil) {
        if ([[theBundle bundleIdentifier] isEqualToString:@"org.CamelBones.framework"]) break;
    }

    // Resolve the path to the dylib, and load it
    NSString *bundlePath = [NSString stringWithFormat:@"%@/Libraries/%s.bundle", [theBundle bundlePath], archver];

    NSString *bundleBinPath = [NSString stringWithFormat:@"%@/Contents/MacOS/%s", bundlePath, archver];
    const char *bundleBinCPath = [bundleBinPath UTF8String];
    void *b = dlopen(bundleBinCPath, RTLD_LAZY | RTLD_LOCAL);
    if (!b) {
        NSLog(@"Error loading support bundle at %s: %s", bundleBinCPath, dlerror());
    }

    // Conversions.m
	NSString *fmt = @"Could not load function: %s";

	CBResolve(CBDerefSVtoID)
	CBResolve(CBDerefIDtoSV)
	CBResolve(CBClassFromSV)
	CBResolve(CBSVFromClass)
	CBResolve(CBSelectorFromSV)
	CBResolve(CBSVFromSelector)
	CBResolve(CBPoke)

    // Structs.m
	CBResolve(CBPointFromAV)
	CBResolve(CBPointFromHV)
	CBResolve(CBPointFromSV)
	CBResolve(CBPointToSV)
	CBResolve(CBRectFromAV)
	CBResolve(CBRectFromHV)
	CBResolve(CBRectFromSV)
	CBResolve(CBRectToSV)
	CBResolve(CBRangeFromAV)
	CBResolve(CBRangeFromHV)
	CBResolve(CBRangeFromSV)
	CBResolve(CBRangeToSV)
	CBResolve(CBSizeFromAV)
	CBResolve(CBSizeFromHV)
	CBResolve(CBSizeFromSV)
	CBResolve(CBSizeToSV)
#ifndef GNUSTEP
	CBResolve(CBOSTypeFromSV)
	CBResolve(CBOSTypeToSV)
#endif
    


    // Runtime.m
	CBResolve(CBWrapRegisteredClasses)
	CBResolve(CBWrapNamedClasses)
	CBResolve(CBWrapObjectiveCClass)
	CBResolve(CBIsClassRegistered)
	CBResolve(CBRegisterClassWithSuperClass)
	CBResolve(CBRegisterClassHandler)


    // NativeMethods.m
	CBResolve(CBIsObjectMethodRegisteredForClass)
	CBResolve(CBIsClassMethodRegisteredForClass)
	CBResolve(CBRegisterObjectMethodsForClass)
	CBResolve(CBRegisterClassMethodsForClass)
	CBResolve(CBCallNativeMethod)


	// PerlMethods.m
	CBResolve(CBGetMethodNameForSelector)
	CBResolve(CBGetMethodArgumentSignatureForSelector)
	CBResolve(CBGetMethodReturnSignatureForSelector)
	CBResolve(CBPerlIMP)

    // Globals.m
	CBResolve(CBWrapAllGlobals)
	CBResolve(CBWrapString)



    // Wrappers.m
	CBResolve(CBCreateWrapperObject)
	CBResolve(CBCreateWrapperObjectWithClassName)
	CBResolve(CBCreateObjectOfClass)
}

@end

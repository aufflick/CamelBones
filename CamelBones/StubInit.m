#import <Foundation/Foundation.h>
#import "CBPerl.h"
#import "AppMain.h"

@implementation CBPerl (StubInit)

static int archver_initialized = 0;

+ (void) initialize {
    NSBundle *theBundle;
    NSEnumerator *e;
    NSString *bundlePath;

    if ( 0 != archver_initialized ) return;
    archver_initialized = 1;
    
    const char *archver = CBGetPerlArchver();

    // Get the framework with the identifier we're interested in
    e = [[NSBundle allFrameworks] objectEnumerator];
    while ((theBundle = [e nextObject]) != nil) {
        if ([[theBundle bundleIdentifier] isEqualToString:@"org.dot-app.CamelBones"]) break;
    }

    // Resolve the path to the dylib, and load it
    bundlePath = [NSString stringWithFormat:@"%@/Libraries/%s.bundle", [theBundle bundlePath], archver];
	NSBundle *newBundle = [NSBundle bundleWithPath:bundlePath];
	[newBundle load];

    // Call the implementation of dylibInit loaded from the .dylib    
    [CBPerl dylibInit: archver];
}
@end

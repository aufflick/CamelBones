// Define storage for function pointers

#import "Conversions.h"
#import "Structs.h"

//
// Functions from Conversions.h
//
id (*CBDerefSVtoID)(void* sv);
void* (*CBDerefIDtoSV)(id target);

Class (*CBClassFromSV)(void* sv);
void* (*CBSVFromClass)(Class c);

SEL (*CBSelectorFromSV)(void* sv);
void* (*CBSVFromSelector)(SEL aSel);

void (*CBPoke)(void *address, void *object, unsigned length);

//
// Functions from Structs.h
//

// Creating NSPoint structs
NSPoint (*CBPointFromAV)(void* av);
NSPoint (*CBPointFromHV)(void* hv);
NSPoint (*CBPointFromSV)(void* sv);

// Converting NSPoint structs to blessed scalar references
void* (*CBPointToSV)(NSPoint point);

// Creating NSRect structs
NSRect (*CBRectFromAV)(void* av);
NSRect (*CBRectFromHV)(void* hv);
NSRect (*CBRectFromSV)(void* sv);

// Converting NSRect structs to blessed scalar references
void* (*CBRectToSV)(NSRect rect);

// Creating NSRange structs
NSRange (*CBRangeFromAV)(void* av);
NSRange (*CBRangeFromHV)(void* hv);
NSRange (*CBRangeFromSV)(void* sv);

// Converting NSRange structs to blessed scalar references
void* (*CBRangeToSV)(NSRange range);

// Creating NSSize structs
NSSize (*CBSizeFromAV)(void* av);
NSSize (*CBSizeFromHV)(void* hv);
NSSize (*CBSizeFromSV)(void* sv);

// Converting NSSize structs to blessed scalar references
void* (*CBSizeToSV)(NSSize size);

// The following aren't needed on GNUStep
#ifndef GNUSTEP
// Creating OSType structs
OSType (*CBOSTypeFromSV)(void* sv);

// Converting OSType structs to blessed scalar references
void* (*CBOSTypeToSV)(OSType type);
#endif



//
// Functions from Runtime.h
//
// Functions to help interface with the Objective-C runtime
#import "Runtime.h"

// Create Perl wrappers for all registered ObjC classes
void (*CBWrapRegisteredClasses)(void);

// Create Perl wrappers for a list of named ObjC classes
void (*CBWrapNamedClasses)(NSArray *names);

// Create a Perl wrapper for a single ObjC class
void (*CBWrapObjectiveCClass)(Class aClass);

// Query class registration
BOOL (*CBIsClassRegistered)(const char *className);

// Register a Perl class with the runtime
void (*CBRegisterClassWithSuperClass)(const char *className, const char *superName);

// Query method registration
BOOL (*CBIsObjectMethodRegisteredForClass)(SEL selector, Class class);
BOOL (*CBIsClassMethodRegisteredForClass)(SEL selector, Class class);

// Perform method registration
void (*CBRegisterObjectMethodsForClass)(const char *package, NSArray *methods, Class class);
void (*CBRegisterClassMethodsForClass)(const char *package, NSArray *methods, Class class);

// Class handler registration
void (*CBRegisterClassHandler)(void);

// Functions found in NativeMethods.m
#import "NativeMethods.h"

// Call a native class or object method
void* (*CBCallNativeMethod)(void* target, SEL sel, void*args, BOOL isSuper);


#import "Globals.h"
// Globals.m
void (*CBWrapAllGlobals)(void);

// Create Perl wrappers for one global variable of a specific type
BOOL (*CBWrapString)(const char *varName, const char *pkgName);



// Functions from PerlMethods.m
#import "PerlMethods.h"

// Get information about a Perl object
NSString* (*CBGetMethodNameForSelector)(void* sv, SEL selector);
NSString* (*CBGetMethodArgumentSignatureForSelector)(void* sv, SEL selector);
NSString* (*CBGetMethodReturnSignatureForSelector)(void* sv, SEL selector);

// IMP registered as a native method
id (*CBPerlIMP)(id self, SEL _cmd, ...);




// Wrappers.m
#import "Wrappers.h"

// Create a Perl object that "wraps" an Objective-C object
void* (*CBCreateWrapperObject)(id obj);
void* (*CBCreateWrapperObjectWithClassName)(id obj, NSString* className);

// Create a new Perl object blessed into the specified package
void* (*CBCreateObjectOfClass)(NSString *className);


// Found in AppMain.h
#import "AppMain.h"
static const char *perlArchVer = NULL;

// Get Perl's architecture & version as a string
const char *CBGetPerlArchver() {
    if (NULL != perlArchVer) return perlArchVer;

    // Get the standard user defaults object
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

	// Add the CamelBones suite
	[def addSuiteNamed: @"org.camelbones"];

    // Establish the registration domain
	NSDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
	NSFileManager *fm = [NSFileManager defaultManager];
    NSString *perlPath;
    if ([fm fileExistsAtPath:@"/System/Library/Perl/5.8.9/darwin-thread-multi-2level/CORE/libperl.dylib"]) {
        perlPath = @"/usr/bin/perl5.8.9";
    } else if ([fm fileExistsAtPath:@"/System/Library/Perl/5.8.8/darwin-thread-multi-2level/CORE/libperl.dylib"]) {
        perlPath = @"/usr/bin/perl5.8.8";
    } else if ([fm fileExistsAtPath:@"/System/Library/Perl/5.8.6/darwin-thread-multi-2level/CORE/libperl.dylib"]) {
        perlPath = @"/usr/bin/perl5.8.6";
	} else if ([fm fileExistsAtPath:@"/System/Library/Perl/5.8.1/darwin-thread-multi-2level/CORE/libperl.dylib"]) {
		perlPath = @"/usr/bin/perl5.8.1";
	} else if ([fm fileExistsAtPath:@"/System/Library/Perl/darwin/CORE/libperl.dylib"]) {
		perlPath = @"/usr/bin/perl5.6.0";
	} else {
		perlPath = @"/usr/bin/perl";
	}

    // Check for support for newer KVC method
    if ([dict respondsToSelector:@selector(setValue:forKey:)]) {
        [dict setValue:perlPath forKey:@"perl"];
    } else {
        [dict takeValue:perlPath forKey:@"perl"];
    }
	[def registerDefaults:dict];

	// Get the string
	perlPath = [def stringForKey:@"perl"];

	// Try to execute the preferred Perl to get the arch & version
	NSTask *perlTask = [[[NSTask alloc] init] autorelease];
	NSArray *args = [NSArray arrayWithObjects:@"-MConfig", @"-e",
							 @"print $Config{archname}, '-', $Config{version}",
							 nil];

	// Set up the file handle
	NSPipe *pipe = [NSPipe pipe];
	[perlTask setStandardOutput: pipe];
	NSFileHandle *fh = [pipe fileHandleForReading];

	// Run the Perl and read its output
	[perlTask setLaunchPath: perlPath];
	[perlTask setArguments: args];
	[perlTask launch];
	while ([perlTask isRunning]) { }
	NSData *dat = [fh readDataToEndOfFile];
	NSString *archName = [[[NSString alloc] initWithData: dat
											encoding: NSUTF8StringEncoding]
							 autorelease];

	perlArchVer = (char*)[archName UTF8String];
	return perlArchVer;
}

void CBSetPerlArchver(const char *archVer) {
    perlArchVer = archVer;
}

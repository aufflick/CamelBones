#import <CamelBones/AppMain.h>
#import <CamelBones/CBPerl.h>
#import <CamelBones/NativeMethods.h>
#import <CamelBones/Conversions.h>
#import <CamelBones/Runtime.h>
#import <CamelBones/DylibInit.h>
#import <CamelBones/PerlImports.h>

#ifdef GNUSTEP
#include <objc/objc.h>
#else
#import <objc/objc-runtime.h>
#import <Carbon/Carbon.h>
#endif

#import <XSUB.h>

MODULE = CamelBones	PACKAGE = CamelBones

PROTOTYPES: ENABLE

void
CBPoke(address, object, size=0)
	void *address;
	SV *object;
	unsigned size;

void
CBInit(archver)
    char *archver
    CODE:
    NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
    CBSetPerlArchver(archver);
    [[CBPerl alloc] initXS];

SV*
CBCallNativeMethod(this, sel, args, isSuper)
    SV* this;
    SEL sel;
    SV *args;
    BOOL isSuper;

BOOL
CBIsClassRegistered(className)
    const char *className;


void
CBRegisterClassWithSuperClass(className, superName)
    const char *className;
    const char *superName;


BOOL
CBIsObjectMethodRegisteredForClass(selector, class)
    SEL selector;
    Class class;


BOOL
CBIsClassMethodRegisteredForClass(selector, class)
    SEL selector;
    Class class;


void
CBRegisterObjectMethodsForClass(package, methods, class)
    const char *package;
    id methods;
    Class class;
    
    
void
CBRegisterClassMethodsForClass(package, methods, class)
    const char *package;
    id methods;
    Class class;

//
//  Runtime.m
//  CamelBones
//
//  Copyright (c) 2002 Sherm Pendley. All rights reserved.
//

#ifdef GNUSTEP
#import <objc/objc-api.h>
#else
#import <objc/objc-class.h>
#import <objc/objc-runtime.h>
#endif

#import <Foundation/Foundation.h>

#import "CBPerl.h"
#import "Runtime_real.h"
#import "PerlImports.h"
#import "PerlMethods_real.h"

// Private function
struct objc_method_list* CBAllocateMethodList(NSArray *methods, Class class);

// Create Perl wrappers for all registered ObjC classes
void REAL_CBWrapRegisteredClasses(void) {
#ifdef GNUSTEP
	void *enum_state;
	Class thisClass;
	
	enum_state = NULL;
	while ((thisClass = objc_next_class(&enum_state))) {
		REAL_CBWrapObjectiveCClass(thisClass);
	}
#else
	int numClasses;
    Class *classes;
    int i;

    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        classes = malloc(sizeof(Class) * numClasses);
        objc_getClassList(classes, numClasses);
        for(i=0; i < numClasses; i++) {
            REAL_CBWrapObjectiveCClass(classes[i]);
        }
        free(classes);
    }
#endif
}

void REAL_CBWrapNamedClasses(NSArray *names) {
	if (nil == names) return;
	NSEnumerator *e = [names objectEnumerator];
    NSString *s;
	while ((s = [e nextObject])) {
		Class c = objc_getClass([s UTF8String]);
		REAL_CBWrapObjectiveCClass(c);
	}
}

// Create a Perl wrapper for a single ObjC class
void REAL_CBWrapObjectiveCClass(Class aClass) {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    // Create the @ClassName::ISA = qw(SuperClass);
    const char *className = aClass->name;
    const char *ISAName;
    const char *SuperName = NULL;
    AV *newIsaAV = NULL;
    SV *newParentSV = NULL;
    
    // Don't add NSObject to its own @ISA - Perl >= 5.10 warns about it
    if (0 == strncmp(className, "NSObject", 8)) {
        return;
    }

    // Get the super class name; default to "NSObject" for root classes
    if (aClass->super_class != NULL) {
        SuperName = aClass->super_class->name;
    } else {
        SuperName = "NSObject";
    }

    // Build up the PackageName::ISA array name and create the array
    ISAName = [[NSString stringWithFormat:@"%s::ISA", className] UTF8String];
    newIsaAV = get_av(ISAName, TRUE);

    // Clear any existing elements
    av_clear(newIsaAV);
            
    // Add the superclass element
    newParentSV = newSVpv(SuperName, 0);
    av_push(newIsaAV, newParentSV);
}

// Query class registration
BOOL REAL_CBIsClassRegistered(const char *className) {
    return (nil != objc_getClass(className)) ? YES : NO;
}

// Register a Perl class with the runtime
void REAL_CBRegisterClassWithSuperClass(const char *className, const char *superName) {
#ifdef GNUSTEP
    NSDictionary *ivars = [NSDictionary dictionaryWithObject:@"v" forKey:@"_sv"];
    NSValue *theClass = GSObjCMakeClass([NSString stringWithUTF8String:className],
                                        [NSString stringWithUTF8String:superName],
                                        ivars);
    GSObjCAddClasses([NSArray arrayWithObjects: theClass, nil]);
#else
    struct objc_class *meta_class;
    struct objc_class *super_class;
    struct objc_class *new_class;
    struct objc_class *root_class;
    struct objc_ivar_list *ivars;

    // Bail out of superName is already registered, or if className is not.
    super_class = (struct objc_class *)objc_lookUpClass(superName);
    if (nil == super_class) return;
    if (nil != objc_lookUpClass(className)) return;
    
    // Find the root class
    root_class = super_class;
    while ( nil != root_class->super_class ) {
        root_class = root_class->super_class;
    }
    
    // Make room, make room
    new_class = calloc( 2, sizeof(struct objc_class) );
    meta_class = &new_class[1];
    
    // Set up the class
    new_class->isa = meta_class;
    new_class->info = CLS_CLASS;
    meta_class->info = CLS_META;
    new_class->name = malloc(strlen(className)+1);
    strcpy((char*)new_class->name, className);
    meta_class->name = new_class->name;
    
    // Empty method lists at first
    new_class->methodLists = calloc( 1, sizeof(struct objc_method_list *) );
    meta_class->methodLists = calloc( 1, sizeof(struct objc_method_list *) );
    
    // Hook up the class hierarchy
    new_class->super_class = super_class;
    meta_class->super_class = super_class->isa;
    meta_class->isa = (void*)root_class->isa;

    // One instance variable, _sv
    ivars = malloc(sizeof(int) + sizeof(struct objc_ivar));
    ivars->ivar_count = 1;
    ivars->ivar_list[0].ivar_name = "_sv";
    ivars->ivar_list[0].ivar_type = "^v";
    ivars->ivar_list[0].ivar_offset = super_class->instance_size;
    new_class->ivars = ivars;
    
    // Make room for the ivar
    new_class->instance_size = super_class->instance_size + sizeof(void*);
    
    // Register the class
    objc_addClass(new_class);
#endif
}

// Query method registration
BOOL REAL_CBIsObjectMethodRegisteredForClass(SEL selector, Class class) {
#ifdef GNUSTEP
    return (NULL != GSGetMethod(class, selector, YES, NO)) ? YES : NO;
#else
	return (nil != class_getInstanceMethod(class, selector)) ? YES : NO;
#endif
}

BOOL REAL_CBIsClassMethodRegisteredForClass(SEL selector, Class class) {
#ifdef GNUSTEP
    return (NULL != GSGetMethod(class, selector, NO, NO)) ? YES : NO;
#else
    return (nil != class_getClassMethod(class, selector)) ? YES : NO;
#endif
}

// Perform method registration
void REAL_CBRegisterObjectMethodsForClass(const char *package, NSArray *methods, Class class) {
    struct objc_method_list *list;

    list = CBAllocateMethodList(methods, class);
#ifdef GNUSTEP
    if (list) {
        GSAddMethodList(class, list, YES);
        GSFlushMethodCacheForClass(class);
    }
#else
    if (list) class_addMethods(class, list);
#endif
}

void REAL_CBRegisterClassMethodsForClass(const char *package, NSArray *methods, Class class) {
    struct objc_method_list *list;

    list = CBAllocateMethodList(methods, class);
#ifdef GNUSTEP
    if (list) {
        GSAddMethodList(class, list, NO);
        GSFlushMethodCacheForClass(class);
    }
#else
    if (list) class_addMethods(class->isa, list);
#endif
}

// Class handler function
#ifdef GNUSTEP
Class
#else
int
#endif
__CB_classHandler(const char* className) {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

	// Try to load it
	NSString *useCommand = [NSString stringWithFormat:@"eval 'use %s'", className];
	[[CBPerl sharedPerl] eval:useCommand];

    // Check for an error
    if (SvTRUE(ERRSV)) {
        NSLog(@"Perl error: %s", SvPV(ERRSV, PL_na));
#ifdef GNUSTEP
        return NULL;
#else
        return 0;
#endif
    }

#ifdef GNUSTEP
    return GSClassFromName(className);
#else
	return 1;
#endif
}

void REAL_CBRegisterClassHandler(void) {
#ifdef GNUSTEP
    _objc_lookup_class = __CB_classHandler;
#else
	objc_setClassHandler(__CB_classHandler);
#endif
}

// Private method
struct objc_method_list* CBAllocateMethodList(NSArray *methods, Class class) {
    struct objc_method_list *list;
#ifndef GNUSTEP
    struct objc_method *this_method;
#endif
    int num_methods;
    int i;

    // Basic sanity checking, for an empty list    
    num_methods = [methods count];
    if (num_methods <= 0) return NULL;

    // Allocate memory for the list and all the methods in it
#ifdef GNUSTEP
    list = GSAllocMethodList(num_methods);
#else
    list = malloc(sizeof(struct objc_method_list) + ((num_methods+1)*sizeof(struct objc_method)));
#endif
    if (!list) return NULL;

#ifndef GNUSTEP
    // Prep the list
    list->obsolete = NULL;
    list->method_count = num_methods;
#endif

    // Add each method in methods to the C struct
    for (i=0; i < num_methods; i++) {
        const char *perlSig;
		const char *selName;

		selName = [[[methods objectAtIndex: i] objectForKey:@"name"] UTF8String];
        perlSig = [[[methods objectAtIndex:i] objectForKey:@"signature"] UTF8String];

#ifdef GNUSTEP
        GSAppendMethodToList(list,
                             GSSelectorFromName(selName),
                             perlSig,
                             REAL_CBPerlIMP,
                             YES);
#else
        this_method = &list->method_list[i];
        this_method->method_name = sel_registerName(selName);

        this_method->method_types = malloc(strlen(perlSig)+1);
        strcpy((char*)this_method->method_types, perlSig);
        
        this_method->method_imp = REAL_CBPerlIMP;
#endif
    }

    return list;
}

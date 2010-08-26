//
//  Runtime.h
//  CamelBones
//
//  Copyright (c) 2002 Sherm Pendley. All rights reserved.
//

@class NSArray;

// Functions to help interface with the Objective-C runtime

// Create Perl wrappers for all registered ObjC classes
extern void REAL_CBWrapRegisteredClasses(void);

// Create Perl wrappers for a list of ObjC classes
extern void REAL_CBWrapNamedClasses(NSArray *names);

// Create a Perl wrapper for a single ObjC class
extern void REAL_CBWrapObjectiveCClass(Class aClass);

// Query class registration
extern BOOL REAL_CBIsClassRegistered(const char *className);

// Register a Perl class with the runtime
extern void REAL_CBRegisterClassWithSuperClass(const char *className, const char *superName);

// Query method registration
extern BOOL REAL_CBIsObjectMethodRegisteredForClass(SEL selector, Class class);
extern BOOL REAL_CBIsClassMethodRegisteredForClass(SEL selector, Class class);

// Perform method registration
extern void REAL_CBRegisterObjectMethodsForClass(const char *package, NSArray *methods, Class class);
extern void REAL_CBRegisterClassMethodsForClass(const char *package, NSArray *methods, Class class);

// Class handler registration
extern void REAL_CBRegisterClassHandler(void);

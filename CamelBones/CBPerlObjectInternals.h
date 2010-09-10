//
//  CBPerlObjectInternals.h
//  Camel Bones - a bare-bones Perl bridge for Objective-C
//  Originally written for ShuX
//
//  Copyright (c) 2002-2010 Sherm Pendley. All rights reserved.

#import "CBPerlObject.h"

#ifdef GNUSTEP
#import <objc/objc-api.h>
#else
#import <objc/objc-class.h>
#import <objc/objc.h>
#endif

union _CB_OBJC_T {
    unsigned int uint;
    int sint;
    unsigned long ulong;
    long slong;
    float sfloat;
    double dfloat;
    char *char_p;
    const char *cchar_p;
    id id_p;
    void *void_p;
    Class class_p;
    SEL sel_p;
    NSPoint point_s;
    NSRange range_s;
    NSRect rect_s;
    NSSize size_s;
};
typedef union _CB_OBJC_T CB_ObjCType;


@interface CBPerlObject (Internals)

+ (CBPerlObject *) objectWithSV: (void *)newSV;
- (CBPerlObject *) initObjectWithSV: (void *)newSV;

- (void *)getSV;
// - (void *)getHV;

@end

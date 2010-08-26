//
//  Conversions_real.h
//  CamelBones
//
//  Copyright (c) 2004 Sherm Pendley. All rights reserved.
//

#import <Foundation/Foundation.h>

// Implementations of functions pointed to in Conversions.h
extern id REAL_CBDerefSVtoID(void* sv);
extern void* REAL_CBDerefIDtoSV(id target);

extern Class REAL_CBClassFromSV(void* sv);
extern void* REAL_CBSVFromClass(Class c);

extern SEL REAL_CBSelectorFromSV(void* sv);
extern void* REAL_CBSVFromSelector(SEL aSel);

extern void REAL_CBPoke(void *address, void *object, unsigned length);

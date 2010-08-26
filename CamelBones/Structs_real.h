//
//  Structs.h
//  CamelBones
//
//  Copyright (c) 2004 Sherm Pendley. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// Functions found in Structs.m
//

// Creating NSPoint structs
extern NSPoint REAL_CBPointFromAV(void* av);
extern NSPoint REAL_CBPointFromHV(void* hv);
extern NSPoint REAL_CBPointFromSV(void* sv);

// Converting NSPoint structs to blessed scalar references
extern void* REAL_CBPointToSV(NSPoint point);

// Creating NSRect structs
extern NSRect REAL_CBRectFromAV(void* av);
extern NSRect REAL_CBRectFromHV(void* hv);
extern NSRect REAL_CBRectFromSV(void* sv);

// Converting NSRect structs to blessed scalar references
extern void* REAL_CBRectToSV(NSRect rect);

// Creating NSRange structs
extern NSRange REAL_CBRangeFromAV(void* av);
extern NSRange REAL_CBRangeFromHV(void* hv);
extern NSRange REAL_CBRangeFromSV(void* sv);

// Converting NSRange structs to blessed scalar references
extern void* REAL_CBRangeToSV(NSRange range);

// Creating NSSize structs
extern NSSize REAL_CBSizeFromAV(void* av);
extern NSSize REAL_CBSizeFromHV(void* hv);
extern NSSize REAL_CBSizeFromSV(void* sv);

// Converting NSSize structs to blessed scalar references
extern void* REAL_CBSizeToSV(NSSize size);

// The following aren't needed on GNUStep
#ifndef GNUSTEP
// Creating OSType structs
extern OSType REAL_CBOSTypeFromSV(void* sv);

// Converting OSType structs to blessed scalar references
extern void* REAL_CBOSTypeToSV(OSType type);
#endif



#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#ifndef GNUSTEP
#include <Carbon/Carbon.h>
#endif

#import <CamelBones/PerlImports.h>
#import <CamelBones/Conversions.h>
#import <CamelBones/Structs.h>

MODULE = CamelBones::Foundation		PACKAGE = CamelBones::Foundation

PROTOTYPES: ENABLE

void
NSLog(logString)
    id logString;
    CODE:
        NSLog(@"%@", logString);

Class
NSClassFromString(aString)
	id aString;


# HFS Utils
#ifndef GNUSTEP
id
NSFileTypeForHFSTypeCode (typeCode)
    OSType typeCode;

OSType
NSHFSTypeCodeFromFileType (fileType)
    id fileType;

id
NSHFSTypeOfFile (filePath)
    id filePath;

#endif

# Path Utils
id
NSFullUserName ()

id
NSHomeDirectory ()

id
NSHomeDirectoryForUser (userName)
    id userName;
    
id
NSOpenStepRootDirectory ()

id
NSSearchPathForDirectoriesInDomains (directory, domainMask, expandTilde)
    int directory;
    int domainMask;
    BOOL expandTilde;

id
NSTemporaryDirectory ()

id
NSUserName ()

# Point utils
int
NSEqualPoints (point1, point2)
    NSPoint point1;
    NSPoint point2;

NSPoint
NSMakePoint (x,y)
    float x;
    float y;

NSPoint
NSPointFromString (aString)
    id aString;

id
NSStringFromPoint (aPoint)
    NSPoint aPoint;

# Range utils
int
NSEqualRanges (range1, range2)
    NSRange range1;
    NSRange range2;

NSRange
NSIntersectionRange (range1, range2)
    NSRange range1;
    NSRange range2;

int
NSLocationInRange (index, aRange)
    int index;
    NSRange aRange;

NSRange
NSMakeRange (location, length)
    int location;
    int length;

int
NSMaxRange (aRange)
    NSRange aRange;

NSRange
NSRangeFromString (aString)
    id aString;

id
NSStringFromRange (aRange)
    NSRange aRange;

NSRange
NSUnionRange (range1,range2)
    NSRange range1;
    NSRange range2;

# Rect utils
int
NSContainsRect (rect1, rect2)
    NSRect rect1;
    NSRect rect2;
    
int
NSEqualRects (rect1, rect2)
    NSRect rect1;
    NSRect rect2;

int
NSIsEmptyRect (aRect)
    NSRect aRect;

float NSHeight (aRect)
    NSRect aRect;
    
NSRect
NSInsetRect (aRect, dX, dY)
    NSRect aRect;
    float dX;
    float dY;

NSRect
NSIntegralRect (aRect)
    NSRect aRect;

NSRect
NSIntersectionRect (rect1, rect2)
    NSRect rect1;
    NSRect rect2;

int
NSIntersectsRect (rect1, rect2)
    NSRect rect1;
    NSRect rect2;

NSRect
NSMakeRect (x,y,width,height)
    float x;
    float y;
    float width;
    float height;

float
NSMaxX (aRect)
    NSRect aRect;

float
NSMaxY (aRect)
    NSRect aRect;

float
NSMidX (aRect)
    NSRect aRect;
    
float
NSMidY (aRect)
    NSRect aRect;

float
NSMinX (aRect)
    NSRect aRect;

float
NSMinY (aRect)
    NSRect aRect;

int
NSMouseInRect (aPoint, aRect, isFlipped)
    NSPoint aPoint;
    NSRect aRect;
    BOOL isFlipped;

NSRect
NSOffsetRect (aRect, dx, dy)
    NSRect aRect;
    float dx;
    float dy;

int
NSPointInRect (aPoint, aRect)
    NSPoint aPoint;
    NSRect aRect;

NSRect
NSRectFromString (aString)
    id aString;
    
id
NSStringFromRect (aRect)
    NSRect aRect;

NSRect
NSUnionRect (rect1, rect2)
    NSRect rect1;
    NSRect rect2;

float
NSWidth (aRect)
    NSRect aRect;

# NSSize functions
int
NSEqualSizes (size1, size2)
    NSSize size1;
    NSSize size2;

NSSize
NSMakeSize (width, height)
    float width;
    float height;
    
NSSize
NSSizeFromString (aString)
    id aString;

id
NSStringFromSize (aSize)
    NSSize aSize;

# Zone functions, but only some of them
int
NSLogPageSize ()

int
NSPageSize ()

int
NSRealMemoryAvailable ()

int
NSRoundDownToMultipleOfPageSize (pSize)
    int pSize;

int
NSRoundUpToMultipleOfPageSize (pSize)
    int pSize;

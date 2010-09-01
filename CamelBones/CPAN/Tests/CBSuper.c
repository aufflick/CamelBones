/*
    Super class for subclass tests
    Created on June 26, 2006 by Sherm Pendley
*/

#import <Cocoa/Cocoa.h>
#import "CBSuper.h"

@implementation CBSuper

- (double) floatValue { return f; }
- (long) intValue { return i; }

- (void) setFloat: (double)newFloat {
    f = newFloat;
    i = (long)newFloat;
}
- (void) setInt: (long)newInt {
    i = newInt;
    f = (double)newInt;
}

@end

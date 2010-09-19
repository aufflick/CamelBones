//
//  CBStructureTests.c
//  CamelBones
//
//  Created by Sherm Pendley on 9/1/10.
//  Copyright 2010 Sherm Pendley.
//

#import <Cocoa/Cocoa.h>
#import "CBStructureTests.h"

@implementation CBStructureTests

- (NSPoint)point {
    return point;
}

- (float)pointX {
    return point.x;
}

- (float)pointY {
    return point.y;
}

- (void)setPoint:(NSPoint)value {
    point = value;
}

- (NSRange)range {
    return range;
}

- (unsigned int) rangeLocation {
    return range.location;
}

- (unsigned int) rangeLength {
    return range.length;
}

- (void)setRange:(NSRange)value {
    range = value;
}

- (NSRect)rect {
    return rect;
}

- (float)rectX {
    return rect.origin.x;
}

- (float)rectY {
    return rect.origin.y;
}

- (float)rectWidth {
    return rect.size.width;
}

- (float)rectHeight {
    return rect.size.height;
}

- (void)setRect:(NSRect)value {
    rect = value;
}

- (NSSize)size {
    return size;
}

- (float)sizeWidth {
    return size.width;
}

- (float)sizeHeight {
    return size.height;
}

- (void)setSize:(NSSize)value {
    size = value;
}

@end

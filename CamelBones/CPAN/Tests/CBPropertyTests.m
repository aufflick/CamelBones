//
//  CBPropertyTests.c
//  CamelBones
//
//  Created by Sherm Pendley on 9/2/10.
//  Copyright 2010 Sherm Pendley.
//

#import "CBPropertyTests.h"

// Declare methods implemented in Perl
@interface NSObject (CBPropertyTests)
- (void)setCharcbtest:(char)value;
- (char)charcbtest;
- (void)setUcharcbtest:(unsigned char)value;
- (unsigned char)ucharcbtest;
- (void)setIntcbtest:(int)value;
- (int)intcbtest;
- (void)setUintcbtest:(unsigned int)value;
- (unsigned int)uintcbtest;
- (void)setLongcbtest:(long)value;
- (long)longcbtest;
- (void)setUlongcbtest:(unsigned long)value;
- (unsigned long)ulongcbtest;
- (void)setFloatcbtest:(float)value;
- (float)floatcbtest;
- (void)setDoublecbtest:(double)value;
- (double)doublecbtest;
- (void)setStringcbtest:(char*)value;
- (char*)stringcbtest;
- (void)setObjectcbtest:(id)value;
- (id)objectcbtest;
- (void)setPointercbtest:(void*)value;
- (void*)pointercbtest;
- (void)setSelectorcbtest:(SEL)value;
- (SEL)selectorcbtest;
- (void)setPointcbtest:(NSPoint)value;
- (NSPoint)pointcbtest;
- (void)setRangecbtest:(NSRange)value;
- (NSRange)rangecbtest;
- (void)setRectcbtest:(NSRect)value;
- (NSRect)rectcbtest;
- (void)setSizecbtest:(NSSize)value;
- (NSSize)sizecbtest;
@end

@implementation CBPropertyTests

- (BOOL)testObject:(id)target withChar:(char)value {
    [target setCharcbtest:value];
    return (value == [target charcbtest]);
}

- (BOOL)testObject:(id)target withUchar:(unsigned char)value {
    [target setUcharcbtest:value];
    return (value == [target ucharcbtest]);
}

- (BOOL)testObject:(id)target withInt:(int)value {
    [target setIntcbtest:value];
    return (value == [target intcbtest]);
}

- (BOOL)testObject:(id)target withUint:(unsigned int)value {
    [target setUintcbtest:value];
    return (value == [target uintcbtest]);
}

- (BOOL)testObject:(id)target withLong:(long)value {
    [target setLongcbtest:value];
    return (value == [target longcbtest]);
}

- (BOOL)testObject:(id)target withUlong:(unsigned long)value {
    [target setUlongcbtest:value];
    return (value == [target ulongcbtest]);
}

- (BOOL)testObject:(id)target withFloat:(float)value {
    [target setFloatcbtest:value];
    return (value == [target floatcbtest]);
}

- (BOOL)testObject:(id)target withDouble:(double)value {
    [target setDoublecbtest:value];
    return (value == [target doublecbtest]);
}

- (BOOL)testObject:(id)target withString:(char*)value {
    [target setStringcbtest:value];
    return (strcmp([target stringcbtest], value) == 0);
}

- (BOOL)testObject:(id)target withObject:(id)value {
    [target setObjectcbtest:value];
    return [[target objectcbtest] isEqual:value];
}

- (BOOL)testObject:(id)target withPointer:(void*)value {
    [target setPointercbtest:value];
    return (value == [target pointercbtest]);
}

- (BOOL)testObject:(id)target withSelector:(SEL)value {
    [target setSelectorcbtest:value];
    return (value == [target selectorcbtest]);
}

- (BOOL)testObject:(id)target withPoint:(NSPoint)value {
    [target setPointcbtest:value];
    NSPoint newValue = [target pointcbtest];
    return NSEqualPoints(value, newValue);
}

- (BOOL)testObject:(id)target withRange:(NSRange)value {
    [target setRangecbtest:value];
    NSRange newValue = [target rangecbtest];
    return NSEqualRanges(value, newValue);
}

- (BOOL)testObject:(id)target withRect:(NSRect)value {
    [target setRectcbtest:value];
    NSRect newValue = [target rectcbtest];
    return NSEqualRects(value, newValue);
}

- (BOOL)testObject:(id)target withSize:(NSSize)value {
    [target setSizecbtest:value];
    NSSize newValue = [target sizecbtest];
    return NSEqualSizes(value, newValue);
}

@end

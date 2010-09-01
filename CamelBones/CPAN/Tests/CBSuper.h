/*
 Super class for subclass tests
 */

@interface CBSuper : NSObject {
    double f;
    long i;
}

- (double) floatValue;
- (long) intValue;

- (void) setFloat: (double)newVal;
- (void) setInt: (long)newInt;
@end

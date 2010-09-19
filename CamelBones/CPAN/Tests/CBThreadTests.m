/*
    Run multi-threaded tests
    Created on 11/3/05 by Sherm Pendley
*/

#include <stdio.h>
#include <unistd.h>
#import <Cocoa/Cocoa.h>

@interface CBThreadTests : NSObject {
    NSMutableDictionary *d;
    NSLock *theLock;
}

- (id) initWithDictionary: (NSDictionary*)dict;
- (void) runTests;
- (void) runFoo: (id)foo;
- (void) runBar: (id)bar;

@end

@implementation CBThreadTests

- (id) initWithDictionary: (NSDictionary*)dict {

    if (nil != (self = [super init])) {
        d = [dict retain];
        theLock = [[NSLock alloc] init];
    }
    return self;
}

- (void) runTests {
    [NSThread detachNewThreadSelector:@selector(runFoo:) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(runBar:) toTarget:self withObject:nil];
    sleep(5); // Stupid hack - should be properly synchronized
}

- (void) runFoo: (id)foo {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int i;
    for(i=0; i<1000; i++) {
        [theLock lock];
        if (![[d valueForKey:@"foo"] isEqualToString:@"bar"])
            exit(1);
        [theLock unlock];
    }
    [pool release];
}

- (void) runBar: (id)bar {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int i;
    for(i=0; i<1000; i++) {
        [theLock lock];
        if (![[d valueForKey:@"baz"] isEqualToString:@"boom"])
            exit(1);
        [theLock unlock];
    }
    [pool release];
}

@end

/*
    Exception tests
    Creates on 3/4/2007 by Sherm Pendley
*/

#import <Cocoa/Cocoa.h>
#import <CamelBones/CamelBones.h>

#import <stdio.h>

@interface CBExceptionTests : NSObject {
}

- (void)bogusPerl;

@end


@implementation CBExceptionTests

- (void)bogusPerl {
    NS_DURING
        [[CBPerl sharedPerl] eval:@"die"];
    NS_HANDLER
        NSLog(@"%@", localException);
    NS_ENDHANDLER
}

@end

//
//  PODImporter.h
//  PODImporter
//
//  Created by Sherm Pendley on 4/30/06.
//  Copyright 2006 Sherm Pendley. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PODImporter : NSObject {
    void *_sv;
}
+ (void) initialize;
@end

@interface PODImporter (PerlMethods)

// Declaring the Perl methods in a category prevents the linker from
// complaining about the incomplete implementation.

+(BOOL) getMetadata: (NSMutableDictionary*)attributes
            forFile: (NSString*)pathToFile
             ofType: (NSString*)contentTypeUTI
      withInterface: (void*)thisInterface;

@end

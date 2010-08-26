//
//  PODImporter.m
//  PODImporter
//
//  Created by Sherm Pendley on 4/30/06.
//  Copyright 2006 Sherm Pendley. All rights reserved.
//

#import <CamelBones/CamelBones.h>
#import "PODImporter.h"

@implementation PODImporter

+ (void) initialize {
    // Get the CFBundle by identifier (NSBundle doesn't find it)
    CFBundleRef bundle = CFBundleGetBundleWithIdentifier(CFSTR("org.camelbones.shux.podimporter"));

    // Get the resources path
    NSURL *resURL = (NSURL*)CFBundleCopyResourcesDirectoryURL(bundle);

    // Initialize CamelBones
    [[CBPerl sharedPerl] useLib: [resURL path]];
    [[CBPerl sharedPerl] useModule:@"PODImporter"];
}

@end

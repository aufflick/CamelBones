//
//  AppMain.m
//  CamelBones
//
//  Copyright (c) 2004 Sherm Pendley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppMain.h"
#import "CBPerl.h"

int CBApplicationMain(int argc, const char *argv[]) {
    return CBApplicationMain2("main.pl", argc, argv);
}

int CBApplicationMain2(const char *scriptName, int argc, const char *argv[]) {
    NSAutoreleasePool *arPool;
    CBPerl *sp;
    NSString *wrapperFolder;
    NSString *mainPL;
    NSString *perlcode;

    arPool = [[NSAutoreleasePool alloc] init];
    sp = [CBPerl sharedPerl];
    wrapperFolder = [[NSBundle mainBundle] resourcePath];
    mainPL = [NSString stringWithFormat: @"%@/%s", wrapperFolder, scriptName];
    perlcode = [NSString stringWithContentsOfFile: mainPL];

    // Run Perl startup code
    [sp eval: perlcode];

    // Clean up
    [arPool release];
    return 0;
}


//
//  PerlMethods.m
//  CamelBones
//
//  Copyright (c) 2004 Sherm Pendley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBPerl.h"
#import "CBPerlObject.h"
#import "CBPerlObjectInternals.h"
#import "PerlMethods_real.h"
#import "Conversions_real.h"
#import "Structs_real.h"
#import "PerlImports.h"

#include <stdarg.h>

// Get information about a Perl object
NSString* REAL_CBGetMethodNameForSelector(void* sv, SEL selector) {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    HV* hash = (HV*)SvRV((SV*)sv);
    HV* stash = SvSTASH(hash);
    char *package = HvNAME(stash);
    NSMutableString *ms = [NSMutableString stringWithString: NSStringFromSelector(selector)];

    NSString *methodEntryName = [NSString stringWithFormat: @"$%s::OBJC_EXPORT{'%@'}->{'method'}", package, ms];
    id methodEntry = [[CBPerl sharedPerl] eval: methodEntryName];

    NSRange all;

    if (methodEntry != nil) {
        return methodEntry;
    }
    
    all = [ms rangeOfString: @":"];
    while (all.length != 0) {
        [ms replaceCharactersInRange: all withString: @"_"];
        all = [ms rangeOfString: @":"];
    }
    if ([ms hasSuffix: @"_"]) {
        all = NSMakeRange([ms length]-1, 1);
        [ms deleteCharactersInRange: all];
    }

    if (gv_fetchmethod(stash, [ms UTF8String]) != NULL) {
        return ms;
    } else {
        return nil;
    }
    return nil;
}

NSString* REAL_CBGetMethodArgumentSignatureForSelector(void* sv, SEL selector) {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    HV* hash = (HV*)SvRV((SV*)sv);
    HV* stash = SvSTASH(hash);
    char *package = HvNAME(stash);
    NSMutableString *ms = [NSMutableString stringWithString: NSStringFromSelector(selector)];
    NSMutableString *params = [NSMutableString stringWithString: @""];

    NSString *methodEntryName = [NSString stringWithFormat: @"$%s::OBJC_EXPORT{'%@'}->{'args'}", package, ms];
    id methodEntry = [[CBPerl sharedPerl] eval: methodEntryName];

    NSRange all;

    if (methodEntry != nil) {
        return methodEntry;
    }

    all = [ms rangeOfString: @":"];
    while (all.length != 0) {
        [params appendString: @"@"];
        [ms replaceCharactersInRange: all withString: @"_"];
        all = [ms rangeOfString: @":"];
    }

    if ([ms hasSuffix: @"_"]) {
        all = NSMakeRange([ms length]-1, 1);
        [ms deleteCharactersInRange: all];
    }

    if (gv_fetchmethod(stash, [ms UTF8String]) != NULL) {
        return params;
    } else {
        return @"";
    }
    return @"";
}

NSString* REAL_CBGetMethodReturnSignatureForSelector(void* sv, SEL selector) {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    HV* hash = (HV*)SvRV((SV*)sv);
    HV* stash = SvSTASH(hash);
    char *package = HvNAME(stash);
    NSMutableString *ms = [NSMutableString stringWithString: NSStringFromSelector(selector)];

    NSString *methodEntryName = [NSString stringWithFormat: @"$%s::OBJC_EXPORT{'%@'}->{'return'}", package, ms];
    id methodEntry = [[CBPerl sharedPerl] eval: methodEntryName];

    NSRange all;

    if (methodEntry != nil) {
        return methodEntry;
    }

    all = [ms rangeOfString: @":"];
    while (all.length != 0) {
        [ms replaceCharactersInRange: all withString: @"_"];
        all = [ms rangeOfString: @":"];
    }

    if ([ms hasSuffix: @"_"]) {
        all = NSMakeRange([ms length]-1, 1);
        [ms deleteCharactersInRange: all];
    }

    if (gv_fetchmethod(stash, [ms UTF8String]) != NULL) {
        if ([ms hasPrefix: @"get"]) {
            return @"@";
        } else {
            return @"@";
        }
    } else {
        return @"@";
    }
    return @"@";
}

id REAL_CBPerlIMP(id self, SEL _cmd, ...) {
    // Define a Perl context
    PERL_SET_CONTEXT(_CBPerlInterpreter);
    dTHX;

    dSP;

    NSMethodSignature *methodSig;
    int numArgs;
    va_list argptr;

    CB_ObjCType typeBuf;
    
    SV *sv;
    const char *methodName;
    
    const char *returnType;
    CB_ObjCType returnValue;
    
    int success;

    // Get the method name
    methodName = [REAL_CBGetMethodNameForSelector(REAL_CBDerefIDtoSV(self), _cmd) UTF8String];

    // Save the Perl stack
    ENTER;
    SAVETMPS;
    
    PUSHMARK(SP);

    // Get "self" SV

    // If there's an accessor method, call it
    if ([self respondsToSelector:@selector(getSV)]) {
        sv = [self getSV];
    } else {

		// See if it has an instance variable

#ifdef GNUSTEP
        const char *ivarType;
        unsigned int ivarSize;
        int ivarOffset;

        if (GSObjCFindVariable(self, "_sv", &ivarType, &ivarSize, &ivarOffset)) {
            // It does - get the value
            GSObjCGetVariable(self, ivarOffset, ivarSize, (void*)&sv);
#else
		if (class_getInstanceVariable(self->isa, "_sv")) {
			// It does - get the value
			object_getInstanceVariable(self, "_sv", (void*)&sv);
		
		} else if (self->isa->info & CLS_META) {
            // Class method, self is the class name as a string
            sv = sv_2mortal(newSVpv(((struct objc_class*)self)->name, strlen(((struct objc_class*)self)->name)));
#endif
        } else {
			NSLog(@"Error: CBPerlIMP called with invalid self");
			sv = &PL_sv_undef;
		}
    }

    // Push "self" onto the stack first
    XPUSHs(sv);
    
    // Get the method signature
    methodSig = [self methodSignatureForSelector:_cmd];
    numArgs = [methodSig numberOfArguments];

    if (numArgs > 2) {
        int i;
        va_start(argptr, _cmd);

        for(i = 2; i < numArgs; i++) {
            const char *argType;

            argType = [methodSig getArgumentTypeAtIndex: i];
            switch (*argType) {
                case 'c':
                case 'i':
                case 's':
                    // short
                    typeBuf.sint = va_arg(argptr, int);
                    XPUSHs(sv_2mortal(newSViv(typeBuf.sint)));
                    break;

                case 'l':
                    // long
                    typeBuf.slong = va_arg(argptr, long);
                    XPUSHs(sv_2mortal(newSViv(typeBuf.slong)));
                    break;

                case 'C':
                case 'I':
                case 'S':
                    // unsigned short
                    typeBuf.uint = va_arg(argptr, unsigned int);
                    XPUSHs(sv_2mortal(newSViv(typeBuf.uint)));
                    break;
                    
                case 'L':
                    // unsigned long
                    typeBuf.ulong = va_arg(argptr, unsigned long);
                    XPUSHs(sv_2mortal(newSViv(typeBuf.ulong)));
                    break;
                    
                case 'f':
                case 'd':
                    // double
                    typeBuf.dfloat = va_arg(argptr, double);
                    XPUSHs(sv_2mortal(newSVnv(typeBuf.dfloat)));
                    break;
                    
                case 'v':
                    // void
                    XPUSHs(&PL_sv_undef);
                    break;

                case '*':
                    // char *
                    typeBuf.char_p = va_arg(argptr, char *);
                    XPUSHs(sv_2mortal(newSVpv(typeBuf.char_p, strlen(typeBuf.char_p))));
                    break;
                    
                case '@':
                    // id
                    typeBuf.id_p = va_arg(argptr, id);
                    XPUSHs(sv_2mortal(REAL_CBDerefIDtoSV(typeBuf.id_p)));
                    break;
                    
                case '^':
                    // Pointer
                    typeBuf.void_p = va_arg(argptr, void*);
                    XPUSHs(sv_2mortal(newSViv(PTR2IV(typeBuf.void_p))));
                	break;

                case '#':
                    // Class
                    typeBuf.class_p = va_arg(argptr, Class);
                    XPUSHs(sv_2mortal(REAL_CBSVFromClass(typeBuf.class_p)));
                    break;

                case ':':
                    // SEL
                    typeBuf.sel_p = va_arg(argptr, SEL);
                    XPUSHs(sv_2mortal(REAL_CBSVFromSelector(typeBuf.sel_p)));
                    break;

                case '[':
                    // array
                    typeBuf.void_p = va_arg(argptr, void*);
                    XPUSHs(sv_2mortal(newSViv(typeBuf.ulong)));
                    break;

                case '{':
                    // struct
                    if (0 == strncmp(argType, "{NSPoint", strlen("{NSPoint"))) {
                        typeBuf.point_s = va_arg(argptr, NSPoint);
                        XPUSHs(sv_2mortal(REAL_CBPointToSV(typeBuf.point_s)));
                    } else if (0 == strncmp(argType, "{NSRange", strlen("{NSRange"))) {
                        typeBuf.range_s = va_arg(argptr, NSRange);
                        XPUSHs(sv_2mortal(REAL_CBRangeToSV(typeBuf.range_s)));
                    } else if (0 == strncmp(argType, "{NSRect", strlen("{NSRect"))) {
                        typeBuf.rect_s = va_arg(argptr, NSRect);
                        XPUSHs(sv_2mortal(REAL_CBRectToSV(typeBuf.rect_s)));
                    } else if (0 == strncmp(argType, "{NSSize", strlen("{NSSize"))) {
                        typeBuf.size_s = va_arg(argptr, NSSize);
                        XPUSHs(sv_2mortal(REAL_CBSizeToSV(typeBuf.size_s)));
                    } else {
                        NSLog(@"Unknown struct type %s in position %d", argType, i);
                        XPUSHs(&PL_sv_undef);
                    }
                    break;

                case '(':
                    // union

                case 'b':
                    // bit field

                case '?':
                    // unknown

                case 'q':
                case 'Q':
                default:
                    NSLog(@"Unknown type %s in position %d", argType, i);
            }
        
        va_end(argptr);
        }
    }

    PUTBACK;

    // Call the method in an "eval" block so errors can be trapped
    success = call_method(methodName, G_EVAL | G_SCALAR);

    SPAGAIN;

    // Check for an error
    if (SvTRUE(ERRSV)) {
        [NSException raise:CBPerlErrorException format:@"Perl exception: %s", SvPV(ERRSV, PL_na)];
    }

    // No error
    returnType = [methodSig methodReturnType];
    if (success) {
        switch (*returnType) {
            case 'c':
                // char
                returnValue.sint = POPi;
                break;
    
            case 'i':
                // int
                returnValue.sint = POPi;
                break;
    
            case 's':
                // short
                returnValue.sint = POPi;
                break;
    
            case 'l':
                // long
                returnValue.slong = POPl;
                break;
    
            case 'q':
                // long long
                NSLog(@"Long long return value not implemented");
                break;
    
            case 'C':
                // unsigned char
                returnValue.uint = POPi;
                break;
    
            case 'I':
                // unsigned int
                returnValue.uint = POPi;
                break;
                
            case 'S':
                // unsigned short
                returnValue.uint = POPi;
                break;
                
            case 'L':
                // unsigned long
                returnValue.ulong = POPi;
                break;
                
            case 'Q':
                // unsigned long long
                NSLog(@"Unsigned long long return value not implemented");
                break;
    
            case 'f':
                // float
                returnValue.dfloat = POPn;
                break;
                
            case 'd':
                // double
                returnValue.dfloat = POPn;
                break;
                
            case 'v':
                // void
                returnValue.void_p = NULL;
                break;
    
            case '*':
                // char *
                returnValue.char_p = SvPV_nolen(POPs);
                break;
    
            case '@':
                // id
                returnValue.id_p = REAL_CBDerefSVtoID(POPs);
                break;

            case '^':
                // pointer
                returnValue.void_p = INT2PTR(void*, POPi);
                break;
    
            case '#':
                // Class
                returnValue.class_p = REAL_CBClassFromSV(POPs);
                break;
    
            case ':':
                // SEL
                returnValue.sel_p = REAL_CBSelectorFromSV(POPs);
                break;
    
            case '[':
                // array
                returnValue.uint = POPi;
                break;
    
            case '{':
                // struct
                if (0 == strncmp(returnType, "{NSPoint", strlen("{NSPoint"))) {
                    returnValue.point_s = REAL_CBPointFromSV(POPs);
                } else if (0 == strncmp(returnType, "{NSRange", strlen("{NSRange"))) {
                    returnValue.range_s = REAL_CBRangeFromSV(POPs);
                } else if (0 == strncmp(returnType, "{NSRect", strlen("{NSRect"))) {
                    returnValue.rect_s = REAL_CBRectFromSV(POPs);
                } else if (0 == strncmp(returnType, "{NSSize", strlen("{NSSize"))) {
                    returnValue.size_s = REAL_CBSizeFromSV(POPs);
                } else {
                    NSLog(@"Unknown struct type %s in return", returnType);
                    returnValue.ulong = 0;
                }
                break;
    
            case '(':
                // union
                break;
    
            case 'b':
                // bit field
                break;
    
            case '?':
                // unknown
                break;
    
            default:
                NSLog(@"Unknown return type %s", returnType);
                break;
        }
    } else {
        returnValue.uint = 0;
    }
    
    FREETMPS;
    LEAVE;

    if (*returnType != 'v') {
        return returnValue.id_p;
    } else {
        return nil;
    }
}


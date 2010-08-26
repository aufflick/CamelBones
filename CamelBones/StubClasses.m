#import "CBPerl.h"

@implementation CBPerl
+ (CBPerl *) sharedPerl { return nil; }
+ (CBPerl *) sharedPerlXS { return nil; }
- (id) init {
    self = [super init];
    return self;
}
- (id) initXS { return nil; }
- (void) useBundleLib: (NSBundle *)aBundle
		withArch: (NSString *)perlArchName
		forVersion: (NSString *)perlVersion {
	return;
}
- (id) eval: (NSString *)perlCode { return nil; }
- (id) valueForKey: (NSString *)key { return nil; }
- (void) setValue:(id)value forKey:(NSString *)key { return ; }
- (long) varAsInt: (NSString *)perlVar { return 0; }
- (void) setVar: (NSString *)perlVar toInt: (long)newValue { return; }
- (double) varAsFloat: (NSString *)perlVar { return 0.0; }
- (void) setVar: (NSString *)perlVar toFloat: (double)newValue { return; }
- (NSString *) varAsString: (NSString *)perlVar { return nil; }
- (void) setVar: (NSString *)perlVar toString: (NSString *)newValue { return; }
- (void) useLib: (NSString *)libPath { return; }
- (void) useModule: (NSString *)moduleName { return; }
- (void) useWarnings { return; }
- (void) noWarnings { return; }
- (void) useStrict { return; }
- (void) useStrict: (NSString *)options { return; }
- (void) noStrict { return; }
- (void) noStrict: (NSString *)options { return; }
- (CBPerlScalar *) namedScalar: (NSString *)varName { return nil; }
- (CBPerlArray *) namedArray: (NSString *)varName { return nil; }
- (CBPerlHash *) namedHash: (NSString *)varName { return nil; }
- (CBPerlObject *) namedObject: (NSString *)varName { return nil; }
- (void) exportArray: (NSArray *)array toPerlArray: (NSString *)arrayName { return; }
- (void) exportDictionary: (NSDictionary *)dictionary toPerlHash: (NSString *)hashName { return; }
- (void) exportObject: (id)object toPerlObject: (NSString *)objectName { return; }

+ (void) stubInit { return; }
+ (void) dylibInit: (char*)archver { NSLog(@"%@", @"Using stub dylibInit!"); }

- (void) bundleDidLoad:(NSNotification *)notification { return; }
@end



#import "CBPerlArray.h"

@implementation CBPerlArray
#ifdef GNUSTEP
- (id) initWithCapacity: (unsigned int) anInt { return nil; }
#endif /* GNUSTEP */
- (unsigned)count { return 0; }
- (id)objectAtIndex:(unsigned)index { return nil; }
- (void)addObject:(id)anObject { return; }
- (void)insertObject:(id)anObject atIndex:(unsigned)index { return; }
- (void)removeLastObject { return; }
- (void)removeObjectAtIndex:(unsigned)index { return; }
- (void)replaceObjectAtIndex:(unsigned)index withObject:(id)anObject { return; }
+ (id) arrayNamed: (NSString *)varName isReference: (BOOL)isRef create: (BOOL)shouldCreate { return nil; }
+ (id) arrayNamed: (NSString *)varName isReference: (BOOL)isRef { return nil; }
+ (id) arrayNamed: (NSString *)varName { return nil; }
+ (id) newArrayNamed: (NSString *)varName { return nil; }
+ (id) arrayReferenceNamed: (NSString *)varName { return nil; }
+ (id) newArrayReferenceNamed: (NSString *)varName { return nil; }
- (id) initArrayNamed: (NSString *)varName isReference: (BOOL)isRef create: (BOOL)shouldCreate { return nil; }
- (id) initArrayNamed: (NSString *)varName isReference: (BOOL)isRef { return nil; }
- (id) initArrayNamed: (NSString *)varName { return nil; }
- (id) initNewArrayNamed: (NSString *)varName { return nil; }
- (id) initArrayReferenceNamed: (NSString *)varName { return nil; }
- (id) initNewArrayReferenceNamed: (NSString *)varName { return nil; }
@end



#import "CBPerlHash.h"

@implementation CBPerlHash
- (unsigned)count { return 0; }
- (NSEnumerator *)keyEnumerator { return nil; }
- (id)objectForKey:(id)aKey { return nil; }
- (void)removeObjectForKey:(id)aKey { return; }
- (void)setObject:(id)anObject forKey:(id)aKey { return; }
+ (id) dictionaryNamed: (NSString *)varName isReference: (BOOL)isRef create: (BOOL)shouldCreate { return nil; }
+ (id) dictionaryNamed: (NSString *)varName isReference: (BOOL)isRef { return nil; }
+ (id) dictionaryNamed: (NSString *)varName { return nil; }
+ (id) newDictionaryNamed: (NSString *)varName { return nil; }
+ (id) dictionaryReferenceNamed: (NSString *)varName { return nil; }
+ (id) newDictionaryReferenceNamed: (NSString *)varName { return nil; }
- (id) initDictionaryNamed: (NSString *)varName isReference: (BOOL)isRef create: (BOOL)shouldCreate { return nil; }
- (id) initDictionaryNamed: (NSString *)varName isReference: (BOOL)isRef { return nil; }
- (id) initDictionaryNamed: (NSString *)varName { return nil; }
- (id) initNewDictionaryNamed: (NSString *)varName { return nil; }
- (id) initDictionaryReferenceNamed: (NSString *)varName { return nil; }
- (id) initNewDictionaryReferenceNamed: (NSString *)varName { return nil; }
@end


@implementation CBPerlHashKeyEnumerator
- (NSArray *)allObjects { return nil; }
- (id)nextObject { return nil; }
@end


#import "CBPerlObject.h"
#import "CBPerlObjectInternals.h"

@implementation CBPerlObject
+ (CBPerlObject *) namedObject: (NSString *)varName { return nil; }
+ (CBPerlObject *) namedObject: (NSString *)varName ofClass: (NSString *)newClassName { return nil; }
- (CBPerlObject *) initNamedObject: (NSString *)varName { return nil; }
- (CBPerlObject *) initNamedObject: (NSString *)varName ofClass: (NSString *)newClassName { return nil; }
- (NSString *) perlClassName { return nil; }
- (BOOL) hasProperty: (NSString *)propName { return FALSE; }
- (id) getProperty: (NSString *)propName { return nil; }
- (void) setProperty: (NSString *)propName toObject: (id)propValue { return; }

+ (CBPerlObject *) objectWithSV: (void *)newSV { return nil; }
- (CBPerlObject *) initObjectWithSV: (void *)newSV { return nil; }
- (void *)getSV { return NULL; }
@end



#import "CBPerlScalar.h"
#import "CBPerlScalarInternals.h"

@implementation CBPerlScalar
+ (CBPerlScalar *) namedScalar: (NSString *)varName { return nil; }
+ (CBPerlScalar *) namedScalar: (NSString *)varName withDefaultString: (NSString *)def { return nil; }
+ (CBPerlScalar *) namedScalar: (NSString *)varName withDefaultInteger: (long)def { return nil; }
+ (CBPerlScalar *) namedScalar: (NSString *)varName withDefaultDouble: (double)def { return nil; }
+ (CBPerlScalar *) namedReference: (NSString *)varName toArray: (CBPerlArray *)target { return nil; }
+ (CBPerlScalar *) namedReference: (NSString *)varName toHash: (CBPerlHash *)target { return nil; }
+ (CBPerlScalar *) namedReference: (NSString *)varName toObject: (CBPerlObject *)target { return nil; }
+ (CBPerlScalar *) namedReference: (NSString *)varName toNativeObject: (NSObject *)target { return nil; }
- (CBPerlScalar *) initNamedScalar: (NSString *)varName { return nil; }
- (CBPerlScalar *) initNamedScalar: (NSString *)varName withDefaultString: (NSString *)def { return nil; }
- (CBPerlScalar *) initNamedScalar: (NSString *)varName withDefaultInteger: (long)def { return nil; }
- (CBPerlScalar *) initNamedScalar: (NSString *)varName withDefaultDouble: (double)def { return nil; }
- (CBPerlScalar *) initNamedReference: (NSString *)varName toArray: (NSArray *)target { return nil; }
- (CBPerlScalar *) initNamedReference: (NSString *)varName toHash: (NSDictionary *)target { return nil; }
- (CBPerlScalar *) initNamedReference: (NSString *)varName toObject: (CBPerlObject *)target { return nil; }
- (CBPerlScalar *) initNamedReference: (NSString *)varName toNativeObject: (NSObject *)target { return nil; }
- (BOOL) isInteger { return NO; }
- (BOOL) isFloat { return NO; }
- (BOOL) isString { return NO; }
- (BOOL) isRef { return NO; }
- (BOOL) isArrayRef { return NO; }
- (BOOL) isHashRef { return NO; }
- (BOOL) isObjectRef { return NO; }
- (BOOL) isTrue { return NO; }
- (BOOL) isDefined { return NO; }
- (int) refType { return 0; }
- (NSString *) getString { return nil; }
- (void) setToString: (NSString *)newValue { return; }
- (long) getInt { return 0; }
- (void) setToInt: (long)newValue { return; }
- (double) getFloat { return 0.0; }
- (void) setToFloat: (double)newValue { return; }
- (id) dereference { return nil; }
- (void) setTargetToArray: (NSArray *)target { return; }
- (void) setTargetToHash: (NSDictionary *)target { return; }
- (void) setTargetToObject: (CBPerlObject *)target { return; }
- (void) setTargetToNativeObject: (NSObject *)target { return; }
- (void) setTargetToPointer: (void *)target { return; }
- (void) replace: (NSString *)pattern with:(NSString *)newString { return; }
- (void) replace: (NSString *)pattern with:(NSString *)newString usingFlags:(NSString *)flags { return; }
- (BOOL) matches: (NSString *)pattern { return NO; }
- (BOOL) matches: (NSString *)pattern usingFlags:(NSString *)flags { return NO; }
- (NSArray *) getMatches: (NSString *)pattern { return nil; }
- (NSArray *) getMatches: (NSString *)pattern usingFlags:(NSString *)flags { return nil; }


+ (CBPerlScalar *) scalarWithSV: (void *)newSV { return nil; }
- (CBPerlScalar *) initScalarWithSV: (void *)newSV { return nil; }
- (void *)getSV { return NULL; }
@end

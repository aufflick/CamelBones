package CoreFoundation;

@ISA = qw(Exporter DynaLoader);
@EXPORT = qw( );
$VERSION = '1.0';
bootstrap CoreFoundation $VERSION;
    
use PerlObjCBridge;

package CFXPreferencesCompatibilitySource;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package CFXPreferencesManagedSource;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package CFXPreferencesPropertyListSource;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package CFXPreferencesSearchListSource;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package CFXPreferencesSource;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSArray;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSBlock;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSCache;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSCalendar;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSData;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSDate;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSDateComponents;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSDictionary;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSEnumerator;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSException;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSInputStream;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSInvocation;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSLocale;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSMessageBuilder;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSMethodSignature;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSMutableArray;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSMutableData;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSMutableDictionary;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSMutableSet;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSNull;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSObject;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSOutputStream;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSRunLoop;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSSet;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSStream;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSTimeZone;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSTimer;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSURL;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package NSUserDefaults;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package _NSZombie_;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __CFHashTable;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __CFMapTable;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __CFPointerArray;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __CFx606449CHT;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __CFx606449CMT;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __CFx606449CPA;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __CFx606449CPF;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __CFx606449PF;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSArray0;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSArrayReverseEnumerator;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSArrayReversed;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSAutoBlock;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSBlockVariable;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSCFArray;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSCFCalendar;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSCFDate;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSCFDictionary;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSCFSet;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSCFTimeZone;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSCFType;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSDictionary0;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSDictionaryObjectEnumerator;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSFastEnumerationEnumerator;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSFinalizingBlock;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSGenericDeallocHandler;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSGlobalBlock;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSLocalTimeZone;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSMallocBlock;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSPlaceholderArray;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSPlaceholderDate;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSPlaceholderDictionary;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSPlaceholderSet;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSPlaceholderTimeZone;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSSet0;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

package __NSStackBlock;
@ISA = qw(PerlObjCBridge);
@EXPORT = qw( );

1;

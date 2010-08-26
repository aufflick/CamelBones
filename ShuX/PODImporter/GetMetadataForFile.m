#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h> 
#import <Cocoa/Cocoa.h>

#import <CamelBones/CamelBones.h>
#import "PODImporter.h"

Boolean GetMetadataForFile(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
    /* Pull any available metadata from the file at the specified path */
    /* Return the attribute keys and attribute values in the dict */
    /* Return TRUE if successful, FALSE if there was no data provided */

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	Boolean retVal = [PODImporter getMetadata: (NSMutableDictionary*)attributes
                                      forFile: (NSString*)pathToFile
                                       ofType: (NSString*)contentTypeUTI
                                withInterface: thisInterface];

	[pool release];
	
    return retVal;
}

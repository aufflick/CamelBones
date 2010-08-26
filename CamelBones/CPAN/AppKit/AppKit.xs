#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#ifndef GNUSTEP
#include <Carbon/Carbon.h>
#endif

#import <CamelBones/PerlImports.h>
#import <CamelBones/Conversions.h>
#import <CamelBones/Structs.h>

MODULE = CamelBones::AppKit		PACKAGE = CamelBones::AppKit

PROTOTYPES: ENABLE

# Services
BOOL
NSShowsServicesMenuItem (itemName)
    id itemName;

int NSSetShowsServicesMenuItem (itemName, enabled)
    id itemName;
    BOOL enabled;

void
NSUpdateDynamicServices ()

BOOL
NSPerformService (itemName, pBoard)
    id itemName;
    id pBoard;

void
NSRegisterServicesProvider (provider, name)
    id provider;
    id name;

# Graphics
void
NSRectFill (aRect)
    NSRect aRect;

void
NSRectFillList(rects, count)
    NSRect *rects;
    int count;

void
NSRectFillListWithGrays(rects, grays, num)
    NSRect *rects;
    float *grays;
    int num;

void
NSRectFillListWithColors(rects, colors, num)
    NSRect *rects;
    NSColor **colors;
    int num;
    
void
NSRectFillUsingOperation (aRect, op)
    NSRect aRect;
    int op;

void
NSRectFillListUsingOperation(rects, count, op)
    NSRect *rects;
    int count;
    int op;
    
void
NSRectFillListWithColorsUsingOperation(rects, colors, num, op)
    NSRect *rects;
    NSColor **colors;
    int num;
    int op;

void
NSFrameRect (aRect)
    NSRect aRect;

void
NSFrameRectWithWidth (aRect, frameWidth)
    NSRect aRect;
    float frameWidth;

#ifndef GNUSTEP
void
NSFrameRectWithWidthUsingOperation (aRect, frameWidth, op)
    NSRect aRect;
    float frameWidth;
    int op;

#endif

void
NSRectClip (aRect)
    NSRect aRect;

void
NSRectClipList(rects, count)
    NSRect *rects;
    int count;

NSRect
NSDrawTiledRects(boundsRect, clipRect, sides, grays, count)
    NSRect boundsRect;
    NSRect clipRect;
    NSRectEdge *sides;
    float *grays;
    int count;

void
NSDrawGrayBezel (boundsRect, clipRect)
    NSRect boundsRect;
    NSRect clipRect;

void
NSDrawGroove (boundsRect, clipRect)
    NSRect boundsRect;
    NSRect clipRect;

void
NSDrawWhiteBezel (boundsRect, clipRect)
    NSRect boundsRect;
    NSRect clipRect;

void
NSDrawButton(boundsRect, clipRect)
    NSRect boundsRect;
    NSRect clipRect;
    
void
NSEraseRect(aRect)
    NSRect aRect;
    
id
NSReadPixel (aPoint)
    NSPoint aPoint;

void
NSDrawBitmap (rect, width, height, bps, spp, bpp, bpr, isPlanar, hasAlpha, colorSpaceName, data)
    NSRect rect;
    int width;
    int height;
    int bps;
    int spp;
    int bpp;
    int bpr;
    BOOL isPlanar;
    BOOL hasAlpha;
    id colorSpaceName;
    void* data;
    CODE:
        NSDrawBitmap(rect, width, height, bps, spp, bpp, bpr, isPlanar, hasAlpha, colorSpaceName, (const unsigned char**)&data );


void
NSCopyBits (srcGState, srcRect, destPoint)
    int srcGState;
    NSRect srcRect;
    NSPoint destPoint;

void
NSHighlightRect (aRect)
    NSRect aRect;

void
NSBeep ()

void
NSCountWindows (count)
    int &count;
    OUTPUT:
    count

void
NSWindowList ( size, list )
    int size;
    int *list;

void
NSCountWindowsForContext(context, count)
    int context;
    int &count;
    OUTPUT:
        count

void
NSWindowListForContext(context, size, list)
    int context;
    int size;
    int *list;
    

NSRect
NSDrawColorTiledRects(boundsRect, clipRect, sides, colors, count)
    NSRect boundsRect;
    NSRect clipRect;
    NSRectEdge *sides;
    NSColor **colors;
    int count;

void
NSDrawDarkBezel (boundsRect, clipRect)
    NSRect boundsRect;
    NSRect clipRect;
    
void
NSDrawLightBezel (boundsRect, clipRect)
    NSRect boundsRect;
    NSRect clipRect;
    
void
NSDottedFrameRect (aRect)
    NSRect aRect;

void
NSDrawWindowBackground (aRect)
    NSRect aRect;

#ifndef GNUSTEP
void
NSSetFocusRingStyle (style)
    int style;

#endif

int
NSInterfaceStyleForKey (key, responder)
    id key;
    id responder;

# Alert panels
# NOTE: No support for variable argument lists - use Perl interpolation of variables into msg instead.

int
NSRunAlertPanel (title, msg, defaultButton, altButton, otherButton)
    id title;
    id msg;
    id defaultButton;
    id altButton;
    id otherButton

int
NSRunInformationalAlertPanel (title, msg, defaultButton, altButton, otherButton)
    id title;
    id msg;
    id defaultButton;
    id altButton;
    id otherButton

int
NSRunCriticalAlertPanel (title, msg, defaultButton, altButton, otherButton)
    id title;
    id msg;
    id defaultButton;
    id altButton;
    id otherButton

void
NSBeginAlertSheet(title, defaultButton, altButton, otherButton, docWindow, modalDelegate, didEndSelector, didDismissSelector, contextInfo, msg)
    id title;
    id defaultButton;
    id altButton;
    id otherButton;
    id docWindow;
    id modalDelegate;
    SEL didEndSelector;
    SEL didDismissSelector;
    void* contextInfo;
    id msg;

void
NSBeginInformationalAlertSheet(title, defaultButton, altButton, otherButton, docWindow, modalDelegate, didEndSelector, didDismissSelector, contextInfo, msg)
    id title;
    id defaultButton;
    id altButton;
    id otherButton;
    id docWindow;
    id modalDelegate;
    SEL didEndSelector;
    SEL didDismissSelector;
    void* contextInfo;
    id msg;

void
NSBeginCriticalAlertSheet(title, defaultButton, altButton, otherButton, docWindow, modalDelegate, didEndSelector, didDismissSelector, contextInfo, msg)
    id title;
    id defaultButton;
    id altButton;
    id otherButton;
    id docWindow;
    id modalDelegate;
    SEL didEndSelector;
    SEL didDismissSelector;
    void* contextInfo;
    id msg;

id
NSGetAlertPanel (title, msg, defaultButton, altButton, otherButton)
    id title;
    id msg;
    id defaultButton;
    id altButton;
    id otherButton;
    
id
NSGetInformationalAlertPanel (title, msg, defaultButton, altButton, otherButton)
    id title;
    id msg;
    id defaultButton;
    id altButton;
    id otherButton;
    
id
NSGetCriticalAlertPanel (title, msg, defaultButton, altButton, otherButton)
    id title;
    id msg;
    id defaultButton;
    id altButton;
    id otherButton;
    
void
NSReleaseAlertPanel (alertPanel)
    id alertPanel;


# Copy and paste
id
NSCreateFilenamePboardType (type)
    id type;

id
NSCreateFileContentsPboardType (type)
    id type;
    
id
NSGetFileType (file)
    id file;
    
id
NSGetFileTypes (files)
    id files;

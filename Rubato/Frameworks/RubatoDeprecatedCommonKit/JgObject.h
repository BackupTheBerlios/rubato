#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import "CommonTypes.h"

#define MAXPATHLEN 1024
#define JGSHALLOWCOPY NSCopyObject(self,0,zone)
#define JgObject NSObject

@interface NSString (JGString)
+ (NSString *)jgStringWithCString:(const char*)str;
@end

@interface NSObject (OldObject)
+ (BOOL)isKindOfClassNamed:(const char *)name;
- (BOOL)isKindOfClassNamed:(const char *)name;
@end

//old code used during conversation from NextStep to MacOSX:
#if 0
// phantasy
// somewhere streams.h is included! There NX_* may not be defined!
// to avoid Compiler warnings, I set here the right values (from streams.h)
#ifndef STREAMS_H
#define NX_READWRITE 4
#define NX_FROMSTART 0
#define NX_FREEBUFFER 0
#endif

// for Stream->MutableString conversion. e.g.:
// JGPrintf(stream, "%s", [delimiters new]);
// [stream appendFormat:@"%s",[delemiters new]]

void JGPrintf(NSMutableString *stream, const char*format, const void *arg); // normally  Ellipse, but is not used
void JGPrintfChar(NSMutableString *stream, const char*format, char arg);// Definition because otherwise warnings
void JGPrintfDouble(NSMutableString *stream, const char*format, double arg); // Definition because otherwise warnings
NSMutableString *JGOpenMemory(const char *address, int size, int mode); 
void JGFlush(NSMutableString *stream);
void JGSeek(NSMutableString *stream,long offset, int ptrName);
void JGGetMemoryBuffer(NSMutableString *stream, char **streambuf, int *len, int *maxlen);
void JGCloseMemory(NSMutableString *stream, int option);

const char *JGUniqueString(const char *paraName);

// implemented as following:
//#define JGPrintf(X,Y,Z) [X appendFormat:[NSString stringWithCString:Y], Z]
//#define JGOpenMemory(X,Y,Z) [NSMutableString new]
//#define JGFlush(X) ;
//#define JGSeek(X, Y, Z) ;
//#define JGGetMemoryBuffer(X,Y,Z,W) ;
//#define JGCloseMemory(X, Y) ;

@interface JgObject : NSObject
// uncommented are not used anymore
//+ (NSString *)getClassName;

- copyWithZone:(NSZone *)zone;
// catch legacy calls to jgCopyWithZone
- jgCopyWithZone:(NSZone *)zone;
- initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (NSString *)name;
@end
#endif

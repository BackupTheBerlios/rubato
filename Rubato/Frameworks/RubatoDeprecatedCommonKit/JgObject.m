#import "JgObject.h"


@implementation NSString (JGString)
+ (NSString *)jgStringWithCString:(const char*)str;
{
  if (str) return [NSString stringWithCString:str];
  else return @"";
}
@end

@implementation NSObject (WasJgObjectCat)

+ (BOOL)isKindOfClassNamed:(const char *)name;
{
// the following only returns true, if name=="NSObject".
//   return [self isKindOfClass:NSClassFromString([NSString stringWithCString:name])];
// that why we have the following code:
 id nameclass=NSClassFromString([NSString stringWithCString:name]);
 id nsobjectclass=[NSObject class];
 id thisclass=[self class];
 if (![thisclass respondsToSelector:@selector(isKindOfClass:)]
     || ![thisclass isKindOfClass:nsobjectclass])
    return NO;
 // sure, that Subclasse of NSObject.
 if (thisclass==nameclass || nameclass==nsobjectclass) return YES;
 while  (thisclass !=nsobjectclass) {
   thisclass=[thisclass superclass];
   if (thisclass==nameclass) return YES;
 }
 return NO;
/* Example:
 BOOL a,b, ab,ba,bb,iab,iba;
 NSString *s=[NSString stringWithCString:"hello"];
 A *ia=[A new];
 B *ib=[B new];
 a=[A isKindOfClassNamed:"NSObject"];
 b=[B isKindOfClassNamed:"NSObject"];
 ab=[A isKindOfClassNamed:"B"];
 ba=[B isKindOfClassNamed:"A"];
 bb=[B isKindOfClassNamed:"B"];
 iab=[ia isKindOfClassNamed:"B"];
 iba=[ib isKindOfClassNamed:"A"];

 printf("a=%d,b=%d,ab=%d,ba=%d,bb=%d,iab=%d,iba=%d",a,b,ab,ba,bb,iab,iba);
// a=1,b=1,ab=0,ba=0,bb=0,iab=0,iba=1  (original +isKindOfClass Method)
// a=1,b=1,ab=0,ba=1,bb=1,iab=0,iba=1  (own Methode) correct!
*/
}
- (BOOL)isKindOfClassNamed:(const char *)name;
{
  return [self isKindOfClass:NSClassFromString([NSString stringWithCString:name])];
}
@end

#if 0
//#ifdef WORKAROUND_NX_STREAM
void JGPrintf(NSMutableString *stream, const char*format, const void *arg) // normally  Ellipse, but is not used
{
  [stream appendFormat:[NSString jgStringWithCString:format], arg];
}
void JGPrintfChar(NSMutableString *stream, const char*format, char arg) // Definition because otherwise warnings
{
  [stream appendFormat:[NSString jgStringWithCString:format], arg];
}
void JGPrintfDouble(NSMutableString *stream, const char*format, double arg) // Definition because otherwise warnings
{
  [stream appendFormat:[NSString jgStringWithCString:format], arg];
}

NSMutableString *JGOpenMemory(const char *address, int size, int mode)
{
  return [NSMutableString new];
}
void JGFlush(NSMutableString *stream){;}
void JGSeek(NSMutableString *stream,long offset, int ptrName){;}
void JGGetMemoryBuffer(NSMutableString *stream, char **streambuf, int *len, int *maxlen){;}
void JGCloseMemory(NSMutableString *stream, int option){;}
// jg?:
const char *JGUniqueString(const char *paraName){return paraName;}

//WORKAROUND_NX_STREAM

@implementation JgObject
/*
+ (NSString *)getClassName;
{
  return NSStringFromClass([self class]);
}
*/

- copyWithZone:(NSZone *)zone;
{
//  return [[[self class] allocWithZone:zone] init]; // jg?:with init??
  return JGSHALLOWCOPY; // shallow copy
}

- jgCopyWithZone:(NSZone *)zone; // if its not catched before, now it is.
{
  return [self copyWithZone:zone]; 
}

- initWithCoder:(NSCoder *)coder;
{
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
  return;
}
- (NSString *)name;
{
  return NSStringFromClass([self class]);
}
@end
#endif


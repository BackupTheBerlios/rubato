//  JGValueArray.m Copyright (c) 2002 Joerg Garbers.
//  This software is open source. See the license.

#import "JGValueArray.h"
#import <FScript/FSKVCoding.h>
#import <FScript/Number.h>
#import "math.h"

// defined in FScript.framework. We do not want to link to it, so we use a workaround here.
#define NumberClass NSClassFromString(@"Number")

// const char *NSGetSizeAndAlignment(const char *typePtr, unsigned int *sizep, unsigned int *alignp)
@implementation JGValueArray 

// for prototypes
+ (NSNumber *)numberWithObjCType:(const char *)typ;
{
  char switchVal=typ[0];
#define NC1(character,method,typ) case character: return [NSNumber method:(typ)(((unsigned typ)-1) >> 1)]; break;
#define NC2(character,method,typ) case character: return [NSNumber method:(typ)(-1)]; break;
  switch(switchVal) {
    NC1('c',numberWithChar,char);
    NC1('i',numberWithInt,int);
    NC1('s',numberWithShort,short);
    NC1('l',numberWithLong,long);
    NC1('q',numberWithLongLong,long long);
    NC2('C',numberWithUnsignedChar,unsigned char);
    NC2('I',numberWithUnsignedInt,unsigned int);
    NC2('S',numberWithUnsignedShort,unsigned short);
    NC2('L',numberWithUnsignedLong,unsigned long);
    NC2('Q',numberWithUnsignedLongLong,unsigned long long);
    case 'f': return [NSNumber numberWithFloat:M_PI]; break;
    case 'd': return [NSNumber numberWithDouble:((double)1.1)*MAXFLOAT]; break;
//    NC('Q',numberWithBool,BOOL);
    default: NSAssert1(0,@"JGNumberArray error: not a number type. Unmatched char %c",switchVal); return nil;
  }
}


+ (NSNumber *)numberWithElementType:(NSString *)elementType;
{
  int c=[elementType length];
  if (c==1)
    return [self numberWithObjCType:[elementType cString]];
  else
    return [self numberWithObjCType:[[self elementTypeForCType:elementType] cString]];
}


// cType e.g. is @"unsigned int"
+ (NSString *)elementTypeForCType:(NSString *)cType;
{
  const char *ctyp=[cType cString];
  char result[2];
  result[1]=0;
#undef NC
#define NC(character,method,typ) if (!strcmp(ctyp,#typ)) { result[0]=character; return [NSString stringWithCString:result]; }
    NC('c',numberWithChar,char);
    NC('C',numberWithUnsignedChar,unsigned char);
    NC('i',numberWithInt,int);
    NC('I',numberWithUnsignedInt,unsigned int);
    NC('s',numberWithShort,short);
    NC('S',numberWithUnsignedShort,unsigned short);
    NC('l',numberWithLong,long);
    NC('L',numberWithUnsignedLong,unsigned long);
    NC('q',numberWithLongLong,long long);
    NC('Q',numberWithUnsignedLongLong,unsigned long long);
    NC('f',numberWithFloat,float);
    NC('d',numberWithDouble,double);
  NSAssert1(0,@"JGNumberArray error: not a correct type \"%@\"",cType); return nil;
}

// creates a number object, if the value is of type NSValue.
+ (NSNumber *)numberWithValue:(NSValue *)value;
{
  char switchVal;
  if ([value isKindOfClass:[NSNumber class]])
    return (NSNumber *)value;
  switchVal=[value objCType][0];
#undef NC
#define NC(character,method,typ) case character: {typ val; [value getValue:&val]; return [NSNumber method:val];} break;
  switch(switchVal) {
    NC('c',numberWithChar,char);
    NC('C',numberWithUnsignedChar,unsigned char);
    NC('i',numberWithInt,int);
    NC('I',numberWithUnsignedInt,unsigned int);
    NC('s',numberWithShort,short);
    NC('S',numberWithUnsignedShort,unsigned short);
    NC('l',numberWithLong,long);
    NC('L',numberWithUnsignedLong,unsigned long);
    NC('q',numberWithLongLong,long long);
    NC('Q',numberWithUnsignedLongLong,unsigned long long);
    NC('f',numberWithFloat,float);
    NC('d',numberWithDouble,double);
//    NC('Q',numberWithBool,BOOL);
    default: NSAssert1(0,@"JGNumberArray error: value not a number. Unmatched char %c",switchVal); return nil;
  }
}

// creates a NSValue object with a typ element from a NSValue or NSNumber or Number object
// it is not and may not be an NSNumber instance, because NSNumber chooses always the shortest
// Representation. But we want to use getValue
+ (NSValue *)valueWithObjCType:(const char *)typ forValue:(id)value;
{
  NSNumber *number;
  NSParameterAssert(typ);
  if ([value isKindOfClass:NumberClass])
    value=[NSNumber numberWithDouble:[value doubleValue]];
  else
    NSParameterAssert([value isKindOfClass:[NSValue class]]);
  if (!strcmp([value objCType],typ)) 
    return value;
  NSParameterAssert(typ[1]==0);
  number=[self numberWithValue:value];
#undef NC
#define NC(character,convertmeth,valtyp) case character: {valtyp val=[number convertmeth]; return [NSValue valueWithBytes:&val objCType:typ];} break;
  switch (typ[0]) {
    NC('c',charValue,char);
    NC('C',unsignedCharValue,unsigned char);
    NC('i',intValue,int);
    NC('I',unsignedIntValue,unsigned int);
    NC('s',shortValue,short);
    NC('S',unsignedShortValue,unsigned short);
    NC('l',longValue,long);
    NC('L',unsignedLongValue,unsigned long);
    NC('q',longLongValue,long long);
    NC('Q',unsignedLongLongValue,unsigned long long);
    NC('f',floatValue,float);
    NC('d',doubleValue,double);
    default: NSAssert1(0,@"JGNumberArray error: value not a number. Unmatched char %c",typ[0]); return nil;
  }
}

+ (unsigned int)sizeForObjCType:(const char *)typ;
{
  unsigned int datasize,align;
  const char *next=NSGetSizeAndAlignment(typ, &datasize, &align);
  NSParameterAssert(*next==NULL);
  return datasize; // +align;
}
+ (unsigned int)sizeForElementType:(NSString *)typ;
{
  return [self sizeForObjCType:[typ cString]];
}
+ (unsigned int)sizeForPrototype:(id)prototype;
{
  if ([prototype isKindOfClass:[NSString class]]) {
    prototype=[JGValueArray numberWithElementType:prototype];
  } 
  if ([prototype isKindOfClass:[NSValue class]])
    return [self sizeForObjCType:[prototype objCType]];
  else if ([prototype isKindOfClass:NumberClass])
    return sizeof(double);
  else 
    NSAssert1(0,@"JGValueArray erro: wrong prototype %@",[prototype description]);
  return 0; // error
}

+ (id)arrayWithData:(NSData *)newData prototype:(id)prototype;
{
  unsigned int asize=[JGValueArray sizeForPrototype:prototype];
  return [[[self alloc] initWithData:newData dataOffset:0 count:[newData length]/asize prototype:prototype] autorelease];
}
+ (id)arrayWithArray:(NSArray *)array prototype:(id)prototype;
{
  JGMutableValueArray *a=[JGMutableValueArray arrayWithArray:array prototype:prototype]; // released (except for the mutabledata)
  return [JGValueArray arrayWithData:[a mutableData] prototype:prototype];
}

#define VALLOCATION (dataOffset+size*idx)
#define VALPOINTER ([data bytes]+VALLOCATION)

- (id)initWithData:(NSData *)newData dataOffset:(unsigned int)offset count:(unsigned int)newCount objCType:(const char *)newObjCType returnType:(int)newReturnType; 
{
#include "JGValueArray_init.m"
}
- (id)initWithData:(NSData *)newData dataOffset:(unsigned int)offset count:(unsigned int)newCount prototype:(id)prototype;
{
#include "JGValueArray_initPrototype.m"
  return [self initWithData:newData dataOffset:offset count:newCount objCType:newObjCType returnType:newReturnType]; 
}

#include "JGValueArray_access.m"
- (NSData *)data;
{
  return data;
}

@end

@implementation JGMutableValueArray

// all available elements
+ (id)arrayWithMutableData:(NSMutableData *)newData prototype:(id)prototype;
{
  unsigned int asize=[JGValueArray sizeForPrototype:prototype];
  return [[[self alloc] initWithMutableData:newData dataOffset:0 count:[newData length]/asize prototype:prototype] autorelease];
}

// zero elements
+ (id)arrayWithCapacity:(unsigned int)capacity prototype:(id)prototype;
{
  unsigned int asize=[JGValueArray sizeForPrototype:prototype];
  NSMutableData *d=[NSMutableData dataWithCapacity:capacity*asize];
  return [[[self alloc] initWithMutableData:d dataOffset:0 count:0 prototype:prototype] autorelease];
}

// length elements initialized to prototype.
+ (id)arrayWithLength:(unsigned int)length prototype:(id)prototype;
{
  if ([prototype isKindOfClass:[NSString class]]) {
    prototype=[JGValueArray numberWithElementType:prototype];
  } 
 {
  id ret;
  unsigned int asize=[JGValueArray sizeForPrototype:prototype];
  NSMutableData *d=[NSMutableData dataWithLength:length*asize];
  ret=[[[self alloc] initWithMutableData:d dataOffset:0 count:length prototype:prototype] autorelease];
  [ret setAllValues:prototype];
  return ret; 
 }
}

+ (id)arrayWithArray:(NSArray *)array prototype:(id)prototype;
{
  id ret;
  unsigned int length=[array count];
  unsigned int asize=[JGValueArray sizeForPrototype:prototype];
  NSMutableData *d=[NSMutableData dataWithLength:length*asize];
  ret=[[[self alloc] initWithMutableData:d dataOffset:0 count:length prototype:prototype] autorelease];
  [ret setValuesWithArray:array];
  return ret;
}

//#define VALLOCATION (dataOffset+size*idx)
#undef VALPOINTER
#define VALPOINTER ([data mutableBytes]+VALLOCATION)
- (id)initWithMutableData:(NSMutableData *)newData dataOffset:(unsigned int)offset count:(unsigned int)newCount objCType:(const char *)newObjCType returnType:(int)newReturnType; 
{
//NSLog(@"offset: %d count:%d type: %s return: %d",offset, newCount, newObjCType, newReturnType);
#include "JGValueArray_init.m"
}

- (id)initWithMutableData:(NSMutableData *)newData dataOffset:(unsigned int)offset count:(unsigned int)newCount prototype:(id)prototype;
{
#include "JGValueArray_initPrototype.m"
  return [self initWithMutableData:newData dataOffset:offset count:newCount objCType:newObjCType returnType:newReturnType]; 
}

#include "JGValueArray_access.m"

- (NSMutableData *)mutableData;
{
  return data;
}

#define CASTCONDITION ([value isKindOfClass:NumberClass] || [value isKindOfClass:[NSValue class]])
#define NONCASTCONDITION (((returnType==2) && [value isKindOfClass:NumberClass]) || ([value isKindOfClass:[NSValue class]] && !strcmp([value objCType],objCType)))
#define VALUECONDITION (castValue ? CASTCONDITION : NONCASTCONDITION)
#define CASTEDCONDITION (castValue ? ((value=[JGValueArray valueWithObjCType:objCType forValue:value]) ? YES:NO) : NONCASTCONDITION)
 
#define VALUEASSERTION NSParameterAssert(CASTEDCONDITION)
//  if (returnType==2) NSParameterAssert([value isKindOfClass:NumberClass]) \
//    else NSParameterAssert([value isKindOfClass:[NSValue class]] && !strcmp([value objCType],objCType))
     
#define SETVALUE(pointr) if (!castValue && (returnType==2)) *(double *)(pointr)=[value doubleValue]; else [value getValue:(pointr)];

// convenience
- (void)setAllValues:(id)value;
{
  int idx;
  VALUEASSERTION;
  if (!castValue && (returnType==2)) {
    double d=[value doubleValue];
    for (idx=0;idx<count; idx++)
      *(double *)VALPOINTER=d;
  } else {
    NSParameterAssert([value isKindOfClass:[NSValue class]]);
    NSParameterAssert(!strcmp([value objCType],objCType));
    for (idx=0;idx<count; idx++)
      [value getValue:VALPOINTER];
  }
}
- (void)setValuesWithArray:(NSArray *)array;
{
  int i,c;
  c=[array count];
  if (c>count)
    c=count;
  for (i=0;i<c;i++)
    [self replaceObjectAtIndex:i withObject:[array objectAtIndex:i]];
}

// helper Methods
- (void)increaseLengthForNewValue;
{
  int extra=[data length]-dataOffset+(count+1)*size;
  if (extra>0)
    [data increaseLengthBy:extra];
}

///// NSMutableArray primitives
- (void)addObject:(id)value;
{
  unsigned int idx=count+1;
  void *dest;
  VALUEASSERTION;
  [self increaseLengthForNewValue];
  dest=VALPOINTER;
  SETVALUE(dest);
  count++;
}
- (void)insertObject:(id)value atIndex:(unsigned)idx;
{
  void *dst,*src;
  VALUEASSERTION;
  NSParameterAssert(idx<=count);
  [self increaseLengthForNewValue];
  src=VALPOINTER;
  if (idx!=count) {
    idx++;
    dst=VALPOINTER;
    memmove(dst, src, size);
  }
  SETVALUE(src);
  count++;
}
- (void)removeLastObject;
{ 
  NSParameterAssert(count>0);
  count--;
}
- (void)removeObjectAtIndex:(unsigned)idx;
{
  NSParameterAssert(idx<count);
  if (idx!=count-1) { // not last object
    void *dst,*src;
    dst=VALPOINTER;
    idx++;
    src=VALPOINTER;
    memmove(dst, src, size);
  }
  count--;
}
- (void)replaceObjectAtIndex:(unsigned)idx withObject:(id)value;
{
  void *dest;
  VALUEASSERTION;
  dest=VALPOINTER;
  SETVALUE(dest);
//  if ([value respondsToSelector:@selector(intValue)])
//    NSLog(@"replaceObjectAtIndex value:%d in c:%d",[value intValue],*(int *)dest);
}
@end

@implementation JGMutableValueArray (FSKVCoding)
- (BOOL)fskvAllowsToTakeValue:(id)value forKey:(NSString *)key; // disallow nil values
{
    if (!VALUECONDITION)
      return NO;
    else return [self fskvIsValidKey:key];
}
@end

@implementation JGValueArray (Testing)
struct oddstruct {
  char a,b,c;
};

+ (NSValue *)testValue;
{
  struct oddstruct str;
  str.a='a';
  str.b='b';
  str.c='c';
  return [NSValue valueWithBytes:&str objCType:@encode(struct oddstruct)];
}
+ (void)test;
{ 
  struct oddstruct strout;
  id arr,inst;
  arr=[JGMutableValueArray arrayWithCapacity:3 prototype:[self testValue]];
  [arr setAllValues:[self testValue]];
  inst=[arr objectAtIndex:1];
  [inst getValue:&strout];
  if (strout.b!='b') 
    NSLog(@"strout.b!=b");
}
+ (NSArray *)testarrays;
{
  id a,b,c;
  a=[JGMutableValueArray arrayWithLength:3 prototype:[NSNumber numberWithFloat:2.0]];
  b=[JGValueArray arrayWithData:[a mutableData] prototype:[NSNumber numberWithFloat:2.0]];
  c=[JGMutableValueArray arrayWithMutableData:[a mutableData] prototype:[NSNumber numberWithInt:2]];
  return [NSArray arrayWithObjects:a,b,c,nil];
}
+ (void)testGetValue;
{
  NSNumber *n=[NSNumber numberWithInt:80000];
  int i;
  char c[20];
  [n getValue:&i];
  [n getValue:c];
  NSLog(@"i: %d c:%d",i,*(int *)c);
}
@end

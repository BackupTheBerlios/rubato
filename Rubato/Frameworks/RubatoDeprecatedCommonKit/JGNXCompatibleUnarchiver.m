//
//  JGNXCompatibleUnarchiver.m
//  RubatoFrameworks
//
//  Created by jg on Thu Oct 18 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import "JGNXCompatibleUnarchiver.h"
#define REPLACE(aDecoder,old,new) \
    if (doReplaceFlag && [aDecoder respondsToSelector:@selector(replaceObject:withObject:)]) \
      [(NSArchiver *)aDecoder replaceObject:old withObject:new];

#define SELFRELEASE ;
// #define SELFRELEASE [self release]

@implementation ListReader
/* original code from: http://web.mit.edu/afs/dev.mit.edu/user/cfields/apple/objc/unichar.h
- read:(NXTypedStream *) stream
{
    NXZone *zone = [self zone];
    [super read: stream];
    if (NXTypedStreamClassVersion (stream, "List") == 0) {
        int             _growAmount = 0;
        NXReadTypes (stream, "ii", &_growAmount, &numElements);
        dataPtr = (id *) NXZoneMalloc (zone, numElements*sizeof(id));
        maxElements = numElements;
        NXReadArray (stream, "@", numElements, dataPtr);
    } else {
        NXReadTypes (stream, "i", &numElements);
        maxElements = numElements;
        if (numElements) {
            dataPtr = (id *) NXZoneMalloc (zone, numElements*sizeof(id));
            NXReadArray (stream, "@", numElements, dataPtr);
        }
    }
    return self;
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder;
{
  static BOOL doReplaceFlag=NO;
  NSMutableArray *arr;
  NSZone *zone=[self zone];
    if ([aDecoder versionForClassName:@"List"] == 0) {
        int             _growAmount = 0;
        [aDecoder decodeValuesOfObjCTypes:"ii", &_growAmount, &numElements];
        dataPtr = (id *) NSZoneMalloc (zone, numElements*sizeof(id));
        maxElements = numElements;
        [aDecoder decodeArrayOfObjCType:"@" count:numElements at:dataPtr];
    } else {
        [aDecoder decodeValuesOfObjCTypes:"i", &numElements];
        maxElements = numElements;
        if (numElements) {
            dataPtr = (id *) NSZoneMalloc (zone, numElements*sizeof(id));
            [aDecoder decodeArrayOfObjCType:"@" count:numElements at:dataPtr];
        }
    }
  arr=[[NSMutableArray alloc] initWithObjects:dataPtr count:numElements];
  REPLACE(aDecoder,self,arr)
  SELFRELEASE; 
  return arr;
}
- (void)dealloc;
{
  // must release all Objects in dataPtr?
  free(dataPtr);
  [super dealloc];
}
@end

@implementation HashTableReader
- (id)objectFromDecoder:(NSCoder *)aDecoder objCType:(const char *)type;
{
  void *value;
  [aDecoder decodeValuesOfObjCTypes:type,&value];
  switch (type[0]) {
    case '@':return (id)value;
    case '*' :
    case '%' :return [NSString stringWithCString:value]; // % is a Unique String (NXAtom)
    default :return [NSValue value:value withObjCType:type];
  }
}
- (id)initWithCoder:(NSCoder *)aDecoder; // also used by NXStringTable
{
  static BOOL doReplaceFlag=NO;
  NSMutableDictionary *dict;
    const char  *keyDesc;       /* Description of keys */
    const char  *valueDesc;     /* Description of values */
    unsigned    nb; /* we set count as 0 but read nb elements */
    if ([aDecoder versionForClassName:@"HashTable"] == 0) {
        [aDecoder decodeValuesOfObjCTypes:"i**", &nb, &keyDesc, &valueDesc];
    } else {
        //[super read: stream];
        [aDecoder decodeValuesOfObjCTypes: "i%%", &nb, &keyDesc, &valueDesc];
    }
    if (! keyDesc) exit (1);
    if (! valueDesc) exit (2);
    dict=[[NSMutableDictionary alloc] init];
    while (nb--) {
        id key;
        id value;
        key=[self objectFromDecoder:aDecoder objCType:keyDesc];
        value=[self objectFromDecoder:aDecoder objCType:valueDesc];
        [dict setObject: value forKey:key];
        };
  REPLACE(aDecoder,self,dict)
  SELFRELEASE; 
  return dict;
}
@end


@implementation JGNXCompatibleUnarchiver
-(id)initForReadingWithData:(NSData *)theData;
{
  [super initForReadingWithData:theData];
  [self decodeClassName:@"Object" asClassName:@"NSObject"];
  [self decodeClassName:@"List" asClassName:@"ListReader"];
  [self decodeClassName:@"HashTable" asClassName:@"HashTableReader"];
  [self decodeClassName:@"NXStringTable" asClassName:@"HashTableReader"];
  [self decodeClassName:@"String" asClassName:@"StringConverter"];
  [self decodeClassName:@"RefCountList" asClassName:@"ListReader"];
  [self decodeClassName:@"RefCountObjectList" asClassName:@"ListReader"];
  [self decodeClassName:@"RefCountObject" asClassName:@"JgRefCountObject"];
  return self;
}
@end


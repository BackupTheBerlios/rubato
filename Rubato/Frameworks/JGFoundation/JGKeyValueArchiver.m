/* JGKeyValueArchiver.m created by jg on Thu 17-Aug-2000 */

#import "JGKeyValueArchiver.h"
#import "JGClassDescription.h"
#import "JGKeyValueCoding.h"

@protocol EntityName
- (NSString *)entityName;
@end

@implementation JGKeyValueArchiver
- (id)init;
{
  [super init];
  getAttributesAsString=YES;
  useEntityNameForClass=YES;
  return self;
}

- (BOOL) getAttributesAsString
{
	return getAttributesAsString;
}

- (void) setGetAttributesAsString:(BOOL)newGetAttributesAsString
{
	getAttributesAsString = newGetAttributesAsString;
}

- (BOOL) useEntityNameForClass
{
	return useEntityNameForClass;
}

- (void) setUseEntityNameForClass:(BOOL)newUseEntityNameForClass
{
	useEntityNameForClass = newUseEntityNameForClass;
}
- (BOOL) separateKeys
{
	return separateKeys;
}

- (void) setSeparateKeys:(BOOL)newSeparateKeys
{
	separateKeys = newSeparateKeys;
}

// overridden methods
- (id)valueForAttribute:(id)att;
  /*" returns [att description] if attributesAsString==YES otherwise [att copy]"*/
{
  if (getAttributesAsString)
    return [att description];
  else
    return [att copy];
}

- (id)classInfoForObject:(id)obj;
{
  if (useEntityNameForClass) {
    id name=[obj entityName];
    if (name) return name;
  } 
  return [super classInfoForObject:obj];
}

- (void)addToDictionary:(NSMutableDictionary *)dictionary representationForObject:(id)obj;
{
  NSArray *keys;
  NSString *key;
  NSEnumerator *e;
  NSString *className;
  BOOL reallyCreateAndSeperate;
  NSMutableDictionary *dict=dictionary;

  if (reallyCreateRepresentation) {
    // Class Name
    className=[self classInfoForObject:obj];
    if (className)
      [dictionary setObject:className forKey:[self classKey]];

    if (separateKeys) {
      dict=[NSMutableDictionary dictionary];
      reallyCreateAndSeperate=YES;
    } else {
      reallyCreateAndSeperate=NO;
    }
    
    // Attributes
    keys=[obj attributeKeys];
    e=[keys objectEnumerator];
    while (key=[e nextObject]) {
      id val=[obj valueForKey:key];
      [dict setObject:[self valueForAttribute:val] forKey:key];
    }
    if (reallyCreateAndSeperate) {
      [dictionary setObject:dict forKey:@"attributes"];
      dict=[NSMutableDictionary dictionary];
    }
  } else
    reallyCreateAndSeperate=NO;
  
  // to one Relations
  keys=[obj toOneRelationshipKeys];
  e=[keys objectEnumerator];
  while (key=[e nextObject]) {
    id obj2=[obj valueForKey:key];
    id reference=[self representationForObject:obj2];
    if (reallyCreateRepresentation)
      [dict setObject:reference forKey:key];
  }
  if (reallyCreateAndSeperate) {
    [dictionary setObject:dict forKey:@"toOneRelationships"];
    dict=[NSMutableDictionary dictionary];
  }
  // to many Relations
  keys=[obj toManyRelationshipKeys];
  e=[keys objectEnumerator];
  while (key=[e nextObject]) {
    NSArray *inArray=[obj valueForKey:key];
    NSEnumerator *e2=[inArray objectEnumerator];
    id obj2;
    if (reallyCreateRepresentation) {
      NSMutableArray *outArray;
      outArray=[NSMutableArray array];
      while (obj2=[e2 nextObject]) {
        id reference=[self representationForObject:obj2];
        if (reallyCreateRepresentation)
          [outArray addObject:reference];
      }
      [dict setObject:outArray forKey:key];
    } else {
      while (obj2=[e2 nextObject]) {
        [self representationForObject:obj2];
      }
    }
  }
  if (reallyCreateAndSeperate) {
    [dictionary setObject:dict forKey:@"toManyRelationships"];
  }
}

@end

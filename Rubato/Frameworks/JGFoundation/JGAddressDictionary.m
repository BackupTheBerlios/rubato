/* JGAddressDictionary.m created by jg on Wed 23-Jun-1999 */
#import "JGAddressDictionary.h"

NSString *unique=@"unique";
NSString *plagiat=@"plagiat";

@implementation UniqueNessDictionary

- (id)init;
{
  dict=[NSMutableDictionary new];
  return self;
}

- (void)insertKey:(id) key;
{
  id previous=[dict objectForKey:key];
  if (!previous) [dict setObject:unique forKey:key];
  else if(previous==unique) [dict setObject:plagiat forKey:key];
}
- (BOOL)isUnique:(id) key;
{
  if (plagiat==[dict objectForKey:key]) return NO;
  else return YES;
}

@end


@implementation JGAddressDictionary
- (id)init;
{
  [super init];
  addresses=[[NSMutableDictionary alloc] init];
  counter=0;
  names=[[UniqueNessDictionary alloc] init];
  return self;
}

- (void)dealloc;
{
  [addresses release];
  [names release];
  [super dealloc];
}

- objectForKey:key;
{ id x=[addresses objectForKey:key];
  return x;
}


- (void)getKey:(NSNumber **)key andValue:(JGAddressDictionaryValue **)val forAddress:(void *)address;
{
  *key=[NSNumber numberWithLong:(long)address];
  *val=[self objectForKey:*key];
}

- (BOOL)containsAddress:(void *)address;
{
  NSNumber *key;
  JGAddressDictionaryValue *val;
  [self getKey:&key andValue:&val forAddress:address];
  if (val) return YES;
  else return NO;
}

- (void)setInfoForAddress:address;
{
  [self getKey:&(info.key) andValue:&(info.val) forAddress:address];
  if (info.val) info.name=[info.val getName];
  else info.name=nil;
  if (info.name) info.unique=[names isUnique:info.name];
}
  
- (void)insertAddress:(void *)address withName:(NSString *)aName;
{
  JGAddressDictionaryValue *val;
  NSNumber *key;
  [self getKey:&key andValue:&val forAddress:address];
  if (val) return;
  val=[JGAddressDictionaryValue addressDictionaryValueWithNumber:(long)counter++ andName:aName];
  [addresses setObject:val forKey:key];
  if (aName) [names insertKey:aName]; // register name
}  


  
- (NSString *)getNumberStringForAddress:(void *)address;
{
  JGAddressDictionaryValue *val;
  NSNumber *key;
  [self getKey:&key andValue:&val forAddress:address];
  if (val) return [val getNumberString];
  else return nil;
}

- (NSMutableString *)getNameForAddress:(void *)address;
{
  JGAddressDictionaryValue *val;
  NSNumber *key;
  [self getKey:&key andValue:&val forAddress:address];
  if (val) return [val getName];
  else return nil;
}

- (NSString *)getUniqueNameForAddress:(void *)address;
{ 
  [self setInfoForAddress:address];
  if (info.name && info.unique) return info.name;
  else return [info.val getNumberString];
}

@end

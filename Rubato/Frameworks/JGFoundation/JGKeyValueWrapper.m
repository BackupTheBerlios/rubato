#import "JGKeyValueWrapper.h"
#import "JGKeyValueCoding.h"
#import <Foundation/Foundation.h>

@implementation JGProxyPool
- init;
{
  [super init];
  pointerDictionary=[[NSMutableDictionary alloc] init];
  lastObjectForPointer=nil;
  return self;
}
- (void)dealloc;
{
  [pointerDictionary release];
  [super dealloc];
}
- (id)objectForPointer:(void *)pointer;
{
  lastObjectForPointer=[pointerDictionary objectForKey:[NSValue valueWithPointer:pointer]];
  return lastObjectForPointer;
}
- (id)lastObjectForPointer; // caches the last result from objectForPointer: (for occur checks)
{
  return lastObjectForPointer;
}
- (void)setObject:(id)obj forPointer:(void *)pointer;
{
  [pointerDictionary setObject:obj forKey:[NSValue valueWithPointer:pointer]];
}
- (NSString *)delegateKeyPathForWrapperKey:(NSString *)key; // filter maps wrappers key to delegates keypath.
{
  return key;
}
- (BOOL)wrapperKeyForDelegateKeyIsTrivial;
{
  return YES;
}
// overriding allows to filter classDescription of delegate
- (NSString *)wrapperKeyForDelegateKey:(NSString *)key;
{
  return key;
}
- (NSArray *)wrapperKeysForDelegateKeys:(NSArray *)keys;
{
  if ([self wrapperKeyForDelegateKeyIsTrivial])
    return keys;
  else {
    NSMutableArray *ret=[NSMutableArray array];
    NSEnumerator *e=[keys objectEnumerator];
    NSString *delegateKey;
    while (delegateKey=[e nextObject]) {
      [ret addObject:[self wrapperKeyForDelegateKey:delegateKey]];
    }
    return ret;
  }
}
@end


@implementation JGKeyValueWrapper
- initWithObject:(id)obj proxyPool:(JGProxyPool *)p;
{
  proxyPool=p;
  delegate=[obj retain];
  [proxyPool setObject:self forPointer:(void *)obj];
  return self;
}
- (void)dealloc;
{
  [delegate release];
  [super dealloc];
}
// how to get value for Key in delegate domain.
- (id)delegate:(id)delegateObj valueForKey:(NSString *)key;
{
  return [delegateObj valueForKey:key];
}
- (id)delegateValueForWrapperKey:(NSString *)wrapperKey;
{
  NSString *keyPath=[proxyPool delegateKeyPathForWrapperKey:wrapperKey];
  NSArray *paths=[keyPath componentsSeparatedByString:@"."];
  NSEnumerator *e=[paths objectEnumerator];
  NSString *key;
  id obj=delegate;
  while (obj && (key=[e nextObject])) {
    obj=[self delegate:obj valueForKey:key];
  }
  return obj;
}

- (id)valueForKey:(NSString *)key;
{
  id obj=[self delegateValueForWrapperKey:key];
  id proxy=[proxyPool objectForPointer:obj];
  if (!proxy)
    if ([obj isKindOfClass:[NSString class]]) {
      proxy=obj; // dont proxy attributes
    } else if ([obj isKindOfClass:[NSArray class]]) {
      proxy=[self arrayProxyForArray:obj];
    } else
      proxy=[[[[self class] alloc] initWithObject:obj proxyPool:proxyPool] autorelease];
  return proxy;
}
- (NSMutableArray *)arrayProxyForArray:(NSArray *)array;
{
  NSMutableArray *proxyArray=[NSMutableArray array];
  NSEnumerator *e=[array objectEnumerator];
  id obj;
  while (obj=[e nextObject]) {
    id proxy;
    proxy=[[[self class] alloc] initWithObject:obj proxyPool:proxyPool];
    [proxyArray addObject:proxy];
    [proxy release];
  }
  return proxyArray;
}
@end

@implementation JGMutableKeyValueWrapper 
- (void)takeValue:(id)value forKey:(NSString *)key;
{
  [delegate takeValue:value forKeyPath:[proxyPool delegateKeyPathForWrapperKey:key]];
}
@end

@implementation JGDictionaryKeyValueWrapper : JGKeyValueWrapper
- initWithObject:(id)obj proxyPool:(JGProxyPool *)p;
{
  NSAssert2([obj isKindOfClass:[NSDictionary class]],@"Object %d of class %@ not of expected type NSDictionary.",(int)obj,NSStringFromClass([obj class]));
  [super initWithObject:obj proxyPool:p];
  attributeKeys=nil;
  toOneRelationshipKeys=nil;
  toManyRelationshipKeys=nil;
  return self;
}
- (void)dealloc;
{
  [attributeKeys release];
  [toOneRelationshipKeys release];
  [toManyRelationshipKeys release];
}  
// all string-values
- (void)newKeys;
{
  [attributeKeys release];
  [toOneRelationshipKeys release];
  [toManyRelationshipKeys release];
  attributeKeys=[[NSMutableDictionary alloc] init];
  toOneRelationshipKeys=[[NSMutableDictionary alloc] init];
  toManyRelationshipKeys=[[NSMutableDictionary alloc] init];
}

- (NSArray *)wrapperKeys;
{
    return [proxyPool wrapperKeysForDelegateKeys:[delegate allKeys]];
}

- (void)scanKeys;
{
  NSEnumerator *e=[[self wrapperKeys] objectEnumerator];
  NSString *key;
  [self newKeys];
  while (key=[e nextObject]) {
    id val=[self delegateValueForWrapperKey:key];
    if ([val isKindOfClass:[NSString class]])
      [attributeKeys addObject:key];
    else if ([val isKindOfClass:[NSDictionary class]])
      [toOneRelationshipKeys addObject:key];
    else if ([val isKindOfClass:[NSArray class]])
      [toManyRelationshipKeys addObject:key];
    else
      NSAssert3(NO,@"Key %@ of Object %d of class %@ not of expected type.",key,(int)val,NSStringFromClass([val class]));
  }
}
// all string-values
- (NSArray *)attributeKeys;
{
  if (!attributeKeys)
    [self scanKeys];
  return attributeKeys;
}
// all dict-values
- (NSArray *)toOneRelationshipKeys;
{
  if (!toOneRelationshipKeys)
    [self scanKeys];
  return toOneRelationshipKeys;
}
// all array-values
- (NSArray *)toManyRelationshipKeys;
{
  if (!toManyRelationshipKeys)
    [self scanKeys];
  return toManyRelationshipKeys;
}

// how to get value for Key in delegate domain.
- (id)delegate:(id)delegateObj valueForKey:(NSString *)key;
{
  return [delegateObj objectForKey:key];
}

@end

#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>

// real-Ids as keys, Wrapper-Objects as values
@interface JGProxyPool : NSObject  // something like an EOEditingContext
{
  NSMutableDictionary *pointerDictionary;
  id lastObjectForPointer; // non retained, not autoreleased
}
- (id)objectForPointer:(void *)pointer;
- (id)lastObjectForPointer; // caches the last result from objectForPointer: (for occur checks)
- (void)setObject:(id)obj forPointer:(void *)pointer; // retains obj
- (NSString *)delegateKeyPathForWrapperKey:(NSString *)key; // filter maps wrappers key to delegates keypath.
- (BOOL)wrapperKeyForDelegateKeyIsTrivial;
- (NSString *)wrapperKeyForDelegateKey:(NSString *)key;
- (NSArray *)wrapperKeysForDelegateKeys:(NSArray *)keys;
@end

// JGKeyValueWrapper is an Object, that wraps another object (delegate) and implements valueForKey on behalf of the delegate.
// JGKeyValueWrapper interface can also be reformulated like EOEditingContext and EOObjectStoreCoordinator would:
// only JGProxyPool has a means of delegate for this object
// proxyPool can be looked up like [EOObjectStoreCoordinator proxyPoolForId:self];
@interface JGKeyValueWrapper : NSObject
{
  JGProxyPool *proxyPool; // not retained (Wrappers belong to Pool, not otherwise round)
  id delegate;
}
- initWithObject:(id)obj proxyPool:(JGProxyPool *)p;
- (void)dealloc;
- (id)delegate:(id)delegateObj valueForKey:(NSString *)key; // how to get value for Key in delegate domain.
- (id)delegateValueForWrapperKey:(NSString *)key; // uses proxyPool delegateKeyPathForWrapperKey and above
- (id)valueForKey:(NSString *)key;
/*"Foreach element calls [[[self class] alloc] initWithObject:obj proxyPool:proxyPool]] "*/
- (NSMutableArray *)arrayProxyForArray:(NSArray *)array;
@end

@interface JGMutableKeyValueWrapper : JGKeyValueWrapper
{
}
- (void)takeValue:(id)value forKey:(NSString *)key;
@end


// JGDictionaryKeyValueWrapper wraps delegates of the following form:
// delegate must be a dictionary with strings as keys and the following values:
// strings (attributes)
// dictionaries (toOneRels)
// arrays of delegates (toManyRels)
@interface JGDictionaryKeyValueWrapper : JGKeyValueWrapper
{
    NSMutableArray *attributeKeys;
    NSMutableArray *toOneRelationshipKeys;
    NSMutableArray *toManyRelationshipKeys;
}
- initWithObject:(id)obj proxyPool:(JGProxyPool *)p;
- (void)dealloc;

- (void)newKeys;
- (void)scanKeys;

- (NSArray *)wrapperKeys;
  //[proxyPool wrapperKeysForDelegateKeys:[delegate allKeys]]

// all string-values
- (NSArray *)attributeKeys;
// all dict-values
- (NSArray *)toOneRelationshipKeys;
// all array-values
- (NSArray *)toManyRelationshipKeys;

@end
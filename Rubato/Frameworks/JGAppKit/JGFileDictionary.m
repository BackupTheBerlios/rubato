//
//  JGFileDictionary.m
//  FileWrapperDoc
//
//  Created by Joerg Garbers on Tue Mar 26 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "JGFileDictionary.h"


#define	setAccessor( type, var, setVar ) \
-(void)setVar:(type)newVar { \
    if ( newVar!=var) {  \
        if ( newVar!=(id)self ) \
            [newVar retain]; \
        if ( var && var!=(id)self) \
            [var release]; \
        var = newVar; \
	} \
} \

@implementation JGFileDictionaryKeyMapper : NSObject
- (id)init;
{
  [super init];
  fileSuffix=[@"" retain];
  ignoredFilePrefix=[@"." retain];
  return self;
}
-(void)dealloc;
{ 
  [fileSuffix release];
  [ignoredFilePrefix release];
  [super dealloc];
}
setAccessor(NSString *,fileSuffix,setFileSuffix)
setAccessor(NSString *,ignoredFilePrefix,setIgnoredFilePrefix)

- (NSString *)objectKeyForFileKey:(NSString *)fileKey;
{
  if ([fileKey hasPrefix:ignoredFilePrefix] || (([fileSuffix length]>0) && ![fileKey hasSuffix:fileSuffix]))
    return nil;
  else // @"" is also o.k., but hasSuffix returns NO.
    return [fileKey substringToIndex:[fileKey length]-[fileSuffix length]]; // index is not included
}
- (NSString *)fileKeyForObjectKey:(NSString *)objectKey;
{
  return [objectKey stringByAppendingString:fileSuffix];
}
@end

@implementation JGFileDictionary 
// By default, we pass every primitive method to "objectDictionary", instead of objectForKey,
// which resolves objects lazily.
- (unsigned)count;
{
  return [objectDictionary count];
}
- (NSEnumerator *)keyEnumerator;
{
  return [objectDictionary keyEnumerator];
}
- (void)removeObjectForKey:(id)aKey;
{
  [objectDictionary removeObjectForKey:aKey];
}

// from here custom behaviour.
+ (id)toBeDecoded;
/*" special value that means: object for key is not resolved yet. "*/
{
  static id val=nil;
  if (!val)
    val=[@"toBeDecoded" copy];
  return val;
}

- (id)init;
/*" Designated Initializer "*/
{
  [super init];
  objectDictionary=[[NSMutableDictionary alloc] init];
  dirtyKeys=nil;//[[NSMutableSet alloc] init];
  directoryWrapper=[[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];
  fileWrapperCoder=nil;
  keyMapper=[[JGFileDictionaryKeyMapper alloc] init];
  archiver=[NSArchiver retain];
  unarchiver=[NSUnarchiver retain];
  return self;
}

setAccessor(NSMutableDictionary *,objectDictionary,setObjectDictionary)
setAccessor(id,fileWrapperCoder,setFileWrapperCoder)
setAccessor(id,keyMapper,setKeyMapper)
setAccessor(NSFileWrapper *,directoryWrapper,setDirectoryWrapper)
setAccessor(id,archiver,setArchiver)
setAccessor(id,unarchiver,setUnarchiver)

- (id)initWithDirectoryWrapper:(NSFileWrapper *)fileWrapper fileWrapperCoder:(id)coder keyMapper:(id)newKeyMapper;
{ 
  [self init];
  [self setFileWrapperCoder:coder];
  [self setDirectoryWrapperAndSync:fileWrapper];
  [self setKeyMapper:newKeyMapper];
  return self;
}

- (void)dealloc;
{
  [archiver release];
  [unarchiver release];
  [dirtyKeys release];
  [objectDictionary release];
  [directoryWrapper release];
  [fileWrapperCoder release];
  [keyMapper release];
  [super dealloc];
}

- (void)setObject:(id)anObject forKey:(id)aKey;
{
  [objectDictionary setObject:anObject forKey:aKey];
  [dirtyKeys addObject:aKey];
}

- (id)objectForKey:(id)aKey;
{
  id obj=[objectDictionary objectForKey:aKey];
  if (directoryWrapper && (obj==[JGFileDictionary toBeDecoded])) {
    NSString *fileKey=[keyMapper fileKeyForObjectKey:aKey];
    NSDictionary *d=[directoryWrapper fileWrappers];
    NSFileWrapper *w=[d objectForKey:fileKey];
    id decoder=fileWrapperCoder ? fileWrapperCoder : self;
    if (!w) {
      NSLog(@"fileWrapper with key %@ not contained in dictionary", fileKey);
      return nil;
    }
    obj=[decoder fileDictionary:self objectForFileWrapper:w];
    if (!obj) {
      NSLog(@"fileWrapperCoder %@ could not decode file wrapper %@", decoder, w);
      return nil;
    }
    [objectDictionary setObject:obj forKey:aKey]; // cache it.
  }
  return obj;
}

- (NSFileWrapper *)updatedDirectoryWrapper;
/*" Update the directory wrapper with the values from objectDictionary and return it on success "*/
{
    NSDictionary *fileWrappers=[directoryWrapper fileWrappers];
    NSEnumerator *e=[objectDictionary keyEnumerator];
    NSString *objectKey,*fileKey;
    id encoder=fileWrapperCoder ? fileWrapperCoder : self;
    while (objectKey=[e nextObject]) {
      if (!dirtyKeys || [dirtyKeys containsObject:objectKey]) { // optimization
        id obj=[objectDictionary objectForKey:objectKey];
        if (obj!=[JGFileDictionary toBeDecoded]) { // leave old fileWrapper
            NSFileWrapper *oldFileWrapper,*newFileWrapper;
            fileKey=[keyMapper fileKeyForObjectKey:objectKey];
            oldFileWrapper=[fileWrappers objectForKey:fileKey];
            newFileWrapper=[encoder fileDictionary:self fileWrapperForObject:obj fileKey:fileKey];
            if (!oldFileWrapper) {
              // NSLog(@"fileWrapper with key %@ not contained in dictionary", fileKey);
            } else {
              [directoryWrapper removeFileWrapper:oldFileWrapper];
            }
            if (!newFileWrapper) {
              NSLog(@"fileWrapperCoder %@ could not encode object %@", encoder, obj);
              return nil;
            } else {
              [directoryWrapper addFileWrapper:newFileWrapper];
            }
        } // if not refaulted 
        [dirtyKeys removeObject:objectKey];
      } // if dirty
    } // while object-key
    
    // remove wrappers, that are not in the objectDictionary
    // but only if there is a mapping. This allows us to keep CVS and other .hidden stuff around
    e=[fileWrappers keyEnumerator];
    while (fileKey=[e nextObject]) {
      objectKey=[keyMapper objectKeyForFileKey:fileKey];
      if (objectKey && ![objectDictionary objectForKey:objectKey])
        [directoryWrapper removeFileWrapper:[fileWrappers objectForKey:fileKey]];
    }
    return directoryWrapper;
}

- (id)fileDictionary:(id)fileDictionary objectForFileWrapper:(NSFileWrapper *)fileWrapper;
{
  id ret=nil;
  if ([fileWrapper isDirectory]) {
    ret=[[[self class] alloc] initWithDirectoryWrapper:fileWrapper fileWrapperCoder:fileWrapperCoder keyMapper:keyMapper];
  } else if ([fileWrapper isRegularFile]) {
    NSData *data=[fileWrapper regularFileContents];
    ret=[unarchiver unarchiveObjectWithData:data];
  } else if ([fileWrapper isSymbolicLink]) {
    NSString *dest=[fileWrapper symbolicLinkDestination];
    NSFileWrapper *w=[[NSFileWrapper alloc] initWithPath:dest];
    ret=[self fileDictionary:fileDictionary objectForFileWrapper:w];
    [w release];
  } 
  return ret;
}

- (NSFileWrapper *)fileDictionary:(id)fileDictionary fileWrapperForObject:(id)obj fileKey:(NSString *)fileKey;
{
  NSFileWrapper *ret=nil;
  if ([obj isKindOfClass:[JGFileDictionary class]]) {
    ret=[obj updatedDirectoryWrapper];
  } else if (obj) {
    NSData *data=[archiver archivedDataWithRootObject:obj];
    ret=[[[NSFileWrapper alloc] initRegularFileWithContents:data] autorelease];
  }
  [ret setPreferredFilename:fileKey];
  return ret; 
}

// Synchronize methods for objectDictionary and directoryWrapper
- (void)addAbsentFaultsFromDictionaryWrapper;
{
    NSDictionary *fileWrappers=[directoryWrapper fileWrappers];
    NSEnumerator *e=[fileWrappers keyEnumerator];
    NSString *fileKey;
    while (fileKey=[e nextObject]) {
      NSString *objectKey=[keyMapper objectKeyForFileKey:fileKey];
      if (objectKey && ![objectDictionary objectForKey:objectKey])
        [objectDictionary setObject:[JGFileDictionary toBeDecoded] forKey:objectKey];
    }
}
- (void)removeFaultsFromDictionary;
{
    NSEnumerator *e=[objectDictionary keyEnumerator];
    NSString *objectKey;
    while (objectKey=[e nextObject]) {
      if ([objectDictionary objectForKey:objectKey]==[JGFileDictionary toBeDecoded]) {
        [objectDictionary removeObjectForKey:objectKey];
        [dirtyKeys removeObject:objectKey];
      }
    }
}
- (void)setDirectoryWrapperAndSync:(NSFileWrapper *)newDirectoryWrapper;
{
  if (newDirectoryWrapper!=directoryWrapper) {
    [self removeFaultsFromDictionary];
    [self setDirectoryWrapper:newDirectoryWrapper];
    [self addAbsentFaultsFromDictionaryWrapper];
  }
}

@end

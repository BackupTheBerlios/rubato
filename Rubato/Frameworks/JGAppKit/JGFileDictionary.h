//
//  JGFileDictionary.h
//  FileWrapperDoc
//
//  Created by Joerg Garbers on Tue Mar 26 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// NSDocument Methods
//- (NSFileWrapper *)fileWrapperRepresentationOfType:(NSString *)type;
//- (BOOL)loadFileWrapperRepresentation:(NSFileWrapper *)wrapper ofType:(NSString *)type;

@protocol JGFileWrapperCoder
- (id)fileDictionary:(id)fileDictionary objectForFileWrapper:(NSFileWrapper *)fileWrapper;
- (NSFileWrapper *)fileDictionary:(id)fileDictionary fileWrapperForObject:(id)obj fileKey:(NSString *)key;
@end

@protocol JGFileDictionaryKeyMapper
// nil means, there is no mapping. good for filtering only some file types.
- (NSString *)objectKeyForFileKey:(NSString *)fileKey;
- (NSString *)fileKeyForObjectKey:(NSString *)objectKey;
@end
@interface JGFileDictionaryKeyMapper : NSObject
{
  NSString *fileSuffix;
  NSString *ignoredFilePrefix;
}
- (void)setFileSuffix:(NSString *)suffix;
- (void)setIgnoredFilePrefix:(NSString *)prefix;
- (NSString *)objectKeyForFileKey:(NSString *)fileKey;
- (NSString *)fileKeyForObjectKey:(NSString *)objectKey;
@end

// if dirtyKeys!=nil, we assume, that the objects in the objectDictionary
// only change with [self setObject:forKey:]. 
// This is normally not the case!
@interface JGFileDictionary : NSMutableDictionary <JGFileWrapperCoder>
{
  NSMutableDictionary *objectDictionary;
  NSFileWrapper *directoryWrapper; // holds a directory
  NSMutableSet *dirtyKeys; // default: nil
  id fileWrapperCoder; // uses self if absent.
  id keyMapper;
  id archiver,unarchiver;
}
// NSMutableDictionary primary methods
- (unsigned)count;
- (NSEnumerator *)keyEnumerator;
- (id)objectForKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id)aKey;

- (id)init;
- (void)setFileWrapperCoder:(id)coder;
- (id)initWithDirectoryWrapper:(NSFileWrapper *)fileWrapper fileWrapperCoder:(id)coder keyMapper:(id)newKeyMapper;
- (NSFileWrapper *)updatedDirectoryWrapper;

// JGFileWrapperCoder methods
- (id)fileDictionary:(id)fileDictionary objectForFileWrapper:(NSFileWrapper *)fileWrapper; // entry in directoryWrapper
- (NSFileWrapper *)fileDictionary:(id)fileDictionary fileWrapperForObject:(id)obj fileKey:(NSString *)key;

//@private
- (void)addAbsentFaultsFromDictionaryWrapper;
- (void)removeFaultsFromDictionary;
- (void)setDirectoryWrapperAndSync:(NSFileWrapper *)newDirectoryWrapper;

@end


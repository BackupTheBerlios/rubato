//  JGValueArray.h Copyright (c) 2002 Joerg Garbers.
//  This software is open source. See the license.

#import <Foundation/Foundation.h>


@interface JGValueArray : NSArray {
  NSData *data;
  unsigned int count,dataOffset,size;
  char *objCType;
  int returnType; // 0:NSValue, 1: NSNumber 2: Number (FScript)
  BOOL castValue; // set YES (Default), if we should try to cast values of input objects.
}
// prototypes
+ (NSNumber *)numberWithObjCType:(const char *)typ;
+ (NSNumber *)numberWithElementType:(NSString *)elementType;

// general Methods (not particularly bound to this class)
+ (NSString *)elementTypeForCType:(NSString *)cType; // elementType is single letter objCType string, CType is e.g. @"unsigned int"
+ (NSNumber *)numberWithValue:(NSValue *)value;
+ (NSValue *)valueWithObjCType:(const char *)typ forValue:(id)value;
+ (unsigned int)sizeForObjCType:(const char *)typ;
+ (unsigned int)sizeForElementType:(NSString *)typ;
+ (unsigned int)sizeForPrototype:(id)prototype;


// creation
+ (id)arrayWithData:(NSData *)newData prototype:(id)prototype;
+ (id)arrayWithArray:(NSArray *)array prototype:(id)prototype;
+ (id)arrayWithArray:(NSArray *)array; // takes the first element (which must exist) as prototype.

- (id)initWithData:(NSData *)newData dataOffset:(unsigned int)offset count:(unsigned int)newCount objCType:(const char *)newObjCType returnType:(int)newReturnType; 
- (id)initWithData:(NSData *)newData dataOffset:(unsigned int)offset count:(unsigned int)newCount prototype:(id)prototype; 
- (BOOL)castValue;
- (void)setCastValue:(BOOL)newCastValue;
- (NSData *)data;

- (unsigned int)elementSize;
- (NSString *)elementType;
- (unsigned)count;
- (id)objectAtIndex:(unsigned)idx;
@end

@interface JGMutableValueArray : NSMutableArray {
  NSMutableData *data;
  unsigned int count,dataOffset,size;
  char *objCType;
  int returnType; // 0:NSValue, 1: NSNumber 2: Number (FScript)
  BOOL castValue; // set YES (Default), if we should try to cast values of input objects.
}
// creation
+ (id)arrayWithMutableData:(NSMutableData *)newData prototype:(id)prototype;
+ (id)arrayWithCapacity:(unsigned int)capacity prototype:(id)prototype;
+ (id)arrayWithLength:(unsigned int)length prototype:(id)prototype;
+ (id)arrayWithArray:(NSArray *)array prototype:(id)prototype;
+ (id)arrayWithArray:(NSArray *)array; // takes the first element (which must exist) as prototype.

- (id)initWithMutableData:(NSMutableData *)newData dataOffset:(unsigned int)offset count:(unsigned int)newCount objCType:(const char *)newObjCType returnType:(int)newReturnType; 
- (id)initWithMutableData:(NSMutableData *)newData dataOffset:(unsigned int)offset count:(unsigned int)newCount prototype:(id)prototype;
- (BOOL)castValue;
- (void)setCastValue:(BOOL)newCastValue;
- (NSMutableData *)mutableData; // modifiing outside possible, even in another typed JGMutableValueArray

- (unsigned int)elementSize;
- (NSString *)elementType;
- (unsigned)count;
- (id)objectAtIndex:(unsigned)idx;

- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(unsigned)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(unsigned)index;
- (void)replaceObjectAtIndex:(unsigned)index withObject:(id)anObject;

- (void)setAllValues:(NSValue *)value;
- (void)setValuesWithArray:(NSArray *)array;
@end

@interface JGMutableValueArray (FSKVCoding)
//- (void)fskvTakeValue:(id)value forKey:(NSString *)key;
//- (BOOL)fskvAllowsToTakeValueForKey:(NSString *)key; // might disallow setting for all values
- (BOOL)fskvAllowsToTakeValue:(id)value forKey:(NSString *)key; // disallow nil values
@end

/* StringConverter.h */
/* This is a general purpose StringConverter class
*  (c) by Oliver Zahorka
*  date: 16.2.94
*  30.3.94	NXZone memory allocation, uses own zone
*  29.7.94	Added typed comparison functions
*  30.12.94	Added methods for Fraction handling
*  3.2.95	Added number concatenation methods
*/

#import "JgObject.h"
//#import <objc/Storage.h>
#import "JGList.h"
#import "CommonTypes.h"
#import "Ordering.h"
#import <Foundation/NSObject.h>

/*comparison type constants*/
enum {type_double = 1, type_float, type_int, type_bool, type_string};

@interface StringConverter:JgObject <Ordering>
{
    char*	myString;
    BOOL	freeString;
    BOOL	noCopy;
}

// substitute NSString for String objects in old binary files.
+ (NSString *)readNSStringWithCoder:(NSCoder *)aDecoder;

/* standard object methods to be overridden */
- init;
- (void)dealloc;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)copyWithZone:(NSZone *)zone;

/*access methods to string*/
- (void)setStringValue:(NSString *)aString; // wants the converting 
- (StringConverter *)setCStringValue:(const char *)aString; // want I
- (void)setStringValueNoCopy:(const char *)aString;
- (void)setStringValueNoCopy:(char *)aString shouldFree:(BOOL)flag;
- (void)setIntValue:(int)aInt;
- (void)setFloatValue:(float)aFloat;
- (void)setDoubleValue:(double)aDouble;
- (selfvoid)setBoolValue: (BOOL)aBool; 
- (selfvoid)setFractValue: (RubatoFract)aFract; 

- (const char *)cString;
- (NSString *)stringValue;
- (int) 	intValue;
- (float)	floatValue;
- (double)	doubleValue;
- (BOOL)	boolValue;
- (RubatoFract)	fractValue;

/* Utility methods */
- (size_t)length;

- (int)compareTo:anObject;
- (int)compareToObject:anObject;
- (int)compareToObject:anObject as:(int)comparisonType;
- (int)compareToDouble:(double)aDouble;
- (int)compareToFloat:(float)aFloat;
- (int)compareToInt:(int)anInt;
- (int)compareToBool:(BOOL)aBool;
- (int)compareToString:(const char *)aString;

- (BOOL)isEqual:anObject;
- (BOOL)isEqualTo:(const char*)aString;
- (BOOL)isEqualToObject:anObject;
- (BOOL)isEqualToObject:anObject as:(int)comparisonType;

- double:(double) aDbl ToString:(char *) floatStr;
/* eventually implement all the string.h functions as methods.
   For example inserting and catenating of strings¼
   Idea by Dominik Eichelberg.
*/
- (selfvoid)concat:(const char*)aString;
- (selfvoid)concatInt:(int)anInt;
- (selfvoid)concatFloat:(float)aFloat;
- (selfvoid)concatDouble:(double)aDouble;
- (selfvoid)concatBool:(BOOL)aBool;
- (selfvoid)concatWith:anObject;
- (selfvoid)insert:(const char*)aString at:(unsigned int)index;
//- (Storage *)tokenizeWith:(const char*)delimiters;
- (JgList *)tokenizeToStringsWith:(const char*)delimiters;

// - readFromStream:(NSMutableString *)mutableString; // not used
- appendToString:(NSMutableString *)mutableString;  // sould not be used any more. Has pendent to NXStringTable (-> NSDictionary)

/* Action methods for IB Objects */
- (void)takeDoubleValueFrom:(id)sender;
- (void)takeFloatValueFrom:(id)sender;
- (void)takeIntValueFrom:(id)sender;
- (void)takeBoolValueFrom:(id)sender;
- (void)takeStringValueFrom:(id)sender;

@end

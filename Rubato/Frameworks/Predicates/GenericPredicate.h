/* GenericPredicate.h */

#import <AppKit/AppKit.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubato/Inspectable.h>
#import <JGFoundation/JGAddressDictionary.h>
#import <Rubato/PredicateTypes.h>
#import "PredicateProtocol.h"
#import "PredicateDelimiter.h"
#import "ValueExtensions.h"
#import "JgFract.h"

#define PKRefCountImplemented NO

// jg: added Keys and dictstruct
// for myName, myForm, myValue
#define AttKey @"att"
#define FormKey @"form"
#define ValKey @"val"
#define ValsKey @"vals"
#define DenKey @"den"
#define ModKey @"mod"

// container for Addresses and collected forms 
typedef struct _dictstruct {
 JGAddressDictionary *addresses;
 NSMutableDictionary *forms;
} dictstruct;

@class GenericForm;

#if PKRefCountImplemented

@interface GenericPredicate:JgRefCountObject <PredicateProtocol, Inspectable>

#else

@interface GenericPredicate:JgObject <PredicateProtocol, Inspectable>

#endif

{
    NSString *myName;
    GenericForm *myForm; // GenericForm *
    int	myTag;
}

/* standard object methods to be overridden */
- init;
- (void)dealloc;
- copyWithZone:(NSZone *)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

/* special object methods to be overridden */
- (NSString *) inspectorNibFile;
- (const char*) fileTypeString;
- (int)tag;
- (void)setTag:(int)anInt;

- appendToString:(NSMutableString *)mutableString withDelimiters:delimiters andIndent:(int)indentCount;
- appendToMathString:(NSMutableString *)mutableString;
- appendToMathString:(NSMutableString *)mutableString andTabs:(int)tabCount;

/*access methods to all predicates names*/
- setName:(id)sender;
- (void)setName0:(NSString *)value; // jg
- setNameString: (const char *)aName;
//jg Change - getName;	/* returns a Predicate object*/
- (NSString *)name; //jg Change getNameString;/* returns a String object */
- (const char *)nameString;

/*access methods to the predicates type */
- (void)setType:sender;
- setTypeString: (const char *)aType;
- (NSString *)type; //jg Change see above  - getTypeString;
- (NSString *)typeName; //jg Change see above  - getTypeString;
- (const char *)typeString;
- (BOOL) canChangeTypeString: (const char *)toType;
- changeTypeString: (const char *)toType;

/*access methods to the predicates form */
- setForm: aPredicateForm;
- form;

/*access methods to the predicates parent (its super-predicate)*/
- setParent: aPredicate;
- parent;

/*access methods to all predicates values*/
- (unsigned int)count;
- (unsigned int)indexOfValue: aValue;

- setValue: aValue;
- removeValue: aValue;
- deleteValue: aValue;
- replaceValue: aValue with: bValue;

- (void)setStringValue:(NSString *)aString;
- (void)setIntValue:(int)aInt;
- (void)setFloatValue:(float)aFloat;
- (void)setDoubleValue:(double)aDouble;
- (selfvoid)setFractValue: (RubatoFract)aFract;
- (selfvoid)setBoolValue: (BOOL)aBool;

- setValueOf: (const char *)aPredicateName to: aValue;
- setStringValueOf: (const char *)aPredicateName to: (const char *)aString;
- setIntValueOf: (const char *)aPredicateName to: (int)aInt;
- setFloatValueOf: (const char *)aPredicateName to: (float)aFloat;
- setDoubleValueOf: (const char *)aPredicateName to: (double)aDouble;
- setFractValueOf: (const char *)aPredicateName to: (RubatoFract)aFract;
- setBoolValueOf: (const char *)aPredicateName to: (BOOL)aBool;

- setValueAt: (unsigned int)index to: aValue;
- setStringValueAt: (unsigned int)index to: (const char *)aString;
- setIntValueAt: (unsigned int)index to: (int)aInt;
- setFloatValueAt: (unsigned int)index to: (float)aFloat;
- setDoubleValueAt: (unsigned int)index to: (double)aDouble;
- setFractValueAt: (unsigned int)index to: (RubatoFract)aFract;
- setBoolValueAt: (unsigned int)index to: (BOOL)aBool;

- getValue;
- getStringValue;
- (NSString *)stringValue;
- (int) 		intValue;
- (float)		floatValue;
- (double)		doubleValue;
- (RubatoFract)		fractValue;
- (BOOL)		boolValue;

- getValueOf: (const char *)aPredicateName;
- getStringValueOf: (const char *)aPredicateName;
- (const char *)	stringValueOf: (const char *)aPredicateName;
- (int)			intValueOf: (const char *)aPredicateName;
- (float)		floatValueOf: (const char *)aPredicateName;
- (double)		doubleValueOf: (const char *)aPredicateName;
- (RubatoFract)		fractValueOf: (const char *)aPredicateName;
- (BOOL)		boolValueOf: (const char *)aPredicateName;

// jg added 17.6.2002. Might return nil
- (NSString *)stringValueOfPredicateWithName:(NSString *)predName;


- getValueAt: (unsigned int)index;
- getStringValueAt: (unsigned int)index;
- (const char *)	stringValueAt: (unsigned int)index;
- (int)			intValueAt: (unsigned int)index;
- (float)		floatValueAt: (unsigned int)index;
- (double)		doubleValueAt: (unsigned int)index;
- (RubatoFract)		fractValueAt: (unsigned int)index;
- (BOOL)		boolValueAt: (unsigned int)index;

- getValueOf: (const char *)aPredicateName;
- getStringValueOf: (const char *)aPredicateName;
- (const char *)	stringValueOf: (const char *)aPredicateName;
- (int)			intValueOf: (const char *)aPredicateName;
- (float)		floatValueOf: (const char *)aPredicateName;
- (double)		doubleValueOf: (const char *)aPredicateName;
- (BOOL)		boolValueOf: (const char *)aPredicateName;

- getValueAt: (unsigned int)index;
- getStringValueAt: (unsigned int)index;
- (const char *)	stringValueAt: (unsigned int)index;
- (int)			intValueAt: (unsigned int)index;
- (float)		floatValueAt: (unsigned int)index;
- (double)		doubleValueAt: (unsigned int)index;
- (BOOL)		boolValueAt: (unsigned int)index;

/*check methods for all predicates*/
- (BOOL) hasPredicate:aPredicate;
- (BOOL) hasPredicate:aPredicate inLevels:(int)levels;

- (BOOL) isPredicateOfNameString:(const char *)aPredicateName;
- (BOOL) hasPredicateOfNameString:(const char *)aPredicateName;
- (BOOL) hasPredicateOfNameString:(const char *)aPredicateName inLevels:(int)levels;
- getFirstPredicateOfNameString:(const char *)aPredicateName;
- getFirstPredicateOfNameString:(const char *)aPredicateName inLevels:(int)levels;
- getAllPredicatesOfNameString:(const char *)aPredicateName;
- getAllPredicatesOfNameString:(const char *)aPredicateName inLevels:(int)levels;

- (BOOL) isPredicateOfName:aPredicateName;
- (BOOL) hasPredicateOfName:aPredicateName;
- (BOOL) hasPredicateOfName:aPredicateName inLevels:(int)levels;
- getFirstPredicateOfName:aPredicateName;
- getFirstPredicateOfName:aPredicateName inLevels:(int)levels;
- getAllPredicatesOfName:aPredicateName;
- getAllPredicatesOfName:aPredicateName inLevels:(int)levels;

- (BOOL)hasPredicateAt:(unsigned int)index;

/*check methods for all predicates TYPES*/
- (BOOL) isPredicateOfType:aPredicateType;
- (BOOL) hasPredicateOfType:aPredicateType;
- (BOOL) hasPredicateOfType:aPredicateType inLevels:(int)levels;
- getFirstPredicateOfType:aPredicateType;
- getFirstPredicateOfType:aPredicateType inLevels:(int)levels;
- getAllPredicatesOfType:aPredicateType;
- getAllPredicatesOfType:aPredicateType inLevels:(int)levels;

/*check methods for all predicates FORMS by form id*/
- (BOOL) isPredicateOfForm: aPredicateForm;
- (BOOL) hasPredicateOfForm: aPredicateForm;
- (BOOL) hasPredicateOfForm: aPredicateForm inLevels:(int)levels;
- getFirstPredicateOfForm: aPredicateForm;
- getFirstPredicateOfForm: aPredicateForm inLevels:(int)levels;
- getAllPredicatesOfForm: aPredicateForm;
- getAllPredicatesOfForm: aPredicateForm inLevels:(int)levels;

/*check methods for all predicates FORMS by name*/
- (BOOL) isPredicateOfFormName: aFormName;
- (BOOL) hasPredicateOfFormName: aFormName;
- (BOOL) hasPredicateOfFormName: aFormName inLevels:(int)levels;
- getFirstPredicateOfFormName: aFormName;
- getFirstPredicateOfFormName: aFormName inLevels:(int)levels;
- getAllPredicatesOfFormName: aFormName;
- getAllPredicatesOfFormName: aFormName inLevels:(int)levels;

/* getAllPredicates according to any specification */
- getFirstPredicateOf:(SEL)aTest with:anObject;
- getFirstPredicateOf:(SEL)aTest with:anObject inLevels:(int)levels;
- getAllPredicatesOf:(SEL)aTest with:anObject;
- getAllPredicatesOf:(SEL)aTest with:anObject inLevels:(int)levels;

// jg added.
- (void)jgSetForm:(id)From;

// jg: PListsupport
+ (void)setFormManager:aManager;
- (NSMutableDictionary *) jgToPropertyListWithDicts:(dictstruct *)dicts;
- (void) jgInitFromPropertyList:(id)d;
+ (GenericPredicate *) jgNewFromPropertyList:(NSDictionary *)d;
#include "PropListSupport.h"

@end

/* CompoundForm.h */

#import <AppKit/AppKit.h>
#import "GenericForm.h"


@interface CompoundForm: GenericForm
{
    id myList;
    NSMutableDictionary *roles; // key=Number=Index in myList, value:roleName
}

+ (CompoundForm *)listForm;

/* standard object methods to be overridden */
- init;
- (void)dealloc;
- copyWithZone:(NSZone *)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

/*Form specific methods*/
- makePredicate;
- makePredicateFromZone:(NSZone *)zone;

/* special object methods to be overridden */
- (NSString *) inspectorNibFile;
- makeString:aString withDelimiters:delimiters andIndent:(int)indentCount;
- appendToString:(NSMutableString *)mutableString withDelimiters:delimiters andIndent:(int)indentCount;

/*access methods to all predicates names*/

/*access methods to the predicates type */
- (BOOL) canChangeTypeString: (const char *)toType;
- changeTypeString: (const char *)toType;

/*access methods to the predicates form */

/*access methods to all predicates values*/
- (unsigned int) count;
- (unsigned int) indexOfValue: aValue;

- setValue: aValue;
- removeValue: aValue;
- deleteValue: aValue;
- replaceValue: aValue with: bValue;

- setValueAt: (unsigned int)index to: aValue;
- setStringValueAt: (unsigned int)index to: (const char *)aString;
- setIntValueAt: (unsigned int)index to: (int)aInt;
- setFloatValueAt: (unsigned int)index to: (float)aFloat;
- setDoubleValueAt: (unsigned int)index to: (double)aDouble;
- setFractValueAt: (unsigned int)index to: (RubatoFract)aFract;
- setBoolValueAt: (unsigned int)index to: (BOOL)aBool;

- getValue;

- getValueAt: (unsigned int)index;
- getStringValueAt: (unsigned int)index;
- (const char *)	stringValueAt: (unsigned int)index;
- (int)			intValueAt: (unsigned int)index;
- (float)		floatValueAt: (unsigned int)index;
- (double)		doubleValueAt: (unsigned int)index;
- (RubatoFract)		fractValueAt: (unsigned int)index;
- (BOOL)		boolValueAt: (unsigned int)index;

/*check methods for all predicates*/
//- (BOOL) hasPredicateOfName:aPredicateName inLevels:(int)levels;

- (BOOL)hasPredicateAt:(unsigned int)index;

/*check methods for all predicates TYPES*/

/*check methods for all predicates FORMS*/

/* get methods according to any specification */
- getFirstPredicateOf:(SEL)aTest with:anObject inLevels:(int)levels;
- getAllPredicatesOf:(SEL)aTest with:anObject inLevels:(int)levels;

- (void)setRoleOfIndex:(int)index to:(NSString *)roleName;
- (NSString *)roleAtIndex:(int)index;
+ (NSString *)roleWithoutFather;

#include "PropListSupport.h"

@end

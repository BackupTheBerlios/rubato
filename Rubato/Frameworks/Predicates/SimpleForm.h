/* SimpleForm.h */

#import <AppKit/AppKit.h>
#import "GenericForm.h"

@interface SimpleForm:GenericForm
{
    NSString *myValue;
}
+ valueForm;
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
- (unsigned int)count;
- (unsigned int)indexOfValue: aValue;

/*access methods to the predicates type */
- (BOOL) canChangeTypeString: (const char *)toType;
- changeTypeString: (const char *)toType;

/*access methods to the predicates form */

/*access methods to all predicates values*/
- setValueAt: (unsigned int)index to: aValue;
- setStringValueAt: (unsigned int)index to: (const char *)aString;
- setIntValueAt: (unsigned int)index to: (int)aInt;
- setFloatValueAt: (unsigned int)index to: (float)aFloat;
- setDoubleValueAt: (unsigned int)index to: (double)aDouble;
- setFractValueAt: (unsigned int)index to: (RubatoFract)aFract;
- setBoolValueAt: (unsigned int)index to: (BOOL)aBool;

- getValueAt: (unsigned int)index;
- getStringValueAt: (unsigned int)index;
- (const char *)	stringValueAt: (unsigned int)index;
- (int)			intValueAt: (unsigned int)index;
- (float)		floatValueAt: (unsigned int)index;
- (double)		doubleValueAt: (unsigned int)index;
- (RubatoFract)		fractValueAt: (unsigned int)index;
- (BOOL)		boolValueAt: (unsigned int)index;

/*check methods for all predicates*/
- (BOOL)hasPredicateAt:(unsigned int)index;

/*check methods for all predicates TYPES*/

/*check methods for all predicates FORMS*/

@end

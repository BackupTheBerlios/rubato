/* GenericForm.h */

#import <AppKit/AppKit.h>
#import "SimplePredicate.h"

@interface GenericForm:GenericPredicate
{
    NSString *myType;
    BOOL needsUniqueName;
    BOOL isLocked;
    struct {
	BOOL changeName;
	BOOL changeType;
	BOOL setValue;
    }allowsTo;
}

/* standard object methods to be overridden */
- init;
- (void)dealloc;
- copyWithZone:(NSZone *)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

/*Form specific methods*/
- setAllowsToChangeName:(BOOL)nameFlag 
		Type:(BOOL)typeFlag 
		Value:(BOOL)valueFlag;
- setAllowsToChangeName:(BOOL)nameFlag ;
- setAllowsToChangeType:(BOOL)typeFlag ;
- setAllowsToChangeValue:(BOOL)valueFlag;
- setNeedsUniqueName:(BOOL)flag;
- setLocked:(BOOL)flag;
- (BOOL)allowsToChangeName;
- (BOOL)allowsToChangeType;
- (BOOL)allowsToChangeValue;
- (BOOL)needsUniqueName;
- (BOOL)isLocked;

- (BOOL)allowsTo:(SEL)aSelector;
- makePredicate;
- makePredicateFromZone:(NSZone *)zone;
/* special object methods to be overridden */
- (const char*) fileTypeString;

/*access methods to all predicates names*/

/*access methods to the predicates type */
- (void)setType:sender;
- (void)setType0:(NSString *)value; // jg without checks.
- setTypeString: (const char *)aType; // to be removed
- (NSString *)type; // = myType
- (NSString *)typeName; // jg new.
// - getTypeString;  removed due to Naming convention. (==type)
- (const char *)typeString; // to be removed

- (BOOL) canChangeTypeString: (const char *)toType;
- changeTypeString: (const char *)toType;

/*access methods to the predicates form */
- setForm: aPredicateForm;
//- form;

/*access methods to all predicates values*/

/*check methods for all predicates*/

/*check methods for all predicates TYPES*/

/*check methods for all predicates FORMS*/

@end
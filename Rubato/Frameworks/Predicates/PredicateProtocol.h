#import <RubatoDeprecatedCommonKit/commonkit.h>
@protocol PredicateProtocol

/* special object methods to be overridden */
- (const char*) fileTypeString;
//- makeMathString:mathString;
//- makeMathString:mathString andTabs:(int)tabCount;
//- makeString:aString withDelimiters:delimiters andIndent:(int)indentCount;

- appendToString:(NSMutableString *)aCoder withDelimiters:delimiters andIndent:(int)indentCount;
- appendToMathString:(NSMutableString *)aString;
- appendToMathString:(NSMutableString *)aString andTabs:(int)tabCount;

/*access methods to all predicates names*/
- setName:(id)sender;  // sender should respond to name or stringValue
/* comments to all methods */
- setNameString: (const char *)aName;
//jg Change - getName;	/* returns a Predicate object*/
- (NSString *)name; //jg Change getNameString;/* returns a String object */
- (const char *)nameString; // to be removed

/*access methods to the predicates type */
- (void)setType:sender;
- setTypeString: (const char *)aType;
- (NSString *)type; //jg Change see above  - getTypeString;
- (const char *)typeString; // to be removed

/* getType method*/
- (BOOL) canChangeTypeString: (const char *)toType; // to be replaced
- changeTypeString: (const char *)toType; // to be replaced
/* calling:
* if ([aPred canChangeTypeTo: typeInt])
*     aPred = [aPred changeType: typeInt]
*/

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

// jg to be replaced by set*ValueOfPredicateNamed: to:
- setValueOf: (const char *)aPredicateName to: aValue;  // aValue=Predicate or something else
- setStringValueOf: (const char *)aPredicateName to: (const char *)aString;
- setIntValueOf: (const char *)aPredicateName to: (int)aInt;
- setFloatValueOf: (const char *)aPredicateName to: (float)aFloat;
- setDoubleValueOf: (const char *)aPredicateName to: (double)aDouble;
- setFractValueOf: (const char *)aPredicateName to: (RubatoFract)aFract;
- setBoolValueOf: (const char *)aPredicateName to: (BOOL)aBool;

// jg to be replaced by set*ValueAtIndex: to:
- setValueAt: (unsigned int)index to: aValue;
- setStringValueAt: (unsigned int)index to: (const char *)aString;
- setIntValueAt: (unsigned int)index to: (int)aInt;
- setFloatValueAt: (unsigned int)index to: (float)aFloat;
- setDoubleValueAt: (unsigned int)index to: (double)aDouble;
- setFractValueAt: (unsigned int)index to: (RubatoFract)aFract;
- setBoolValueAt: (unsigned int)index to: (BOOL)aBool;

- getValue;
- getStringValue;  // jg remove (no longer needed)
- (NSString *)stringValue;
- (int) 		intValue;
- (float)		floatValue;
- (double)		doubleValue;
- (RubatoFract)		fractValue;
- (BOOL)		boolValue;

- getValueOf: (const char *)aPredicateName;
- getStringValueOf: (const char *)aPredicateName;  // jg remove
- (const char *)	stringValueOf: (const char *)aPredicateName;
- (int)			intValueOf: (const char *)aPredicateName;
- (float)		floatValueOf: (const char *)aPredicateName;
- (double)		doubleValueOf: (const char *)aPredicateName;
- (RubatoFract)		fractValueOf: (const char *)aPredicateName;
- (BOOL)		boolValueOf: (const char *)aPredicateName;

- getValueAt: (unsigned int)index;
- getStringValueAt: (unsigned int)index;  // jg remove
- (const char *)	stringValueAt: (unsigned int)index;
- (int)			intValueAt: (unsigned int)index;
- (float)		floatValueAt: (unsigned int)index;
- (double)		doubleValueAt: (unsigned int)index;
- (RubatoFract)		fractValueAt: (unsigned int)index;
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

@end

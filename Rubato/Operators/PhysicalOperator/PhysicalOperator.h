/* PhysicalOperator */
/* This one changes the symbolic events, but only to calulate the performance, not to change the data! */

#import <PerformanceScore/PerformanceOperator.h>

@interface PhysicalOperator:PerformanceOperator
{

}

/* get the operator's nib file */
+ (NSString *)inspectorNibFile;

/*Calculate the performed events of a LPS */
- (double) calcEventComponent:(int)index at:anEvent;

/*get the string representation of the operator*/
- (NSString *)stringValue;
- (const char*)operatorString;

/* Calculate the Field of an Operator */
- calcPerformanceField:(double *)field at:anEvent;

@end
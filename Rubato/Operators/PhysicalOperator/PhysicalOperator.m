/* PhysicalOperator */

#import "PhysicalOperator.h"
#import <Rubette/WeightWatcher.h>

@implementation PhysicalOperator

/*Calculate the performed events of a LPS*/
- (double) calcEventComponent:(int)index at:anEvent;
{
    if([self hierarchyTopAt:index] && [anEvent spaceAt:index]  && [self directionAt:index]){
	double  curBruteValue = [myWeightWatcher weightSumAt:anEvent];
		curBruteValue *= fieldDilatation[index];
		curBruteValue *= [super calcEventComponent:index at:anEvent];
    return  curBruteValue += fieldTranslation[index];
	}

    else
    return [super calcEventComponent:index at:anEvent];
}

/* get the operator's nib file */
+ (NSString *)inspectorNibFile;
{
    return @"PhysicalOperatorInspector.nib";
}




/*get the string representation of the operator*/
- (NSString *)stringValue;
{
    return @"(ax + b)";
}

- (const char*)operatorString;
{
    [myConverter setStringValue:@"PhysicalBruteForce(a * "];
    [myConverter concat:[myMother operatorString]];
    [myConverter concat:"+ b)"];
    
    return [[myConverter stringValue] cString];
}

/* Calculate the Field of an Operator */
- calcPerformanceField:(double *)field at:anEvent;
{
    /* The PhysicalBruteForce Operator doesn't alter the field at all */
    return self;
}

@end
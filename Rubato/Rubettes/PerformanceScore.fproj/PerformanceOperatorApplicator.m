/* PerformanceOperatorApplicator.m */

#import "PerformanceOperatorApplicator.h"
#import "PerformanceOperator.h"
#import <Rubette/space.h>

@implementation PerformanceOperatorApplicator

/* Import the standard SpaceProtocolMethods */
#import "SpaceProtocolMethods.m"


- init;
{
    int i;
    [super init];
    mySpace = 0;
    for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	fieldTranslation[i] = 0.0;
	fieldDilatation[i] = 1.0;
    }
    return self;
}

- collectValues:sender;
{
    int i;
    if ([directionMatrix respondsToSelector:@selector(cellWithTag:)]) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) 
	    [self setSpaceAt:i to:[[directionMatrix cellWithTag:i] intValue]];
    if ([distributionMatrix respondsToSelector:@selector(cellWithTag:)]) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    [self setFieldTranslationAt:i to:[[distributionMatrix cellWithTag:i] doubleValue]];
	    [self setFieldDilatationAt:i to:[[distributionMatrix cellWithTag:i+MAX_SPACE_DIMENSION] doubleValue]];

	}
    return [super collectValues:sender];
}

- displayValues:sender;
{
    int i;
    if ([directionMatrix respondsToSelector:@selector(cellWithTag:)]) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) 
	    [[directionMatrix cellWithTag:i] setIntValue:[self spaceAt:i]];
    if ([distributionMatrix respondsToSelector:@selector(cellWithTag:)]) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	[[distributionMatrix cellWithTag:i] setDoubleValue:fieldTranslation[i]];
	[[distributionMatrix cellWithTag:i+MAX_SPACE_DIMENSION] setDoubleValue:fieldDilatation[i]];
    }
    return [super displayValues:sender];
}


- setFieldDilatationAt:(int)index to:(double)aDouble;
{
    if (index<MAX_SPACE_DIMENSION) {
	if (aDouble || fieldTranslation[index])
	    fieldDilatation[index] = fabs(aDouble);
    }
    return self;
}

- (double)fieldDilatationAt:(int)index;
{
    if (index<MAX_SPACE_DIMENSION)
	return fieldDilatation[index];
    else
	return 1.0;
}

- setFieldTranslationAt:(int)index to:(double)aDouble;
{
    if (index<MAX_SPACE_DIMENSION) {
	fieldTranslation[index] = fabs(aDouble);
    }
    return self;
}

- (double)fieldTranslationAt:(int)index;
{
    if (index<MAX_SPACE_DIMENSION)
	return fieldTranslation[index];
    else
	return 0.0;
}


- operatorClass;
{
    return [PerformanceOperator class];
}

@end

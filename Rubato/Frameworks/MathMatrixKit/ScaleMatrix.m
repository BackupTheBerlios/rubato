/* ScaleMatrix.m */

#import "ScaleMatrix.h"


@implementation ScaleMatrix

-init;
{
    [super init];
    myScalar = 1.0;
    myRightOperand = nil;
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    [aDecoder decodeValuesOfObjCTypes:"d", &myScalar];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeValuesOfObjCTypes:"d", &myScalar];
}

- setRightOperand:rightOperand;
{
    if ([rightOperand respondsToSelector:@selector(doubleValue)]) {
	myScalar = [rightOperand doubleValue];
	isCalculated = NO;
    }
    return self;
}


- setScalar:(double)scalar;
{
    myScalar = scalar;
    isCalculated = NO;
    return self;

}

- doCustomCalculation;
{
    if (myLeftOperand && myScalar!=1.0) {
	[self setToCopyOfMatrix:myLeftOperand];

	[self scale:self];
	isCalculated=YES;
    } else if (myLeftOperand) {
	[self setToCopyOfMatrix:myLeftOperand];
	isCalculated = YES;
    } else
	isCalculated = NO;
    return self;
}

- scale:aMatrix; /* scalar multiplication with a double */ 
{
    int i;
    [aMatrix setDoubleValue:[aMatrix doubleValue]*myScalar];
    for(i = 0; i < [aMatrix rows]*[aMatrix columns]; i++)
	[self scale:[aMatrix matrixAt:i]];
    return self;
}

- undo;
{
    if (myLeftOperand) {
	[myLeftOperand ref]; // jgrelease??
	[self nxrelease];
	[myLeftOperand deRef];
	return myLeftOperand;
    }
    return self;
}


@end
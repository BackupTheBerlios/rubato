/* PowerMatrix.m */

#import "TaylorMatrix.h"

@implementation TaylorMatrix

-init;
{
    [super init];
    myExponent = 1;
    myRightOperand = nil;
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    [aDecoder decodeValuesOfObjCTypes:"i", &myExponent];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeValuesOfObjCTypes:"i", &myExponent];
}

- setRightOperand:rightOperand;
{
    if ([rightOperand respondsToSelector:@selector(intValue)]) {
	myExponent = (int)[rightOperand intValue];
	isCalculated = NO;
    }
    return self;
}

- setExponent:(int)exp;
{
    myExponent = exp;
    isCalculated = NO;
    return self;
}

- doCustomCalculation;
{
    if (myLeftOperand) {
	
	[self doTaylor]; 

    } else if (myLeftOperand) {
	[self setToCopyOfMatrix:myLeftOperand];
	isCalculated = YES;
    } else
	isCalculated = NO;
    return self;
}

- doTaylor;
{
    int i, fac, ex = myExponent;
    id aMatrix = nil;
    BOOL transposeState = isTransposed;
    
    [myCoefficients freeObjects];
    isTransposed = NO;
    isCalculated = NO;

    myRightOperand = [myLeftOperand strip];/* set right operand to strip of left one */

    if([myRightOperand rows]==[myRightOperand columns]){ 
	if(myExponent<0){
	    /*myRightOperand = [myRightOperand adjoint];*/
	    ex = myExponent*-1;
	    if(![myRightOperand isCalculated] || ![myRightOperand determinant]) {
		isCalculated = NO;
                if (!NEWRETAINSCHEME) [myRightOperand nxrelease];
		myRightOperand = nil;
		return self;
	    } else {
                id newOperand = [myRightOperand inverse];
                if (!NEWRETAINSCHEME) [myRightOperand release];
	        myRightOperand=newOperand;
            }
	}
    
	aMatrix = [[[MathMatrix alloc] initIdentityMatrixOfWidth:[myRightOperand rows]] autorelease];
	for(i = 1, fac = 1; i<=ex /*fac(i)=i!*/; i++) {
          id powerMatrix=[myRightOperand powerOfExponent:i];
          id scaleMatrix=[powerMatrix scaleWith:1/(double)fac];
          id prevMatrix=aMatrix;
	    fac = fac*i;
	    aMatrix = [aMatrix sumWith:scaleMatrix];
            if (!NEWRETAINSCHEME) {
              [prevMatrix release];
              [scaleMatrix release];
              [powerMatrix release];
            }
	}
	if([aMatrix isCalculated]) {
	    aMatrix = [aMatrix emancipate];
	    [self setToMatrix:aMatrix];
	    isCalculated = YES;
	} else
	    isCalculated = NO;

        aMatrix = nil;
    }
    if (!NEWRETAINSCHEME) [myRightOperand nxrelease];
    myRightOperand = nil;
    isTransposed = transposeState;
    return self;
}


@end
/* PowerMatrix.m */

#import "PowerMatrix.h"

@implementation PowerMatrix

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
    if (myLeftOperand && myExponent!=1) {
	
	[self doPowerOfExponent]; 

    } else if (myLeftOperand) {
	[self setToCopyOfMatrix:myLeftOperand];
	isCalculated = YES;
    } else
	isCalculated = NO;
    return self;
}

- doPowerOfExponent;
{
    int k;
    id aMatrix = nil;
    BOOL transposeState = isTransposed;
    
    [myCoefficients freeObjects];
    isTransposed = NO;
    isCalculated = NO;

    [myRightOperand release];
    // condition: myRightOperand has a sum of retaincounts=0 (incl. retain and autorelease)
    myRightOperand = [myLeftOperand strip];/* set right operand to strip of left one */

      if([myRightOperand rows]==[myRightOperand columns]){ /* Rule: first strip! */
	if(myExponent == 0) {
	    [self convertToIdentityMatrixOfWidth:[myRightOperand rows]];
	    isCalculated = YES;
	
	} else if(myExponent > 0){
          id oldRight=myRightOperand;
	    //[myRightOperand deRef];/* since we'll redefine myRightOperand it's not referenced anymore */
            // we do need it!
	    for(k = 2; k<=myExponent && myExponent%k; k++); /*Start NEW version*/
            if (k==myExponent) {
              id powerMatrix=[myRightOperand powerOfExponent: k-1];
		myRightOperand = [myRightOperand productWith:powerMatrix];
                if (!NEWRETAINSCHEME) [powerMatrix release];
            } else {
              id powerMatrix=[myRightOperand powerOfExponent:myExponent/k];
		myRightOperand = [powerMatrix powerOfExponent:k];
                if (!NEWRETAINSCHEME) [powerMatrix release];
            }
            if (!NEWRETAINSCHEME) [oldRight release];
              /*End NEW version*/
			
	    /* set self to the result matrix */ 
	    if ([myRightOperand isCalculated]) {
		myRightOperand = [myRightOperand emancipate];
		[self setToMatrix:myRightOperand];
		isCalculated = YES;
	    }
    }
	else if(myExponent < 0 && [myLeftOperand determinant] && [aMatrix=[myLeftOperand adjoint] result]){ 
	    //[myRightOperand deRef];/* since we'll redefine myRightOperand it's not referenced anymore */
          id inverse=[myRightOperand inverse];
          if (!NEWRETAINSCHEME) [myRightOperand release];
	    myRightOperand = [inverse powerOfExponent:myExponent*-1];
            if (!NEWRETAINSCHEME) [inverse release];
	    /* set self to the result matrix */
	    if ([myRightOperand isCalculated]) {
		myRightOperand = [myRightOperand emancipate];
		[self setToMatrix:myRightOperand];
		isCalculated = YES;
	    }
	}
    }
    if (!NEWRETAINSCHEME) [aMatrix release];
    aMatrix = nil;
    if (!NEWRETAINSCHEME) [myRightOperand nxrelease];
    myRightOperand = nil;
    isTransposed = transposeState;
    return self;
}


@end
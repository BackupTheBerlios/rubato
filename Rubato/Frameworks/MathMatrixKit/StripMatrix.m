/* StripMatrix.m */

#import "StripMatrix.h"

@implementation StripMatrix

- doCustomCalculation;
{
    if (myLeftOperand) {
	[self doStrip];
	 
    } else
	isCalculated = NO;
    return self;
}

- doStrip;
{
    unsigned int i;
    myRightOperand = myLeftOperand;
    myLeftOperand = [[[MathMatrix alloc]init]ref]; // jgrelease?
    
    [self setToEmptyCopyOfMatrix:myRightOperand];

    isCalculated=YES;

    [myLeftOperand setToEmptyCopyOfMatrix:myRightOperand];
    [myLeftOperand convertToRealMatrix];
    
    if ([myRightOperand hasCoefficients]) {
      for (i=0; i<myRows*myCols; i++) {
        id strippedMatrix=[[myRightOperand matrixAt:i]strip];
        [myLeftOperand replaceMatrixAt:i with:strippedMatrix];
        if (!NEWRETAINSCHEME) [strippedMatrix release];
      }
    }
    
    [self doUndress];

    [myLeftOperand nxrelease];
    myLeftOperand = myRightOperand;
    myRightOperand = nil;
        
    return self;
}
	
- strip;
{ // increases the sum of retainCounts by one, as MathMatrix does.
  // and it is independent.
    return [self copy];
}
@end
/* SumMatrix.m */

#import "SumMatrix.h"


@implementation SumMatrix

- doCustomCalculation;
{
    if (myLeftOperand && myRightOperand) {
	
	[self sum:myLeftOperand with:myRightOperand];
    
    } else if (myLeftOperand) {
	[self setToCopyOfMatrix:myLeftOperand];
	isCalculated = YES;
    } else if (myRightOperand) {
	[self setToCopyOfMatrix:myRightOperand];
	isCalculated = YES;
    }
    return self;
}

- sum:matrix1 with:matrix2;
{
    int i;
    BOOL transposeState = isTransposed;
// jgrelease?
    if (!NEWRETAINSCHEME) {
      [matrix1 ref];
      [matrix2 ref];
    }
    [myCoefficients freeObjects];
    isTransposed = NO;
    myRows = [matrix1 rows];
    myCols = [matrix1 columns];
    myValue = [matrix1 doubleValue];

    if([matrix1 rows]==[matrix2 rows] && [matrix1 columns]==[matrix2 columns]) { 
	isCalculated  = YES;
	myValue = [matrix1 doubleValue] + [matrix2 doubleValue];
	
	if([matrix1 hasCoefficients] || [matrix2 hasCoefficients]) {
	
          if(![matrix1 coefficients]) {
            if (!NEWRETAINSCHEME) [matrix1 release];
            matrix1 = [matrix1 undress];
          }
          if(![matrix2 coefficients]) {
            if (!NEWRETAINSCHEME) [matrix2 release];
            matrix2 = [matrix2 undress];
          }
	    
	    if (!myCoefficients)
		myCoefficients = [[RefCountList alloc]initCount:[matrix1 columns]*[matrix2 rows]];

	    for(i = 0; i < [matrix1 rows]*[matrix1 columns]; i++) {
		id coeffSum = [[matrix1 matrixAt:i] sumWith:[matrix2 matrixAt:i]];
		if ([coeffSum isCalculated])
		    [myCoefficients addObject:coeffSum];
		else {
                    if (!NEWRETAINSCHEME) [coeffSum release];
		    [myCoefficients freeObjects];
		    break;
		/* At this point I would not set isCalculated = NO;, but keep the setting YES : The result
		reduces to a constant Matrix. */
		}
	    }
	    
	}
    }
    if (!NEWRETAINSCHEME) {
      [matrix1 release];
      [matrix2 release];
    }
    isTransposed = transposeState;
    return self;
}
		  


@end
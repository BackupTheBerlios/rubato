/* ProductMatrix.m */

#import "ProductMatrix.h"
#import "SumMatrix.h"


@implementation ProductMatrix

- doCustomCalculation;
{
    if (myLeftOperand && myRightOperand) {

	[self multiply:myLeftOperand with:myRightOperand];

    } else if (myLeftOperand) {
	[self setToCopyOfMatrix:myLeftOperand];
	isCalculated = YES;
    } else if (myRightOperand) {
	[self setToCopyOfMatrix:myRightOperand];
	isCalculated = YES;
    } else
	isCalculated = NO;
    return self;
}

- multiply:matrix1 with:matrix2;
{
    int r, c, k;
    BOOL transposeState = isTransposed;

    if (!NEWRETAINSCHEME) {
      [matrix1 retain];
      [matrix2 retain];
    }
    [myCoefficients freeObjects];
    isTransposed = NO;

    if([matrix1 columns] ==  [matrix2 rows]) {
	myCols = [matrix2 columns];
	myRows = [matrix1 rows];
	myValue = [matrix1 doubleValue]*[matrix1 rows]*[matrix2 doubleValue];
	isCalculated = YES;
	
	if([matrix1 coefficients] || [matrix2 coefficients]){

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
	    for(r = 1; r <= myRows; r++){
		for(c = 1; c <= myCols; c++){
		    SumMatrix *theSum = nil;
		    for(k = 1; k <= [matrix2 rows]; k++){
                      id product=[[matrix1 matrixAt:r:k] productWith:[matrix2 matrixAt:k:c]];
                      id oldSum=theSum;
			theSum = [[[SumMatrix alloc]init] calculateWith:
					theSum :product];
                        [oldSum release];
                        if (!NEWRETAINSCHEME) [product release];
		    }
		    if ([theSum isCalculated])
			[myCoefficients addObject:theSum];
		    else {
			[myCoefficients freeObjects];
			break;
		    }
                    [theSum release];
		    /* this works since we calc along our index */
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
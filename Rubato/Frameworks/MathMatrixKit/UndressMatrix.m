/* UndressMatrix.m */

#import "UndressMatrix.h"

@implementation UndressMatrix

- doCustomCalculation;
{
    if (myLeftOperand) {
	[self doUndress];
	 
    } else
	isCalculated = NO;
    return self;
}

- doUndress;
{
    int i, r, c, rr, cc;
    id aCoefficient;
    BOOL transposeState = isTransposed;

    if (![myLeftOperand isWellDressed]) {
	[self setToCopyOfMatrix:myLeftOperand];
	isCalculated=NO;
    } else {
	if (![myLeftOperand hasCoefficients]) {
	    [self setToEmptyCopyOfMatrix:myLeftOperand];
	    [self convertToRealMatrix];
	    isCalculated=YES;
	} else {
	    myRows = 0;
	    myCols = 0;
	    
	    for (i=1; i<=[myLeftOperand columns]; i++) {
		myCols += [[myLeftOperand matrixAt:1:i]columns];
	    }
	    for (i=1; i<=[myLeftOperand rows]; i++) {
		myRows += [[myLeftOperand matrixAt:i:1]rows];
	    }
	    
	    [myCoefficients freeObjects];
	    if ([myCoefficients capacity]>(myRows*myCols)+4) {
		/* accept extra capacity of 4 Objects */
		[myCoefficients nxrelease];
		myCoefficients = [[RefCountList allocWithZone:[self zone]]initCount:myRows*myCols];
	    }
	    [self convertToRealMatrix];
	    isTransposed = NO;
	    
	    for (r=1; r<=myRows; r++)
		for (c=1; c<=myCols; c++) {
		    aCoefficient = [[myLeftOperand matrixAt:r:c]clone];
		    [aCoefficient convertToRealMatrix];
		    for (rr=0; rr<[aCoefficient rows]; rr++)
			for (cc=0; cc<[aCoefficient columns]; cc++) {
			    [self replaceMatrixAt:rr+r:cc+c with:[aCoefficient matrixAt:rr+1:cc+1]];
			}
		    [aCoefficient release];
		}
	    
	    isCalculated=YES;
	}
    }
    isTransposed = transposeState;
    return self;
}
	

@end
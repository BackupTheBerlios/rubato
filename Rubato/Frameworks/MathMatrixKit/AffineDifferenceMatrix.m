/* AffineDifferenceMatrix.m */

#import "AffineDifferenceMatrix.h"

@implementation AffineDifferenceMatrix

- doCustomCalculation;
{
    if ([myLeftOperand columns]>1) {
	
	[self doAffineDifference];
	 
    } else
	isCalculated = NO;
    return self;
}

- doAffineDifference;
/* Construction of a difference matrix with respect to the first column */
{
    int i, j;
    [self setToCopyOfMatrix:myLeftOperand];
    
    if(1<[self columns]){
	for(j=2;j<=[self columns]; j++){
          for(i=1;i<=[self rows]; i++) {
            id differenceMatrix=[[self matrixAt:i:j] differenceTo: [self matrixAt:i:1]];
	    [self replaceMatrixAt:i:j with:differenceMatrix];
            if (!NEWRETAINSCHEME) [differenceMatrix release];
          }
	}
	[self removeColAt:1];
	isCalculated = YES;
    }
    return self;
}


@end
/* InverseMatrix.m */

#import "InverseMatrix.h"

@implementation InverseMatrix

- doCustomCalculation;
{
    if (myLeftOperand) {
	
	[self doInverse];
	 
    } else
	isCalculated = NO;
    return self;
}

- doInverse;
{
    double det;
    id adjointMatrix = [myLeftOperand adjoint]; //jg removed ref
    det = [myLeftOperand determinant];
    isCalculated = NO;
    
    if(det && [adjointMatrix result]){
        id newMatrix= [adjointMatrix scaleWith:(1/det)];
        if (!NEWRETAINSCHEME) [adjointMatrix release];
	adjointMatrix = newMatrix;
	[self setToMatrix:adjointMatrix];
	isCalculated = YES;
    }
    if (!NEWRETAINSCHEME) [adjointMatrix release];
    adjointMatrix = nil;
    return self;
}

@end
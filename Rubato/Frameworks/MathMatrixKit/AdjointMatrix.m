/* AdjointMatrix.m */

#import "AdjointMatrix.h"

@implementation AdjointMatrix

- doCustomCalculation;
{
    if (myLeftOperand) {
	
	[self doAdjoint];
	 
    } else
	isCalculated = NO;
    return self;
}

- doAdjoint;
{
    int i;
    myRightOperand = [myLeftOperand strip]; /* use rightOperand as strip of left one*/
    
    [myCoefficients freeObjects];
    myRows = [myRightOperand rows];
    myCols = [myRightOperand columns];
    myValue = [myRightOperand determinant];
    
    if([myRightOperand rows] - [myRightOperand columns] || ![myRightOperand isNumeric])
	isCalculated = NO;

    else if([myRightOperand rows] == 1)
	[self convertToIdentityMatrixOfWidth:1]; 

    else{
	[self convertToRealMatrix];
	for(i = 0; i < myRows*myCols; i++)
	    [[self matrixAt:i] setDoubleValue:[myRightOperand minorAt:i]];
    }
    if (!NEWRETAINSCHEME) [myRightOperand release];
    myRightOperand = nil;
    isCalculated = YES;

    return self;
}


@end
/* ScaleMatrix.h */


#import "BinaryMatrixOperator.h"

@interface ScaleMatrix : BinaryMatrixOperator
{
    double myScalar;
}

- init;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- setRightOperand:rightOperand;
- setScalar:(double)scalar;

- doCustomCalculation;
- scale:aMatrix; /* scalar multiplication with a double */ 

- undo;

@end
/* TaylorMatrix.h */


#import "BinaryMatrixOperator.h"

@interface TaylorMatrix : BinaryMatrixOperator
{
    int myExponent;
}

- init;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- setRightOperand:rightOperand;
- setExponent:(int)exp;

- doCustomCalculation;
- doTaylor;

@end
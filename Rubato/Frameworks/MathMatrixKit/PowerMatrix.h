/* PowerMatrix.h */


#import "BinaryMatrixOperator.h"

@interface PowerMatrix : BinaryMatrixOperator
{
    int myExponent;
}

- init;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- setRightOperand:rightOperand;
- setExponent:(int)exp;

- doCustomCalculation;
- doPowerOfExponent;

@end
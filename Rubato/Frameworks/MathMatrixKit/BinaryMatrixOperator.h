/* BinaryMatrixOperator.h */


#import "MathMatrix.h"

@interface BinaryMatrixOperator : MathMatrix
{
    MathMatrix *myLeftOperand;
    MathMatrix *myRightOperand;
    BOOL isCalculated;
}

- init;
- initWithOperands:leftOperand :rightOperand;
- (void)dealloc;
- copyWithZone:(NSZone*)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- setLeftOperand:leftOperand;
- leftOperand;
- setRightOperand:rightOperand;
- rightOperand;
- setOperands:leftOperand :rightOperand;

- (selfvoid)setToEmptyCopyOfMatrix:aMatrix;

- (id)emancipateWithMaxRetainCount:(unsigned int)maxRetainCount;
- (BOOL)isEmancipatedWithMaxRetainCount:(unsigned int)maxRetainCount;
- (BOOL)isCalculated;
- (selfvoid)calculate;
- calculateWith:leftOperand :rightOperand;
- recalculate;
- doCustomCalculation;
- result;

- undo;

@end
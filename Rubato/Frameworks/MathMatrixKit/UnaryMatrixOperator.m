/* UnaryMatrixOperator.m */

#import "UnaryMatrixOperator.h"

@implementation UnaryMatrixOperator

- initWithOperand:anOperand;
{
    [self init];
    [self setLeftOperand:anOperand];
    return self;
}


- setRightOperand:rightOperand;
{
    /* cannot set right operand */
    myRightOperand = nil;
    return self;
}

- setOperand:anOperand;
{
    return [self setLeftOperand:anOperand];
}

@end
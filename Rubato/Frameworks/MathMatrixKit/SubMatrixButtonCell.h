/* SubMatrixButtonCell.h */

#import <AppKit/NSButtonCell.h>
#import <MathMatrixKit/MathMatrix.h>

@interface SubMatrixButtonCell:NSButtonCell
{
    MathMatrix *myMathMatrix;
}

/* standard object methods to be overridden */

- init;
- initWith:aMathMatrix;
- setMathMatrix:aMathMatrix;

@end
/* MathMatrixView.h */

#import <AppKit/NSMatrix.h>
#import <MathMatrixKit/MathMatrix.h>

@interface MathMatrixView:NSMatrix
{
    MathMatrix *myMathMatrix;
    MathMatrixView *mySuperMatrixView;
}

/* standard object methods to be overridden */
//- init;
- initWithFrame:(NSRect)frameRect;
- initFrame:(NSRect)frameRect matrix:aMathMatrix;
- initFrame:(NSRect)frameRect matrix:aMathMatrix superMatrixView:aMathMatrixView;
//- free;
//- copyFromZone:(NXZone*)zone;
//- read:(NXTypedStream *)stream;
//- write:(NXTypedStream *)stream;

- setMathMatrix:aMathMatrix;
- setDoubleValueFrom:sender;
- construct;
- (void)display;

- openMatrixOfCell:sender;
- closeSubMatrixView:sender;

@end
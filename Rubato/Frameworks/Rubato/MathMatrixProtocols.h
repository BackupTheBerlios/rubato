// This file is not needed anymore, because MatrixEvent is moved to Weight.framework.

// Using this Protocol, some Rubettes (Harmo, Primavista) 
// need not be linked to PerformanceScore-Subproject, which belongs 
// mostly to PerformanceRubette, and also need not be linked to MathMatrixKit-Framework.

#import <Foundation/NSValue.h>
#import "RubatoTypes.h"

@protocol MatrixAccess
- (NSNumber *) numberAt:(int)row :(int)col;
- (void)setDoubleValue:(double)value at:(int)row:(int)col;
@end

@protocol MatrixEventProtocol
- (BOOL) isSuperspaceFor:(spaceIndex) aSpace;
- (double) doubleValueAtIndex:(int)index;
@end
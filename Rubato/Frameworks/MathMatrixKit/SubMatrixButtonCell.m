/* SubMatrixButtonCell.m */

#import <AppKit/NSTextFieldCell.h>

#import "SubMatrixButtonCell.h"

@implementation SubMatrixButtonCell

/* standard object methods to be overridden */

- init;
{
    [super initImageCell:[NSImage imageNamed:@"SUBMATRIX_ICON"]];
    [self setImagePosition:NSImageAbove];
    [self setEntryType:NSDoubleType];
    return self;
}

- initWith:aMathMatrix;
{
    [self init];
    [self setMathMatrix:aMathMatrix];
    return self;
}

- setMathMatrix:aMathMatrix;
{
    if ([aMathMatrix isKindOfClass:[MathMatrix class]]) {
	id aTextCell = [[NSTextFieldCell alloc]init];
	[aTextCell setDoubleValue:[aMathMatrix doubleValue]];
	[myMathMatrix deRef];
	myMathMatrix = [aMathMatrix ref];
	[self setTitle:[aTextCell stringValue]];
	[aTextCell release];
    }
    return self;
}

@end
/* MathMatrixView.m */

#import <AppKit/NSTextFieldCell.h>
#import <AppKit/NSTextField.h>

#import "MathMatrixView.h"
#import <MathMatrixKit/MathMatrix.h>
#import "SubMatrixButtonCell.h"

@implementation MathMatrixView

/* standard object methods to be overridden */

- initWithFrame:(NSRect)frameRect;
{
    [self initFrame:frameRect matrix:nil];
    return self;
}

- initFrame:(NSRect)frameRect matrix:aMathMatrix;
{
    [self initFrame:frameRect matrix:nil superMatrixView:nil];
    return self;
}

- initFrame:(NSRect)frameRect matrix:aMathMatrix superMatrixView:aMathMatrixView;
{
    if ([aMathMatrixView isKindOfClass:[MathMatrixView class]])
	mySuperMatrixView = aMathMatrixView;
    if ([aMathMatrix isKindOfClass:[MathMatrix class]]) {
	myMathMatrix = aMathMatrix;
	[super initWithFrame:frameRect mode:NSRadioModeMatrix cellClass:([aMathMatrix hasNumericFormat] ? 
			[NSTextFieldCell class] : [SubMatrixButtonCell class]) numberOfRows:[aMathMatrix rows] numberOfColumns:[aMathMatrix columns]];
    } else
	[super initWithFrame:frameRect mode:NSRadioModeMatrix cellClass:[NSTextFieldCell class] numberOfRows:1 numberOfColumns:1];
    [self setTarget:self];
    [self setDoubleAction:@selector(closeSubMatrixView:)];
    [self setFrameSize:NSMakeSize(NSWidth(frameRect), NSHeight(frameRect))];
    [self setEnabled:YES];
    //[self setOpaque:NO];
    //[self setBackgroundGray:NX_LTGRAY];
    [self setCellBackgroundColor:[NSColor lightGrayColor]];
    return self;
}

- setMathMatrix:aMathMatrix;
{
    if ([aMathMatrix isKindOfClass:[MathMatrix class]]) {
      [aMathMatrix retain];
	[myMathMatrix release];
	myMathMatrix = aMathMatrix;
	[self display];
    }
    return self;
}

- setDoubleValueFrom:sender;
{
    if ([[sender selectedCell] respondsToSelector:@selector(doubleValue)]) {
	[[myMathMatrix matrixAt:[[self cells] indexOfObject:[sender selectedCell]]] setDoubleValue:[[sender selectedCell] doubleValue]];
	[self display];
    }
    return self;
}

- construct;
{
    unsigned int i;
    id aCell, aMatrix, aRepObj;
    int numRows,numCols;
    if (myMathMatrix && ([myMathMatrix rows]!=[self numberOfRows] ||  [myMathMatrix columns]!=[self numberOfColumns])) {
	[self renewRows:[myMathMatrix rows] columns:[myMathMatrix columns]];
	[self sizeToCells];
    }
    [self getNumberOfRows:&numRows columns:&numCols];
    for (i=0; i<numRows*numCols; i++) {
	aCell = [[self cells] objectAtIndex:i];
	aMatrix  = [myMathMatrix matrixAt:i];
	if (!aMatrix || [aMatrix rows]*[aMatrix columns]==1) {
	    if (![aCell isKindOfClass:[NSTextFieldCell class]]
         && ![aRepObj=[aCell representedObject] isKindOfClass:[NSTextField class]]) {
	    // jg case: Matrix is a field
		//[aRepObj release]; //jg also with own alloc?
		aRepObj = [[NSTextField alloc]init];
		//[aRepObj retain]; // jg also?
		[aRepObj setDoubleValue:[aMatrix doubleValue]];
		[aCell setRepresentedObject:aRepObj];
                [aRepObj release];
	    }
	    if (!aMatrix) {
		[aCell setDoubleValue:[myMathMatrix doubleValue]];
		[aCell setEditable:NO];
		[aCell setTarget:nil];
		[aCell setAction:NULL];
	    } else {
		[aCell setDoubleValue:[aMatrix doubleValue]];
		[aCell setEditable:YES];
		[aCell setTarget:self];
		[aCell setAction:@selector(setDoubleValueFrom:)];
	    }
	} else {
        // jg Case: Matrix contains several fields
        // is this correct code?
	    if (![aCell isKindOfClass:[SubMatrixButtonCell class]]
         && ![aRepObj=[aCell representedObject] isKindOfClass:[SubMatrixButtonCell class]]) {
             	   aRepObj = [[SubMatrixButtonCell alloc]init];
                   [aCell setRepresentedObject:aRepObj];
                   [aRepObj release];
	    }
	    [aCell setMathMatrix:aMatrix];
	    [aCell setTarget:self];
	    [aCell setAction:@selector(openMatrixOfCell:)];
	}
    }
    [self sizeToFit];
    return self;
}

- (void)display;
{
    [self construct];
    [super display];
}

- openMatrixOfCell:sender;
{
    NSRect aFrame;
    id aMatrix, aSubMatrixView;
    if ([sender isKindOfClass:[NSMatrix class]])
	aMatrix = [myMathMatrix matrixAt:[[self cells] indexOfObject:[sender selectedCell]]];
    else
	aMatrix = [myMathMatrix matrixAt:[[self cells] indexOfObject:sender]];
    
    aSubMatrixView = [[MathMatrixView alloc]initFrame:[self frame] matrix:aMatrix superMatrixView:self];
    
    aFrame = [[aSubMatrixView construct] frame];
    [self addSubview:aSubMatrixView];
    [self setFrame:aFrame];
    [aSubMatrixView display];
    return self;
}

- closeSubMatrixView:sender;
{
    if (!([NSView focusView] == self)) {
	if (mySuperMatrixView) {
	    id aView = [self superview];
	    [self removeFromSuperview];
	    [aView display];
	    [self release];
            return nil;
	}
    }
    return self;
}

@end
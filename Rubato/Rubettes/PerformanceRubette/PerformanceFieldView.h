/* PerformanceFieldView.h */

#import <AppKit/AppKit.h>
#import "LPSView.h"

@interface PerformanceFieldView:LPSView
{
    id	xAxisPopUp; //NSPopUpButton
    id	yAxisPopUp; // ebenfalls
    id	myEventFieldSwitch;
    id	myLengthScaleField;
}

- (void)awakeFromNib;

- (void)calcDrawSize;
//- (void)drawRect:(NSRect)rects;
- (void)drawContent;

@end

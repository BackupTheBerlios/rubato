
#import <AppKit/AppKit.h>
#import <Rubette/WeightyView.h>

#import "MetroRubetteDriver.h"

@interface MetroWeightView:WeightyView
{
    weightList	theWeightList;
/*    grid	theGrid;
    id	myGridOriginField;
    id	myGridMeshField;
    id	myLineWidthField;
    id	myConverter;
  */
}

- initWithFrame:(NSRect)frameRect;
- (void)dealloc;
- (void)calcDrawSize;
- doWeightRedraw:sender;
- displayWeightList:(weightList)aWeightList;
//- (void)drawRect:(NSRect)rects;
- (void)drawContent;
- (int)weightCount;

@end

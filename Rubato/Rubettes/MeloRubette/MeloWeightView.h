
#import <AppKit/AppKit.h>
#import <Rubette/WeightyView.h>
#import "MeloRubetteDriver.h"

@interface MeloWeightView:WeightyView
{
/*    id	myGridOriginField;
    id	myGridMeshField;
    id	myRadiusField;
    id	myLineWidthField;
    id	myConverter;
    struct {
	    double origin;
	    RubatoFract mesh;
    } theGrid;
  */
    M2D_weightList	theWeightList;
//    double	weightScaleFactor;
}

- initWithFrame:(NSRect)frameRect;
- (void)dealloc;
- doWeightRedraw:sender;
- (void)calcDrawSize;
- displayWeightList:(M2D_weightList)aWeightList;
//- (void)drawRect:(NSRect)rects;
//- drawFrame;
//- drawGrid;
- (void)drawContent;
- (int)weightCount;

@end

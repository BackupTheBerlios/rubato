/* MeloMotifView.h */

#import <AppKit/AppKit.h>
#import <Rubette/WeightyView.h>
#import "MeloRubetteDriver.h"


@interface MeloMotifView:WeightyView
{
//    id	myRadiusField;
//    id	myLineWidthField;
    id	myMotifSpanField;
    id	myMotifPresenceField;
    id	myMotifContentField;
    id	myMotifWeightField;
    id	myMotifOnsetField;
//    id	myGridOriginField;
//    id	myGridMeshField;
//    id	myConverter;
//    struct {
//	    double origin;
//	    RubatoFract mesh;
//    } theGrid;
    M2D_compList	theMotif;
    double pitchSpan, pitchLow;
}

- initWithFrame:(NSRect)frameRect;
- (void)dealloc;
- takePitchSpanFrom:sender;
- takePitchLowFrom:sender;
- setPitchSpanTo:(double)aDouble;
- setPitchLowTo:(double)aDouble;

- doMotifRedraw:sender;
- (void)calcDrawSize;
- displayMotif:(M2D_compList)aMotif;
//- (void)drawRect:(NSRect)rects;
//- drawFrame;
//- drawGrid;
- (void)drawContent;
- (int)weightCount;

@end

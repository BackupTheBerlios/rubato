/* WeightView.h */

// Most of the code is not specific to Weights, but a graphic view with lineWith, size calculation, grid, frame.
#import <AppKit/NSView.h>
#import <AppKit/NSPopUpButton.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>

#import <Rubato/RubatoTypes.h>
#import "MatrixEvent.h"
#import "SpaceProtocol.h"

@protocol WeightyViewTheWeight
- (unsigned int)count;
- (spaceIndex) space;
- (int) dimension;
@end

@interface WeightyView:NSView
{
  // must be set by subclass
  id theWeight; // must respond to: count, space, dimension

  // set these in subclasses -setCustomValues
  // all min and max values are used to compute bounds of view.
  double maxX;
  double maxY;
  double minX;
  double minY;
  double maxWeight;
  double minWeight;
  double meanLevel;
  // set by calcDrawSize
  double width;
  double height;

  // values set by drawRect:
  double wOffset;
  NSSize sz; // ?clear this: the meaning of sz is bound to usePS. It should be a unit (see convertSize setBoundsSize)
  double	weightScaleFactor; // set by calcDrawSize

  id	myGridOriginField;
  id	myGridMeshField;
  id	myGridSwitch;
  id	myMeanLevelSwitch;
  id	myRadiusField;
  id	myLineWidthField;
  id	myBoildDownPopUp;

  IBOutlet NSButton *drawLinesSwitch;
  IBOutlet NSButton *drawSplinesSwitch;

  // values set by valuesFromFields
  double radius, lineWidth;
  BOOL shouldDrawMeanLevel,shouldDrawGrid, shouldDrawLines, shouldDrawSplines;
  int	myBDIndex;
  struct {
          double origin;
          RubatoFract mesh;
  } theGrid;

  // helpers:
  StringConverter *myConverter;
  MatrixEvent *anEvent;

  // to be removed:
  int usePS;
    //    id	myFrameMatrix; // not used
    //    LPS_Frame myKernelFrame[MAX_SPACE_DIMENSION]; // not used
  NSAffineTransform *transformation;
  NSAffineTransform *inverseTransformation;
}
#define WEIGHTY_VIEW_DECLARE_COLOR_METHOD(x) -(NSColor *)x; 
WEIGHTY_VIEW_DECLARE_COLOR_METHOD(backgroundColor)
WEIGHTY_VIEW_DECLARE_COLOR_METHOD(lineColor)
WEIGHTY_VIEW_DECLARE_COLOR_METHOD(circleColor)
WEIGHTY_VIEW_DECLARE_COLOR_METHOD(circleFillColor)
WEIGHTY_VIEW_DECLARE_COLOR_METHOD(circleBorderColor)
WEIGHTY_VIEW_DECLARE_COLOR_METHOD(meanLevelColor)
WEIGHTY_VIEW_DECLARE_COLOR_METHOD(gridColor)
WEIGHTY_VIEW_DECLARE_COLOR_METHOD(rectColor)
WEIGHTY_VIEW_DECLARE_COLOR_METHOD(rectBorderColor)
+ (void)setBorderWidth:(float)w;
- (float)borderWidth;

- (NSAffineTransform*) transformation;
- (void) setTransformation:(NSAffineTransform*)newTransformation;
- (NSAffineTransform*) inverseTransformation;
- (void) setInverseTransformation:(NSAffineTransform*)newInverseTransformation;

- initWithFrame:(NSRect)frameRect;
- (void)dealloc;
- (void)doRedraw:sender;
- (void)drawFrame;
- (void)drawCircleAtX:(double)x Y:(double)y;
- (void)drawCircleAtX:(double)x Y:(double)y fillColor:(double)c;
- (void)valuesFromFields;
- (void)setTransformations;
- (void)calcDrawSize;
- (void)drawMeanLevel;
- (void)drawGrid;
- (void)drawDim1;
- (void)drawDim2;
- (void)drawContent;
- (void)drawRect:(NSRect)rects;

// Subclasses must override these, if they do not use theWeight. 
// To use drawRect, override weightCount.
// This class uses the corresponding methods of theWeight (see WeightyViewTheWeight protocol)
- (BOOL)weightExists; // used by calcDrawSize
- (spaceIndex)weightSpace;// used by drawContent
- (int)weightDimension;// used by calcDrawSize drawContent drawMeanLevel
- (unsigned int)weightCount;// used by drawContent, drawRect

// to be overridden
- (double)weightValueAtEvent:(id)event;
- (void)setCustomValues;
- (void)customDrawDim1;
- (void)customDrawDim2;


//- displayWeight:aWeight;
//- displayWeight:aWeight withInversion:(BOOL)flag andDeformation:(double)deform;

@end

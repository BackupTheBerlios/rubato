
#import <AppKit/AppKit.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubato/RubatoTypes.h>
#import <Rubette/WeightyView.h>

@interface KernelView:WeightyView
{
/*    id	myGridOriginField;
    id	myGridMeshField;
    id	myGridSwitch;
    id	myRadiusField;
    id	myLineWidthField;
    
    id	myConverter;
  struct {
          double origin;
          RubatoFract mesh;
  } theGrid;
  double	weightScaleFactor;
*/
  id	myEventList;
  id	myFrameMatrix;
    LPS_Frame myKernelFrame[MAX_SPACE_DIMENSION];
}

- initWithFrame:(NSRect)frameRect;
- (void)dealloc;
- (void)doRedraw:sender;// overridden
- sizeViewToKernel:sender;
- sizeViewToFrame:sender;
- setKernelFrame:sender;
- displayEventList:anEventList;
- calcKernelFrame;
- (BOOL)frameContains:anEvent;
- (void)calcDrawSize;
//- (void)drawRect:(NSRect)rects;
//- drawFrame;
//- drawGrid;
- (unsigned int)weightCount;
- (void)drawContent;

@end

/* WeightView.m */

#ifdef WITH_PS
#import <AppKit/psops.h>
#endif
#import <AppKit/NSApplication.h>

#import "WeightView.h"
#import "MatrixEvent.h"
//jg#import "LocalPerformanceScore.h"
#import "Weight.h"

@implementation WeightView

- initWithFrame:(NSRect)frameRect;
{
    [super initWithFrame:frameRect];
  myWeight=nil;
    return self;
}

- (void)dealloc;
{
  [myWeight release];
    [super dealloc];
}

- (void)displayWeight:aWeight;
{
  [self displayWeight:aWeight withInversion:NO andDeformation:0.0];
}


- (void)displayWeight:aWeight withInversion:(BOOL)flag andDeformation:(double)deform;
{
/*    if (aWeight != myWeight) {
	[[myWeight setInversion:isInverted] release];
	myWeight = aWeight;
	[myWeight ref];
	[myBDWeight release];
        myBDWeight = nil;
    }
*/
  [aWeight retain];
  [myWeight release];
  myWeight=aWeight;
  invertWeight=flag;
    deformationFactor = deform;
    [self display];
}

/*
- (NSPoint)pointAtIndex:(int)index;
{
  double x,y;
  x = [[theWeight eventAt:i] doubleValueAt:0]-minX;
  y = [theWeight normWeightAt:i]-minWeight+wOffset;
  return NSMakePoint(x,y);
}
*/

- (NSBezierPath *)bottomPath;
{
  double x,y;
  int i;
  int c=[theWeight count];
  NSBezierPath *bPath=[NSBezierPath bezierPath];
  for (i=0; i<c; i++) {
    x = [[theWeight eventAt:i] doubleValueAt:0]-minX;
    y = [theWeight normWeightAt:i]-minWeight+wOffset;
    [bPath moveToPoint:NSMakePoint(x, 0.0)];
    [bPath lineToPoint:NSMakePoint(x, y)];
  }
  return bPath;
}

- (void)drawDim1NoDeformation;
/* efficient code */
{
  double x,y,x3=0.0, y3=0.0;
  int i;
  int c=[theWeight count];
//  double tol = [theWeight tolerance], minX = [theWeight minCoordinate:0]-tol;

  NSBezierPath *linePath=[NSBezierPath bezierPath];

  x = 0.0;
  y = 1.0-minWeight+wOffset;

  for (i=0; i<c; i++) {
      if (usePS) {
#ifdef WITH_PS
        PSmoveto (x/sz.width, y/sz.height);
#endif
      } else {
        [linePath moveToPoint:NSMakePoint(x, y)];
//                  [cirlePath moveToPoint:NSMakePoint(x/sz.width, y/sz.height)];
      }

      x3 = [[theWeight eventAt:i] doubleValueAt:0]-minX;
      y3 = [theWeight normWeightAt:i]-minWeight+wOffset;

      if (lineWidth) {
        if (usePS) {
#ifdef WITH_PS
          PScurveto ((x+(x3-x)/3)/sz.width, y/sz.height, (x3-(x3-x)/3)/sz.width, y3/sz.height, x3/sz.width, y3/sz.height);
          PSsetgray(NSBlack);
          PSsetlinewidth(lineWidth);
          PSstroke();
#endif
        } else {
          //          [linePath curveToPoint:NSMakePoint((x+(x3-x)/3)/sz.width, y/sz.height)
          //            controlPoint1:NSMakePoint((x3-(x3-x)/3)/sz.width, y3/sz.height)
          //            controlPoint2:NSMakePoint(x3/sz.width, y3/sz.height)];
          // jg: largest Point first!
          if (shouldDrawSplines)
            [linePath curveToPoint:NSMakePoint(x3, y3)
                   controlPoint1:NSMakePoint((x+(x3-x)/3), y)
                   controlPoint2:NSMakePoint((x3-(x3-x)/3), y3)];
//                    [[NSColor blackColor] set];
//                    [bPath setLineWidth:lineWidth];
//                    [bPath stroke];
        }
      }

      if (radius) { /* don't draw if radius = 0.0 */
        [self drawCircleAtX:x3 Y:y3];
      }
      x = x3;
      y = y3;
  } // for

  if (lineWidth) {
    // draw from last Point to end of View
      y3 = 1.0-minWeight+wOffset;
    if (usePS) {
#ifdef WITH_PS
      PSmoveto (x/sz.width, y/sz.height);
      PScurveto ((x+([self bounds].size.width-x)/3)/sz.width, y/sz.height,
              ([self bounds].size.width-([self bounds].size.width-x)/3)/sz.width, y3/sz.height,
              [self bounds].size.width/sz.width, y3/sz.height);
      PSsetgray(NSBlack);
      PSsetlinewidth(lineWidth);
      PSstroke();
#endif
    } else {
      [linePath moveToPoint:NSMakePoint(x, y)];
//      [linePath curveToPoint:NSMakePoint((x+([self bounds].size.width-x)/3)/sz.width, y/sz.height)
//        controlPoint1:NSMakePoint(
//              ([self bounds].size.width-([self bounds].size.width-x)/3)/sz.width, y3/sz.height)
//        controlPoint2:NSMakePoint([self bounds].size.width/sz.width, y3/sz.height)];
      // jg: largest Point first!
      if (shouldDrawSplines)
        [linePath curveToPoint:NSMakePoint(width, y3)
               controlPoint1:NSMakePoint((x+(width-x)/3), y)
               controlPoint2:NSMakePoint((width-(width-x)/3), y3)];
//                [[NSColor blackColor] set];
//                [bPath setLineWidth:lineWidth];
//                [bPath stroke];
    }
  }
  if (!usePS) {
    // make uncommented perform here
    [[self lineColor] set];
    [linePath transformUsingAffineTransform:transformation];
    [linePath setLineWidth:lineWidth];
    [linePath stroke];
    if (shouldDrawLines) {
      NSBezierPath *bPath=[self bottomPath];
      [bPath transformUsingAffineTransform:transformation];
      [bPath setLineWidth:lineWidth];
      [bPath stroke];      
    }
  }
}


- (double)weightValueAtEvent:(id)event;
{
  if (deformationFactor)
    return [theWeight splineAt:event deformation:deformationFactor];
  return [theWeight splineAt:event];
}

- (void)setCustomValues;
{
  double tol;
  [theWeight release];
  theWeight = myBDIndex!=-1 ? [[myWeight bDWeightTo:myBDIndex]retain] : [myWeight copy];
  if (invertWeight)
    [theWeight setInversion:invertWeight];

  if (theWeight) {
    tol=[theWeight tolerance];
    minX=[theWeight minCoordinate:0]-tol;
    minY = [theWeight minCoordinate:1]-tol;
    maxX = [theWeight maxCoordinate:0]+tol;
    maxY = [theWeight maxCoordinate:1]+tol;
    maxWeight = [theWeight highNorm];
    minWeight = [theWeight lowNorm];
  }
  meanLevel=[theWeight meanNormalizedWeight];
  // shift by (-minWeight + wOffset) done in drawRect;
//  minX=[myWeight originAt:(myBDIndex!=-1 ? myBDIndex : [myWeight indexOfDimension:1])]-[myWeight tolerance]; // ??
// jg is equivalent to
}

- (void)customDrawDim1;
{
  int i;
  int c=[theWeight count];
  double x,y;
  for (i=0; i<c; i++) {
      x = ([[theWeight eventAt:i] doubleValueAt:0]-minX);
      y = ([theWeight splineAt:[theWeight eventAt:i] deformation:deformationFactor]-minWeight+wOffset);

      [self drawCircleAtX:x Y:y];
  }
}

- (void)customDrawDim2;
{
  int x;
  int c=[theWeight count];
  for (x=0; x<c; x++) {
    id jEvent=[theWeight eventAt:x];
    [self drawCircleAtX:([jEvent doubleValueAt:0]-minX)
                      Y:([jEvent doubleValueAt:1]-minY)
              fillColor:1 - ([theWeight normWeightAt:x] - minWeight)*weightScaleFactor];
  }
}

- (void)drawDim1;
{
  if (!deformationFactor) { 
    [self drawDim1NoDeformation];
  } else {
    [super drawDim1];
  }
}

@end

#import "WeightyView.h"
#import <Foundation/NSDebug.h>

// enables Postscript code.
// iVar usePS switches this on.

@protocol WeightyViewScrollViewMenu
- (IBAction)setMenuWithJGScrollViewControllerActions:(id)sender;
@end


@implementation WeightyView

static NSColor *backgroundColor,*lineColor,*circleColor,*circleColor,*circleFillColor,*circleBorderColor;
static NSColor *meanLevelColor,*gridColor,*rectColor,*rectBorderColor;
static float borderWidth=0.3;

+ (void)initColors;
{
backgroundColor=[[NSColor whiteColor] retain];
lineColor=[[NSColor blackColor] retain];
circleColor=[[NSColor blackColor] retain];
circleFillColor=[[NSColor blackColor] retain]; // with fraction
circleBorderColor=[[NSColor blackColor] retain];
meanLevelColor=[[[NSColor blueColor] colorWithAlphaComponent:0.5] retain];
gridColor=[[[NSColor redColor] colorWithAlphaComponent:0.5] retain];
rectColor=[[NSColor blackColor] retain];
rectBorderColor=[[NSColor blackColor] retain];
}
#define DEFINE_METHOD(x) -(NSColor *)x; {return x;}
DEFINE_METHOD(backgroundColor)
DEFINE_METHOD(lineColor)
DEFINE_METHOD(circleColor)
DEFINE_METHOD(circleFillColor)
DEFINE_METHOD(circleBorderColor)
DEFINE_METHOD(meanLevelColor)
DEFINE_METHOD(gridColor)
DEFINE_METHOD(rectColor)
DEFINE_METHOD(rectBorderColor)
+ (void)setBorderWidth:(float)w;
{ borderWidth=w;
}
- (float)borderWidth;
{
  return borderWidth;
}

- initWithFrame:(NSRect)frameRect;
{
    if (!backgroundColor) 
      [WeightyView initColors];
    [super initWithFrame:frameRect];
    myConverter = [[StringConverter alloc]init];
    theWeight=nil;
    anEvent=nil;
    myBDIndex = 0 /*-1*/;
    usePS=0;
    transformation=nil;
    inverseTransformation=nil;
    if ([self respondsToSelector:@selector(setMenuWithJGScrollViewControllerActions:)])
      [(id)self setMenuWithJGScrollViewControllerActions:nil]; // see JGScrollViewController
    return self;
}

- (void)dealloc;
{
  [transformation release];
  [inverseTransformation release];
    [myConverter release];
    [theWeight release];
    [anEvent release];
    [super dealloc];
}

- (void)doRedraw:sender;
{
    [self display];
}

- (NSAffineTransform*) transformation
{
	return transformation;
}

- (void) setTransformation:(NSAffineTransform*)newTransformation
{
	[newTransformation retain];
	[transformation release];
	transformation = newTransformation;
}


- (NSAffineTransform*) inverseTransformation
{
	return inverseTransformation;
}

- (void) setInverseTransformation:(NSAffineTransform*)newInverseTransformation
{
	[newInverseTransformation retain];
	[inverseTransformation release];
	inverseTransformation = newInverseTransformation;
}



- (void)drawFrame;
{
//    [self sizeBy:4.0 :4.0];
//    [self moveBy:-2.0 :-2.0];
//    NSDrawGrayBezel([self bounds] , [self bounds]);
//    [self sizeBy:-4.0 :-4.0];
//    [self moveBy:2.0 :2.0];
  if (usePS) {
    [self setBoundsSize:NSMakeSize([self frame].size.width, [self frame].size.height)];
#ifdef WITH_PS
    PSsetgray(NSWhite);
#endif
  } else
      [backgroundColor set];
    NSRectFill([self bounds]);
}

- (void)drawCircleAtX:(double)x Y:(double)y;
{
  if (usePS) {
#ifdef WITH_PS
    PSsetgray(NSBlack);

    PSnewpath();
    PSarc(x/sz.width, y/sz.height, radius, 0.0, 360.0);
    PSclosepath();
    PSfill();
#endif
  } else {
    NSBezierPath *circlePath=[NSBezierPath bezierPath];
    [circleColor set];
    [circlePath appendBezierPathWithArcWithCenter:
                                      [transformation transformPoint:NSMakePoint(x, y)]
                                      radius:radius
                                   startAngle:0.0
                                    endAngle:360.0];
    [circlePath closePath];
    [circlePath fill];
  }
}

- (void)drawCircleAtX:(double)x Y:(double)y fillColor:(double)c;
{
  if (usePS) {
#ifdef WITH_PS
    PSnewpath();
    PSarc(x/sz.width, y/sz.height, radius, 0.0, 360.0);
    PSsetgray(c);
    PSclosepath();
    PSgsave();
    PSfill();
    PSgrestore();
    PSsetgray(NSBlack);
    PSsetlinewidth(0.1);
    PSstroke();
#endif
  } else {
    NSBezierPath *circlePath=[NSBezierPath bezierPath];
    [circlePath appendBezierPathWithArcWithCenter:
                                      [transformation transformPoint:NSMakePoint(x, y)]
                                      radius:radius
                                   startAngle:0.0
                                    endAngle:360.0];
//    [[NSColor colorWithCalibratedWhite:c alpha:1.0] set];
    [[circleFillColor blendedColorWithFraction:c ofColor:backgroundColor] set];
    [circlePath closePath];
    [circlePath fill];
    [circleBorderColor set];
    [circlePath setLineWidth:[self borderWidth]];
    [circlePath stroke];
  }
}

- (void)valuesFromFields;
{
  radius = myRadiusField ?
      [myRadiusField doubleValue] : 1.0;
  lineWidth = myLineWidthField ?
      [myLineWidthField doubleValue] : 0.1;
  shouldDrawMeanLevel=[myMeanLevelSwitch state];
  shouldDrawGrid=[myGridSwitch state];
  shouldDrawLines=[drawLinesSwitch state];
  shouldDrawSplines=[drawSplinesSwitch state];
  [myConverter setStringValue:[myGridOriginField stringValue]];
  theGrid.origin = [myConverter doubleValue]-minX;
  [myConverter setStringValue:[myGridMeshField stringValue]];
  theGrid.mesh = [myConverter fractValue];

  //jg: was oz
  //    myBDIndex = [[[myBoildDownPopUp target]itemList]selectedCell] ?
  //                                [[[[myBoildDownPopUp target]itemList]selectedCell]tag] : 0 /*-1*/;
  //jg: second was:   myBDIndex = [myBoildDownPopUp indexOfSelectedItem]; // if nothing selected, return -1
  //    if (myBDIndex==-1) myBDIndex=0; // jg:is this reasonable? simillar comment in original source code
  // first guess: it should always be selekted something. Even if it is with tag -1 (no projection).
  // but: no projection offen takes too long with complex Weights, because the space is parketted at lineWidth>0. 
  // Thats why we let it at 0 (projection to E)
  myBDIndex=[myBoildDownPopUp selectedItem] ?
    [[myBoildDownPopUp selectedItem] tag] : 0; // if myBoildDownPopUp does not exist, -1 (no projection)
}


- (void)setTransformations;
{
  if (usePS) {
    static int setBounds=1;
    if (setBounds) {
      [self setBoundsSize:NSMakeSize(width, height)];
      [self setBoundsOrigin:NSMakePoint(0.0, 0.0)];
    }
  } else {
    NSSize s;
    static int setBounds=0;
    if (setBounds) {
      [self setBoundsSize:NSMakeSize(width, height)];
      [self setBoundsOrigin:NSMakePoint(0.0, 0.0)];
    }
    s=[self bounds].size;
    [self setTransformation:[NSAffineTransform transform]];
    [self setInverseTransformation:[NSAffineTransform transform]];
    [transformation scaleXBy:s.width/width yBy:s.height/height];
    [inverseTransformation scaleXBy:width/s.width yBy:height/s.height];
  }
}

- (void)calcDrawSize;
/*" initialization method for everything in drawRect.
    Sets bounds with maxX, minX, maxY, minY, maxWeight, minWeight, that can be set by -setCustomValues "*/
{
  double weight; 
  if ([self weightExists]) {
    width = maxX - minX;
    weight = maxWeight-minWeight;

    if ([self weightDimension]==1) {
        height = weight;
        height +=(minWeight>1.0 ? minWeight-1.0 : (maxWeight<1.0 ? 1.0-maxWeight : 0.0));
    } else {
        height = maxY - minY;
    }
  } else {
        width=0.0, height=0.0, weight=1.0;
  }

  width = width>(double)LONG_MAX ? (double)LONG_MAX : (width>0.0 ? width : 1.0);
  height = height>(double)LONG_MAX ? (double)LONG_MAX : (height>0.0 ? height : 1.0);
  weightScaleFactor = weight ? 1/weight : 1.0;

  [self setTransformations];
}

- (void)drawMeanLevel;
{
  /* this is the new code using PostScript for drawing the spline */
    // draw the mean level line
//          y = [theWeight meanNormalizedWeight]-[theWeight lowNorm] + wOffset;
    if (usePS) {
#ifdef WITH_PS
      // scaling is done external in drawRect
      PSsetgray(NSLightGray);
      PSsetlinewidth(1.0);
      PSmoveto (0.0, meanLevel/sz.height);
      PSlineto ([self bounds].size.width/sz.width, meanLevel/sz.height);
      PSstroke();
#endif
    } else {
      NSBezierPath *bPath=[NSBezierPath bezierPath];
      [meanLevelColor set];
      [bPath setLineWidth:1.0];
      [bPath moveToPoint:NSMakePoint(0.0, meanLevel)];
      [bPath lineToPoint:NSMakePoint(width, meanLevel)];
      [bPath transformUsingAffineTransform:transformation];
      [bPath stroke];
    }
}

- (void)drawGrid;
  /*" ???theGrid coordinates visual or virtual ?"*/
{
    double gridPos = 0, gridWidth = 0;
    NSBezierPath *linePath=[NSBezierPath bezierPath];

    gridWidth = theGrid.mesh.isFraction&&theGrid.mesh.denominator ?
                                theGrid.mesh.numerator/theGrid.mesh.denominator :
                                        (theGrid.mesh.numerator ? theGrid.mesh.numerator : 1.0);

    if (usePS) {
#ifdef WITH_PS
      PSsetgray(NSLightGray);
      gridPos += theGrid.origin;
      while (gridPos < [self bounds].size.width) {
          PSmoveto(gridPos, 0.0);
          PSlineto(gridPos, [self bounds].size.height);
        gridPos += gridWidth;
      }
      PSscale (sz.width, sz.height);
      PSsetlinewidth(1.0);
      PSstroke();
      PSscale (1/sz.width, 1/sz.height);
#endif
    } else {
      [gridColor set];
      gridPos += theGrid.origin;
      while (gridPos < width){
          [linePath moveToPoint:NSMakePoint(gridPos,0.0)]; // virtual points 
          [linePath lineToPoint:NSMakePoint(gridPos, height)];
          gridPos += gridWidth;
      }

      [linePath transformUsingAffineTransform:transformation]; // visual points
      [linePath setLineWidth:lineWidth]; // jg 26.04.2002: changed from 1.0 
      [linePath stroke];
    }
}

- (void)drawDim1;
{
//  double tol = [theWeight tolerance], minX = [theWeight minCoordinate:0]-tol;
  NSBezierPath *linePath=[NSBezierPath bezierPath];

  if (lineWidth) {
      /* this is the old drawing code which uses the calculated
          * spline instead of the PostScript drawing command.
          */
    double x; // visual coordinate
      [anEvent setDoubleValue:minX at:0]; // why? is overridden in for(x)
      if (usePS) {
#ifdef WITH_PS
        PSmoveto (0.0, ([self weightValueAtEvent:anEvent]-minWeight+wOffset)/sz.height);
        for (x=0; x<[self bounds].size.width/sz.width; x=x+lineWidth){
            [anEvent setDoubleValue:x*sz.width+minX at:0];
            PSlineto (x, ([self weightValueAtEvent:anEvent]-minWeight+wOffset)/sz.height);
        }
        PSsetgray(NSBlack);
        PSsetlinewidth(lineWidth);
        PSstroke();
#endif
      } else {
        [linePath moveToPoint:NSMakePoint(0.0, ([self weightValueAtEvent:anEvent]-minWeight+wOffset))];
        for (x=0; x<[self bounds].size.width; x=x+lineWidth){ // ??? lineWidth steps? should better be stepWidth
          NSPoint p=[inverseTransformation transformPoint:NSMakePoint(x,0.0)];
          [anEvent setDoubleValue:p.x+minX at:0];
          [linePath lineToPoint:NSMakePoint(p.x, ([self weightValueAtEvent:anEvent]-minWeight+wOffset))];
        }
        [linePath transformUsingAffineTransform:transformation];
        [lineColor set];
        [linePath setLineWidth:lineWidth];
        [linePath stroke];
      }
  }
  if (radius) { /* don't draw if radius = 0.0 */
    [circleColor set]; // instead of setting color repeatedly in loop
    [self customDrawDim1];
  }
}


- (void)drawDim2;
{
//  double tol = [theWeight tolerance], minX = [theWeight minCoordinate:0]-tol, minY = [theWeight minCoordinate:1];

  
  if (lineWidth) { // this takes real long
    double x,y,endx,endy,stepx, stepy; // visual coordinates
      double weight;
      stepx=lineWidth; // visually increase by lineWidth
      stepy=lineWidth; // ??? make these configurable by using instance variable e.g. stepWidth ?

    if (usePS) {
#ifdef WITH_PS
      endx=[self bounds].size.width/sz.width-stepx;
      endy=[self bounds].size.height/sz.height-stepy;
      PSmoveto(0.0, 0.0);
      for (x=0; x<endx; x+=stepx){
        NSEvent *theEvent;
          theEvent = [[self window] nextEventMatchingMask:(int)NSKeyDownMask untilDate:[NSDate dateWithTimeIntervalSinceNow:0.0] inMode:NSEventTrackingRunLoopMode dequeue:YES];
          if (theEvent && [theEvent modifierFlags] & NSCommandKeyMask && [[theEvent charactersIgnoringModifiers] isEqual:@"."])
                  break;
          for (y=0; y<endy; y+=stepy){
              [anEvent setDoubleValue:x*sz.width+minX at:0];
              [anEvent setDoubleValue:y*sz.height+minY at:1];

              weight = [self weightValueAtEvent:anEvent] - minWeight;
              // print Points as small rects, no lines
              PSsetgray(weight*weightScaleFactor);
              PSrectfill(x, y, x+lineWidth, y+lineWidth); // ??? maybe wrong (see below)
          }
      }
#endif
    } else {
      endx=[self bounds].size.width-stepx;
      endy=[self bounds].size.height-stepy;
      for (x=0; x<endx; x+=stepx){
        NSEvent *theEvent;
        if (NSDebugEnabled) NSLog(@"%f of %f, press cmd-. to stop",x,endx);
          theEvent = [[self window] nextEventMatchingMask:(int)NSKeyDownMask untilDate:[NSDate dateWithTimeIntervalSinceNow:0.0] inMode:NSEventTrackingRunLoopMode dequeue:YES];
          if (theEvent && [theEvent modifierFlags] & NSCommandKeyMask && [[theEvent charactersIgnoringModifiers] isEqual:@"."])
                  break;
          for (y=0; y<endy; y+=stepy){
            NSPoint p=[inverseTransformation transformPoint:NSMakePoint(x,y)];
              [anEvent setDoubleValue:p.x+minX at:0];
              [anEvent setDoubleValue:p.y+minY at:1];

              weight = [self weightValueAtEvent:anEvent] - minWeight;
              // print Points as small rects, no lines
                // 1.0 means non transparent. intended?
//              [[NSColor colorWithCalibratedWhite:weight*weightScaleFactor alpha:1.0] set];
              [[rectColor blendedColorWithFraction:weight*weightScaleFactor ofColor:backgroundColor] set];
              [NSBezierPath fillRect:NSMakeRect(x, y, stepx, stepx)]; // modified
          }
      }
    } // if (usePS) else
  } // if lineWidth

  if (radius) { /* don't draw if radius = 0.0 */
    [self customDrawDim2];
  }
}

- (void)drawContent;
  /*" initializes anEvent according to [self weightSpace] and calls drawMeanLevel and drawDim1 or drawDim2 "*/
{
    [anEvent release];
    anEvent = [[[MatrixEvent alloc]init]setSpaceTo:[self weightSpace]];
    wOffset = (minWeight>1.0 ? minWeight-1.0 : 0.0);
    meanLevel = meanLevel-minWeight+wOffset;

    // for what is this good? found in old WeightWatcherView
    [anEvent setDoubleValue:minX-1.0 at:0]; // value beyond all limits, i.e. in normalizedMean range

    if ([self weightDimension]==1 && shouldDrawMeanLevel)
      [self drawMeanLevel];
    if ([self weightDimension]==1) {
      [self drawDim1];
    } else if ([self weightDimension]==2) {
      [self drawDim2];
    }
}

- (void)drawRect:(NSRect)rects;
  /*" Setup sizes (lines, radius, scaling) and calls drawFrame, drawContent, drawGrid "*/
{
//    id theWeight;
  static BOOL doScale=YES; // test, if this affects something
    sz = NSMakeSize(1.0, 1.0);

    [self drawFrame];
    [self valuesFromFields];
    [self setCustomValues];
    [self calcDrawSize];

    if ([self weightCount]>0) {
      sz = [self convertSize:sz fromView:nil];
      sz.width = sz.width ? sz.width : 1.0;
      sz.height = sz.height ? sz.height : 1.0;

      if (doScale && usePS) {
#ifdef WITH_PS
        PSscale (sz.width, sz.height);
#endif
      }

      [self drawContent]; // 

      if (doScale && usePS) {
#ifdef WITH_PS
          PSscale (1/sz.width, 1/sz.height);
#endif
        }
      
      if (shouldDrawGrid)
          [self drawGrid];
    }
}

- (BOOL)weightExists;
{
  if (theWeight)
    return YES;
  else
    return NO;
}
- (spaceIndex)weightSpace;
{
  return [theWeight space];
}
- (int)weightDimension;
{
  return [theWeight dimension];
}
- (unsigned int)weightCount;
/*" Gives the number of Points to be drawn. "*/
{
  return [theWeight count];
}
- (double)weightValueAtEvent:(id)event;
{
  return 0.0;
}
- (void)setCustomValues;
{}
- (void)customDrawDim1;
{}
- (void)customDrawDim2;
{}

@end
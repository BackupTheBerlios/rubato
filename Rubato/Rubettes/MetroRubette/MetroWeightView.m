
#import "MetroWeightView.h"
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Foundation/NSDebug.h>

@implementation MetroWeightView

- initWithFrame:(NSRect)frameRect;
{
    [super initWithFrame:frameRect];
//    myConverter = [[StringConverter alloc]init];
    return self;
}

- (void)dealloc;
{
//    [myConverter release]; myConverter = nil;
    [super dealloc];
}

- doWeightRedraw:sender;
{
    [self display];
    return self;    
}


- displayWeightList:(weightList)aWeightList;
{
    theWeightList = aWeightList;
    [self display];
    return self;
}

- (void)calcDrawSize;
{
    size_t i;
  width=0.0;
  height=0.0; 
    if (theWeightList.wP && theWeightList.length) {
	for (i=0; i<theWeightList.length; i++)
	    width = width<theWeightList.wP[i].param ? theWeightList.wP[i].param : width;
	for (i=0; i<theWeightList.length; i++)
	    height = height<theWeightList.wP[i].weight ? theWeightList.wP[i].weight : height;
    }
    width = width>INT_MAX ? INT_MAX : (width>0.0 ? width+width/theWeightList.length : 1.0);
    height = height>INT_MAX ? INT_MAX : (height>0.0 ? height*1.1 : 1.0);

    [self setTransformations];
}

// for debug 1: scale in MetroView::drawRect 2:in drawContent.
// 0: scaling is done in WeightyView::drawRect
static int scaleContentIndex=0;

- (void)drawRect:(NSRect)rects // for Debug
{
  static BOOL useSuper=YES;
  static BOOL debugit,initDebug=YES;
    double gridPos = 0, gridWidth = 0;
    if (initDebug) {
      debugit=NSDebugEnabled;
      initDebug=NO;
    }  
    sz = NSMakeSize(1.0, 1.0);

    if (useSuper) { 
      // disable all code here.
      scaleContentIndex=0;
      [super drawRect:rects];
      return;
    } else {
      if (scaleContentIndex==0)
        scaleContentIndex=2; // 2 funktioniert, 1 nicht!
      usePS=1;
    }

    [myConverter setStringValue:[myGridOriginField stringValue]];
    theGrid.origin = [myConverter doubleValue];
    [myConverter setStringValue:[myGridMeshField stringValue]];
    theGrid.mesh = [myConverter fractValue];
    
    gridWidth = theGrid.mesh.isFraction&&theGrid.mesh.denominator ?
    				theGrid.mesh.numerator/theGrid.mesh.denominator : 
					(theGrid.mesh.numerator ? theGrid.mesh.numerator : 1.0);

// drawFrame begin
    if (debugit) {
      NSSize s = [self convertSize:sz fromView:nil];
      NSLog(@"sz before %f %f %f %f",s.width, s.height, [self bounds].size.width,[self bounds].size.height);
    }
    [self setBoundsSize:NSMakeSize([self frame].size.width, [self frame].size.height)];
    if (debugit) {
      NSSize s = [self convertSize:sz fromView:nil];
      NSLog(@"sz after %f %f %f %f",s.width, s.height, [self bounds].size.width,[self bounds].size.height);
    }
//    [self sizeBy:4.0 :4.0];
//    [self moveBy:-2.0 :-2.0];
    NSDrawGrayBezel([self bounds] , [self bounds]);
//    [self sizeBy:-4.0 :-4.0];
//    [self moveBy:2.0 :2.0];
#ifdef WITH_PS
    PSsetgray(NSWhite);
#else
  [[self backgroundColor] set];
#endif
    NSRectFill([self bounds]);
// drawFrame end


    [self calcDrawSize]; // sets the size of the virtual draw-plane (effects internal coordinate system)
    if (debugit) NSLog(@"bounds after calcDrawSize %f %f",[self bounds].size.width,[self bounds].size.height);
    if (theWeightList.length && theWeightList.wP) {

	sz = [self convertSize:sz fromView:nil]; // sz is the physical size of a unit square
        if (debugit) NSLog(@"sz after calcDrawSize %f %f",sz.width,sz.height);
  
// drawGrid
#ifdef WITH_PS
	PSsetgray(NSLightGray);
#else
  [[self gridColor] set];
#endif
	gridPos += theGrid.origin;
	while (gridPos < [self bounds].size.width){
#ifdef WITH_PS
	    PSmoveto(gridPos, 0.0);
	    PSlineto(gridPos, [self bounds].size.height);
#endif
	    gridPos += gridWidth;
	}
	
#ifdef WITH_PS
	PSscale (sz.width, sz.height);
	PSsetlinewidth(1.0);
	PSstroke();
	PSscale (1/sz.width, 1/sz.height);
	
        if (scaleContentIndex==1)
          PSscale (sz.width, sz.height);
#endif
        [self drawContent];
#ifdef WITH_PS
        if (scaleContentIndex==1)
  	  PSscale (1/sz.width, 1/sz.height);
#endif
    }
}

- (void)valuesFromFields;
{
  static BOOL staticShouldDrawGrid=YES;
  [super valuesFromFields];
  shouldDrawGrid=staticShouldDrawGrid;
}

- (void)drawContent;
{
  size_t i;
  if (usePS) {
#ifdef WITH_PS
    PSsetgray(NSBlack);
    for (i=0; i<theWeightList.length; i++){
       PSmoveto(theWeightList.wP[i].param, 0.0);
        PSlineto(theWeightList.wP[i].param, theWeightList.wP[i].weight);
    }
    if (scaleContentIndex==2)
      PSscale (sz.width, sz.height);
    PSsetlinewidth([myLineWidthField doubleValue]);
    PSstroke();
#endif
  } else {
    NSBezierPath *bPath=[NSBezierPath bezierPath];
    [[self lineColor] set];
    for (i=0; i<theWeightList.length; i++) {
      [bPath moveToPoint:NSMakePoint(theWeightList.wP[i].param, 0.0)];
      [bPath lineToPoint:NSMakePoint(theWeightList.wP[i].param, theWeightList.wP[i].weight)];
    }
    [bPath transformUsingAffineTransform:transformation];
    [bPath setLineWidth:lineWidth];
    [bPath stroke];
  }
}
  
- (int)weightCount;
{
  if (theWeightList.wP)
    return theWeightList.length;
  else
    return 0;
}


@end

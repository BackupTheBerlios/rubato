/* MeloWeightView.m */


#import "MeloWeightView.h"

#import <RubatoDeprecatedCommonKit/commonkit.h>

@implementation MeloWeightView
// static     M2D_weightPoint wP[] = {{0.125, 64, 0.2}, {0.25, 66, 0.5}, {0.375, 68, 1.0}, {0.625, 64, 0.6}, {1.125, 69, 0.8}};


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


- displayWeightList:(M2D_weightList)aWeightList;
{
    theWeightList = aWeightList;// (M2D_weightList){wP, 5};
    [self display];
    return self;
}

- (void)calcDrawSize;
{
    size_t i;
    double weight=1.0;
    width=0.0;
    height=0.0;
    if (theWeightList.M2D_wP && theWeightList.length) {
	for (i=0; i<theWeightList.length; i++) {
	    width = width<theWeightList.M2D_wP[i].M2D_Pt.para1 ? theWeightList.M2D_wP[i].M2D_Pt.para1 : width;
	    height = height<theWeightList.M2D_wP[i].M2D_Pt.para2 ? theWeightList.M2D_wP[i].M2D_Pt.para2 : height;
	    weight = weight<theWeightList.M2D_wP[i].weight ? theWeightList.M2D_wP[i].weight : weight;
	}
    }
    width = width>INT_MAX ? INT_MAX : (width>0.0 ? width+width/theWeightList.length : 1.0);
    height = height>INT_MAX ? INT_MAX : (height>0.0 ? height*1.1 : 1.0);
    weightScaleFactor = weight ? 1/weight : 1.0;

    [self setTransformations];
}

/*
- (void)drawRect:(NSRect)rects
{
    size_t i;
    NSSize sz = {1.0, 1.0};
    double radius, lineWidth;
    radius = myRadiusField ?
	[myRadiusField doubleValue] : 1.0; 
    lineWidth = myLineWidthField ?
	[myLineWidthField doubleValue] : 0.1;

    [self drawFrame];
    [self calcDrawSize];
    if (theWeightList.length && theWeightList.M2D_wP) {

	sz = [self convertSize:sz fromView:nil];

	[self drawGrid];

	PSscale (sz.width, sz.height);

        [self drawContent];
        PSscale (1/sz.width, 1/sz.height);
    }
}
*/
- (void)drawContent;
{
  int i;
	for (i=0; i<theWeightList.length; i++){
	    if (lineWidth) { /* don't draw if lineWidth = 0.0 */
              if (usePS) {
#ifdef WITH_PS
		PSsetgray(NSBlack);
		PSmoveto(theWeightList.M2D_wP[i].M2D_Pt.para1/sz.width, 0.0);
		PSlineto(theWeightList.M2D_wP[i].M2D_Pt.para1/sz.width,
			    theWeightList.M2D_wP[i].M2D_Pt.para2/sz.height);
		PSsetlinewidth(lineWidth);
		PSstroke();
#endif
              } else {
                NSBezierPath *bPath=[NSBezierPath bezierPath];
                [[self lineColor] set];
                [bPath moveToPoint:NSMakePoint(theWeightList.M2D_wP[i].M2D_Pt.para1, 0.0)];
                [bPath lineToPoint:NSMakePoint(theWeightList.M2D_wP[i].M2D_Pt.para1,
                                               theWeightList.M2D_wP[i].M2D_Pt.para2)];
                [bPath transformUsingAffineTransform:transformation];
                [bPath setLineWidth:lineWidth];
                [bPath stroke];
              }
	    }
	    
	    if (radius) { /* don't draw if radius = 0.0 */
              [self drawCircleAtX:theWeightList.M2D_wP[i].M2D_Pt.para1 Y:theWeightList.M2D_wP[i].M2D_Pt.para2 fillColor:(1-(theWeightList.M2D_wP[i].weight * weightScaleFactor))];
	    }
  }
}
- (int)weightCount;
{
  if (theWeightList.M2D_wP)
    return theWeightList.length;
  else
    return 0;
}

/*
- drawGrid;
{
    double gridPos = 0, gridWidth = 0;
    NSSize sz = {1.0, 1.0};

    [myConverter setStringValue:[myGridOriginField stringValue]];
    theGrid.origin = [myConverter doubleValue];
    [myConverter setStringValue:[myGridMeshField stringValue]];
    theGrid.mesh = [myConverter fractValue];
    
    gridWidth = theGrid.mesh.isFraction&&theGrid.mesh.denominator ?
    				theGrid.mesh.numerator/theGrid.mesh.denominator : 
					(theGrid.mesh.numerator ? theGrid.mesh.numerator : 1.0);

    sz = [self convertSize:sz fromView:nil];

    PSsetgray(NSLightGray);
    gridPos += theGrid.origin;
    while (gridPos < [self bounds].size.width){
	PSmoveto(gridPos, 0.0);
	PSlineto(gridPos, [self bounds].size.height);
	gridPos += gridWidth;
    }
    
    PSscale (sz.width, sz.height);
    PSsetlinewidth(1.0);
    PSstroke();
    PSscale (1/sz.width, 1/sz.height);

    return self;
}

- drawFrame;
{
    [self setBoundsSize:NSMakeSize([self frame].size.width, [self frame].size.height)];
//    [self sizeBy:4.0 :4.0];
//    [self moveBy:-2.0 :-2.0];
    NSDrawGrayBezel([self bounds] , [self bounds]);
//    [self sizeBy:-4.0 :-4.0];
//    [self moveBy:2.0 :2.0];
    PSsetgray(NSWhite);
    NSRectFill([self bounds]);

    return self;
}
*/
@end

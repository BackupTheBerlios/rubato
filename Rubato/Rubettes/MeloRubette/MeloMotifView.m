/* MeloMotifView.m */

#import <RubatoDeprecatedCommonKit/commonkit.h>

#import "MeloMotifView.h"

@implementation MeloMotifView

- initWithFrame:(NSRect)frameRect;
{
    [super initWithFrame:frameRect];
    pitchSpan = 128;
    pitchLow = 0.0;
//    myConverter = [[StringConverter alloc]init];
    return self;
}

- (void)dealloc;
{
//    [myConverter release]; myConverter = nil;
    [super dealloc];
}

- takePitchSpanFrom:sender;
{
    if ([sender respondsToSelector:@selector(doubleValue)]) {
	[self setPitchSpanTo:[sender doubleValue]];
    }
    return self;
}

- takePitchLowFrom:sender;
{
    if ([sender respondsToSelector:@selector(doubleValue)]) {
	[self setPitchLowTo:[sender doubleValue]];
    }
    return self;
}

- setPitchSpanTo:(double)aDouble;
{
    pitchSpan = aDouble;
    [self doMotifRedraw:self];
    return self;
}

- setPitchLowTo:(double)aDouble;
{
    pitchLow = aDouble;
    [self doMotifRedraw:self];
    return self;
}

- doMotifRedraw:sender;
{
    [self display];
    return self;    
}


- displayMotif:(M2D_compList)aMotif;
{
    theMotif = aMotif;
    [myMotifContentField setDoubleValue:theMotif.content];
    [myMotifPresenceField setDoubleValue:theMotif.presence];
    [myMotifWeightField setDoubleValue:theMotif.weight];
    [myMotifOnsetField setDoubleValue:theMotif.M2D_comp[0].para1];
    [self display];
    return self;
}

- (void)calcDrawSize;
{
    if (theMotif.M2D_comp && theMotif.length) {
	width = fabs([myMotifSpanField doubleValue]);
	height = fabs(pitchSpan);
	width = width ? width : 1.0;	
	height = height ? height : 1.0;	
	
        [self setTransformations];
    }
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
    

    if (theMotif.M2D_comp && theMotif.length) {
	[self drawGrid];

	sz = [self convertSize:sz fromView:nil];

	PSscale (sz.width, sz.height);
        [self drawContent];
        PSscale (1/sz.width, 1/sz.height);
    }
}
*/

- (void)drawContent;
{
  int i;
  double xOffset = theMotif.M2D_comp[0].para1;

	if (lineWidth) { // don't draw if lineWidth = 0.0 
	    for (i=0; i<theMotif.length-1; i++){
              if (usePS) {
#ifdef WITH_PS
		PSsetgray(NSLightGray);
		PSmoveto((theMotif.M2D_comp[i].para1-xOffset)/sz.width,
			 (theMotif.M2D_comp[i].para2-pitchLow)/sz.height);
		PSlineto((theMotif.M2D_comp[i+1].para1-xOffset)/sz.width,
			 (theMotif.M2D_comp[i+1].para2-pitchLow)/sz.height);
		PSsetlinewidth(lineWidth);
		PSstroke();
#endif
              } else {
                NSBezierPath *bPath=[NSBezierPath bezierPath];
                [[NSColor lightGrayColor] set];
                [bPath moveToPoint:NSMakePoint((theMotif.M2D_comp[i].para1-xOffset),
                                               (theMotif.M2D_comp[i].para2-pitchLow))];
                [bPath lineToPoint:NSMakePoint((theMotif.M2D_comp[i+1].para1-xOffset),
                                               (theMotif.M2D_comp[i+1].para2-pitchLow))];
                [bPath transformUsingAffineTransform:transformation];
                [bPath setLineWidth:lineWidth];
                [bPath stroke];
              }
	    }
	}
	    
	if (radius) { /* don't draw if radius = 0.0 */
	    for (i=0; i<theMotif.length; i++){
		[self drawCircleAtX:(theMotif.M2D_comp[i].para1-xOffset)
                    Y:(theMotif.M2D_comp[i].para2-pitchLow)];
	    }
	}	
}

- (int)weightCount;
{
  if (theMotif.M2D_comp)
    return theMotif.length;
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

/* KernelView.m */

#import <Rubato/RubatoTypes.h>
#import <Rubette/MatrixEvent.h>
#import <PerformanceScore/LocalPerformanceScore.h>

#import "KernelView.h"

@implementation KernelView


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


- (void)doRedraw:sender;
{
  [self setNeedsDisplay:YES];
}


- sizeViewToKernel:sender;
{
    [self calcKernelFrame];
    [self setNeedsDisplay:YES];
    return self;
}

- sizeViewToFrame:sender;
{
    [self setKernelFrame:myFrameMatrix];
    [self setNeedsDisplay:YES];
    return self;
}

- setKernelFrame:sender;
{
    int i;
  if ([sender isKindOfClassNamed:"LocalPerformanceScore"]) {
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    myKernelFrame[i] = (LPS_Frame) *[sender frameAt:i]; // Methode aus PerformanceScore.subproj (nur hier benutzt, sonst nirgends.
	    [[myFrameMatrix cellAtRow:i column:0] setDoubleValue:myKernelFrame[i].origin];
	    [[myFrameMatrix cellAtRow:i column:1] setDoubleValue:myKernelFrame[i].end];
	}
    }
    if (sender=myFrameMatrix) {
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    myKernelFrame[i].origin = [[myFrameMatrix cellAtRow:i column:0]doubleValue];
	    myKernelFrame[i].end = [[myFrameMatrix cellAtRow:i column:1]doubleValue];
	}
    }
    return self;
}

- displayEventList:anEventList;
{
    if (myEventList != anEventList) {
	[myEventList release];
	myEventList = anEventList;
	[myEventList ref];
        [self setNeedsDisplay:YES];
    }
    return self;
}

- calcKernelFrame;
{
    int i, j, c;
    id event;
    double val = 0.0, evi = 0.0, evipia = 0.0; /*evi resp. evipia is the basis resp. the pianola coordinate of index i */
    
    if (c=[myEventList count]) {
	for (j=0; j<c; j++) {
	    event = [myEventList objectAt:j];
            if ([event isKindOfClass:NSClassFromString(@"MathMatrix")]) {
		for(i=0; i<3; i++){
		    evi = [event doubleValueAtIndex:i];
		    evipia = [event doubleValueAtIndex:i+3];
		    myKernelFrame[i].origin =
			myKernelFrame[i].origin < (val=(evi<evi + evipia ? evi : evi+evipia)) ? myKernelFrame[i].origin : val;
		    myKernelFrame[i].end =
			myKernelFrame[i].end > (val=(evi>evi + evipia ? evi : evi+evipia)) ? myKernelFrame[i].end : val;
		    myKernelFrame[i+3].origin = 
			myKernelFrame[i+3].origin < evipia ? myKernelFrame[i+3].origin : evipia;
		    myKernelFrame[i+3].end = 
			myKernelFrame[i+3].end > evipia ? myKernelFrame[i+3].end : evipia;
	    
		}
	    }
	}
    }
    return self;
}

- (BOOL)frameContains:event;
{
    int i;
    double evi = 0.0, evipia = 0.0; /*evi resp. evipia is the basis resp. the pianola coordinate of index i */
    
    if(![event dimension])
	return NO; /* don't accept 0 dimensional Events */

    for(i=0; i<MAX_SPACE_DIMENSION; i++){
	if([event spaceAt:i]){
	    evi = [event doubleValueAtIndex:i];
	    evipia = (i+3 < MAX_SPACE_DIMENSION) ? [event doubleValueAtIndex:i+3] : 0.0;
	    if(!(myKernelFrame[i].origin <= (evi<evi + evipia ? evi : evi + evipia) && 
		    (evi<evi + evipia ? evi : evi + evipia) <= myKernelFrame[i].end))
		return NO;
	}
    }
    return YES;
}

- (void)calcDrawSize;
{
    double weight=1.0; // width=0.0, height=0.0, 

    width = myKernelFrame[indexE].end - myKernelFrame[indexE].origin;
    height = myKernelFrame[indexH].end - myKernelFrame[indexH].origin;
    weight = myKernelFrame[indexL].end - myKernelFrame[indexL].origin;

    width = width>LONG_MAX ? LONG_MAX : (width>0.0 ? width : 1.0);
    height = height>LONG_MAX ? LONG_MAX : (height>0.0 ? height : 1.0);
    weightScaleFactor = weight ? 1/weight : 1.0;

//    [self setBoundsSize:NSMakeSize(width, height)];
//    [self setBoundsOrigin:NSMakePoint(0.0, 0.0)];
    [self setTransformations];
}

- (unsigned int)weightCount;
{
  return [myEventList count];
}

- (void)drawContent;
{
  // writes information for E (x),H(y),L(color),D(width),G(height),
    int i, c;
    id event;
    c=[self weightCount];
  
        [myEventList sort];
	for (i=0; i<c; i++){
	    if (lineWidth) { /* don't draw if lineWidth = 0.0 */
		event = [myEventList objectAt:i];
                if ([event isKindOfClass:NSClassFromString(@"MathMatrix")] && 
                        [self frameContains:event]) {
                  if (usePS) {
                    double x, y,awidth, aheight;
		    x = ([event doubleValueAtIndex:indexE]-myKernelFrame[indexE].origin)/sz.width;
		    y = ([event doubleValueAtIndex:indexH]-myKernelFrame[indexH].origin)/sz.height;
		    awidth = [event doubleValueAtIndex:indexD]/sz.width;
		    aheight = [event doubleValueAtIndex:indexG]/sz.height;
#ifdef WITH_PS
                    PSsetgray(1-(([event doubleValueAtIndex:indexL]-myKernelFrame[indexL].origin) * weightScaleFactor));
		    //PSgsave();
		    PSrectfill(x, y-lineWidth/2, awidth, aheight+lineWidth);
		    //PSgrestore();
		    PSsetgray(NSBlack);
		    PSsetlinewidth(0.1);
		    PSrectstroke(x, y-lineWidth/2, awidth, aheight+lineWidth);
#endif
                  } else {
                    NSRect r;
                    NSPoint p;
                    NSSize s;
                    NSBezierPath *bPath;
                    p.x = ([event doubleValueAtIndex:indexE]-myKernelFrame[indexE].origin);
                    p.y = ([event doubleValueAtIndex:indexH]-myKernelFrame[indexH].origin);
                    s.width = [event doubleValueAtIndex:indexD];
                    s.height = [event doubleValueAtIndex:indexG];
                    p=[transformation transformPoint:p];
                    s=[transformation transformSize:s];
                    r.origin=NSMakePoint(p.x,p.y-lineWidth/2);
                    r.size=NSMakeSize(s.width,s.height+lineWidth); // add lineWidth to see anything, if aheight==0
                    bPath=[NSBezierPath bezierPathWithRect:r];
                    //[[NSColor colorWithCalibratedWhite:1-(([event doubleValueAtIndex:indexL]-myKernelFrame[indexL].origin) * weightScaleFactor) alpha:1.0] set];
                    [[[self rectColor] blendedColorWithFraction:1-(([event doubleValueAtIndex:indexL]-myKernelFrame[indexL].origin) * weightScaleFactor) ofColor:[self backgroundColor]] set];
                    [bPath fill];
                    [[self rectBorderColor] set];
                    [bPath setLineWidth:[self borderWidth]];
                    [bPath stroke];
                  }
		}
	    }
  	}
}

/*
- (void)drawRect:(NSRect)rects
{
    int i, c;
    NSSize sz = {1.0, 1.0};
    double lineWidth, x, y, width, height;
    lineWidth = myLineWidthField ?
        [myLineWidthField doubleValue] : 0.1;

    [self drawFrame];

    [self calcDrawSize];

    if (c = [myEventList count]) {
        id anEvent;

        sz = [self convertSize:sz fromView:nil];
        sz.width = sz.width ? sz.width : 1.0;
        sz.height = sz.height ? sz.height : 1.0;

        if ([myGridSwitch state]) [self drawGrid];

#ifdef WITH_PS
        PSscale (sz.width, sz.height);
#endif
        [self drawContent];
#ifdef WITH_PS
        PSscale (1/sz.width, 1/sz.height);
#endif	
    }
}

- drawGrid;
{
    double gridPos = 0, gridWidth = 0;
    NSSize sz = {1.0, 1.0};

    [myConverter setStringValue:[myGridOriginField stringValue]];
    theGrid.origin = [myConverter doubleValue] - myKernelFrame[indexE].origin;
    [myConverter setStringValue:[myGridMeshField stringValue]];
    theGrid.mesh = [myConverter fractValue];
    
    gridWidth = theGrid.mesh.isFraction&&theGrid.mesh.denominator ?
    				theGrid.mesh.numerator/theGrid.mesh.denominator : 
					(theGrid.mesh.numerator ? theGrid.mesh.numerator : 1.0);

    sz = [self convertSize:sz fromView:nil];
    sz.width = sz.width ? sz.width : 1.0;
    sz.height = sz.height ? sz.height : 1.0;

#ifdef WITH_PS
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
#endif

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
#ifdef WITH_PS
    PSsetgray(NSWhite);
#endif
    NSRectFill([self bounds]);

    return self;
}
*/
@end

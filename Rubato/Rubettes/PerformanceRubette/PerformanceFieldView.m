
#import "PerformanceFieldView.h"
#import <Rubato/RubatoTypes.h>
#import <Rubette/MatrixEvent.h>
#import <PerformanceScore/LocalPerformanceScore.h>
#import <Rubette/space.h>

@implementation PerformanceFieldView


static NSColor *fieldLineColor,*fieldOvalFillColor,*fieldOvalBorderColor;
+(void)initializeFieldColors;
{
  fieldLineColor=[[NSColor darkGrayColor] retain];
  fieldOvalFillColor=[[NSColor lightGrayColor] retain];
  fieldOvalBorderColor=[[NSColor blackColor] retain];
}

-(id)initWithFrame:(NSRect)frameRect;
{
  id ret=[super initWithFrame:frameRect];
  if (!fieldLineColor) 
    [PerformanceFieldView initializeFieldColors];
  return ret;
}

- (void)awakeFromNib;
{
    //[super awakeFromNib];
    [xAxisPopUp selectItemAtIndex:[xAxisPopUp indexOfItemWithTitle:[xAxisPopUp title]]];
    [yAxisPopUp selectItemAtIndex:[yAxisPopUp indexOfItemWithTitle:[yAxisPopUp title]]];
}


- (void)calcDrawSize;
{
    int xIndex, yIndex;
    //double width=0.0, height=0.0

//    xIndex = xAxisPopUp ? [xAxisPopUp tag] : 0; // jg was selectedCell] tag]
//    yIndex = yAxisPopUp ? [yAxisPopUp tag] : 1; // "
    xIndex = xAxisPopUp ? [[xAxisPopUp selectedItem] tag] : 0; // jg was selectedCell] tag]
    yIndex = yAxisPopUp ? [[yAxisPopUp selectedItem] tag] : 1; // "
    
    width = myKernelFrame[xIndex].end - myKernelFrame[xIndex].origin;
    height = myKernelFrame[yIndex].end - myKernelFrame[yIndex].origin;

    width = width>LONG_MAX ? LONG_MAX : (width>0.0 ? width : 1.0);
    height = height>LONG_MAX ? LONG_MAX : (height>0.0 ? height : 1.0);

//    [self setBoundsSize:NSMakeSize(width, height)];
//    [self setBoundsOrigin:NSMakePoint(0.0, 0.0)];
    [self setTransformations];
}

- (void)drawContent;
{
  NSPoint visualPoint,virtualPoint;
  int i, c, xIndex, yIndex, evtField;
  double lScale, x, y, field[6] = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0};
  id curEvent=nil, evt1, evt2;
  evtField = myEventFieldSwitch ?
      [myEventFieldSwitch state] : 1;
  lScale = myLengthScaleField ?
      [myLengthScaleField doubleValue] : 1.0;
  lineWidth = myLineWidthField ?
      [myLineWidthField doubleValue] : 1.0;

  xIndex = xAxisPopUp ? [[xAxisPopUp selectedItem] tag] : 0; // jg was selectedCell] tag]
  yIndex = yAxisPopUp ? [[yAxisPopUp selectedItem] tag] : 1;
  minX = [myLPS frameOriginAt:xIndex];
  minY = [myLPS frameOriginAt:yIndex];

  evt1 = [[[MatrixEvent alloc]initWithSpace:((spaceOfIndex(xIndex))|(spaceOfIndex(yIndex)))]ref];
  evt2 = [[[MatrixEvent alloc]initWithSpace:((spaceOfIndex(xIndex))|(spaceOfIndex(yIndex)))]ref];

  if (usePS) {
    if (lineWidth) {
#ifdef WITH_PS
        PSsetlinewidth(0.1);
        PSsetgray(NSDarkGray);
        PSmoveto(0.0, 0.0);
#endif
        for (x=0; x<[self bounds].size.width/sz.width; x+=lineWidth){
            for (y=0; y<[self bounds].size.height/sz.height; y+=lineWidth){
                curEvent = curEvent==evt1 ? evt2 : evt1;
                [curEvent setDoubleValue:x*sz.width+minX atIndex:xIndex];
                if (yIndex!=xIndex)
                    [curEvent setDoubleValue:y*sz.height+minY atIndex:yIndex];

                field[0] = [myLPS calcFieldComponent:xIndex at:curEvent];
                field[1] = (yIndex!=xIndex) ? [myLPS calcFieldComponent:yIndex at:curEvent] : 1.0;

#ifdef WITH_PS
                PSmoveto(x, y);
                PSlineto(x+(lineWidth*field[0]*lScale), y+(lineWidth*field[1]*lScale));
                PSstroke();
#endif
            }
        }
    }
    if (radius) { /* don't draw if radius = 0.0 */
        c = [myEventList count];
        for (i=0; i<c; i++) {
            curEvent = [myEventList objectAt:i];
            x = ([curEvent doubleValueAt:xIndex]-minX)/sz.width;
            y = ([curEvent doubleValueAt:yIndex]-minY)/sz.height;

            if(evtField) {
              x = ([curEvent doubleValueAt:xIndex]-minX)/sz.width; //??? jg same as above!
              y = ([curEvent doubleValueAt:yIndex]-minY)/sz.height; //??? jg same as above!

                field[0] = [myLPS calcFieldComponent:xIndex at:curEvent];
                field[1] = (yIndex!=xIndex) ? [myLPS calcFieldComponent:yIndex at:curEvent] : 1.0;

#ifdef WITH_PS
                PSsetgray(NSDarkGray);
                PSmoveto(x, y);
                PSlineto(x+(lineWidth*field[0]*lScale), y+(lineWidth*field[1]*lScale));
                PSstroke();
#endif
            }
#ifdef WITH_PS
            PSnewpath();
            PSarc(x, y, radius, 0.0, 360.0);
            PSsetgray(NSLightGray);
            PSclosepath();
            PSgsave();
            PSfill();
            PSgrestore();
            PSsetgray(NSBlack);
            PSsetlinewidth(0.1);
            PSstroke();
#endif
        }
    }
  } else { // if usePS
    if (lineWidth) {
      NSBezierPath *bPath=[NSBezierPath bezierPath];
      [bPath setLineWidth:[self borderWidth]];
      [fieldLineColor set];
      [bPath moveToPoint:NSMakePoint(0.0, 0.0)];
        for (x=0; x<[self bounds].size.width; x+=lineWidth){
            for (y=0; y<[self bounds].size.height; y+=lineWidth){
              visualPoint.x=x;
              visualPoint.y=y;
              virtualPoint=[inverseTransformation transformPoint:visualPoint];
                curEvent = curEvent==evt1 ? evt2 : evt1;
                [curEvent setDoubleValue:virtualPoint.x+minX atIndex:xIndex];
                if (yIndex!=xIndex)
                  [curEvent setDoubleValue:virtualPoint.y+minY atIndex:yIndex];

                field[0] = [myLPS calcFieldComponent:xIndex at:curEvent];
                field[1] = (yIndex!=xIndex) ? [myLPS calcFieldComponent:yIndex at:curEvent] : 1.0;

                [bPath moveToPoint:visualPoint];
                [bPath lineToPoint:NSMakePoint(visualPoint.x+(lineWidth*field[0]*lScale), visualPoint.y+(lineWidth*field[1]*lScale))];
                [bPath stroke];
            }
        }
    }
    if (radius) { /* don't draw if radius = 0.0 */
        c = [myEventList count];
        for (i=0; i<c; i++) {
          NSBezierPath *oval;
          NSBezierPath *bPath=[NSBezierPath bezierPath];
          [bPath setLineWidth:[self borderWidth]];
            curEvent = [myEventList objectAt:i];
            virtualPoint.x = ([curEvent doubleValueAt:xIndex]-minX);
            virtualPoint.y = ([curEvent doubleValueAt:yIndex]-minY);
            visualPoint=[transformation transformPoint:virtualPoint];

            if(evtField) {
                field[0] = [myLPS calcFieldComponent:xIndex at:curEvent];
                field[1] = (yIndex!=xIndex) ? [myLPS calcFieldComponent:yIndex at:curEvent] : 1.0;

                [fieldLineColor set];
                [bPath moveToPoint:visualPoint];
                [bPath lineToPoint:NSMakePoint(visualPoint.x+(lineWidth*field[0]*lScale), visualPoint.y+(lineWidth*field[1]*lScale))];
                [bPath stroke];
            }
            oval=[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(visualPoint.x-radius,visualPoint.y-radius,2*radius,2*radius)];
            [fieldOvalFillColor set];
            [oval fill];
            [fieldOvalBorderColor set];
            [oval setLineWidth:[self borderWidth]];
            [oval stroke];
        }
    }
  }
    [evt1 release];
    [evt2 release];    
}
 /*
  - (void)drawRect:(NSRect)rects;
  {
      int i, c, xIndex, yIndex, evtField;
      NSSize sz = {1.0, 1.0};
      double lScale, radius, lineWidth, x, y, minX, minY, field[6] = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0};
      id curEvent=nil, evt1, evt2;
      evtField = myEventFieldSwitch ?
          [myEventFieldSwitch state] : 1;
      lScale = myLengthScaleField ?
          [myLengthScaleField doubleValue] : 1.0;
      radius = myRadiusField ?
          [myRadiusField doubleValue] : 1.0;
      lineWidth = myLineWidthField ?
          [myLineWidthField doubleValue] : 1.0;

      xIndex = xAxisPopUp ? [xAxisPopUp tag] : 0; // jg was selectedCell] tag]
      yIndex = yAxisPopUp ? [yAxisPopUp tag] : 1;
      minX = [myLPS frameOriginAt:xIndex];
      minY = [myLPS frameOriginAt:yIndex];

      evt1 = [[[MatrixEvent alloc]initWithSpace:((spaceOfIndex(xIndex))|(spaceOfIndex(yIndex)))]ref];
      evt2 = [[[MatrixEvent alloc]initWithSpace:((spaceOfIndex(xIndex))|(spaceOfIndex(yIndex)))]ref];

      [self drawFrame];

      [self calcDrawSize];

      sz = [self convertSize:sz fromView:nil];
      sz.width = sz.width ? sz.width : 1.0;
      sz.height = sz.height ? sz.height : 1.0;

  #ifdef WITH_PS
      PSscale (sz.width, sz.height);
  #endif

      if (lineWidth) {
  #ifdef WITH_PS
          PSsetlinewidth(0.1);
          PSsetgray(NSDarkGray);
          PSmoveto(0.0, 0.0);
  #endif
          for (x=0; x<[self bounds].size.width/sz.width; x+=lineWidth){
              for (y=0; y<[self bounds].size.height/sz.height; y+=lineWidth){
                  curEvent = curEvent==evt1 ? evt2 : evt1;
                  [curEvent setDoubleValue:x*sz.width+minX atIndex:xIndex];
                  if (yIndex!=xIndex)
                      [curEvent setDoubleValue:y*sz.height+minY atIndex:yIndex];

                  field[0] = [myLPS calcFieldComponent:xIndex at:curEvent];
                  field[1] = (yIndex!=xIndex) ? [myLPS calcFieldComponent:yIndex at:curEvent] : 1.0;

  #ifdef WITH_PS
                  PSmoveto(x, y);
                  PSlineto(x+(lineWidth*field[0]*lScale), y+(lineWidth*field[1]*lScale));
                  PSstroke();
  #endif
              }
          }
      }
      if (radius) { // don't draw if radius = 0.0 
          c = [myEventList count];
          for (i=0; i<c; i++) {
              curEvent = [myEventList objectAt:i];
              x = ([curEvent doubleValueAt:xIndex]-minX)/sz.width;
              y = ([curEvent doubleValueAt:yIndex]-minY)/sz.height;

              if(evtField) {
                  x = ([curEvent doubleValueAt:xIndex]-minX)/sz.width; //??? jg same as above!
                  y = ([curEvent doubleValueAt:yIndex]-minY)/sz.height;  //??? jg same as above!

                  field[0] = [myLPS calcFieldComponent:xIndex at:curEvent];
                  field[1] = (yIndex!=xIndex) ? [myLPS calcFieldComponent:yIndex at:curEvent] : 1.0;

  #ifdef WITH_PS
                  PSsetgray(NSDarkGray);
                  PSmoveto(x, y);
                  PSlineto(x+(lineWidth*field[0]*lScale), y+(lineWidth*field[1]*lScale));
                  PSstroke();
  #endif
              }
  #ifdef WITH_PS
              PSnewpath();
              PSarc(x, y, radius, 0.0, 360.0);
              PSsetgray(NSLightGray);
              PSclosepath();
              PSgsave();
              PSfill();
              PSgrestore();
              PSsetgray(NSBlack);
              PSsetlinewidth(0.1);
              PSstroke();
  #endif
          }
      }

  #ifdef WITH_PS
      PSscale (1/sz.width, 1/sz.height);
  #endif
      [evt1 release];
      [evt2 release];
      if ([myGridSwitch state]) [self drawGrid];

  }
*/
@end

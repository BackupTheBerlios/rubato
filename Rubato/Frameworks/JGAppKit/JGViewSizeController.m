//
//  JGViewSizeController.m
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Wed Apr 24 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "JGViewSizeController.h"

#define INSERTINSTANCE(x) if (x) [dict setObject:x forKey:[NSString stringWithCString: #x ]]

@implementation JGViewSizeController

- (NSDictionary *)instanceVariables;
{
  NSMutableDictionary *dict=[NSMutableDictionary dictionary];
  INSERTINSTANCE(targetView);
  INSERTINSTANCE(controllerView);
  INSERTINSTANCE(xTextField);
  INSERTINSTANCE(yTextField);
  INSERTINSTANCE(absRelSwitch);
  INSERTINSTANCE(boundsFrameSwitch);
  INSERTINSTANCE(orgCurrentSwitch);
  INSERTINSTANCE(okSwitch);
  INSERTINSTANCE(okButton);
  INSERTINSTANCE(xSlider);
  INSERTINSTANCE(ySlider);
  return dict;
}


// initialization
- (id)init;
{
  [super init];
  compareSize=NSMakeSize(300.0,300.0);
  linearSliderFactor=NSMakeSize(10.0,10.0); // max e^10
  enclosingView=nil;
  return self;
}
- (void)awakeFromNib;
{
  [self displayValues];
}

- (NSView *)controllerView;
{
  return controllerView;
}

- (void)setEnclosingView:(NSView *)newView;
{
  [newView retain];
  [enclosingView release];
  enclosingView=newView;  
}
// instance variable setting
- (void)setTargetView:(NSView *)newView;
  /*" set targetView and currentSize and originalSize "*/
{
  [newView retain];
  [targetView release];
  targetView=newView;

  originalFrame=[targetView frame];
  originalBounds=[targetView bounds];
  [self resetValues];
  [self displayValues];
}

// Primitives defined by User Interface Switches
- (BOOL)updateSizeNow;
{
  return ([okSwitch intValue]!=0);
}
- (BOOL)updateAbsolute;
{
  return ([absRelSwitch intValue]!=0);
}
- (BOOL)displayCurrentSize;
{
  return ([orgCurrentSwitch intValue]==0);
}
- (BOOL)destinationIsFrame;
{
  return ([boundsFrameSwitch intValue]==0);
}



// helper methods
- (void)setValuesOfSize:(NSSize *)p toSize:(NSSize *)s;
{
  p->width=s->width;
  p->height=s->height;
}
- (void)setOriginalSizes;
{
  NSSize f=[targetView frame].size;
  NSSize b=[targetView bounds].size;
  [self setValuesOfSize:&currentFrameSize toSize:&f];
  [self setValuesOfSize:&currentBoundsSize toSize:&b];
}
- (void)setSizePointers:(BOOL)isFrame;
{
  if (isFrame) {
    currentSize=&currentFrameSize;
    nextSize=&nextFrameSize;
    factor=&nextFrameFactor;
  } else {
    currentSize=&currentBoundsSize;
    nextSize=&nextBoundsSize;
    factor=&nextBoundsFactor;
  }
}

- (void)resetView;
{
  [targetView setFrame:originalFrame];
  [targetView setBounds:originalBounds];
  [targetView setNeedsDisplay:YES];
  [enclosingView setNeedsDisplay:YES];
}

// updates
- (void)resetValues;
{
  int i;
  NSSize one=NSMakeSize(1.0,1.0);
  BOOL isFrame;
  [self setOriginalSizes];
  for (i=0;i<2;i++) {
    isFrame=(i==0);
    [self setSizePointers:isFrame];
    [self setValuesOfSize:nextSize toSize:currentSize];
    [self setValuesOfSize:factor toSize:&one];
  }
}
- (void)updateValues;
{
  float x,y;
  BOOL isFrame=[self destinationIsFrame];
  [self setOriginalSizes];
  [self setSizePointers:isFrame];

  x=[xTextField floatValue];
  if (x<=0.0) x=1.0;
  y=[yTextField floatValue];
  if (y<=0.0) y=1.0;
  if ([self updateAbsolute]) {
    nextSize->width=x;
    nextSize->height=y;
    factor->width=nextSize->width/currentSize->width;
    factor->height=nextSize->height/currentSize->height;
  } else {
    factor->width=x;
    factor->height=y;
    nextSize->width = factor->width*currentSize->width;
    nextSize->height =factor->height*currentSize->height;
  }
}
- (void)displayValues;
{
  double x,y;
  NSSize *s;
  if ([self updateAbsolute]) {
    if ([self displayCurrentSize]) {
      s=nextSize;
    } else {
      s=currentSize;
    }
    x=s->width;
    y=s->height;
    [self setSliderWithAbsoluteSize:s];
  } else {
    x=factor->width;
    y=factor->height;
    [self setSliderWithFactorSize:factor];
  }
  [xTextField setStringValue:[NSString stringWithFormat:@"%f",x]]; 
  [yTextField setStringValue:[NSString stringWithFormat:@"%f",y]];  
  [controllerView setNeedsDisplay:YES];
}
 // [xTextField setDoubleValue:x]; does not work, because it writes 0,5 instead of 0.5

// Slider methods
/* (given a sliderValue between -1 and 1 and a linearSliderFactor)
linearSliderValue==linearSliderFactor*sliderValue
sliderFactor==e^linearSliderValue==absoluteSize/compareSize

absoluteSize==compareSize*expSliderValue
sliderValue== linearSliderValue/linearSliderValue == ln(absoluteSize/compareSize)/linearSliderFactor
*/
- (void)setSliderWithAbsoluteSize:(NSSize *)s;
{
  NSSize ratio;
  ratio.width=s->width/compareSize.width;
  ratio.height=s->height/compareSize.height;
  [self setSliderWithFactorSize:&ratio];
}
- (void)setSliderWithFactorSize:(NSSize *)s;
{
  double xSliderValue,ySliderValue;
  xSliderValue=log(s->width)/linearSliderFactor.width;
  ySliderValue=log(s->height)/linearSliderFactor.height;
  [xSlider setDoubleValue:xSliderValue];
  [ySlider setDoubleValue:ySliderValue];
}
- (NSSize)sliderFactor;
{
  return NSMakeSize(exp(linearSliderFactor.width*[xSlider doubleValue]),exp(linearSliderFactor.height*[ySlider doubleValue]));
}
- (NSSize)sliderValue;
{
  NSSize s=[self sliderFactor];
  s.width*=compareSize.width;
  s.height*=compareSize.height;
  return s;
}
- (void)setTextFieldsFromSlider;
{
  NSSize s;
  if ([self updateAbsolute]) {
    s=[self sliderValue];
  } else {
    s=[self sliderFactor];
  }
  [xTextField setStringValue:[NSString stringWithFormat:@"%f",s.width]]; 
  [yTextField setStringValue:[NSString stringWithFormat:@"%f",s.height]]; 
}

// modifiing the targetView
- (void)updateSize;
{
  static BOOL updateBoth=NO;
  if (updateBoth) {
    [targetView setFrameSize:nextFrameSize];
    [targetView setBoundsSize:nextBoundsSize];
  } else {
    if ([self destinationIsFrame]) {
      [targetView setFrameSize:nextFrameSize]; // this one changes bounds also.
      if (![syncFrameBoundsSwitch state])
        [targetView setBoundsSize:currentBoundsSize]; // this removes the bounds change
    } else
      [targetView setBoundsSize:nextBoundsSize];
  }
  [targetView setNeedsDisplay:YES];
   // if targetView became smaller than previous targetView and is smaller than the clipview
  [enclosingView setNeedsDisplay:YES];
}

// Action methods
- (IBAction)currentNextSwitchAction:(id)sender;
/*" Special treatment of orgCurrentSwitch switch: disable for current. "*/
{
  NSArray *a=[NSArray arrayWithObjects:xTextField,yTextField,xSlider,ySlider,okButton,nil];
  NSEnumerator *e=[a objectEnumerator];
  id item;
  BOOL value;
  [self updateValues];
  if ([orgCurrentSwitch state]) {
    value=NO;
  } else {
    value=YES;
  }
  while (item=[e nextObject]) {
    [item setEnabled:value];
  }
  [self displayValues];
}
- (IBAction)sliderAction:(id)sender;
{
  [self setTextFieldsFromSlider];
  [self changeValueAction:sender];
}
- (IBAction)changeValueAction:(id)sender;
{
  [self updateValues];
  [self displayValues];

  if ((sender==okButton) || [okSwitch intValue])
    [self updateSize];
}
- (IBAction)resetAction:(id)sender;
{
  [self resetView];
  [self resetValues];
  [self displayValues];
}
- (IBAction)displayValuesAction:(id)sender;
{
  [self displayValues];
}
@end


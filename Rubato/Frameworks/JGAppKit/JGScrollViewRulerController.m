//
//  JGScrollViewRulerController.m
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Wed Apr 24 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "JGScrollViewRulerController.h"
#define INSERTINSTANCE(x) if (x) [dict setObject:x forKey:[NSString stringWithCString: #x ]]

@implementation JGScrollViewRulerController
- (NSDictionary *)instanceVariables;
{
  NSMutableDictionary *dict=[NSMutableDictionary dictionary];
  INSERTINSTANCE(scrollView);
  INSERTINSTANCE(controllerView);
  INSERTINSTANCE(hasHorizontalRulerSwitch);
  INSERTINSTANCE(hasVerticalRulerSwitch);
  INSERTINSTANCE(showRulersSwitch);
  INSERTINSTANCE(horizontalStepUpCycleTextField);
  INSERTINSTANCE(horizontalStepDownCycleTextField);
  INSERTINSTANCE(horizontalConversionFactorTextField);
  INSERTINSTANCE(horizontalOriginOffsetTextField);
  INSERTINSTANCE(verticalStepUpCycleTextField);
  INSERTINSTANCE(verticalStepDownCycleTextField);
  INSERTINSTANCE(verticalConversionFactorTextField);
  INSERTINSTANCE(verticalOriginOffsetTextField);
  INSERTINSTANCE(okSwitch);
  INSERTINSTANCE(okButton);
  INSERTINSTANCE(stepUpCycleTextField);
  INSERTINSTANCE(stepDownCycleTextField);
  INSERTINSTANCE(conversionFactorTextField);
  INSERTINSTANCE(originOffsetTextField);
  INSERTINSTANCE(unitName);
  INSERTINSTANCE(ruler);
  return dict;
}

- (void)awakeFromNib;
{
  [self updateButtons];
}

- (NSView *)controllerView;
{
  return controllerView;
}

- (IBAction)changeDone:(id)sender;
  /*"Only does something,   if ([sender==okButton] || [okSwitch intValue]) "*/
{
  if ((sender==okButton) || [okSwitch intValue]) {
    [self updateScrollView];
    [self updateButtons];
    [scrollView setNeedsDisplay:YES];
  }
}

- (void)setScrollView:(NSScrollView *)newScrollView;
{
  [newScrollView retain];
  [scrollView release];
  scrollView=newScrollView;
  [self updateButtons];
}

- (NSMutableArray *)numbersFromTextField:(NSTextField *)textField isStepUp:(BOOL)isStepUp;
{
  NSString *str=[textField stringValue];
  NSArray *strings=[str componentsSeparatedByString:@" "];
  NSEnumerator *e=[strings objectEnumerator];
  NSMutableArray *result=[NSMutableArray array];
  while (str=[e nextObject]) {
    double d=[str doubleValue];
    if ((d!=0.0) && (d!=1.0))
      [result addObject:[NSNumber numberWithDouble:d]];
  }
  if (![result count])
    [result addObject:[NSNumber numberWithDouble:(isStepUp?10.0:0.1)]];
  return result;
}

- (NSString *)unitNameWithDirection:(NSString *)direction;
{
  return [NSString stringWithFormat:@"%@ %d",direction,(int)self];
}


- (void)setTemporaries:(BOOL)isHorizontal;
{
  if (isHorizontal) {
    stepUpCycleTextField=horizontalStepUpCycleTextField;
    stepDownCycleTextField=horizontalStepDownCycleTextField;
    conversionFactorTextField=horizontalConversionFactorTextField;
    originOffsetTextField=horizontalOriginOffsetTextField;
    hasRuler=[scrollView hasHorizontalRuler];
    ruler=[scrollView horizontalRulerView];
    unitName=@"x";
  } else {
    stepUpCycleTextField=verticalStepUpCycleTextField;
    stepDownCycleTextField=verticalStepDownCycleTextField;
    conversionFactorTextField=verticalConversionFactorTextField;
    originOffsetTextField=verticalOriginOffsetTextField;
    hasRuler=[scrollView hasVerticalRuler];
    ruler=[scrollView verticalRulerView];
    unitName=@"y";
  }
}


- (void)registerUnitWithDirection:(NSString *)direction abbreviation:(NSString *)abbreviation unitToPointsConversionFactor:(float)conversionFactor stepUpCycle:(NSArray *)stepUpCycle stepDownCycle:(NSArray *)stepDownCycle;
{
  [NSRulerView registerUnitWithName:[self unitNameWithDirection:direction] abbreviation:abbreviation unitToPointsConversionFactor:conversionFactor stepUpCycle:stepUpCycle stepDownCycle:stepDownCycle];
}


- (void)updateScrollView;
{
  int i;
  [scrollView setHasHorizontalRuler:(BOOL)[hasHorizontalRulerSwitch intValue]];
  [scrollView setHasVerticalRuler:(BOOL)[hasVerticalRulerSwitch intValue]];
  [scrollView setRulersVisible:(BOOL)[showRulersSwitch intValue]];

  for (i=0; i<2; i++) {
    BOOL isHorizontal=(i==0);
    [self setTemporaries:isHorizontal];
    if (hasRuler) {
      NSArray *upCycle=[self numbersFromTextField:stepUpCycleTextField isStepUp:YES];
      NSArray *downCycle=[self numbersFromTextField:stepDownCycleTextField isStepUp:NO];
      double conversion=[conversionFactorTextField doubleValue];
      double originOffset=[originOffsetTextField doubleValue];
      if (conversion==0.0) { // maybe we should then change to standard pixel?
        conversion=1.0;
      }
      [ruler setOriginOffset:originOffset];
      [self registerUnitWithDirection:unitName abbreviation:unitName unitToPointsConversionFactor:conversion
                          stepUpCycle:upCycle stepDownCycle:downCycle];
      [ruler setMeasurementUnits:[self unitNameWithDirection:unitName]];

      // set the text back to the textfields, to show, what is understood:
      [stepUpCycleTextField setStringValue:[upCycle componentsJoinedByString:@" "]];
      [stepDownCycleTextField setStringValue:[downCycle componentsJoinedByString:@" "]];
      [conversionFactorTextField setStringValue:[NSString stringWithFormat:@"%f",conversion]];
      [originOffsetTextField setStringValue:[NSString stringWithFormat:@"%f",originOffset]];
    }
  }
}
- (void)updateButtons;
{
  [hasHorizontalRulerSwitch setState:[scrollView hasHorizontalRuler]];
  [hasVerticalRulerSwitch setState:[scrollView hasVerticalRuler]];
  [showRulersSwitch setState:[scrollView rulersVisible]];
}

@end


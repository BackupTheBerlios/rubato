//
//  JGScrollViewRulerController.h
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Wed Apr 24 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface JGScrollViewRulerController : NSObject {
  IBOutlet NSScrollView *scrollView;
  IBOutlet NSView *controllerView;

  IBOutlet NSButton *hasHorizontalRulerSwitch,*hasVerticalRulerSwitch,*showRulersSwitch;
  IBOutlet NSTextField *horizontalStepUpCycleTextField,*horizontalStepDownCycleTextField, *horizontalConversionFactorTextField, *horizontalOriginOffsetTextField;
  IBOutlet NSTextField *verticalStepUpCycleTextField,*verticalStepDownCycleTextField, *verticalConversionFactorTextField, *verticalOriginOffsetTextField;

  IBOutlet NSButton *okSwitch, *okButton;

  // temporary variables
  BOOL hasRuler;
  NSTextField *stepUpCycleTextField, *stepDownCycleTextField, *conversionFactorTextField, *originOffsetTextField;
  NSString *unitName;
  NSRulerView *ruler;
}
- (NSView *)controllerView;

  // Action methods
- (IBAction)changeDone:(id)sender; // the only action of all UI-Elements.

- (void)setScrollView:(NSScrollView *)newScrollView;

  // helpers
- (NSMutableArray *)numbersFromTextField:(NSTextField *)textField isStepUp:(BOOL)isStepUp;
- (NSString *)unitNameWithDirection:(NSString *)direction;
- (void)setTemporaries:(BOOL)isHorizontal;
- (void)registerUnitWithDirection:(NSString *)direction abbreviation:(NSString *)abbreviation unitToPointsConversionFactor:(float)conversionFactor stepUpCycle:(NSArray *)stepUpCycle stepDownCycle:(NSArray *)stepDownCycle;

  // main methods
- (void)updateScrollView;
- (void)updateButtons;
@end



//
//  JGViewSizeController.h
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Wed Apr 24 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

// Handles all types of scaling of view
@interface JGViewSizeController : NSObject {
  IBOutlet NSView *targetView;
  IBOutlet NSView *controllerView; // contains the buttons below
  IBOutlet NSView *enclosingView; // is sent -setNeedsDisplay on targetView resize, when invoked by JGViewSizeController.
 
  IBOutlet NSTextField *xTextField,*yTextField;
  IBOutlet NSButton *absRelSwitch, *boundsFrameSwitch, *orgCurrentSwitch, *syncFrameBoundsSwitch;
  IBOutlet NSButton *okSwitch, *okButton;

  IBOutlet NSSlider *xSlider,*ySlider; // -1 .. 1 for exponential sliding.

  NSSize compareSize;
  NSSize linearSliderFactor;

  NSRect originalFrame, originalBounds; // used for reset
  NSSize currentFrameSize, currentBoundsSize, nextFrameSize, nextBoundsSize, nextFrameFactor, nextBoundsFactor;
  NSSize *currentSize, *nextSize, *factor;
}
- (NSView *)controllerView;

- (id)init;
- (void)awakeFromNib;
- (void)setEnclosingView:(NSView *)newView;
- (void)setTargetView:(NSView *)view;

  // Primitives defined by User Interface Switches
- (BOOL)updateSizeNow;
- (BOOL)updateAbsolute;
- (BOOL)displayCurrentSize;
- (BOOL)destinationIsFrame;

  // helper methods
- (void)setValuesOfSize:(NSSize *)p toSize:(NSSize *)s;
- (void)setOriginalSizes;
- (void)setSizePointers:(BOOL)isFrame;

  // updates
- (void)resetView;
- (void)resetValues;
- (void)updateValues;
- (void)displayValues;

  // Slider methods
- (void)setSliderWithAbsoluteSize:(NSSize *)s;
- (void)setSliderWithFactorSize:(NSSize *)s;
- (NSSize)sliderFactor;
- (NSSize)sliderValue;
- (void)setTextFieldsFromSlider;

  // modifiing the view
- (void)updateSize;

  // Action methods
- (IBAction)currentNextSwitchAction:(id)sender;
- (IBAction)sliderAction:(id)sender;
- (IBAction)changeValueAction:(id)sender;
- (IBAction)resetAction:(id)sender;
- (IBAction)displayValuesAction:(id)sender;
@end


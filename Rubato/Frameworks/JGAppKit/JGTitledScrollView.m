//
//  JGTitledScrollView.m
//  Rubato
//
//  Created by Joerg Garbers on Wed Oct 02 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "JGTitledScrollView.h"

#define NOT_CORRECT 
@implementation JGTitledScrollView

#ifndef NOT_CORRECT
- (void)awakeFromNib;
{
  //  [super awakeFromNib]; // selector not recognised!
  if (horizontalTitleView && (![horizontalTitleView isKindOfClass:[NSScrollView class]]))
    horizontalTitleView=[self scrollableWrapperForView:horizontalTitleView];
  if (verticalTitleView && (![verticalTitleView isKindOfClass:[NSScrollView class]]))
    verticalTitleView=[self scrollableWrapperForView:verticalTitleView];
}
- (void)dealloc;
{
  [horizontalTitleView release];
  [verticalTitleView release];
  [super dealloc];
}

- (NSScrollView *)scrollableWrapperForView:(NSView *)view;
{// return value has retaincount 1.
  id superView=[view superview];
  id newView=[[NSScrollView alloc] initWithFrame:[horizontalTitleView frame]];
  [newView setHasVerticalScroller:NO];
  [newView setHasHorizontalScroller:NO];
  [view setFrameOrigin:NSZeroPoint]; // move to relative 0,0 
  [view retain];
  [superView replaceSubview:view with:newView];
  [newView setDocumentView:view];
  [view setNeedsDisplay:YES];
  [newView setNeedsDisplay:YES];
  [view release];
  [superView setNeedsDisplay:YES];
  return newView;
}
- (void)reflectScrolledClipView:(NSClipView *)clipView; // overridden
{
  // called also during initialisation (before awakeFromNib)
  NSRect dr,dvr;
  [super reflectScrolledClipView:clipView];
  if (horizontalTitleView || verticalTitleView) {
    dr=[clipView documentRect];
    dvr=[clipView documentVisibleRect];    
  }
  if (horizontalTitleView) {
    NSRect rect=[[horizontalTitleView documentView] frame];
    NSPoint point=NSMakePoint(rect.origin.x + dvr.origin.x - dr.origin.x,
                              [horizontalTitleView documentVisibleRect].origin.y);
    [[horizontalTitleView contentView] scrollToPoint:point];
  }
  if (verticalTitleView) {
    NSRect rect=[[verticalTitleView documentView] frame];
    NSPoint point=NSMakePoint([verticalTitleView documentVisibleRect].origin.x,
                              rect.origin.y + dvr.origin.y - dr.origin.y);
    [[verticalTitleView contentView] scrollToPoint:point];    
  }
  if (reflectScrolledClipViewDelegate)
    [reflectScrolledClipViewDelegate scrollView:self reflectScrolledClipView:clipView];
}
#endif

- (NSScrollView *)horizontalTitleView;
{
  return horizontalTitleView;
}
- (NSScrollView *)verticalTitleView;
{
  return verticalTitleView;
}
- (id)reflectScrolledClipViewDelegate;
{
  return reflectScrolledClipViewDelegate;
}

@end

//
//  JGTitledScrollView.m
//  Rubato
//
//  Created by Joerg Garbers on Wed Oct 02 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "JGTitledScrollView.h"

@implementation JGTitledScrollView

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


static BOOL sizesTitleScrollViews=YES;

+ (void)setSizesTitleScrollViews:(BOOL)newVal;
{
  sizesTitleScrollViews=newVal;
}

- (NSScrollView *)scrollableWrapperForView:(NSView *)view;
{// return value has retaincount 1.
  id superView=[view superview];
  NSRect titleViewFrame=[view frame]; // need not be a titleView, but then it has a special behaviour
  id newView;
  if (sizesTitleScrollViews) {
    NSRect scrollViewFrame=[self frame];
    if (view==horizontalTitleView) {
      titleViewFrame.size.width=scrollViewFrame.size.width-(titleViewFrame.origin.x-scrollViewFrame.origin.x);
    } else if (view==verticalTitleView) {
      titleViewFrame.size.height=scrollViewFrame.size.height-(titleViewFrame.origin.y-scrollViewFrame.origin.y);      
    }
  }
  newView=[[NSScrollView alloc] initWithFrame:titleViewFrame];
  [newView setDrawsBackground:NO];
  [newView setHasVerticalScroller:NO];
  [newView setHasHorizontalScroller:NO];

  // Resizing
  [newView setAutoresizingMask:[view autoresizingMask]]; // get mask from view
  [view setAutoresizingMask:NSViewNotSizable]; // in a scrollView the contentView need not be resized.
  
  [view setFrameOrigin:NSZeroPoint]; // move to relative 0,0
  [view retain];
  [superView replaceSubview:view with:newView]; // keeps the back to front ordering? or replacable by next two methods?
//  [view removeFromSuperview];
//  [superView addSubview:newView];
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

// Adjustes the matices of a contentView with titles
- (void)setTitles:(NSArray *)titles horizontal:(BOOL)horizontal isContent:(BOOL)isContent;
{
  NSScrollView *titleView=isContent?self:(horizontal?horizontalTitleView:verticalTitleView);
  if (titleView && titles) {
    NSMatrix *mat=[titleView documentView];
    if ([mat isKindOfClass:[NSMatrix class]]) {
      int titleCount=[titles count];
      int colCount,rowCount,cellCount;
      int i;
      [mat getNumberOfRows:&rowCount columns:&colCount];
      cellCount=(horizontal?colCount:rowCount);
      if (titleCount<cellCount) {
        for (i=cellCount-1;i>=titleCount;i--)
          (horizontal?[mat removeColumn:i]:[mat removeRow:i]);
      }
      for (i=0; i<titleCount; i++) {
        NSCell *cell;
        if (i>=cellCount)
          (horizontal?[mat addColumn]:[mat addRow]);
        if (!isContent) {
          cell=[mat cellAtRow:(horizontal?0:i) column:(horizontal?i:0)];
          [cell setStringValue:[titles objectAtIndex:i]];
        }
      }
      [mat sizeToCells];
    }
  }
}

- (void)setHorizontalTitles:(NSArray *)titles;
{
  [self setTitles:titles horizontal:YES isContent:NO];
  [self setTitles:titles horizontal:YES isContent:YES];
}
- (void)setVerticalTitles:(NSArray *)titles;
{
  [self setTitles:titles horizontal:NO isContent:NO];
  [self setTitles:titles horizontal:NO isContent:YES];
}
- (void)setHorizontalTitles:(NSArray *)horizontalTitles verticalTitles:(NSArray *)verticalTitles;
{
  [self setHorizontalTitles:horizontalTitles];
  [self setVerticalTitles:verticalTitles];
}

@end

@implementation NSMatrix (JGTitledScrollView)
- (JGTitledScrollView *)jgTitledScrollView;
{
  id view=[[self superview] superview];
  NSParameterAssert([view isKindOfClass:[JGTitledScrollView class]]);
  return view;
}
@end


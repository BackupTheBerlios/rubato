//
//  JGTitledScrollView.h
//  Rubato
//
//  Created by Joerg Garbers on Wed Oct 02 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@protocol ReflectScrolledClipViewDelegate
- (void)scrollView:(NSScrollView *)sv reflectScrolledClipView:(NSClipView *)clipView;
@end

// use this to reflect the scrolling in a scrollview in its title views.
// useful, if the size of the title views correspond to the document view.
@interface JGTitledScrollView : NSScrollView
{
  IBOutlet id horizontalTitleView;
  IBOutlet id verticalTitleView;
  id reflectScrolledClipViewDelegate; //   [reflectScrolledClipViewDelegate scrollView:self reflectScrolledClipView:clipView];

}
- (NSScrollView *)scrollableWrapperForView:(NSView *)view;
- (void)awakeFromNib; // puts title views in clip views if necessary
- (void)reflectScrolledClipView:(NSClipView *)cView; // overridden

- (NSScrollView *)horizontalTitleView;
- (NSScrollView *)verticalTitleView;
- (id)reflectScrolledClipViewDelegate;
@end

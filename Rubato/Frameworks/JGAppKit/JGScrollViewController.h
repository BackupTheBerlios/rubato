//
//  JGScrollViewController.h
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Mon Apr 22 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class JGScrollViewRulerController;
@class JGViewSizeController;


@interface NSView (JGScale)
- (IBAction)putInJGScrollViewController:(id)sender;
- (IBAction)putInJGScrollViewControllerInZoomView:(id)sender;
- (IBAction)removeJGScrollViewController:(id)sender;
- (IBAction)showJGScrollViewController:(id)sender;
- (IBAction)setMenuWithJGScrollViewControllerActions:(id)sender;

- (IBAction)printScrollView:(id)sender;
- (IBAction)printScrollViewContent:(id)sender;
- (IBAction)printScrollViewDocument:(id)sender; // forwarded to [self print:]
@end

// Sets documentView to scrollViews documentView
// adds rulers to the scrollView
// assume documentView has a logical NSFrame and a physical NSFrame (or bound?)
// the rulers display the logical frame (origin and extent).

// listen to APPKIT_EXTERN NSString *NSViewBoundsDidChangeNotification;

@interface JGScrollViewController : NSObject {
  IBOutlet NSWindow *controllerPanel;
  IBOutlet NSTabView *controllerView;

  IBOutlet NSWindow *scrollViewWindow;
  IBOutlet NSScrollView *scrollView;
  IBOutlet NSView *documentView;

  NSView *zoomView;
  JGScrollViewRulerController *zoomViewRulerController, *documentViewRulerController;
  JGViewSizeController *zoomViewSizeController,*documentViewSizeController;

  NSString *docSizeTitle,*zoomSizeTitle,*docRulerTitle,*zoomRulerTitle;
  NSString *docSizeIdentifier,*zoomSizeIdentifier,*docRulerIdentifier,*zoomRulerIdentifier;
  BOOL shouldHaveZoomView; // to be set right after init. Default:NO
}
+ (void)registerScrollViewController:(id)controlle forView:(NSView *)view;
+ (id)registeredScrollViewControllerForView:(id)view;
+ (id)newScrollViewControllerForView:(NSView *)view setShouldHaveZoomView:(BOOL)useZoomview skipIfExists:(BOOL)skipIfExists;
+ (void)addScrollViewActionsToMenu:(NSMenu *)m target:(id)target;

+ (id)globalScrollViewController;
+ (id)newScrollViewController;

- (NSDictionary *)instanceVariables;
- (BOOL)loadDefaultNib;
- (id)newScrollViewRulerController;
- (id)newViewSizeControllerWithTarget:(NSView *)target;
- (id)init;
- (void)fillTabView;

- (void)awakeFromNib;
- (void)setScrollView:(NSScrollView *)newScrollView;
- (void)setDocumentView:(NSView *)newDocumentView;
- (void)setShouldHaveZoomView:(BOOL)yn; // to be set right after init. Default:NO
- (void)foldViews;
- (void)makeScrollViewForNewDocumentView:(NSView *)newDocumentView;
- (void)replaceScrollViewWithDocumentView;
- (void)disposeControllerPanel;
- (IBAction)showPanel:(id)sender;
@end


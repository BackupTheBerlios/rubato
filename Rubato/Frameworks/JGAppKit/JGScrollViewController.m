//
//  JGScrollViewController.m
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Mon Apr 22 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "JGScrollViewController.h"
#import "JGScrollViewRulerController.h"
#import "JGViewSizeController.h"

#define INSERTINSTANCE(x) if (x) [dict setObject:x forKey:[NSString stringWithCString: #x ]]


@implementation NSView (JGScale)
- (IBAction)showJGScrollViewController:(id)sender;
{
  id controller=[JGScrollViewController registeredScrollViewControllerForView:self];
  [controller showPanel:sender];
}

- (IBAction)printScrollView:(id)sender;
{
  id controller=[JGScrollViewController registeredScrollViewControllerForView:self];
  id scrollView=[controller valueForKey:@"scrollView"];
  [scrollView print:sender];
}
- (IBAction)printScrollViewContent:(id)sender;
{
  id controller=[JGScrollViewController registeredScrollViewControllerForView:self];
  id scrollView=[controller valueForKey:@"scrollView"];
  id view=[scrollView contentView];
  [view print:sender];
}
- (IBAction)printScrollViewDocument:(id)sender;
{
  [self print:sender];
}

static BOOL JGScrollViewControllerSkipIfExists=YES;

// add NSWindowWillCloseNotification listener, so the controller closes, when the view closes?
- (IBAction)putInJGScrollViewController:(id)sender;
{
  [JGScrollViewController newScrollViewControllerForView:self
                          setShouldHaveZoomView:NO
                          skipIfExists:JGScrollViewControllerSkipIfExists];
}
- (IBAction)putInJGScrollViewControllerInZoomView:(id)sender;
{
  [JGScrollViewController newScrollViewControllerForView:self
                          setShouldHaveZoomView:YES
                          skipIfExists:JGScrollViewControllerSkipIfExists];
}
- (IBAction)removeJGScrollViewController:(id)sender;
{
  id controller=[JGScrollViewController registeredScrollViewControllerForView:self];
  [controller replaceScrollViewWithDocumentView];
  [JGScrollViewController registerScrollViewController:nil forView:self];
}

- (IBAction)setMenuWithJGScrollViewControllerActions:(id)sender;
{
  NSMenu *m=[self menu];
  if (!m)
    m=[[NSMenu alloc] initWithTitle:@"ScrollView"];
  [JGScrollViewController addScrollViewActionsToMenu:m target:self];
  [self setMenu:m];
  [m release];
}


@end

@implementation JGScrollViewController
static NSMutableDictionary *jgScrollViewControllerDictionary=nil;
+ (void)registerScrollViewController:(id)controller forView:(NSView *)view;
{
  if (!jgScrollViewControllerDictionary)
    jgScrollViewControllerDictionary=[[NSMutableDictionary alloc] init];
  if (controller)
    [jgScrollViewControllerDictionary setObject:controller forKey:[NSValue valueWithNonretainedObject:view]];
  else
    [jgScrollViewControllerDictionary removeObjectForKey:[NSValue valueWithNonretainedObject:view]];
}
+ (id)registeredScrollViewControllerForView:(id)view;
{
  return [jgScrollViewControllerDictionary objectForKey:[NSValue valueWithNonretainedObject:view]];
}

+ (id)newScrollViewControllerForView:(NSView *)view setShouldHaveZoomView:(BOOL)useZoomview skipIfExists:(BOOL)skipIfExists;
{
  id controller=[JGScrollViewController registeredScrollViewControllerForView:view];
  if (skipIfExists && controller)
    return nil;
  controller=[[[self class] alloc] init];
  [controller setShouldHaveZoomView:useZoomview];
  [controller makeScrollViewForNewDocumentView:view];
  [JGScrollViewController registerScrollViewController:controller forView:view];
  return controller;
}

+ (void)addScrollViewActionsToMenu:(NSMenu *)m target:(id)target;
{
  NSMenuItem *item;
  item=[m addItemWithTitle: @"Put in Scrollview" action:@selector(putInJGScrollViewController:) keyEquivalent:@""];
  [item setTarget:target];
  item=[m addItemWithTitle: @"Put in ZoomView & Scrollview" action:@selector(putInJGScrollViewControllerInZoomView:) keyEquivalent:@""];
  [item setTarget:target];
  item=[m addItemWithTitle: @"Remove from Scrollview" action:@selector(removeJGScrollViewController:) keyEquivalent:@""];
  [item setTarget:target];
  item=[m addItemWithTitle: @"Show Scrollview Panel" action:@selector(showJGScrollViewController:) keyEquivalent:@""];
  [item setTarget:target];
  item=[m addItemWithTitle: @"Print View" action:@selector(printScrollViewDocument:) keyEquivalent:@""];
  [item setTarget:target];
  item=[m addItemWithTitle: @"Print Scrollview" action:@selector(printScrollView:) keyEquivalent:@""];
  [item setTarget:target];
  item=[m addItemWithTitle: @"Print Scrollviews Visable Content" action:@selector(printScrollViewContent:) keyEquivalent:@""];
  [item setTarget:target];
}

+ (id)globalScrollViewController;
{
  static JGScrollViewController *sv=nil;
  if (!sv) {
    sv=[JGScrollViewController newScrollViewController];
  }
  return sv;
}
+ (id)newScrollViewController;
{
  id result=[[JGScrollViewController alloc] init];
  [result loadDefaultNib];
  return result;
}


// listen to APPKIT_EXTERN NSString *NSViewBoundsDidChangeNotification;
- (NSDictionary *)instanceVariables;
{
  NSMutableDictionary *dict=[NSMutableDictionary dictionary];
  INSERTINSTANCE(controllerPanel);
  INSERTINSTANCE(controllerView);
  INSERTINSTANCE(scrollViewWindow);
  INSERTINSTANCE(scrollView);
  INSERTINSTANCE(documentView);
  INSERTINSTANCE(zoomView);
  INSERTINSTANCE(zoomViewRulerController);
  INSERTINSTANCE(documentViewRulerController);
  INSERTINSTANCE(zoomViewSizeController);
  INSERTINSTANCE(documentViewSizeController);
  return dict;
}
- (BOOL)loadDefaultNib;
{
  return [NSBundle loadNibNamed:@"JGScrollViewController.nib" owner:self];
}
- (id)newScrollViewRulerController;
{
  id result=[[JGScrollViewRulerController alloc] init];
  [result setScrollView:scrollView];
  [NSBundle loadNibNamed:@"JGScrollViewRulerController.nib" owner:result];
  return result;
}
- (id)newViewSizeControllerWithTarget:(NSView *)target;
{
  id result=[[JGViewSizeController alloc] init];
  [result setTargetView:target];
  [result setEnclosingView:scrollView];
  [NSBundle loadNibNamed:@"JGViewSizeController.nib" owner:result];
  return result;
}
- (id)init;
{
  [super init];
  zoomView=nil;
  docSizeTitle=[@"DocSize" retain];
  zoomSizeTitle=[@"ZoomSize" retain];
  docRulerTitle=[@"DocRuler" retain];
  zoomRulerTitle=[@"ZoomRuler" retain];
  docSizeIdentifier=[@"DocSize" retain];
  zoomSizeIdentifier=[@"ZoomSize" retain];
  docRulerIdentifier=[@"DocRuler" retain];
  zoomRulerIdentifier=[@"ZoomRuler" retain];
  shouldHaveZoomView=NO;
  return self;
}
- (NSView *)controllerView;
{
  return controllerView;
}

- (void)setTabViewItemWithIdentifier:(NSString *)identifier label:(NSString *)label view:(NSView *)view;
{
  int idx=[controllerView indexOfTabViewItemWithIdentifier:identifier];
  NSTabViewItem *item;
  if (idx==NSNotFound) {
    item=[[[NSTabViewItem alloc] initWithIdentifier:identifier] autorelease];
    [controllerView addTabViewItem:item];
  } else {
    item=[controllerView tabViewItemAtIndex:idx];			    
  }
  [item setLabel:label];
  [item setView:view];
}

- (void)fillTabView;
{
  documentViewRulerController=[self newScrollViewRulerController];
  documentViewSizeController=[self newViewSizeControllerWithTarget:documentView];
  [self setTabViewItemWithIdentifier:docSizeIdentifier label:docSizeTitle view:[documentViewSizeController controllerView]];
  [self setTabViewItemWithIdentifier:docRulerIdentifier label:docRulerTitle view:[documentViewRulerController controllerView]];

  if (shouldHaveZoomView) {
    zoomViewRulerController=[self newScrollViewRulerController];
    zoomViewSizeController=[self newViewSizeControllerWithTarget:zoomView];    
    [self setTabViewItemWithIdentifier:zoomSizeIdentifier label:zoomSizeTitle view:[zoomViewSizeController controllerView]];
    [self setTabViewItemWithIdentifier:zoomRulerIdentifier label:zoomRulerTitle view:[zoomViewRulerController controllerView]];
  }
  
  [controllerView setDelegate:self];
}

// delegate message
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
/*" change clientView of the rulers according to the selected tabViewItem "*/
{
  NSView *clientView=nil;
  id rulerController=nil;
  if (tabView==controllerView) {
    if ([docRulerIdentifier isEqualToString:[tabViewItem identifier]]) {
      clientView=documentView;
      rulerController=documentViewRulerController;
    }
    else if ([zoomRulerIdentifier isEqualToString:[tabViewItem identifier]]) {
      clientView=zoomView;
      rulerController=zoomViewSizeController;
    }
    if (clientView) {
      static BOOL doChangeRulers=NO;
      BOOL needUpdate=NO;
      if (clientView != [[scrollView horizontalRulerView] clientView]) {
        needUpdate=YES;
        [[scrollView horizontalRulerView] setClientView:clientView];
      }
      if (clientView != [[scrollView verticalRulerView] clientView]) {
        needUpdate=YES;
        [[scrollView verticalRulerView] setClientView:clientView];        
      }
      if (doChangeRulers && needUpdate) {
        [rulerController updateScrollView];
        [rulerController updateButtons];
        [scrollView setNeedsDisplay:YES];        
      }
    }
  }
}

- (void)awakeFromNib;
{
  if (!documentView) {
    // There is a scrollViewWindow set up in, which is used, if there is no target documentView set.
    NSScrollView *v=[[[scrollViewWindow contentView] subviews] objectAtIndex:0];
    [self setScrollView:v];
    [self setDocumentView:[v documentView]]; // set what is allready in there
    [self foldViews];
    [scrollViewWindow orderFront:nil];
  }
  [self fillTabView];
}
- (void)setScrollView:(NSScrollView *)newScrollView;
{
  [newScrollView retain];
  [scrollView release];
  scrollView=newScrollView;
  [zoomViewRulerController setScrollView:scrollView];
  [documentViewRulerController setScrollView:scrollView];  
}
- (void)setDocumentView:(NSView *)newDocumentView;
{
  [newDocumentView retain];
  [zoomView replaceSubview:documentView with:newDocumentView];
  [documentView release];
  documentView=newDocumentView;  
  [documentViewSizeController setTargetView:documentView];
}
- (void)setShouldHaveZoomView:(BOOL)yn;
{
  shouldHaveZoomView=yn;
}
- (void)foldViews;
{
  NSRect frame;
  if (!documentView) return;

  frame=[documentView frame];
  if (!scrollView)
    scrollView=[[[NSScrollView alloc] initWithFrame:frame] autorelease];
  if (shouldHaveZoomView) {
    if (!zoomView) {
      zoomView=[[NSView alloc] initWithFrame:frame];
      [zoomView setAutoresizesSubviews:NO];
    }
    [zoomView addSubview:documentView];
    [scrollView setDocumentView:zoomView];
  }
  [scrollView setDocumentView:documentView];
}

- (void)makeScrollViewForNewDocumentView:(NSView *)newDocumentView;
{
  NSWindow *destWindow=[newDocumentView window];
  BOOL isContentView=(newDocumentView==[destWindow contentView]);
  [newDocumentView retain];
  scrollView=[[NSScrollView alloc] initWithFrame:[newDocumentView frame]];
  [scrollView setAutoresizingMask:[newDocumentView autoresizingMask]];
  if (isContentView)
    [destWindow setContentView:scrollView];
  else
    [[newDocumentView superview] replaceSubview:newDocumentView with:scrollView];
  documentView=newDocumentView;
  [self foldViews];
  [newDocumentView release];
  [scrollView setHasVerticalScroller:YES];
  [scrollView setHasHorizontalScroller:YES];
  [scrollView setHasVerticalRuler:YES];
  [scrollView setHasHorizontalRuler:YES];
  [scrollView setRulersVisible:YES];
  [scrollView setNeedsDisplay:YES];
}
- (void)replaceScrollViewWithDocumentView;
{
  NSWindow *destWindow=[scrollView window];
  BOOL isContentView=(scrollView==[destWindow contentView]);
  [documentView setFrame:[scrollView frame]];
  if (isContentView)
    [destWindow setContentView:documentView];
  else
    [[scrollView superview] replaceSubview:scrollView with:documentView];  
}
- (void)disposeControllerPanel;
{
  [controllerPanel close];
  [controllerPanel release];
  controllerPanel=nil;
}
- (IBAction)showPanel:(id)sender;
{
  if (!controllerPanel)
    [self loadDefaultNib];
  [controllerPanel orderFront:sender];
}
@end


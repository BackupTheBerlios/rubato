
#import "ObjectInspectorDriver.h"

#import "GenericObjectInspector.h"
#import <AppKit/NSBox.h>

/* There are two retain schemes for ObjectInspectorDriver and its inspectorPanel:
1. There exist an owner. Then the owner with the Nib loading, holds a retain on
globalInspector (ObjectInspectorDriver). So when owner releases globalInspector, and
it was the only retain, everything has to be cleaned (see dealloc).
2. There is no owner (an emancipated Inspector). Then the only way of releasing is to close
the window. So in that case, the ObjectInspectorDriver gets a notification, clears its references
to the window, and releases itself.
It is not clear, why it should not release the window, because the window has its
"release window when closed" checkmark off.
*/

// see comments about Notifications below at showKVBrowserWithSelection
#import "DistributorFScript.h"
@interface FSKVBrowsing
+ (id)kvBrowserWithRootObject:(id)obj interpreter:(id)interpreter;
@end

#define	setAccessor( type, var, setVar ) \
-(void)setVar:(type)newVar { \
    if ( newVar!=var) {  \
        if ( newVar!=(id)self ) \
            [newVar retain]; \
        if ( var && var!=(id)self) \
            [var release]; \
        var = newVar; \
	} \
} \


@implementation GlobalInspectorHolder
- (id)globalInspector;
{
  return globalInspector;
}
@end

@implementation ObjectInspectorDriver

setAccessor(id,objectInspector,setObjectInspector)

+ (BOOL)needsToRegisterAsObserver;
{
  static BOOL val=NO;
  return val;
}

- (void)awakeFromNib;
{
    if (!isAwake) {
	isAwake = YES;
	[inspectorPanel setFrameUsingName:NSStringFromClass([self class])];
	[inspectorPanel setBecomesKeyOnlyIfNeeded:YES];
        if ([ObjectInspectorDriver needsToRegisterAsObserver])
          [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(windowWillClose:)
                                              name:NSWindowWillCloseNotification
                                              object:inspectorPanel];
          
// jg inpectorMenuBtn is in OS PopUpMenu!
        [inspectorMenuBtn setTarget:self];  //jg? still necessary? //jg new
        [inspectorMenuBtn setAction:@selector(debugSelectInspectorSubview:)];//jg new  
//old       [[inspectorMenuBtn target] setTarget:self];  //jg? still necessary?
//       [[inspectorMenuBtn target] setAction:@selector(showInspectorSubview:)];
	[self loadDefaultInspector];
	if (objectInspector) { /* assure whether nib file was found and loaded */
	    [objectInspector setOwner:self];
	    /* get new inspector's view and install it in the inspectorBox */
	    [objectInspector setUpMenu];
	    [self selectInspectorSubview:nil];
	}
    }
}

- (void)dealloc;
{
  // on discussion about release of inspectorPanel see top of file
  static int doit=2;
//  NSLog(@"ObjectInspectorDriver dealloc");
  if ([ObjectInspectorDriver needsToRegisterAsObserver])
    [[NSNotificationCenter defaultCenter] removeObserver:self];
  [manager release];
  [selected release];
  [objectInspector release];

  // this is done in windowWillClose Notification.
  if (doit>0)
    [inspectorPanel setDelegate:nil];
  if (doit==2)
    [inspectorPanel release]; // it is our responsibility to release the panel!
  [super dealloc];
}

/* access to instance variables */
- setManager:aManager;
{
  if (manager!=aManager && manager!=self) {
    [aManager retain];
    [manager release];
    manager = aManager;
  }      
    return self;
}

- manager;
{
    return manager;
}

- (NSTabView *)tabView;
{
  return tabView;
}

- inspectorMenuBtn;
{
  return inspectorMenuBtn;
}
// is not called any more!?
- inspectorMenu;
{
//  return inspectorMenuBtn; // is: PopUpButton. 
    return [inspectorMenuBtn target]; // otherwise Rubato will not come up.
}


- updateMenuButton;
{
    [inspectorMenuBtn setTitle:[inspectorMenuBtn titleOfSelectedItem]];
    return self;
}


- setPatientEdited:(BOOL)flag;
{
    [objectInspector setPatientEdited:flag];
    return self;
}

- (void)setSelected: aPatient;
{
    if ([aPatient respondsToSelector:@selector(inspectorNibFile)] || !aPatient) {
        [aPatient retain];
        [selected release];
        selected = aPatient;
	if (selected != [objectInspector patient]) { /* only do something if really new */
	    if (![objectInspector patientNew] || ![objectInspector patient])  { /*patient from manager or is nil */
		if ([objectInspector patient] && selected) 
		    inspectorChanged = ![[selected inspectorNibFile] isEqualToString:
				    [[objectInspector patient] inspectorNibFile]];
		else
		    inspectorChanged = YES;
		[self loadInspectorFor:aPatient];
		[objectInspector setPatient:aPatient];
	    }
	}
	[objectInspector savePatient];
	[self displayPatient:self];
    } else {
      [self showKVBrowserForObject:aPatient];
  }
}

- selected;
{
    return selected;
}

- patient;
{
    return [objectInspector patient];
}

- savedPatient;
{
    return [objectInspector savedPatient];
}

- deselect:sender;
{
    [self setSelected:nil];
    return self;
}

- revert: sender;
{
    if (NSRunAlertPanel(@"Revert", @"Revert predicate to previous state?", @"Revert", @"Cancel", nil)) {
	[objectInspector revert:sender];
	[self displayPatient:self];
    }
    return self;
}


- showClass;
{
    id thePatient=[objectInspector patient];
    NSString *title;
    if (thePatient) 
//        if ([thePatient respondsToSelector:@selector(name)])
//            title=[thePatient name];
//        else
            title=NSStringFromClass([thePatient class]);
    else
	title=NSStringFromClass([self class]);
    [inspectorPanel setTitle:title];
    return self;
}

- displayPatient: sender
{
//jg #error WindowConversion: 'disableDisplay' is obsolete.  You can probably remove this call.  Typically drawing should happen as part of the update mechanism after every event.  Display is now optimized using the View setNeedsDisplay: method.  See the conversion doc for more info.
//jg    [inspectorPanel disableDisplay];
    [self loadInspectorFor:[objectInspector patient]];
    /* now display the predicate */
    if ([objectInspector patientChanged] || [objectInspector patientEdited]) {
	[objectInspector displayPatient:sender];
	[self showClass];
	if ([manager respondsToSelector:@selector(invalidate)]) [manager invalidate];
    }
    [inspectorPanel display];
    return self;
}

- (void)update;
{
// called by HarmoRubetteDriver:doCalculateRieman....

//jg #error WindowConversion: 'disableDisplay' is obsolete.  You can probably remove this call.  Typically drawing should happen as part of the update mechanism after every event.  Display is now optimized using the View setNeedsDisplay: method.  See the conversion doc for more info.
//jg     [inspectorPanel disableDisplay];
    
    [objectInspector displayPatient:self];
    
    [inspectorPanel display];
}


- loadInspectorFor:aPatient;
{
  if (inspectorChanged) { /* only replace inspector if new patient */
	/* load new inspector from nib file */
    if (![objectInspector use_tabView])
      [objectInspector saveCurrentViewContent:[inspectorBox contentView]]; // jg 18.9.01
    [(NSBox *)inspectorBox setContentView:(NSView *)nil];
    [self setObjectInspector:nil];
    if ([aPatient respondsToSelector:@selector(inspectorNibFile)]) {
      NSString *path;
      path = [[NSBundle bundleForClass:[aPatient class]] pathForResource:[aPatient inspectorNibFile] ofType:nil]; //ofType:@"nib" ist zuviel gewesen.
      if(![NSBundle loadNibFile:path externalNameTable:[NSDictionary dictionaryWithObjectsAndKeys:self, @"NSOwner", nil] withZone:[self zone]]) {
         /* if we couldn't get a valid path try it in the App's directory */
         [NSBundle loadNibNamed:[aPatient inspectorNibFile] owner:self];
      }
    }
    if (!objectInspector)  /* assure whether nib file was found and loaded */
      [self loadDefaultInspector];
    [objectInspector setOwner:self];
    [objectInspector setUpMenu];
    [self selectInspectorSubview:nil]; /* this sets the default view */
    inspectorChanged = NO;	
  }
  return self;
}

- loadDefaultInspector;
{
    if (!objectInspector)
	[NSBundle loadNibNamed:@"DefaultInspector.nib" owner:self];
    return self;
}

- debugSelectInspectorSubview:sender;
{
  return [self showInspectorSubview:sender];
}
- selectInspectorSubview:sender;
{
    NSRect boxRect = [inspectorBox frame];
    NSRect viewRect;
    id newInspectorView;
    BOOL usesTabView=[objectInspector use_tabView];
    if (!usesTabView)
      [objectInspector saveCurrentViewContent:[inspectorBox contentView]]; // jg 18.9.01
    else if (![inspectorBox contentView]) { // if we have no tabView
      static int type=NSNoTabsLineBorder;
      [tabView setTabViewType:type]; // bug? NSNoTabsNoBorder makes has reverse colors!
      [(NSBox *)inspectorBox setContentView:(NSView *)tabView];
    }
    [objectInspector selectInspectorSubview:sender];
    if (!usesTabView) {
      newInspectorView = [objectInspector inspectorSubview];
      [newInspectorView retain]; // jg new! Must be called here, otherwise error when new view is chosen (it looks like view is released at a certain position).
    } else {
      newInspectorView=[[tabView selectedTabViewItem] view];
    }
    viewRect = [newInspectorView frame];

    if (!usesTabView) 
      [(NSBox *)inspectorBox setContentView:newInspectorView];

    (&viewRect)->origin.x = (NSWidth(boxRect)-NSWidth(viewRect))/2.0;
    (&viewRect)->origin.y = (NSHeight(boxRect)-NSHeight(viewRect))/2.0;

    [newInspectorView setFrame:viewRect];
    [inspectorBox setNeedsDisplay:YES];
    return self;
}

- showInspectorSubview:sender;
{
    [self selectInspectorSubview:sender];
    [self showInspectorPanel:sender];
    return self;
}

- showInspectorPanel:sender;
{
    [inspectorPanel orderFront:self];
    return self;
}



// new code at 3.7.2002
- (void) emancipateFromWindow:(NSWindow *)w;
{  
  owner=nil;
  [inspectorPanel setShowsResizeIndicator:YES];
//  [inspectorPanel setReleasedWhenClosed:YES];
  
  if (w)
    [inspectorPanel cascadeTopLeftFromPoint:[w frame].origin];
}

- (void)windowWillClose:(NSNotification *)notification;
{
  // on discussion about release of inspectorPanel see top of file
  //  NSLog(@"panel count before close: %d",[inspectorPanel count])
  if (owner==nil) { // if emancipated
    static int doit=2;
    if (doit>0)
      [inspectorPanel setDelegate:nil]; // remove self as an observer
    if (doit>1)
      [self autorelease];
    if (doit>2)
      [inspectorPanel release];
    inspectorPanel=nil;
  }
}

- (void) emancipatedCopyOfInspector;
{
  GlobalInspectorHolder *holder=[[GlobalInspectorHolder alloc] init];
  ObjectInspectorDriver *driver;
  [NSBundle loadNibNamed:@"ResizableInspectorDriver.nib" owner:holder];
  driver=[holder globalInspector];
  [driver setManager:[self manager]];
  [driver setSelected:[self selected]];
  [driver showInspectorPanel:self];
  [driver emancipateFromWindow:inspectorPanel];
  [holder release];
}

- (void) emancipatedCopyOfInspector:(id)sender;
{
  [self emancipatedCopyOfInspector];
}

- (void) showKVBrowserForObject:(id)obj;
{
  // maybe this should be realized with a Notification
  // a request for being shown in a KV-Browser
  // which one that is, can be set in the system.
  // (possible: no reaction to Notification)
  id interpreter=[[Distributor globalDistributor] interpreter];
  [NSClassFromString(@"FSKVBrowser") kvBrowserWithRootObject:[self selected] interpreter:interpreter];
}
- (void) showKVBrowserWithSelection:(id)sender;
{
  [self showKVBrowserForObject:[self selected]];
}
- (void) setShortInfo:(NSString *)info;
{
  [shortInfoTextField setStringValue:info];
}
@end


@implementation ObjectInspectorDriver(WindowDelegate)
/* (WindowDelegate) methods */

- (BOOL)windowShouldClose:(id)sender;
{
    [inspectorPanel saveFrameUsingName:NSStringFromClass([self class])];
    return YES;
}

@end

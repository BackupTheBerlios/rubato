/* Version Control:
   $Header: /home/xubuntu/berlios_backup/github/tmp-cvs/rubato/Repository/Rubato/Frameworks/Rubato/ObjectInspector.subproj/GenericObjectInspector.m,v 1.2 2002/09/05 22:17:37 garbers Exp $
   $Log: GenericObjectInspector.m,v $
   Revision 1.2  2002/09/05 22:17:37  garbers
   Added FScript for all Rubettes (Toolbar)
   changed several (id)setValue:(id) to (void)setValue:
   ExternalRubette more comfortable
   PerformanceRubette has Play-Midi in Workspace menu item.

   Revision 1.1.1.1  2002/08/07 13:14:10  garbers
   Initial import

   Revision 1.1.1.1  2001/05/04 16:23:51  jg
   OSX build 1

   Revision 1.4  1999/11/04 14:18:36  jg
   vor Restaurierung mit RETAINCOUNTMINUS1

   Revision 1.3  1999/09/09 09:56:58  jg
   CVS-Test

   Revision 1.2  1999/09/09 09:52:52  jg
   Added CVS-Keywords

*/
 
#import "GenericObjectInspector.h"
#import <AppKit/NSWindow.h>

#ifdef DEBUG
#define DEBUG_GENERICOBJECTINSPECTOR
#endif
#import <Foundation/NSDebug.h>

#define USE_TABVIEW

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

@implementation GenericObjectInspector

// these might be set by nib-file
setAccessor(id,subviewContainer,setSubviewContainer)
setAccessor(id,defaultView,setDefaultView)
setAccessor(id,currentView,setCurrentView)

- (void)awakeFromNib;
{
    //[super awakeFromNib];
    if(!subviewContainer)
	[self setSubviewContainer:[panel contentView]];
    if (!defaultView)
	[self setDefaultView:[[subviewContainer subviews] objectAtIndex:0]];
    if (!currentView)
	[self setCurrentView:defaultView];
//    [self setUpMenu]; // dont do this here, so the subviews would be lost in awake, while owner or tabView is not yet set!
//    [self updateMenuSelection];
}

- init
{
    [super init];
    /* class-specific initialization goes here */
    use_tabView=YES;
    defaultTabViewIndex=0;
    return self;
}


- (void)dealloc
{
    /* class-specific initialization goes here */
    if (patientNew) {
//???	[patient release];
        patient = nil;
	patientChanged = YES;
	patientEdited = NO;
	patientNew = NO;
    }
    [panel release];
    [subviewContainer release];
    [defaultView release];
    [currentView release];
    panel = nil;
    { [super dealloc]; return; };
}

- (BOOL)use_tabView;
{
  return use_tabView;
}
- (NSTabView *)tabView;
{
  return [owner tabView];
}

- (NSPopUpButton *)inspectorMenuBtn;
{
  return [owner inspectorMenuBtn];
}

- (NSString *)identifierForInt:(int)i;
{
  return [NSStringFromClass([self class]) stringByAppendingFormat:@"%d",i];
}

- setUpMenu;
{
    int i, c = [[subviewContainer subviews] count];
    char keyAsCString[2];
    NSString *keyAsNSString, *title;
    NSArray *subviews;
    id subview;
    id menu = [self inspectorMenuBtn]; // jg inspectorMenuBtn?
//alt    id menu = [owner inspectorMenu];
    keyAsCString[1]=0;
//alt    while([menu count]) [menu removeItemAtIndex:0];
    while([menu numberOfItems]) 
      [menu removeItemAtIndex:0];
    if (use_tabView) {
        NSTabView *tv=[self tabView];
        NSEnumerator *e=[[tv tabViewItems] objectEnumerator];
        NSTabViewItem *item;
        while (item=[e nextObject]) {
          [tv removeTabViewItem:item];
        }
    }
    for(i=0; i<c; i++) {
        keyAsCString[0]=i+'1';
        keyAsNSString=[NSString jgStringWithCString:keyAsCString];
        subviews=[subviewContainer subviews];
        subview=[subviews  objectAtIndex:i];
        //[subview retain]; braucht mans?//jgHarmoBug
        title=[subview title];
        [menu addItemWithTitle:title]; // jg returns void
        {
        id newVar = [menu lastItem]; //jg returns NSMenuItem
        [newVar setKeyEquivalent:keyAsNSString];
        [newVar setTag:i];
    // not necessary: (also not good) PopUpMenu has target and action!
    //       [newVar setTarget:[menu target]];  
    //       [newVar setAction:@selector(showInspectorSubview:)]; 
        }
        if (use_tabView) {
          NSTabView *tv=[self tabView];
          NSTabViewItem *item=[[NSTabViewItem alloc] initWithIdentifier:[self identifierForInt:i]];
          [item setView:[subview contentView]];
          [tv addTabViewItem:item];
          if (subview==currentView) {
            [tv selectTabViewItem:item];
          } 
          if (subview==defaultView) {
            defaultTabViewIndex=i;
          }           
        }
    } // for
    return self;
}


/*
    NSLog(@"Buttons:%d\n",buttons);
    NSLog(@"Subviews:%d\n",[[subviewContainer subviews] count]);
    NSLog(@"Currentview:%d\n",index);
    NSLog(@"Button:%@\n",[[owner inspectorMenuBtn] description]);
    NSLog(@"Subviews:%@\n",[[subviewContainer subviews] description]);
*/
- updateMenuSelection;
{
// jg: i guess, the PopUpButton-Indices correspond with those from subviewContainer.
   int index;
#ifdef DEBUG_GENERICOBJECTINSPECTOR
    int buttons;
#endif
   if (use_tabView) {
     NSTabView *tv=[self tabView];
     index=[tv indexOfTabViewItem:[tv selectedTabViewItem]];
   } else 
     index=[[subviewContainer subviews] indexOfObject:currentView];
#ifdef DEBUG_GENERICOBJECTINSPECTOR
    buttons=[[self inspectorMenuBtn] numberOfItems];
    if (buttons>=index+1)
#endif
      [[self inspectorMenuBtn] selectItemAtIndex:index]; // jg only itemArray exist in NSMenu und NSPopUpButton. after Conversion this was itemMatrix, before itemList. // jg was inspectorMenu instead of ...Btn
#ifdef DEBUG_GENERICOBJECTINSPECTOR
    else {
      int i;
      NSLog(@"#buttons(%d)<1+SubviewIndex(%d)\n",buttons,index);
      NSLog(@"Buttons:\n");
      for(i=0;i<buttons;i++) {
        NSLog(@"   %@\n",[[[self inspectorMenuBtn] itemAtIndex:i] title]);
      }
      NSLog(@"Subviews:\n");
      for(i=0;i<[[subviewContainer subviews] count];i++) {
        NSLog(@"   %@\n",[[[subviewContainer subviews] objectAtIndex:i] title]);
      }
      [[self inspectorMenuBtn] selectItemAtIndex:0];
    }
#endif
   [owner updateMenuButton];
   return self;
}


- inspectorSubview;
{
// caution: if the returned contentView object is inserted in another view hierarchy it is removed from the currentView ! the following method will repair this later.
  if (use_tabView) {
    if (NSDebugEnabled) NSLog(@"-[GenericObjectInspector inspectorSubview] called with use_tabView");
    return nil;
  } else
    return [currentView contentView]; 
//   return currentView; // jg?
}

- (void)saveCurrentViewContent:(id)contentView; // jg 18.9.01
{
  if (use_tabView) 
    return; // do nothing
  if (contentView!=nil)
    if ([currentView contentView]==nil) // this check is important!
      [(NSBox *)currentView setContentView:contentView];
    else
      if (NSDebugEnabled) NSLog(@"saveCurrentViewContent mistake? o.k. when while ObjectInspectorDriver awakeFromNib?"); // set breakpoint here.  
}

- (void)setCurrentViewIndex:(int)index;
{
   if (use_tabView) {
    NSTabView *tv=[self tabView];
    [tv selectTabViewItemWithIdentifier:[self identifierForInt:index]];
   } else {
     [self setCurrentView:[[subviewContainer subviews] objectAtIndex:index]];
   }
}

- selectInspectorSubview:sender;
{
    int tag;
#ifdef DEBUG_GENERICOBJECTINSPECTOR
    int debug;
    if (sender==nil) debug=0;
    else if ([sender isKindOfClass:[NSPopUpButton class]]) debug=1;
    else if ([sender isKindOfClass:[NSMenuItem class]]) debug=2;
    else debug=3;
    if (debug==1) {
      tag=[[sender selectedItem] tag];
      if (tag>0)
        debug=4;
      [self setCurrentViewIndex:tag];
    } else if (debug==2) {
      [self setCurrentViewIndex:[sender tag]];
    }
    else  // nur hier original: 
      if([sender respondsToSelector:@selector(selectedCell)]) {
        tag=[[sender selectedCell] tag];
	if (tag>0)
	  debug=4;
        [self setCurrentViewIndex:tag]]; // NSMenuItem
#else
    if([sender respondsToSelector:@selector(selectedItem)]) {
      tag=[[sender selectedItem] tag];
      if (tag>0)
        [NSNumber numberWithInt:tag]; // set BreakPoint here
      [self setCurrentViewIndex:tag];
#endif

// jg alt:
/*    if([sender respondsToSelector:@selector(selectedCell)]) {
	currentView = [[subviewContainer subviews] objectAtIndex:[[sender selectedCell]tag]]; // geht bei NSMatrix.
*/
    } else if(!sender)
	[self setCurrentViewIndex:defaultTabViewIndex];
/* jg removed!
    else if([sender isKindOfClass:[NSBox class]]) {
	// SO, any view could be inserted like this!!!!
	[self setCurrentView:sender];
    }
*/
    
    [self updateMenuSelection];
    return self;
}

- setOwner:anOwner;
{
    owner = anOwner;
    return self;
}

- owner;
{
    return owner;
}


/* Patient maintenance */
- setPatient:aPatient;
{
    patientChanged = YES;
    patientEdited = NO;
    if (savedPatient != patient) {
	//[savedPatient free];
    
	//[savedPatient free];
    }
    patient = aPatient;
    [self savePatient];
    return self;
}

- patient;
{
    return patient;
}

- savedPatient;
{
    return savedPatient;
}

- savePatient;
{
    //if (!savedPatient)
	//savedPatient = [patient copy];
    savedPatient = nil;
    return self;
}

/* Getting & setting information about the patient */
- setPatientEdited:(BOOL)flag;
{
    patientEdited = flag;
    if (!patientNew && [[owner manager] respondsToSelector:@selector(setDocumentEdited:)]) 
	[[owner manager] setDocumentEdited:flag];
    if ([[owner manager] respondsToSelector:@selector(invalidate)]) 
	[[owner manager] invalidate];
    return self;
}

- (BOOL)patientEdited;
{
    return patientEdited;
}

- (BOOL)patientChanged;
{
    return patientChanged;
}

- (BOOL)patientNew;
{
    return patientNew;
}



- (void)setValue:(id)sender;
{
    [owner setPatientEdited:YES];
    [owner displayPatient:self];
}

- revert: sender;
{
    id reverted;
//???    [patient release];
    patient = nil;
    reverted = savedPatient;
    savedPatient = nil;
    patientEdited = NO;
    patientNew = NO;
    patientChanged = YES;
    [revertButton setEnabled:NO];
    return self;
}

- displayPatient: sender
{
    [revertButton setEnabled:savedPatient && patientEdited];
    patientChanged = NO;
    return self;
}


- showObjectInspector:sender
{
    if (!panel)
	    [NSBundle loadNibNamed:[patient inspectorNibFile] owner:self];
    [panel makeKeyAndOrderFront:self];
    return self;
}

@end

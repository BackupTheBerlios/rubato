/* Distributor.m */
/* Version Control:
   $Header: /home/xubuntu/berlios_backup/github/tmp-cvs/rubato/Repository/Rubato/Frameworks/Rubato/Distributor.m,v 1.1 2002/08/07 13:14:10 garbers Exp $
   $Log: Distributor.m,v $
   Revision 1.1  2002/08/07 13:14:10  garbers
   Initial revision

   Revision 1.1.1.1  2001/05/04 16:23:50  jg
   OSX build 1

   Revision 1.3  1999/12/09 10:30:06  jg
   vor Predicate Umbau

   Revision 1.2  1999/09/09 09:52:52  jg
   Added CVS-Keywords

*/

#import "Distributor.h"
#import "Rubato.h"
#import "ObjectInspectorDriver.h"
#import <RubatoDeprecatedCommonKit/JgFrameworkNibLoading.h>
#import <Foundation/NSDebug.h>

@implementation Distributor

+ (void)testLog;
{
  if (NSDebugEnabled) NSLog(@"Distributor exists");
}

- (id)init;
{
  [super init];
  tools=[[NSMutableDictionary alloc] init];
  archiverClassName=[@"NSArchiver" retain];
  unarchiverClassName=[@"JGNXCompatibleUnarchiver" retain]; // allow reading old Nextstep binaries
  return self;
}

- (void)dealloc;
{
  [tools release];
  [archiverClassName release];
  [unarchiverClassName release];
  [super dealloc];
}

- (void)awakeFromNib;
{
  static BOOL awake=NO;
  if (!awake) {
    awake=YES;
    [self setupRubetteMenuCell];
    [self insertBuildInRubetteMenuItems];
    [self globalFormManager]; // calls awakeFromNib again!
    [self globalInspector];   // calls awakeFromNib again!
    [self interpreterView];
  }
}

// usefull for all plugins.
+ (void)menu:(NSMenu *)m insertItemsForPlugInsOfType:(NSString *)type action:(SEL)selector target:(id)target;
{
  NSArray *a=[NSBundle pathsForResourcesOfType:type inDirectory:[[NSBundle mainBundle] builtInPlugInsPath]];
  NSEnumerator *e=[a objectEnumerator];
  NSString *str;
  while (str=[e nextObject]) {
    NSString *itemName=[[str lastPathComponent] stringByDeletingPathExtension];
    NSMenuItem *item=[[NSMenuItem alloc] initWithTitle:itemName action:selector keyEquivalent:@""];
    [item setTarget:target];
    [item setRepresentedObject:str];
    [m addItem:item];
    [item release];
  }
}

// should we check, if the rubettes respond to selectors?
- (NSMutableArray *)array:(NSArray *)a subarrayRespondingToSelector:(SEL)sel;
{
    NSMutableArray *subarray=[NSMutableArray array];
    NSEnumerator *e=[a objectEnumerator];
    id item;
    while (item=[e nextObject])
        if ([item respondsToSelector:sel])
            [subarray addObject:item];
    return subarray;
}

// helpers for setupMenuCell, although of general interest
- (void)makeRubettesPerformSelector:(SEL)sel;
{
    NSArray *subarray=[self array:[self rubetteList] subarrayRespondingToSelector:sel];
    [subarray makeObjectsPerformSelector:sel];
}
- (void)makeRubettesPerformSelector:(SEL)sel withObject:(id)obj;
{
    NSArray *subarray=[self array:[self rubetteList] subarrayRespondingToSelector:sel];
    [subarray makeObjectsPerformSelector:sel withObject:obj];
}
- (void)allRubettesPerform:(id)sender;
{
    NSString *title=[sender title];
    if ([title isEqualToString:@"Close All"]) {
        if (NSRunAlertPanel(@"Rubette: Close", @"Closing the Rubettes deletes all intermediate results. Proceed?", @"OK", @"Cancel", nil, NULL)==NSAlertDefaultReturn) {
            [self makeRubettesPerformSelector:@selector(closeRubette)];
        }
    } else if ([title isEqualToString:@"Show All"]) {
        [self makeRubettesPerformSelector:@selector(showWindow:) withObject:sender];
    } else if ([title isEqualToString:@"Hide All"]) {
        [self makeRubettesPerformSelector:@selector(hideWindow:) withObject:sender];
    }
}

- (void)setupRubetteMenuCell;
{
    NSMenu *menu = [[[NSMenu alloc] init] autorelease];
    NSMenu *loadMenu = [[[NSMenu alloc] init] autorelease];

    [[loadMenu addItemWithTitle:@"Load File..." action:@selector(loadRubette:) keyEquivalent:@""] setTarget:self];
    [[loadMenu addItemWithTitle:@"Load All Build-Ins" action:@selector(loadAllBuildInRubettes:) keyEquivalent:@""] setTarget:self];

    [[menu addItemWithTitle:@"Load Rubette" action:nil keyEquivalent:@""] setSubmenu:loadMenu];
    [[menu addItemWithTitle:@"Show All" action:@selector(allRubettesPerform:) keyEquivalent:@""] setTarget:self];
    [[menu addItemWithTitle:@"Hide All" action:@selector(allRubettesPerform:) keyEquivalent:@""] setTarget:self];
    [[menu addItemWithTitle:@"Close All" action:@selector(allRubettesPerform:) keyEquivalent:@""] setTarget:self];

    [menu setTitle:@"Rubettes"];
    if (!rubettesMenuCell)
        rubettesMenuCell=[[NSMenuItem alloc] initWithTitle:@"Rubettes" action:nil keyEquivalent:@""];
    [rubettesMenuCell setSubmenu:menu];
}


- (NSMenu *)buildInRubettesMenu;
{
  NSMenuItem *buildInRubettesMenuItem=[[[self rubettesMenuCell] submenu] itemWithTag:0];
  NSMenu *m=[buildInRubettesMenuItem submenu];
  return m;
}

- (void)insertBuildInRubetteMenuItems;
{
  NSMenu *m=[self buildInRubettesMenu];
  [Distributor menu:m insertItemsForPlugInsOfType:@"rubette" action:@selector(loadBuildInRubette:) target:self];
}

- (void)loadBuildInRubette:(id)buildInMenuItem;
{
  NSString *str=[buildInMenuItem representedObject];
  [self loadRubetteByFilename:str];
}

- (void)loadAllBuildInRubettes:(id)sender;
{
  NSMenu *m=[self buildInRubettesMenu];
  NSEnumerator *e=[[m itemArray] objectEnumerator];
  NSMenuItem *item;
  while (item=[e nextObject])
    [self loadBuildInRubette:item];
}


- (NSString*) archiverClassName
{
	return archiverClassName;
}
- (void) setArchiverClassName:(NSString*)newArchiverClassName
{
	[newArchiverClassName retain];
	[archiverClassName release];
	archiverClassName = newArchiverClassName;
}
- (NSString*) unarchiverClassName
{
        return unarchiverClassName;
}
- (void) setUnarchiverClassName:(NSString*)newUnarchiverClassName
{
        [newUnarchiverClassName retain];
        [unarchiverClassName release];
        unarchiverClassName = newUnarchiverClassName;
}

// overridden in DistributorFScript.m
- (id)interpreterView;
{
    return interpreterView;
}

- (id)interpreterWindow;
{
  return interpreterWindow;
}

- (void)createOwnInspector:(id)sender;
{
  if (!globalInspector)
      [self loadNibNamed:@"InspectorDriver.nib" forClass:[ObjectInspectorDriver class]];
  if (self==[Distributor globalDistributor])
    [globalInspector setShortInfo:@"Global"];
  else
    [globalInspector setShortInfo:@"Own"];
}
- (void)removeOwnInspector:(id)sender;
{
  if (globalInspector) {
    [globalInspector release];
    globalInspector=nil;
  }
}
- (void)toggleOwnInspector:(id)sender;
{
  if (globalInspector) {
    [self removeOwnInspector:sender];
  }
  else {
    [self createOwnInspector:sender];
  }
}
- (void)toggleOwnInspectorStateFromSender:(id)sender;
{
  BOOL r,s;
  r=[sender respondsToSelector:@selector(state)];
  if (r)
    s=[sender state];
  if (globalInspector) {
    if (!r || !s)
      [self removeOwnInspector:sender];
  }
  else {
    if (!r || s)
      [self createOwnInspector:sender];    
  }
}

- (void)unsetInspector:(id)inspector;
{
  if (inspector==globalInspector)
    globalInspector=nil;
}

- globalInspector;
{
  // if there is no own Inspector use the one from globalDistributor
  if (!globalInspector) {
    if (self==[Distributor globalDistributor])
      [self createOwnInspector:nil];
    return [[Distributor globalDistributor] globalInspector];
  }
  return globalInspector;
}

- predicateFinder;
{
    if (!predicateFinder)
        [self loadNibNamed:@"Find.nib" forClassName:@"PrediBaseDocument"];
    return predicateFinder;
}

- globalFormManager;
{
    if (!globalFormManager) {
        [self loadNibNamed:@"FormBrowser.nib" forClassName:@"FormManager"];
        [globalFormBrowser setBecomesKeyOnlyIfNeeded:YES];
    }
    return globalFormManager;
}

// this is necessary, because there are more Distributors out in the Multi-Document scheme.
- (id)globalPreferences;
{
  id preferenceProvider=[NSApp delegate];
  if (self==preferenceProvider)
    return preferences; // IB-Outlet of class RubatoPreferences
  else
    return [preferenceProvider globalPreferences];
}

- (NSString *)fileDirectory;
{
    return [[self globalPreferences] fileDirectory];
}

/* managing Rubettes */
- (NSString *)rubetteDirectory;
{
    return [[self globalPreferences] rubetteDirectory];
}

- (NSString *)operatorDirectory;
{
    return [[self globalPreferences] operatorDirectory];
}

- (NSString *)stemmaDirectory;
{
    return [[self globalPreferences] stemmaDirectory];
}

- (NSString *)weightDirectory;
{
    return [[self globalPreferences] weightDirectory];
}

/* menu management */
- rubettesMenuCell;
{
    return rubettesMenuCell;
}

// obsolete because of validateMenuItem (see also error messages in applicationDidFinishLaunching)
- (BOOL) menuActive:menuCell;
{
    /* this method is used by some menuCells to set their enable state;
     * it returns YES to the cell if the cell must be redrawn after a
     * state chage.
     */
    
    BOOL shouldBeEnabled;
    shouldBeEnabled = [[[NSApplication sharedApplication] mainWindow] isDocumentEdited];
    
    if ([menuCell isEnabled] != shouldBeEnabled) {
	/* MenuCell is not in the correct state:
	 * flip state according to shouldBeEnabled variable
	 */
	[menuCell setEnabled:shouldBeEnabled];
	return YES; /* redisplay */
    }
    
    return NO; /* no change */
}

//jg hope, that this is in responder chain.
- (BOOL)validateMenuItem:(NSMenuItem *)anItem;
{
  if((anItem==saveMenuCell) || (anItem==revertToSavedMenuCell))
    return [[[NSApplication sharedApplication] mainWindow] isDocumentEdited];
  else return YES;
}

- (id)globalFormBrowser;
{
//  return [[self globalDistributor] globalFormBrowser];
  return globalFormBrowser;
}
@end

@implementation Distributor(Overridden)
- (void)setPrediBase:(id<PrediBase>)pb;
{
  NSAssert(((!pb) || [pb conformsToProtocol:@protocol(PrediBase)]),@"Distributor setPrediBase");
    if ([self prediBase]!=pb) {
        prediBase = pb;
        [[self rubetteList] makeObjectsPerformSelector:@selector(setPrediBase:) withObject:pb];
    }
}
- (id)prediBase;
{
  return prediBase;
}

- (void)setActiveRubette:(id<RubetteDriver>)newActiveRubette;
/*" nonretained "*/
{
  static BOOL debugMode=NO;
  if (!newActiveRubette || [newActiveRubette conformsToProtocol:@protocol(RubetteDriver)]) {
    if (activeRubette) 
      if (debugMode) NSLog(@"Rubette %@ to be deactivated",[activeRubette rubetteKey]);
    else
      if (debugMode) NSLog(@"No Rubette to be deactivated");
    if (newActiveRubette) {
      if (debugMode) NSLog(@"Rubette %@ to be activated",[newActiveRubette rubetteKey]);   
      [self setPrediBase:[newActiveRubette prediBase]];
    } else {
      if (debugMode) NSLog(@"No Rubette to be activated");      
    }
    [[self rubetteList] makeObjectsPerformSelector:@selector(rubetteChanged:) withObject:newActiveRubette];
    activeRubette=newActiveRubette;
  }
}

- activeRubette;
{
    return activeRubette;
}

//@implementation AbstractDistributor (AddingTools)
// primitives
- (NSMenuItem *)toolsMenuItem; // where to put the toolMenuItems
{
  return rubettesMenuCell;
}
- (NSMutableDictionary *)toolDictionary; // where to put the tools
{
  return tools;
}
@end


@implementation Distributor(ApplicationDelegate)

/* ApplicationDelegate methods */
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
//    id documentMenu = [documentMenuCell target];
//    id editMenu = [editMenuCell target];

// see    validateMenuItem
//#error MenuCell method setUpdateAction:forMenu: is obsolete, use validateCell: from NSMenuActionResponder protocol instead.
//    [saveMenuCell setUpdateAction:@selector(menuActive:) forMenu:documentMenu];    
//#error MenuCell method setUpdateAction:forMenu: is obsolete, use validateCell: from NSMenuActionResponder protocol instead.
//    [revertToSavedMenuCell setUpdateAction:@selector(menuActive:) forMenu:documentMenu];
//#error MenuCell method setUpdateAction:forMenu: is obsolete, use validateCell: from NSMenuActionResponder protocol instead.
//    [undoMenuCell setUpdateAction:@selector(validateCommand:) forMenu:editMenu];
//#error MenuCell method setUpdateAction:forMenu: is obsolete, use validateCell: from NSMenuActionResponder protocol instead.
//    [redoMenuCell setUpdateAction:@selector(validateCommand:) forMenu:editMenu];
    
// #error ApplicationConversion: 'setAutoupdate:' is obsolete ; autoupdate is always on at the application level
//     [[NSApplication sharedApplication] setAutoupdate:YES];
    /* set automatic updating of menuCells.
     * This MAY DECREASE PERFORMANCE.
     */
    /* now load the rubettes */

    [self showInfoPanel:self];
  [NSTimer scheduledTimerWithTimeInterval:5.0 target:infoPanel selector:@selector(performClose:) userInfo:nil repeats:NO];
}

// #error Application Conversion: 'appAcceptsAnotherFile:' is obsolete
// - (BOOL)appAcceptsAnotherFile:sender;
// {
//    return YES;/* no limitationon open file number */
// }

#if 0
- (int)application:sender openFile:(NSString *)filename;
{
    NSString *aType=[filename pathExtension];
    [self showPredicateBrowser:self];
    if ([aType isEqualToString:ns_PredFileType]) {/* if its a .pred File*/
	if (prediBase) {
	    if ([prediBase loadFile:filename])
	    return YES;
	}
    }
    return NO;
}
#endif

#if 0
- (BOOL)applicationShouldTerminate:(id)sender;
{
    if ([self countEditedWindows]>0) {
	int q = NSRunAlertPanel(@"Quit", @"There are edited windows.", @"Review Unsaved", @"Quit Anyway", @"Cancel");
	
	if (q==1) { // Review 
	    int i;
	    NSArray *aWindowList = [[NSApplication sharedApplication] windows];
	    
	    for (i=0; i<[aWindowList count]; i++) {
		id aWindow = [aWindowList objectAtIndex:i];
		
		if ([[aWindow delegate] respondsToSelector:@selector(save:)]) {
		    [aWindow performClose:nil];
		}
	    }
	    return YES;
	}
	if (q==-1) { // Cancel 
	    return NO;
	}
    }
    [globalFormManager windowShouldClose:nil];
    [globalInspector windowShouldClose:nil];
    [predicateFinder windowShouldClose:nil];
    [interpreterWindow windowShouldClose:nil];
    return YES; // quit 
}
#endif
@end

@implementation Distributor(NibLoading)
- (BOOL)loadNibNamed:(NSString *)nibName forClass:(id)cls;
{
// jg: does this work? It uses loadNibFile, which maybe needs a whole path! No, it doesnt.
  id bundle=[NSBundle bundleForClass:cls];
  id table=[NSDictionary dictionaryWithObject:self forKey:@"NSOwner"];
  BOOL success=[bundle loadNibFile:nibName externalNameTable:table withZone:[self zone]];
  return success; // set breakpoint here 
}
- (BOOL)loadNibNamed:(NSString *)nibName forClassName:(NSString *)className;
{
  id cls=NSClassFromString(className);
  return [self loadNibNamed:nibName forClass:cls];
}
@end


#import "NibDrivenRubetteDriver.h"
#import "RubetteDriver.h"

// a NibDrivenRubetteDriver has one nib, that is loaded.
@implementation NibDrivenRubetteDriver

// bundle is the bundle of the actual RubetteDriver subclass, where also the nib should reside.
+ (void)initializeBundle:(NSBundle *)bundle withDistributor:(id/* <Distributor> */)aDistributor display:(BOOL)display;
{
  NSString *nib=[self nibFileName];
//  id table=[NSDictionary dictionaryWithObject:aDistributor forKey:@"NSOwner"];
  id myInstance=[[self alloc] init];
  id table=[NSDictionary dictionaryWithObject:myInstance forKey:@"NSOwner"];
  [bundle loadNibFile:nib externalNameTable:table withZone:[self zone]];
  if ([myInstance respondsToSelector:@selector(wasAwakeFromNib:)]) 
    [myInstance wasAwakeFromNib:aDistributor]; // set owner=aDistributor + sign in.
}

/* class methods to be overriden */
+ (NSString *)nibFileName;
{
    return @"DefaultRubette.nib";
}

+ (const char *)rubetteName;
{
    return "Rubette";
}

- (NSString *)nibFileName;
{
    return [[self class] nibFileName];
}


- (const char *)rubetteName;
{
    return [[self class] rubetteName];
}

- (NSArray *)attributeKeys;
{
    static NSArray *keys=nil;
    if (!keys)
        keys=[[NSArray alloc] initWithObjects:@"rubetteKey",@"writeRubetteDataOnToolChange",@"myDataChanged",nil];
    return keys;
}
- (NSArray *)toOneRelationshipKeys;
{
    static NSArray *keys=nil;
    if (!keys)
        keys=[[NSArray alloc] initWithObjects:@"owner",@"prediBase",@"rubetteObject",nil];
    return keys;
}

  
- init;
{
    [super init];
    myMenu = nil;
    toolMenuItem=nil;
    rubetteObject=nil;  
    rubetteKey = [[NSString stringWithCString:[[self class] rubetteName]] retain];
    writeRubetteDataOnToolChange=YES;
    myDataChanged = NO;
    return self;
}

- (void)dealloc;
{
  [toolMenuItem release];
  [myMenu release];
  [rubetteKey release];
  [super dealloc];
}

// Menu methods
- setUpMenu;
{
    if (!myMenu) {
        NSString *menuName=[[self rubetteKey] stringByAppendingString:@" - Rubette"];
        myMenu = [[NSMenu allocWithZone:[[self distributor] zone]]initWithTitle:menuName];
        [[myMenu addItemWithTitle:@"Info" action:@selector(showRubetteInfoPanel:) keyEquivalent:@""] setTarget:self];
//        [[myMenu addItemWithTitle:@"Import" action:@selector(showFindPredicatesWindow:) keyEquivalent:@""] setTarget:self];
        [[myMenu addItemWithTitle:@"Help" action:@selector(showRubetteHelpPanel:) keyEquivalent:@""] setTarget:self];
        [self insertCustomMenuCells];
        [[myMenu addItemWithTitle:@"Show" action:@selector(showWindow:) keyEquivalent:@""] setTarget:self];
        [[myMenu addItemWithTitle:@"Hide" action:@selector(hideWindow:) keyEquivalent:@""] setTarget:self];
        [[myMenu addItemWithTitle:@"Close" action:@selector(closeRubette:) keyEquivalent:@""] setTarget:self];	
    }
    return self;
}

- insertCustomMenuCells;
{
    return self;
}

- rubetteMenu;
{
    return myMenu;
}

- (NSMenuItem *)toolMenuItem;
{
  if (!toolMenuItem) {
    id menu;
    [self setUpMenu];
    menu=[self rubetteMenu];
    toolMenuItem = [[NSMenuItem alloc] initWithTitle:[self rubetteKey] action:(SEL)nil keyEquivalent:@""];
    if (menu)
      [toolMenuItem setSubmenu:menu];
  }
  return toolMenuItem;
}

- (NSString*) rubetteKey
{
        return rubetteKey;
}

- (void) setRubetteKey:(NSString*)newRubetteKey
{
        [newRubetteKey retain];
        [rubetteKey release];
        rubetteKey = newRubetteKey;
}   

- (id<PrediBase>)prediBase;
{
  return prediBase;
}
- (void)setPrediBase:(id<PrediBase>)aPrediBase;
{
  NSString *myRubetteKey;
  myRubetteKey=[self rubetteKey];
  if (!aPrediBase) { // signal for: remove pointers to self in prediBase
    if ([self dataChanged])
        [self writeRubetteData];
    [[self rubetteObject] setExtendedRubetteDriver:nil];
    [prediBase removeCustomObjectForKey:myRubetteKey]; // ?? really?
  } else if ([aPrediBase conformsToProtocol:@protocol(PrediBase)]) {
    id newRubetteObject;
    if ([self dataChanged])
        [self writeRubetteData];
    [[self rubetteObject] setExtendedRubetteDriver:nil];
    newRubetteObject=[aPrediBase customObjectForKey:myRubetteKey];
    if (!newRubetteObject) {
      newRubetteObject=[[[self rubetteObjectClass] alloc] initWithExtendedRubetteDriver:self];
      [aPrediBase setCustomObject:newRubetteObject forKey:myRubetteKey];
      [newRubetteObject release];
    }
    [self setRubetteObject:newRubetteObject];
    [[self rubetteObject] setExtendedRubetteDriver:self];
  }
  prediBase=aPrediBase;
}

- (void)rubetteChanged:(id<RubetteDriver>)newActiveRubette;
{
  if (newActiveRubette!=self)
     if ([self writeRubetteDataOnToolChange]) // ??? rework Rubettes for: && [self dataChanged])
       [self writeRubetteData];
}

// derived, but can be overridden
- (id/* <Distributor> */)distributor; 
{
  return owner;
}

- (id)rubetteObjectClass; // to be overridden
{
  return nil;
}

- (id)rubetteObject;
{
  return rubetteObject;
}

- (void)setRubetteObject:(id)object;
{
  [object retain];
  [rubetteObject release];
  rubetteObject=object;
}

- (void)readWeightParameters;
{
   [rubetteObject readWeightParameters];
}

- (void)writeWeightParameters;
{
  [rubetteObject writeWeightParameters];
}

- (BOOL) writeRubetteDataOnToolChange
{
	return writeRubetteDataOnToolChange;
}

- (void) setWriteRubetteDataOnToolChange:(BOOL)newWriteRubetteDataOnToolChange
{
	writeRubetteDataOnToolChange = newWriteRubetteDataOnToolChange;
}

- (BOOL)dataChanged;
{
  return myDataChanged;
}
- (void)setDataChanged:(BOOL)yn;
{
  myDataChanged=yn;
}

// to be overridden
- (void)writeRubetteData;
{
}
@end

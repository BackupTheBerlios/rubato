
#import "ExternalRubetteDriver.h"
#import <Predicates/PredicateProtocol.h>
#import <Predicates/GenericForm.h>
#import <Rubette/Weight.h>
#import "JGTableDataViewController.h"

#import <FScript/FScript.h>

@implementation ExternalRubetteDriver
+ (const char *)rubetteName;
{
    return "External";
}

+ (id)rubetteObjectClass;
{
  return [ExternalRubette class];
}

- init;
{
    [super init];
    return self;
}

- (void)closeRubetteWindows1;
{
  [interpreterWindow close];
  interpreterWindow=nil;
  interpreterView=nil;
}
- (void)closeRubetteWindows;
{
  [self closeRubetteWindows1];
  [super closeRubetteWindows];
}

- (void)dealloc;
{
  [self closeRubetteWindows1];
  [tableViewController release];
    [super dealloc];
}

- (ExternalRubette *)externalObject;
{
  return (ExternalRubette *)rubetteObject;
}

- customAwakeFromNib;
{
  tableViewController=[[JGTableDataViewController controllerWithTableView:tableView] retain];
  [tableView setDelegate:tableViewController];
  [[self externalObject] setTableData:[tableViewController tableData]];
  return self;
}

- (id)interpreterWindowLoadIfNeeded:(BOOL)loadIfNeeded;
{
  if (loadIfNeeded && !interpreterWindow) {
    id interpreter;
    [NSBundle loadNibNamed:@"FScript.nib" owner:self];
    interpreter=[self interpreter];
    [interpreter setShouldJournal:NO];
    [interpreter setObject:self forIdentifier:@"externalRubetteDriver"];
  }
  return interpreterWindow;
}
- (IBAction)showInterpreterWindow:(id)sender;
{
  [self interpreterWindowLoadIfNeeded:YES];
  [interpreterWindow makeKeyAndOrderFront:nil];
}
- (NSWindow *)interpreterWindow;
{
  return interpreterWindow;
}
- (id)interpreterView;
{
  return interpreterView;
}
- (id)interpreter;
{
  return [interpreterView interpreter];
}

- (void)readCustomData;
{
}

- (void)writeCustomData;
{
}

- (void)readWeight;
{
    [super readWeight];
}

- loadWeight:sender;
{
    [super loadWeight:sender];
  // here update the tableData?
    return self;
}


- (void)doSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
{
  [super doSearchWithFindPredicateSpecification:specification];
  [self makePredList];
}

- (void)initSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
{
  [super initSearchWithFindPredicateSpecification:specification];
  [self makePredList];
}

- (void)makePredList;
{
  [[self externalObject] makePredList];
  [tableView reloadData];
}

- doCalculateWeight:sender;
{
//    [self makePredList];
    [self calculateWeight];
//    [self doWriteData:self];

    return self;
}

- (void)calculateWeight;
{
  [[self externalObject] calculateWeight];
  [self afterCreatingNewWeight];
}

/* methods to be overridden by subclasses */
- insertCustomMenuCells;
{
    [[myMenu addItemWithTitle:@"Load Weight" action:@selector(loadWeight:) keyEquivalent:@""] setTarget:self];
    [[myMenu addItemWithTitle:@"Save Weight As" action:@selector(saveWeightAs:) keyEquivalent:@""] setTarget:self];
    return self;
}

+ (NSString *)nibFileName;
{
  return @"ExternalRubette.nib";
}


/* window management */
- (IBAction)showWindow:(id)sender;
{
    [super showWindow:sender];
}

- hideWindow:sender;
{
    return [super hideWindow:sender];
}

- (void)copy:(id)sender;
{
  [tableViewController copy:sender];
}

- (IBAction)showTableViewTextController:(id)sender;
{
  [tableViewController showTableViewTextController:sender];
}
@end


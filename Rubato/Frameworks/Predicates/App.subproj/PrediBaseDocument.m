#import "PrediBaseDocument.h"

#import <Rubato/RubatoController.h>
#import <Predicates/predikit.h>
#import <JGFoundation/JGLogUnarchiver.h>
//#import <RubatoDeprecatedCommonKit/StickyNXImage.h>

#import "PredicateManager.h"
#import "PredicateInspector.h"
#import "FormManager.h"
#import <Rubato/Distributor.h>

@implementation PrediBaseDocument
- init;
{
  static BOOL useOwn=YES;
  [super init];
  useOwnDistributor=useOwn;
  myDistributor=nil;
  mustInvalidate=NO;
  [self scorePredicate];
  return self;
}

- (void)shouldCloseWindowController:(NSWindowController *)windowController delegate:(id)delegate shouldCloseSelector:(SEL)callback contextInfo:(void *)contextInfo;
{ // delegate==window callback==_document:shouldClose:contextInfo: contextInfo==0
  [super shouldCloseWindowController:(NSWindowController *)windowController delegate:(id)delegate shouldCloseSelector:(SEL)callback contextInfo:(void *)contextInfo];
}
// after return of [WindowController shouldCloseDocument]
- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo;
{// delegate==window callback==_document:shouldClose:contextInfo: contextInfo==0
  [super canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo];
}

// This is not called automatically. I do not know why. 
- (void)close;
{
  [[self distributor] makeRubettesPerformSelector:@selector(closeRubette)];
  [super close];
}

- (id)scorePredicate;
{
    id scorePredicate=[self predicateForKey:@"Scores"];
    if (!scorePredicate) {
        scorePredicate = [[CompoundForm listForm] makePredicateFromZone:[self zone]];
        [scorePredicate setNameString:"Scores"];
        [self setPredicate:scorePredicate forKey:@"Scores"];
    }
    return scorePredicate;
}


// overrides PrediBaseDocumentBasics
- (id/* <Distributor> */)distributor;
{
    if (useOwnDistributor) {
        if (!myDistributor) {
            myDistributor=[[Distributor alloc] init];
            [myDistributor setupRubetteMenuCell];
            [myDistributor insertBuildInRubetteMenuItems];            
        }
        return myDistributor;
    }  else
        return [[NSApplication sharedApplication] delegate];
}

- (void)dealloc;
{
  [myDistributor release];
  [super dealloc];
}

- (void)invalidateSetRoot:(BOOL)sr;
{
  int i;
  NSArray *wcs=[self windowControllers];
  PredicateManager *wc;
  id p=[self predicateList];
  for (i=0; i<[wcs count]; i++) {
    wc=[wcs objectAtIndex:i];
    if (sr)
      if ([wc respondsToSelector:@selector(setRootPredicate:)])
        [wc setRootPredicate:p];
    if ([wc respondsToSelector:@selector(setBrowserIsValid:)])
      [wc setBrowserIsValid:NO];
    if ([wc respondsToSelector:@selector(invalidate)])
      [wc invalidate];
  }
}

- (void)willSetPredicate:(id)object forKey:(NSString *)key; // hook
{
  id setPredicateForKeyCache=[self predicateForKey:key];
  mustInvalidate=(setPredicateForKeyCache!=object);
}
- (void)didSetPredicate:(id)object forKey:(NSString *)key; // hook
{
  if (mustInvalidate)
    [self invalidateSetRoot:YES];
  mustInvalidate=NO;
}

- (void)invalidate;
{
  [self invalidateSetRoot:NO];
}

- (id)predicateList;
{
  NSDictionary *predDict=[self predicateDictionary];
  id myPredicateList = [[CompoundForm listForm] makePredicateFromZone:[self zone]];
  NSEnumerator *e=[predDict keyEnumerator];
  NSString *key;
  [myPredicateList setNameString:"List Of ALL Predicates"];
  while (key=[e nextObject]) {
    [myPredicateList setValue:[predDict objectForKey:key]];
  }
  return [myPredicateList autorelease];
}


/* form list management */

- addPredicateForm:aForm;
{
    if ([aForm isKindOfClass:[GenericForm class]]) { // not nil & really form 
        [[self formList] setValue:aForm];
        if ([aForm count]>1) {
            unsigned int theCount = [aForm count], index;
            for (index = 0;index<theCount;index++) {
                [self addPredicateForm:[aForm getValueAt:index]];
            }
        }
    }
    return self;
}

- addForm:aForm;
{
    if ([aForm isKindOfClass:[GenericForm class]]) { // not nil & really form 
        [self addPredicateForm:aForm];
        [self updateChangeCount:NSChangeDone];
    } else
        NSBeep();
    return self;
}


- formList; // might be removed
{
    return  [self predicateForKey:@"Forms"];
}


- addPredicate: aPredicate;
{
    /* insert it */
    if ([aPredicate isKindOfClass:[GenericForm class]])
        [self addForm: aPredicate];
    else
        [self addPredicate: aPredicate Before: nil];
    return self;
}

- addPredicate: aPredicate Before: bPredicate;
{
    unsigned int index;
    id parent;

    if (aPredicate) {
      /* decide insertion point of new predicates by current selection*/
      parent = (([self selected]==nil) ? [self predicateForKey:@"Scores"] : [self selected]);

      if (!parent && aPredicate && !bPredicate) {
        [self setPredicate:aPredicate forKey:@"Scores"];
      } else {
        /* determine bPredicates index */
        index = [parent indexOfValue: bPredicate];

        if (!(index==NSNotFound))
            [parent setValueAt:index to:aPredicate];
        else {
            [parent setValue: aPredicate];/* insert aPredicate */
        }
        /* set selection to the new inserted predicate*/
        [self updateChangeCount:NSChangeDone];
      }
    } else
        NSBeep();
    return self;
}


- (void)updateChangeCount:(NSDocumentChangeType)change;
{
  [super updateChangeCount:change];
  [self invalidate];
}

- (void)setDocumentEdited:(BOOL)flag;
{
  if (flag) {
    [self updateChangeCount:NSChangeDone];
  }
}

- (void)addPredicateBrowserForPredicate:(GenericPredicate *)pred;
{
  id pm=[[PredicateManager alloc] initWithWindowNibName:@"PrediBaseBrowser"];
  [pm setRootPredicate:pred];
  [self addWindowController:pm];
  [pm window]; // first addWindowController, then window
  [pm showWindow:nil]; // this is necessary for the 2nd, 3rd etc. windowController
  [pm setDocumentEdited:[self isDocumentEdited]];
}

- (void)addPredicateBrowser;
{
  [self addPredicateBrowserForPredicate:[self predicateList]];
}

- (void)addPredicateBrowser:(id)sender;
{
  [self addPredicateBrowser];
}
- (void)addRubetteBrowser:(id)sender;
{
  // remove IBs
}


- (void)makeWindowControllers;
{
  [self addPredicateBrowser];
//  [subDocumentNode addSubDocumentsBrowser];
  [self showWindows];
}


@end

/*
#if 0


- formManager;
{
    return formManager;
}



- init
{
  id listForm;
  id scorePredicate;

  [super init];

  customObjectDictionary=[[NSMutableDictionary alloc] init];
  predicateDictionary=[[NSMutableDictionary alloc] init];
  weightDictionary=[[NSMutableDictionary alloc] init];

//  listForm = [[formManager formList] getFirstPredicateOfNameString:"ListForm"];
    listForm = [CompoundForm listForm];

    myFormList = [listForm makePredicateFromZone:[self zone]];
    [[myFormList setNameString:"List Of ALL Forms"]setValueAt:0 to:listForm];

    myPredicateList = [listForm makePredicateFromZone:[self zone]];
    [myPredicateList setNameString:"List Of ALL Predicates"];

    scorePredicate = [listForm makePredicateFromZone:[self zone]];
    [scorePredicate setNameString:"Scores"];
    [self setPredicate:scorePredicate forKey:@"Scores"];

//    myRubetteList = [listForm makePredicateFromZone:[self zone]];
//    [myRubetteList setNameString:"List Of ALL Rubette Data"];

    selected=nil;
    return self;
}


// jg?? was ist mit weightList?
- (void)dealloc {
//    if (myRubetteList)
//        [myRubetteList release];
    if (myPredicateList)
        [myPredicateList release];
    if (myFormList)
        [myFormList release];
    [customObjectDictionary removeAllObjects];
    [customObjectDictionary release];
    [super dealloc];
}

// save & load methods 
- (void)setFileName:(NSString*) aFileName;
{
  char *aFilename;
  [super setFileName:aFileName];
  aFilename=[aFileName lastPathComponent];
  [myPredicateList setNameString:aFilename];
  [myFormList setNameString:aFilename];
}

- (NSData *)dataRepresentationOfType:(NSString *)aType;
{
  id theStream=nil;
  NSMutableData *data=[NSMutableData data];
  id returnValue = self; // this variable is used in the load handler macro 
  id myData;
  NSArray *a=[NSArray arrayWithObjects:myPredicateList,myFormList, myWeightList, nil];
//  NSArray *a=[NSArray arrayWithObjects:myPredicateList,myFormList, myRubetteList, myWeightList, nil];
  id archiverClass=nil;
  //  NSAssert([aType isEqualToString:@"PrediBase"], @"Unknown type");
  if ([aType isEqualToString:@"PrediBase"]) {
    archiverClass=[NSArchiver class];
  }
#ifdef WITH_MPWXmlKit
    else if ([aType isEqualToString:@"PrediBaseXML"]) {
      archiverClass=[MPWXmlArchiver class];
  }
#endif
  NS_DURING
    myData=[archiverClass archivedDataWithRootObject:a];
  NS_HANDLER
  LOAD_HANDLER  // a load handler macro in macros.h 
  NS_ENDHANDLER // end of handler 
  if (returnValue)
    return myData
  else
    return nil;
}


- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType
{
  BOOL retVal=NO;
  id processString=[NSString stringWithFormat:@"Loading %@ File:",docType];
  id archiverClass=nil;
  if ([docType isEqualToString:@"PrediBase"]) {
    archiverClass=[JGNXCompatibleUnarchiver class];
  }
#ifdef WITH_MPWXmlKit
    else if ([aType isEqualToString:@"PrediBaseXML"]) {
      archiverClass=[MPWXmlArchiver class];
  }
#endif
  retVal=[self loadFileWithData:[NSData dataWithContentsOfFile:fileName] archiverClass:archiverClass];
  if (!retVal) {
    NSRunAlertPanel(processString, @"Cannot load file %@", @"Sorry", nil, nil, fileName);
  }
  [self setFileName:fileName];
  //  [self invalidate]; // jg 14.6.
  return retVal;
}



- (BOOL)loadFileWithData:(NSData *)data archiverClass:(id)archiverClass;
{
  NSArray *a;
        id returnValue = self; // this variable is used in the load handler macro 
        [myPredicateList release]; // free current list object 
        [myFormList release]; // free current formlist object 

        NS_DURING
        a=[archiverClass unarchiveObjectWithData:data];
        myPredicateList = [[a objectAtIndex:0] retain];
        myFormList = [[a objectAtIndex:1] retain];
        //        myRubetteList = [[a objectAtIndex:] retain];
        myWeightList = [[a objectAtIndex:2] retain];
        NS_HANDLER
        LOAD_HANDLER  // a load handler macro in macros.h 
        myPredicateList = nil;
        myFormList = nil;
//        myRubetteList = nil;
        myWeightList = nil;
        NS_ENDHANDLER // end of handler 

        if (![myWeightList isKindOfClass:[NSMutableArray class]]) {
            // convert the old List objects to
                // RefCounList or OrderedList objects
                //
          id list = myWeightList;
          myWeightList = [[NSMutableArray alloc]initWithCapacity:[list count]];
          [myWeightList addObjectsFromArray:list];
          [list release];
        } else
          [myWeightList ref]; // jgrelease?

        if (!myFormList) { // failed to read forms, create a list 
            id listForm;
//            listForm = [[formManager formList] getFirstPredicateOfNameString:"ListForm"];
            listForm = [CompoundForm listForm];

            myFormList = [listForm makePredicateFromZone:[self zone]];
            [[myFormList setNameString:"List Of ALL Forms"]setValueAt:0 to:listForm];
        }

        if (!myPredicateList) { // failed to read predicates, create a list 
            id listForm = [myFormList getValueOf:"ListForm"];
            myPredicateList = [listForm makePredicateFromZone:[self zone]];
            [myPredicateList setNameString:"List Of ALL Predicates"];
        }
        if (returnValue) return YES;
        else return NO;
}

#endif
*/

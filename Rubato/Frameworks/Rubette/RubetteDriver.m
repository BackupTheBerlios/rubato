/* RubetteDriver.m */

#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Predicates/predikit.h>
#import <JGFoundation/JGLogUnarchiver.h>
#import <JGAppKit/JGSubDocument.h>

#import "RubetteDriver.h"
#import <Predicates/PrediBaseDocument.h>
#import <Predicates/FormManager.h>
#import <Rubato/RubatoController.h>
#import "Weight.subproj/Weight.h"

//@class Weight;


@implementation RubetteDriver


/* class methods */

+ (id)rubetteObjectClass;
{
  return [RubetteObject class]; // overwrite!
}


/* instance methods */
- init;
{
    [super init];
    weightCount = 0;
    [self setLastFoundPredicates:nil];
    findPredicatesWindowController=[[FindPredicatesWindowController alloc] initWithWindowNibName:[FindPredicatesWindowController findPredicatesPanelNibName]];
    [findPredicatesWindowController setCascadeSearch:NO];
    [findPredicatesWindowController setDelegate:self];
    isAwake = NO; // ?
    
    myConverter = [[StringConverter alloc]init];
    isInitializingForDocument=NO;
    return self;
}

- (void)closeRubetteWindows;
{
  [myInfoPanel close];
  [myInfoPanel release];
  myInfoPanel=nil;
  [myWindow close];
  [myWindow release];
  myWindow=nil;
}

- (void)dealloc;
{
  [self closeRubetteWindows];
    [findPredicatesWindowController release];
//    [myMenu close];
    if (weightfile) free(weightfile);
    [myConverter release];
    [self setRubetteObject:nil];
    [super dealloc];
}

/* just in case the owner knows something, forward an unknown message */
// e.g. weightDirectory!
- (void)forwardInvocation:(NSInvocation *)invocation;
{
  id forwarder=[self distributor];
  if (forwarder) {
    if ([forwarder respondsToSelector:[invocation selector]])
        [invocation invokeWithTarget:forwarder];
    else
      [forwarder forwardInvocation:invocation];
  } else [super forwardInvocation:invocation];
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector;
{
  id forwarder;
  id superSignature=[super methodSignatureForSelector:selector];
  if (superSignature)
    return superSignature;
  forwarder=[self distributor];
  if (forwarder)  
    return [forwarder methodSignatureForSelector:selector];
  else
    return nil;
}

- (void)showImportView:(id)sender;
{
    NSTabView *tv=[myWindow contentView];
    [tv selectTabViewItemWithIdentifier:@"Import"];
}
- (void)showEvaluationView:(id)sender;
{
    NSTabView *tv=[myWindow contentView];
    [tv selectTabViewItemWithIdentifier:@"Evaluation"];
}

// helper method for the following methods
- (void)resizeTabView:(NSTabView *)tabView withContentSize:(NSSize)size;
{
    NSRect tabviewFrame=[tabView frame];
    NSRect contentFrame=[tabView contentRect]; // old content size
    tabviewFrame.size.width=tabviewFrame.size.width-contentFrame.size.width+size.width;
    tabviewFrame.size.height=tabviewFrame.size.height-contentFrame.size.height+size.height;
    [tabView setFrame:tabviewFrame];
}

- (void)setTitleWithPrediBaseAndRubetteKey;
{
    NSString *title;
    if (prediBase && [prediBase respondsToSelector:@selector(displayName)]) {
        id displayProvider=prediBase;
        title=[rubetteKey stringByAppendingFormat:@" (%@)",[displayProvider displayName]];
    } else
        title=rubetteKey;
    [myWindow setTitle:title];    
}

// to be renamed
- (void)wasAwakeFromNib:(id)aDistributor;
{
    if (!isAwake) {
	isAwake = YES;
      owner=aDistributor;
      [self setRubetteKey:[NSString stringWithCString:[[self class] rubetteName]]];
      if ([[self distributor] signInRubette:self]) {
        [self setTitleWithPrediBaseAndRubetteKey];
        [myWindow setFrameUsingName:[NSString stringWithCString:[self rubetteName]]]; // really use old position? This hides another instance!
        [self customAwakeFromNib];
        [self showWindow:self];
        //            [self insertImportView];
        if (1) {
            static int moveFrame=1;
            static int useMax=0;
            static NSTabViewType type=NSNoTabsLineBorder; //NSNoTabsNoBorder (makes black background. error in AppKit?), NSTopTabsBezelBorder 
            static NSControlTint tint=NSDefaultControlTint;
            static NSControlSize controlSize=NSSmallControlSize;
            NSView *originalView,*v;
            NSTabView *tv;
            NSTabViewItem *item;
            NSString *identifier;
            NSRect originalFrame;
            NSSize maxContentSize, viewSize;
            originalView=[[(NSWindow *)myWindow contentView] retain];
            originalFrame=[originalView frame];
            maxContentSize=originalFrame.size;
            tv=[[NSTabView alloc] initWithFrame:originalFrame];
            [tv setControlTint:tint];
            [tv setTabViewType:type];
            [tv setControlSize:controlSize];
            [tv setDelegate:self];
                
            identifier=@"Import";
            v=[findPredicatesWindowController importView];
            viewSize=[v frame].size;
            maxContentSize.width=MAX(maxContentSize.width,viewSize.width);
            maxContentSize.height=MAX(maxContentSize.height,viewSize.height);
            item=[[NSTabViewItem alloc] initWithIdentifier:identifier];
            [item setLabel:identifier];
            [item setView:v];
            [tv addTabViewItem:item];
            [item release];

            identifier=@"Evaluation";
            item=[[NSTabViewItem alloc] initWithIdentifier:identifier];
            [item setLabel:identifier];
            [item setView:originalView];
            [tv addTabViewItem:item];
            [item release];

            if (useMax) [tv setFrameSize:maxContentSize];
            // make shure, that the size of the contentRect will be as large as the previously set frame 
            // to do this, we make add (tabviewFrame-contentRect) to originalFrame
            if (moveFrame) {
                [self resizeTabView:tv withContentSize:maxContentSize];
//                contentRect=[tv contentRect];
//                tabviewFrame=[tv frame];
//                tabviewFrame.size.width=2.0*tabviewFrame.size.width-contentRect.size.width;
//                tabviewFrame.size.height=2.0*tabviewFrame.size.height-contentRect.size.height;   
//                [tv setFrame:tabviewFrame];           
            }
            [(NSWindow *)myWindow setContentView:tv];
            [[myWindow contentView] setNeedsDisplay:YES];
            [originalView release];
        } // if (1)
        [self setupToolbar];
      } else { // not signed in
        [self release];
      }
   } // if awake
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
{
    static int use=0;
    if (use && (tabView==[myWindow contentView])) {
        NSView *view=[tabViewItem view];
        [self resizeTabView:tabView withContentSize:[view frame].size];
    }        
}

// only for not moderized Rubette-Driver, that are not owner but allocated inside nib.
/*
- (void)awakeFromNib;
{
  static BOOL flag=NO; // default: new rubette.
  if (flag)
    [self wasAwakeFromNib:owner];
}
*/

- customAwakeFromNib;
{
    return self;
}

// FScript needs this
- (id)findPredicatesWindowController;
{
  return findPredicatesWindowController;
}

- loadNibSection:(const char *)name;
{
    id aBundle;
    NSString *buf;
    
    aBundle = [NSBundle bundleForClass:[self class]];
    buf = [aBundle pathForResource:[NSString jgStringWithCString:name] ofType:@"nib"];
    [NSBundle loadNibFile:buf externalNameTable:[NSDictionary dictionaryWithObjectsAndKeys:self, @"NSOwner", nil] withZone:[self zone]];
    return self;
}

- (id)rubetteObjectClass;
{
  return [[self class] rubetteObjectClass];
}

- (NSString *)directory;
{
    return [[self class] directory];
}

- (NSString *)helpDirectory;
{
    return [[self class] helpDirectory];
}

- (BOOL)getHelpPath:(char *)path;
{
    return [[self class]getHelpPath:path];
}


- (void)setPrediBase:(id<PrediBase>)aPrediBase;
{
//    if (manager!=aManager && ([aManager isKindOfClass:[PrediBaseDocument class]] || !aManager)) {
  // jg: removed manager!=aManager to allow for editing Rubette-Data in the same Manager and
  // getting updates.
  [super setPrediBase:aPrediBase];
  if (prediBase) {
    id oldRubetteData;
    [self setTitleWithPrediBaseAndRubetteKey];
    /* initialize our variables */
    [findPredicatesWindowController setFindString:@""];
    [findPredicatesWindowController setFindLevels:ALL_LEVELS];
    /* get rubettes data */
    oldRubetteData=[prediBase predicateForKey:rubetteKey]; // jg there are Problems in Metro. instead of [[self class] rubetteName]=="Metro" it is "9)" hmmm. Then rubetteData (contained in self) returns 0.
// jg from here
#if 0
        { id debugPL=[[prediBase rubetteList] jgToPropertyList]; // jg?
          [debugPL description];
        }
#endif
    if (!oldRubetteData) {
      id rubetteData=[[[rubetteObject listForm] makePredicateFromZone:[self zone]]setNameString:[[self rubetteKey] cString]];
//          [self setRubetteData:rubetteData];
          [prediBase setPredicate:rubetteData forKey:rubetteKey];
          [[self rubetteObject] setRubetteData:rubetteData];
          [findPredicatesWindowController setFindString:ns_DEFAULT_FIND_TEXT];
          [findPredicatesWindowController setFindLevels:DEFAULT_FIND_LEVELS];
          isInitializingForDocument=YES;
          [self writeRubetteData];
          isInitializingForDocument=NO;
        }
#if 0
        { id debugPL=[[prediBase rubetteList] jgToPropertyList]; // jg?
          [debugPL description];
        }
#endif
        // jg bis hier.
	[self setWeight:nil];
	[self readRubetteData];
    }
}

- prediBase;
{
    return prediBase;
}


/* read & write Rubettes results, defaults etc. from open .pred file */
- (void)readRubetteData;
{
  NSString *theRubetteKey;
  theRubetteKey=[self rubetteKey];
  if (prediBase) {
        id rubetteData=[[self prediBase] predicateForKey:[self rubetteKey]];
        [rubetteObject setRubetteData:rubetteData];
	if ([rubetteData hasPredicateOfNameString:FIND_TEXT]) // jg possibly rubetteData does not exist! (siehe setmanager:)
	    [findPredicatesWindowController setFindString:[NSString jgStringWithCString:[rubetteData stringValueOf:FIND_TEXT]]];
	else
	    [findPredicatesWindowController setFindString:ns_DEFAULT_FIND_TEXT];
	if ([rubetteData hasPredicateOfNameString:FIND_LEVELS])
	    [findPredicatesWindowController setFindLevels:[rubetteData intValueOf:FIND_LEVELS]];
	else
	    [findPredicatesWindowController setFindLevels:DEFAULT_FIND_LEVELS];
        
        // RubetteObjects *foundPredicates
        [self setLastFoundPredicates:nil];
        [self setFoundPredicates:nil];
        [self setLastFoundPredicates:[rubetteData
            getFirstPredicateOfNameString:LAST_FOUND_NAME]];

        // if old version, read values, if you can and then write new structure.
        if (![[[rubetteData getValueOf:VERS_NAME] stringValue]
                             isEqualToString:[NSString stringWithCString:[[self class] rubetteVersion]]]) {// jg
             [self readCustomData];
             [prediBase removePredicateForKey:theRubetteKey];
             rubetteData = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]setNameString:[theRubetteKey cString]];
             [prediBase setPredicate:rubetteData forKey:theRubetteKey];
             [[self rubetteObject] setRubetteData:rubetteData];
             [self writeRubetteData];
         }
	
        // RubetteObjects *foundPredicates
	if (![self lastFoundPredicates]) {
	    [self setLastFoundPredicates:[[[rubetteObject listForm] makePredicateFromZone:[self zone]]
		    setNameString:LAST_FOUND_NAME]];
	    [rubetteData setValueOf:RSLT_NAME to:[self lastFoundPredicates]];
	}
	[self setFoundPredicates:[[self lastFoundPredicates] getValueAt:
			[[self lastFoundPredicates] count]-1]];

	[self readCustomData];
	[self readWeight];
    }
}

- (void)writeRubetteData;
{
  id rubetteData=[self rubetteData];
    if (rubetteData && prediBase) {
	if (![rubetteData hasPredicateOfNameString:VERS_NAME]) {
	    id aPredicate = [[[rubetteObject valueForm] makePredicateFromZone:[self zone]]setNameString:VERS_NAME];
	    [rubetteData setValue:aPredicate];
	}
	
	if (![rubetteData hasPredicateOfNameString:PREF_NAME]) {
	    id aPredicate = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]setNameString:PREF_NAME];
	    [rubetteData setValue:aPredicate];
	}
    
	if (![rubetteData hasPredicateOfNameString:RSLT_NAME]) {
	    id aPredicate = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]setNameString:RSLT_NAME];
	    [rubetteData setValue:aPredicate];
	}
        if (!isInitializingForDocument)
  	  if (![rubetteData hasPredicateOfNameString:LAST_FOUND_NAME] &&
	  	 		[self lastFoundPredicates]) {
	     [rubetteData setValueOf:RSLT_NAME to:[self lastFoundPredicates]];
	  }

	if (![rubetteData hasPredicateOfNameString:FIND_TEXT]) {
	    id aPredicate = [[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
	    			setNameString:FIND_TEXT];
	    [rubetteData setValueOf:PREF_NAME to:aPredicate];
	}
	
	if (![rubetteData hasPredicateOfNameString:FIND_LEVELS]) {
	    id aPredicate = [[[rubetteObject valueForm] makePredicateFromZone:[self zone]]
	    			setNameString:FIND_LEVELS];
	    [rubetteData setValueOf:PREF_NAME to:aPredicate];
	}
	[rubetteData setStringValueOf:VERS_NAME to:[[self class] rubetteVersion]];
	[rubetteData setStringValueOf:FIND_TEXT to:[[findPredicatesWindowController findString] cString]];
	[rubetteData setIntValueOf:FIND_LEVELS to:[findPredicatesWindowController findLevels]];
	[self writeCustomData];
	[self writeWeight];
	[prediBase setPredicate:rubetteData forKey:[self rubetteKey]];
    }
    [self setDataChanged:NO];
}

- (void)readCustomData;
{
   [[self rubetteObject] readCustomData];
}

- (void)writeCustomData;
{
  [[self rubetteObject] writeCustomData];
}

/* manage, read & write Rubettes weights */
- (void)newWeight;
{
  weightCount = weightCount==ULONG_MAX ? 1 : weightCount+1;
  [myConverter setStringValue:@"New Weight "];
  [myConverter concatInt:weightCount];
  [rubetteObject newWeightWithName:[myConverter stringValue]];
  [self afterCreatingNewWeight];
}

- (void)afterCreatingNewWeight;
{
  [weightName setEnabled:YES];
  [weightName setStringValue:[NSString jgStringWithCString:[[self weight] nameString]]];
}

- takeWeightNameFrom:sender;
{
    if ([sender respondsToSelector:@selector(stringValue)])
	[[self weight] setNameString:[[sender stringValue] cString]];
    return self;
}

- (void)readWeight;
{
  [rubetteObject getWeightFromPrediBase];
  if ([self weight]) {
      [weightName setEnabled:YES];
      [weightName setStringValue:[NSString jgStringWithCString:[[self weight] nameString]]];
  }
  else {
      [weightName setEnabled:NO];
      [weightName setStringValue:@"No weight"];
  }
}

- (void)writeWeight;
{
  return [rubetteObject setWeightToPrediBase];
}

- setWeightfile:(const char *)aFilename;
{
    /* this method taken from Garfinkel & Mahoney, p. 331 */
    if (weightfile) free(weightfile);
    weightfile = malloc(strlen(aFilename)+1);
    strcpy(weightfile, aFilename);
    return self;
}

- loadWeight:sender;
{
    char path[MAXPATHLEN+1];
    NSArray *types = [NSArray arrayWithObject:ns_WeightFileType];
    NSString *aFilename;
    id openPanel;
    NSArchiver *theStream;

    if (weightfile) {
	if (rindex(weightfile, '/')) 
	    strncpy(path, weightfile, rindex(weightfile, '/')-weightfile+1);
	else
	    strcpy(path, weightfile);
    }
    else {
// was:	strcpy(path, [self weightDirectory]);  // forward an owner, which is possibly initialized in Nibfile ?NSOwner? initialisiert.
        strcpy(path, [[[self distributor] weightDirectory] cString]);// jg is.
	strcat(path, "/");
	strcat(path, [[self class]rubetteName]);
    }

//#warning FactoryMethods: [OpenPanel openPanel] used to be [OpenPanel new].  Open panels are no longer shared.  'openPanel' returns a new, autoreleased open panel in the default configuration.  To maintain state, retain and reuse one open panel (or manually re-set the state each time.)
    openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:@"Load Weight"];
    [openPanel setCanChooseDirectories:NO];

    [openPanel setTreatsFilePackagesAsDirectories:NO];
    if([openPanel runModalForDirectory:[NSString jgStringWithCString:(const char *)path] file:@"" types:types]) {
      id archiverClass=[[self distributor] unarchiverForType:@"Weight"];
	aFilename = [openPanel filename];

	theStream = [[archiverClass
 alloc] initForReadingWithData:[NSData dataWithContentsOfFile:aFilename]];
	if(theStream) {
	    id weight, returnValue = self; /* this variable is used in the load handler macro */
            NSString *oldTitle=[myWindow title];
	    [myWindow setTitle:@"Loading Weight¼"];
	    
	    NS_DURING
	    weight = [[theStream decodeObject] retain];
	    
	    NS_HANDLER
	    LOAD_HANDLER  /* a load handler macro in macros.h */
	    weight = nil;
	    NS_ENDHANDLER /* end of handler */
	    
	    [theStream release];
	    
	    if ([self canLoadWeight:weight]) {
		[self setWeight:[weight ref]]; // jg? ref...
		[self readWeightParameters];
		[weightName setEnabled:YES];
		[weightName setStringValue:[NSString jgStringWithCString:[[self weight] nameString]]];
		[self setWeightfile:[aFilename cString]];
	    }
	    else /* failed to read weight, create myWeight */
		NSRunAlertPanel(@"Load Weight", @"Can't load this type of weight", @"Sorry", nil, nil, NULL);
	    [myWindow setTitle:oldTitle];
    
	    return returnValue;
	}
    }
    return nil;

}

- (BOOL)canLoadWeight:aWeight;
{
    return aWeight && !strcmp([aWeight rubetteName], [self rubetteName]) 
			&& (spaceIndex)[aWeight space]==[[self class]rubetteSpace];
}

- saveWeightAs:sender;
{
    id	panel;
    NSString *pathExtension=[NSString jgStringWithCString:WeightFileType];
    NSString *fileSuggestion=[NSString jgStringWithCString:[[self weight] nameString]];
    NSString *path;
    NSString *weightFileName=nil;

    if ([fileSuggestion length])
        fileSuggestion=[fileSuggestion stringByAppendingPathExtension:pathExtension];

    if (weightfile) {
#if 0
        if (rindex(weightfile, '/')) 
	    strncpy(path, weightfile, rindex(weightfile, '/')-weightfile+1);
	else
	    strcpy(path, weightfile);
#else
        weightFileName=[NSString stringWithCString:weightfile];
        path=[weightFileName stringByDeletingLastPathComponent];
#endif
    }
    else {
#if 0
//was    strcpy(path, [self weightDirectory]);// forward to owner, which evtually is initialized in Nibfiles NSOwner.
      strcpy(path, [[[self distributor] weightDirectory] cString]); // jg more clear.
	strcat(path, "/");
	strcat(path, [[self class]rubetteName]);
#else
        path=[[[self distributor] weightDirectory] stringByAppendingPathComponent:[NSString jgStringWithCString:[[self class]rubetteName]]];
#endif
    }

//#warning FactoryMethods: [SavePanel savePanel] used to be [SavePanel new].  Save panels are no longer shared.  'savePanel' returns a new, autoreleased save panel in the default configuration.  To maintain state, retain and reuse one save panel (or manually re-set the state each time.)
    panel = [NSSavePanel savePanel];
    [panel setTreatsFilePackagesAsDirectories:NO];
    [panel setRequiredFileType:pathExtension];

    if ([panel runModalForDirectory:path file:fileSuggestion]) {
	[self setWeightfile:[[panel filename] cString]];
	return [self saveWeight:sender];
    }
    return nil; /*didn't save */
}


- saveWeight:sender;
{
    id returnValue = self; /* this variable is used in the load handler macro */
    if ([self weight]) {
	NSData *data=nil;
        NSString *oldTitle=[myWindow title];
	
	if (weightfile==0) return [self saveWeightAs:sender];
	[myWindow setTitle:@"Saving Weight¼"];
	
	NS_DURING
          data = [[[self distributor] archiverForType:@"Weight"] archivedDataWithRootObject:[self weight]];
          [data writeToFile:[NSString jgStringWithCString:weightfile] atomically:YES]; 
	NS_HANDLER
	LOAD_HANDLER  /* a load handler macro in macros.h */
	NS_ENDHANDLER /* end of handler */
	
	[myWindow setTitle:oldTitle];
    }
    return returnValue;
}


/* finding predicates */
- (void)doSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
{
  if (![[specification findString] isEqualToString:@""]) {
    [self setFoundPredicates:[self searchForPredicatesWithFindPredicateSpecification:specification]];
	[[self lastFoundPredicates] setValue:[self foundPredicates]];
    }
}

- (id)searchForPredicatesWithFindPredicateSpecification: (id<FindPredicateSpecification>)specification;
{
    SEL testMethod = @selector(isPredicateOfName:);
    id aPredicate = nil, aListPredicate = nil, aList=nil;
    id anInput;
    int findVal=0;
    if (specification) // UI-Object
      findVal=[specification findSource];
    else
      findVal=0;
    // zero means: look in current manager
    anInput=prediBase;
    // negative Values are looking for parents.
    if (findVal<0 && [anInput respondsToSelector:@selector(subDocumentNode)]) {
      id node=[anInput subDocumentNode]; // JGSubDocumentNode
      while (findVal<0) {
        node=[node parentDocumentNode];
        findVal++;
      }
      anInput=[node document];
    }
    // positive Values look up a JGSubDocument with Nr findVal
    if (findVal>0) {
      int j;
      NSDocumentController *dc=[NSDocumentController sharedDocumentController];
      NSArray *arr=[dc documents];
      id doc;
      anInput=nil;
      for (j=0;!anInput && (j<[arr count]);j++) {
        doc=[arr objectAtIndex:j];
        if ([doc isKindOfClass:[JGSubDocument class]] && ([doc globalDocumentNr]==findVal))
            anInput=doc;
      }
    }
    /* if we want to search in already found predicates */
    if ([specification cascadeSearch]) {
	unsigned int count = [[self lastFoundPredicates] count];
	aPredicate = [[self lastFoundPredicates] getValueAt:count-1];
    }
    /* if input is a Predicate Manager */
    else if ([anInput isKindOfClass:[PrediBaseDocument class]]) {
	aPredicate = [anInput selected] ? [anInput selected] : [anInput predicateList]; // jg??? replace with [predicateManager/predicateEditor predicateList]?
    }
    else if ([anInput isKindOfClass:[RubetteDriver class]]) {
	aListPredicate = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]setNameString:"- searchForPredicates: Found Predicates"];
      [aListPredicate setValue:[anInput searchForPredicatesWithFindPredicateSpecification: (id<FindPredicateSpecification>)specification]];
	aPredicate = aListPredicate;
    }
    else if ([anInput conformsToProtocol:@protocol(PredicateProtocol)]) {
	aPredicate = anInput;
    }
    
    if (aPredicate) {
      switch ([specification findWhat]+[specification findHow]) {
	    case 0: testMethod = @selector(isPredicateOfName:);
		    break;
	    case 1: testMethod = @selector(hasPredicateOfName:);
		    break;
	    case 2: testMethod = @selector(isPredicateOfType:);
		    break;
	    case 3: testMethod = @selector(hasPredicateOfType:);
		    break;
	    case 4: testMethod = @selector(isPredicateOfFormName:);
		    break;
	    case 5: testMethod = @selector(hasPredicateOfFormName:);
		    break;
	    case 6: testMethod = @selector(isPredicateOfForm:);
		    break;
	    case 7: testMethod = @selector(hasPredicateOfForm:);
		    break;
	}
	aList = [aPredicate getAllPredicatesOf:testMethod
                                          with:[specification findString] inLevels:[specification findLevels]]; // jg was: without stringValue
	if (aList) {
	    aListPredicate = [[[rubetteObject listForm] makePredicateFromZone:[self zone]]setNameString:[[specification findString] cString]];
	    [aListPredicate setValue:aList];
	}
	aPredicate = nil;
    }
    [self setDataChanged:YES];
    return aListPredicate;
}

/*
- changeFindSource:sender;
{
  [findPredicatesWindowController setFindSource:[[sender selectedCell] tag]]; // selectedItem
  return self;
}

- changeFindLevels:sender;
{
    levels = [[sender selectedCell] tag];  // selectedItem
    [findPredicatesWindowController setFindLevels:levels];
    return self;
}

- setCascadeSearch:sender;
{
    if ([sender respondsToSelector:@selector(state)])
	cascadeSearch = (BOOL)[sender state];
    if (!cascadeSearch) newSearch = YES;
    return self;
}
*/

- (void)initSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
{
    unsigned int i;
    for (i=[[self lastFoundPredicates] count]; i>0; i--)
	[[self lastFoundPredicates] deleteValue:
			[[self lastFoundPredicates] getValueAt:i-1]];
    [self setFoundPredicates:nil];
    [self setDataChanged:YES];
}

- (void)closeRubette;
{
  [[self distributor] signOutRubette:self];
  [self closeRubetteWindows];
    /* this calls setManager with nil and writes the data */
    [self release];
}
@end

@implementation RubetteDriver(IBObjects)

- closeRubette:sender;
{
    if (NSRunAlertPanel(@"Rubette: Close", [NSString stringWithCString:"Closing this Rubette "
                        "deletes all intermediate results and may cause other "
                        "Rubettes to recalculate their results. Proceed?"], @"OK", @"Cancel", nil, NULL)==NSAlertDefaultReturn) {
        [self closeRubette];
        return nil;
    } else
        return self;
}


- doReadData:sender;
{
    [self readRubetteData];
    return self;
}

- doWriteData:sender;
{
    [self writeRubetteData];
    return self;
}

/* window management */
- (IBAction)showWindow:(id)sender;{
    [myWindow makeKeyAndOrderFront:nil];
}

- hideWindow:sender;
{
    [myWindow orderOut:self];
    return self;
}

- showRubetteInfoPanel:sender;
{
    [myInfoPanel makeKeyAndOrderFront:self];
    return self;
}

//jg not yet implemented.
- showRubetteHelpPanel:sender;
{
    char file[MAXPATHLEN+1], marker[MAXPATHLEN+1];

    strcpy(marker, [[self class] rubetteName]);
    strcat(marker, "Rubette");
    [self getHelpPath:file];
    strcat(file, "/Introduction.rtf");
//#error FactoryMethods: NXHelpPanel is obsolete.  Use NSHelpManager.
//jg?    [[NXHelpPanel new] showFile:[NSString stringWithCString:file] atMarker:[NSString stringWithCString:marker]];
//jg?    [[NSApplication sharedApplication] showHelp:self];

    return self;
}

- (IBAction)showFindPredicatesWindow:(id)sender;
{
  [findPredicatesWindowController showWindow:sender];
}

@end

@implementation RubetteDriver(WindowDelegate)
/* (WindowDelegate) methods */

- (BOOL)readRubetteDataIfBecomeKey;
{
  return [findPredicatesWindowController readRubetteDataIfBecomeKey];
}

- (BOOL)writeRubetteDataIfResignKey;
{
  return [findPredicatesWindowController writeRubetteDataIfResignKey];
}

- (void)windowDidBecomeKey:(NSNotification *)notification;
{
  if ([[self distributor] activeRubette]!=self) {
    [[self distributor] setActiveRubette:self];
    if ([self readRubetteDataIfBecomeKey])
	[self readRubetteData];
  }
}

- (void)windowDidResignKey:(NSNotification *)notification
{
//    NSWindow *theWindow = [notification object];
    if ([self writeRubetteDataIfResignKey]) // jg was: && [self dataChanged]) // removed because dataChanged not called all the time.
      [self writeRubetteData];
}

- (BOOL)windowShouldClose:(id)sender;
{
    if (sender==myWindow) {
	[myWindow saveFrameUsingName:[NSString jgStringWithCString:[[self class] rubetteName]]];
    }
    else if ([sender isKindOfClass:[NSWindow class]]) {
	[sender saveFrameUsingName:[sender title]];
    }
    return YES;
}


@end

@implementation RubetteDriver (NowRubetteObject)
+ (const char *)rubetteVersion;
{
   return [[self rubetteObjectClass] rubetteVersion];
}

+ (spaceIndex) rubetteSpace;
{
   return [[self rubetteObjectClass] rubetteSpace];
}

- (const char *)rubetteVersion;
{
    return [[self class] rubetteVersion];
}

- (spaceIndex) rubetteSpace;
{
    return [[self class] rubetteSpace];
}


- (id)rubetteData;
{
  return [rubetteObject rubetteData];
}
- (void)setRubetteData:(id)fp;
{
  [rubetteObject setRubetteData:fp];
}
- (id)foundPredicates;
{
  return [rubetteObject foundPredicates];
}
- (void)setFoundPredicates:(id)fp;
{
  [rubetteObject setFoundPredicates:fp];
}
- (id)lastFoundPredicates;
{
  return [rubetteObject lastFoundPredicates];
}
- (void)setLastFoundPredicates:(id)fp;
{
  [rubetteObject setLastFoundPredicates:fp];
}

- (id)weight;
{
  return [rubetteObject weight];
}

- (void)setWeight:(id)weight;
{
  [rubetteObject setWeight:weight];
}
@end
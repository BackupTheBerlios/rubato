/* PerformanceRubetteDriver.m */

#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubato/inspectorkit.h>
#import <Rubato/RubatoController.h>
#import <Rubato/SpaceTypes.h>
#import <Rubato/Distributor.h>
#import <Rubette/SpaceProtocol.h>
#import <Rubette/MatrixEvent.h>
#import <PerformanceScore/LocalPerformanceScore.h>
#import <PerformanceScore/PerformanceOperator.h>
#import <Rubette/Weight.h>

#import "PerformanceRubetteDriver.h"
#import "PerformanceManager.h"
#import "LPSView.h"
#import <Rubette/WeightListManager.h>
#import <Rubette/WeightWatcherInspector.h>

#define KERNEL_PANEL_NAME "Kernel View"
#define FIELD_PANEL_NAME "Field View"

@implementation PerformanceRubetteDriver

- init;
{
    [super init];
    myKernel = [[[OrderedList alloc]init]ref];
    myOperatorClassList = [[JgList alloc]init];
    return self;
}

- (void)closeRubetteWindows1;
{
  [myKernelViewPanel performClose:self];
  [myKernelViewPanel release]; myKernelViewPanel = nil;
  [myFieldViewPanel performClose:self];
  [myFieldViewPanel release]; myFieldViewPanel = nil;
  [myGraphicPrefsPanel performClose:self];
  [myGraphicPrefsPanel release]; myGraphicPrefsPanel = nil;
  [myFindPanel performClose:self];
  [myFindPanel release]; myFindPanel = nil;
}
- (void)closeRubetteWindows;
{
  [self closeRubetteWindows1];
  [super closeRubetteWindows];
}


- (void)dealloc;
{
    [[[self distributor] globalInspector] setManager:nil];
    [[[self distributor] globalInspector] setSelected:nil];

    [self closeRubetteWindows1];

    [[myKernel freeObjects] release]; myKernel = nil;
    [myOperatorClassList release]; myOperatorClassList = nil;
    [myWeightWatcherInspector release]; myWeightWatcherInspector = nil;
    [myWeightListManager release]; myWeightListManager = nil;
    
    [super dealloc];
}

- customAwakeFromNib;
{
    NSRect columnRect;
    if (![myOperatorMenu isKindOfClass:[NSPopUpButton class]]) myOperatorMenu = [myOperatorMenu target];
    
    [myKernelViewPanel setFrameUsingName:[NSString jgStringWithCString:KERNEL_PANEL_NAME]];
    [myKernelViewPanel setBecomesKeyOnlyIfNeeded:YES];
    
    [myFieldViewPanel setFrameUsingName:[NSString jgStringWithCString:FIELD_PANEL_NAME]];
    [myFieldViewPanel setBecomesKeyOnlyIfNeeded:YES];
    
    [myGraphicPrefsPanel setFrameUsingName:[myGraphicPrefsPanel title]];
    [myGraphicPrefsPanel setBecomesKeyOnlyIfNeeded:YES];
    
    [myFindPanel setFrameUsingName:[myFindPanel title]];
    [myFindPanel setBecomesKeyOnlyIfNeeded:YES];
    
    [myBrowser loadColumnZero];
    columnRect = [[myBrowser matrixInColumn:0] frame];
    [myBrowser setMinColumnWidth:NSWidth(columnRect)];
    [myBrowser setMaxVisibleColumns:10];
    [myBrowser setDoubleAction:@selector(showOperatorInspectorPanel:)];
    [self insertBuildInOperatorMenuItems];
    return self;
}


- performanceManager;
{
    return myPerformanceManager;
}

- weightListManager;
{
    return myWeightListManager;
}

- weightWatcherInspector;
{
    return myWeightWatcherInspector;
}


- makeKernel;
{
    id predicate;
    unsigned int i, prediCount = [[self foundPredicates] count];

    /* first clean up the predicates*/
    for (i=0; i<prediCount; i++) {
	predicate = [[self foundPredicates] getValueAt:i];
	if (!([predicate hasPredicateOfNameString:"E"] ||
		[predicate hasPredicateOfNameString:"H"] ||
		[predicate hasPredicateOfNameString:"L"] ||
		[predicate hasPredicateOfNameString:"D"] ||
		[predicate hasPredicateOfNameString:"G"] ||
		[predicate hasPredicateOfNameString:"C"])) {
	    [[self foundPredicates] removeValue:predicate];
	    prediCount--;
	    i--;
	}
    }
    
    if (prediCount) {
	id anEvent;
	[myKernel freeObjects];
	for (i=0; i<prediCount; i++) {
	    anEvent = [[MatrixEvent alloc]init];
	    predicate = [[self foundPredicates] getValueAt:i];

	    if ([predicate hasPredicateOfNameString:"E"])
		[[anEvent setSpaceAt:indexE to:YES]
		setDoubleValue:[predicate doubleValueOf:"E"] atIndex:indexE];
	    if ([predicate hasPredicateOfNameString:"H"])
		[[anEvent setSpaceAt:indexH to:YES]
		setDoubleValue:[predicate doubleValueOf:"H"] atIndex:indexH];
	    if ([predicate hasPredicateOfNameString:"L"])
		[[anEvent setSpaceAt:indexL to:YES]
		setDoubleValue:[predicate doubleValueOf:"L"] atIndex:indexL];
	    if ([predicate hasPredicateOfNameString:"D"])
		[[anEvent setSpaceAt:indexD to:YES]
		setDoubleValue:[predicate doubleValueOf:"D"] atIndex:indexD];
	    if ([predicate hasPredicateOfNameString:"G"])
		[[anEvent setSpaceAt:indexG to:YES]
		setDoubleValue:[predicate doubleValueOf:"G"] atIndex:indexG];
	    if ([predicate hasPredicateOfNameString:"C"])
		[[anEvent setSpaceAt:indexC to:YES]
		setDoubleValue:[predicate doubleValueOf:"C"] atIndex:indexC];

	    [myKernel addObjectIfAbsent:[anEvent ref]];
	}
    }
    return self;
}


- setKernel:sender;
{
    if (!performanceScore)
	[self newPerformanceScore:self];
    [self makeKernel];
    [performanceScore setKernel:myKernel];
    [self displayLPS:performanceScore];
    [myKernelView setViewToLPSFrame:self];
    browserValid = NO;
    [myBrowser validateVisibleColumns];
    browserValid = YES;
    return self;
}

- newPerformanceScore:sender;
{
    [self deletePerformanceScore];
    [self setPerformanceScore: [[LocalPerformanceScore alloc]init]];
    return self;
}

- setPerformanceScore:anLPS;
{
    if ([anLPS isKindOfClass:[LocalPerformanceScore class]] || !anLPS) {
	[self deletePerformanceScore];
	performanceScore = [anLPS ref];
	selected = nil;
	browserValid = NO;
	[myBrowser loadColumnZero];
	browserValid = YES;
	[self displayLPS:performanceScore];
	[myKernelView setViewToLPSFrame:self];
	[myWeightListManager updateWeightListFromLPS:performanceScore];
    }
    return self;
}


- deletePerformanceScore;
{
    if([[[self distributor] globalInspector] selected]==selected)
	[[[self distributor] globalInspector] setSelected:nil];
    [performanceScore release];
    performanceScore = nil;
    selected = nil;
    return self;
}


- performanceScore;
{
    return performanceScore;
}

- deleteDaughter:sender;
{
    if (selected!=performanceScore && 
	NSRunAlertPanel(@"Delete LPS", @"This deletes %s and its entire sub-stemma", @"Yes", @"Cancel", nil, [selected nameString])) {
	id daughter = selected;
	[[daughter mother] killDaughter:daughter];
	selected = nil;
	selIndex = [[myBrowser matrixInColumn:[myBrowser selectedColumn]-1] selectedRow];
	[self setSelected:[self selectedAtColumn:[myBrowser selectedColumn]-1]];
    }
    return self;
}

- debugLoadAllOperators:sender;
{ 
   [self debugLoadAllOperatorsWithFilenames];
   return self;
}
- loadOperator:sender;
{
    NSString *path;
    NSArray *types = [NSArray arrayWithObject:[NSString jgStringWithCString:OperatorFileType]];
    id  openPanel;

    path=[[self distributor] operatorDirectory];

    openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:@"Load Operator"];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setTreatsFilePackagesAsDirectories:NO];
    if([openPanel runModalForDirectory:path file:@"" types:types]) {
      [self loadOperatorWithFilename:[openPanel filename]];
    }
    return self;
}

- (void) debugLoadAllOperatorsWithFilenames;
{ // hard wired:
[self loadOperatorWithFilename:@"/Local/Users/jg/rubato/Operators/debuglink/Physical.operator"];
[self loadOperatorWithFilename:@"/Local/Users/jg/rubato/Operators/debuglink/Scalar.operator"];
[self loadOperatorWithFilename:@"/Local/Users/jg/rubato/Operators/debuglink/Split.operator"];
[self loadOperatorWithFilename:@"/Local/Users/jg/rubato/Operators/debuglink/Symbolic.operator"];
[self loadOperatorWithFilename:@"/Local/Users/jg/rubato/Operators/debuglink/Tempo.operator"];
}

- (void)loadOperatorWithFilename:(NSString *)filename;
{
  const char *fname, *ftype="";
  NSBundle *bundle;
  id operatorClass;

	fname = [filename cString];
	if(rindex(fname, '.')) /* increment ptr to actual filetype */
	    ftype = rindex(fname, '.') +1;
    
	if (!strcmp(ftype, OperatorFileType)) {/* if its a .operator Directory*/
	    bundle = [[NSBundle alloc] initWithPath:[NSString jgStringWithCString:fname]];
	    operatorClass = [bundle principalClass];
//jg only possible with the more complex class enmethod from JgObject.
	    if ([operatorClass isKindOfClassNamed:"PerformanceOperator"] &&
		[myOperatorClassList addObjectIfAbsent:operatorClass]) {
// was:		[[myOperatorMenu addItemWithTitle:NSStringFromClass(operatorClass) action:@selector(applyOperator:) keyEquivalent:@""] setTarget:self];
// myOperatorMenu ist NSPopupButton!
            NSMenuItem *mi; 
            [myOperatorMenu addItemWithTitle:NSStringFromClass(operatorClass)];
	    mi=[myOperatorMenu lastItem];
            [mi setAction:@selector(applyOperator:)];
            [mi setTarget:self];
	    }
	}
}

- (void)insertBuildInOperatorMenuItems;
{
  NSMenu *m=[myLoadOperatorPopUpButton menu];
  [Distributor menu:m insertItemsForPlugInsOfType:[NSString jgStringWithCString:OperatorFileType] action:@selector(loadBuildInOperator:) target:self];
}

- (void)loadBuildInOperator:(id)buildInMenuItem;
{
  NSString *str=[buildInMenuItem representedObject];
  if (str)
    [self loadOperatorWithFilename:str];
}

- (void)loadAllBuildInOperators:(id)sender;
{
  NSMenu *m=[myLoadOperatorPopUpButton menu];
  NSEnumerator *e=[[m itemArray] objectEnumerator];
  NSMenuItem *item;
  while (item=[e nextObject])
    [self loadBuildInOperator:item];
}


- applyOperator:sender;
{
    int i, c = [myOperatorClassList count];
    NSString *className = [sender title]; // jg was const char*
//jg was:    for (i=0; i<c && ![[myOperatorClassList objectAt:i]isMemberOfClassNamed:className]; i++);
    for (i=0; i<c && ![NSStringFromClass([myOperatorClassList objectAt:i]) isEqualToString:className]; i++);
    [[myOperatorClassList objectAt:i]applyTo:selected];
    selected = nil;
    [self setSelected:[self selectedAtColumn:[myBrowser selectedColumn]]];
    return self;
}


- loadWeight:sender;
{
    [super loadWeight:sender];
    [myWeightListManager addWeight:[self weight]];
    [self setWeight:nil];
    return self;
}

- (BOOL)canLoadWeight:aWeight;
{
    return [aWeight isKindOfClass:[Weight class]]; 
}

- (void)readWeight;
{
  [myWeightListManager appendList:[[self prediBase] weightList]];
}

- (void)setSelectedCell:sender;
{
    if ([sender isKindOfClass:[NSBrowser class]] && [sender selectedColumn]!=NSNotFound) {
	selIndex = [[sender matrixInColumn:[sender selectedColumn]] selectedRow];
	[self setSelected:[self selectedAtColumn:[sender selectedColumn]]];
    }
    else {
	selIndex = NSNotFound;
	[self setSelected:nil];
    }
}

- selectedAtColumn:(int)column;
{
    id daughter;
    int c;
    daughter = column>=0 ? performanceScore : nil;
    for (c=1; c<=column && [[myBrowser matrixInColumn:c]selectedRow]!=NSNotFound; c++){
	daughter = [daughter daughterAt:[[myBrowser matrixInColumn:c]selectedRow]];
    }
    return daughter;

}


- (void)setSelected:anLPS;
{
    if ((anLPS!=selected) && (!anLPS || [anLPS isKindOfClass:[LocalPerformanceScore class]])) {
	selected = anLPS;
	[[[self distributor] globalInspector] setSelected:selected];
	
	browserValid = NO;
	[myBrowser validateVisibleColumns];
	//[myPerformButton setEnabled:![selected isCalculated]];
	[self displayLPS:selected];
    }
}


- selected;
{
    return selected;
}


- (void)setLPSEdited:(BOOL)flag;
{
    [[[self distributor] globalInspector] setPatientEdited:YES];
    [[[self distributor] globalInspector] displayPatient:self];

//    return self;
}

- (void)setDocumentEdited:(BOOL)flag;
{
    browserValid = NO;
    [myWindow setDocumentEdited:flag];
    [myBrowser validateVisibleColumns];
    //[myPerformButton setEnabled:![selected isCalculated]];
    if ([selected isKindOfClassNamed:"SymbolicOperator"])
	[myKernelView doRedraw:self];
    [myFieldView doRedraw:self];
}

- displayLPS:anLPS;
{
    [myConverter setStringValue:[NSString jgStringWithCString:KERNEL_PANEL_NAME]];
    if (anLPS) {
      [myConverter concat:" Ð "];
      [myConverter concat:[anLPS nameString]];
    }
    [myKernelViewPanel setTitle:[myConverter stringValue]];
    [myKernelView displayLPS:anLPS];
    
    [myConverter setStringValue:[NSString jgStringWithCString:FIELD_PANEL_NAME]];
    if (anLPS) {
      [myConverter concat:" Ð "];
      [myConverter concat:[anLPS nameString]];
    }
    [myFieldViewPanel setTitle:[myConverter stringValue]];
    [myFieldView displayLPS:anLPS];
    [myFieldView setViewToLPSFrame:self];
    
    [myWeightWatcherInspector takeWeightWatcherFrom:anLPS];
    return self;
}

- showOperatorInspectorPanel:sender;
{
    [[[self distributor] globalInspector] showInspectorPanel:sender];
    return self;
}

- insertCustomMenuCells;
{
     id submenu;
     /* this is an example [[myMenu addItem:"Info¼"
      *				action:@selector(showRubetteInfoPanel:)
      *			keyEquivalent:@""]setTarget:self];
      */
   
    [[myMenu addItemWithTitle:@"Kernel View" action:@selector(makeKeyAndOrderFront:) keyEquivalent:@""] setTarget:myKernelViewPanel];
//jg26.04.02    [[myMenu addItemWithTitle:@"Select Kernel" action:@selector(makeKeyAndOrderFront:) keyEquivalent:@""] setTarget:myFindPanel];
/*
    [[myMenu addItem:"Load Operator¼" 
	action:@selector(loadOperator:) 
	keyEquivalent:@""]setTarget:self];

    [[myMenu addItem:"Operator Inspector¼" 
	action:@selector(showOperatorInspectorPanel:) 
	keyEquivalent:@""]setTarget:self];

    [[myMenu addItem:"Load Weight¼" 
	action:@selector(loadWeight:) 
	keyEquivalent:@""]setTarget:self];
*/
    /* Build the Stemma submenu */
    submenu = [[NSMenu alloc] initWithTitle:@"Stemma"];
    [[submenu addItemWithTitle:@"Load" action:@selector(loadStemma:) keyEquivalent:@"L"] setTarget:myPerformanceManager];
    [[submenu addItemWithTitle:@"New" action:@selector(newStemma:) keyEquivalent:@""] setTarget:myPerformanceManager];
    [[submenu addItemWithTitle:@"Save" action:@selector(saveStemma:) keyEquivalent:@""] setTarget:myPerformanceManager];
    [[submenu addItemWithTitle:@"Save As" action:@selector(saveStemmaAs:) keyEquivalent:@""] setTarget:myPerformanceManager];
	
    [myMenu setSubmenu:submenu 
	forItem:[myMenu addItemWithTitle:@"Stemma" action:0 keyEquivalent:@""]];
    [[myMenu addItemWithTitle:@"Save Performance As Score" action:@selector(saveScoreAs:) keyEquivalent:@""] setTarget:myPerformanceManager];
    [[myMenu addItemWithTitle:@"Save Performance As MIDI" action:@selector(saveMidiAs:) keyEquivalent:@""] setTarget:myPerformanceManager];
    [[myMenu addItemWithTitle:@"Graphic Preferences" action:@selector(makeKeyAndOrderFront:) keyEquivalent:@""] setTarget:myGraphicPrefsPanel];

    return self;
}

/* window management */
- (IBAction)showWindow:(id)sender;
{
    //[myKernelViewPanel makeKeyAndOrderFront:self];
    //[myFindPanel makeKeyAndOrderFront:self];
    //[myGraphicPrefsPanel makeKeyAndOrderFront:self];
    [super showWindow:sender];
}

- hideWindow:sender;
{
    [myKernelViewPanel orderOut:self];
    [myFieldViewPanel orderOut:self];
    [myFindPanel orderOut:self];
    [myGraphicPrefsPanel orderOut:self];
    return [super hideWindow:sender];
}

+ (NSString *)nibFileName;
{
  return @"PerformanceRubette.nib";
}

+ (const char *)rubetteName;
{
    return "Performance";
}

+ (const char *)rubetteVersion;
{
    return "1.0";
}

+ (spaceIndex) rubetteSpace;
{
    return 63;
}

@end

@implementation PerformanceRubetteDriver(BrowserDelegate)
/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    if (column)
	return [[self selectedAtColumn:column-1] daughterCount];
    else
	return performanceScore ? 1 : 0;
}

//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    id daughter = performanceScore;
    NSFont *font=[NSFont fontWithName:@"Times-Roman" size:13.0];
    NSFont *italFont=[[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSItalicFontMask];

    if (column)
	daughter = [[self selectedAtColumn:column-1] daughterAt:row];
    if (daughter) {
	if ([daughter isCalculated])
            [cell setFont:font];
//	    [cell setFont:[[NSFontManager new] convertFont:[cell font] toNotHaveTrait:NSItalicFontMask]];
	else
            [cell setFont:italFont];
//	    [cell setFont:[[NSFontManager new] convertFont:[cell font] toHaveTrait:NSItalicFontMask]];
	[cell setLoaded:YES];
	[cell setStringValue:[NSString jgStringWithCString:[daughter nameString]]];
	[cell setLeaf:![daughter daughterCount]];
    }
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
{
    BOOL retVal;
    retVal = ([NSView focusView] == [sender matrixInColumn:column]) ? YES : browserValid;
    return retVal;
}

@end

@implementation PerformanceRubetteDriver(WindowDelegate)
/* (WindowDelegate) methods */

// /*
// jg? commented out because of the many error messages. Necessary to review!
//#warning NotificationConversion: windowDidUpdate:(NSNotification *)notification is an NSWindow notification method (used to be a delegate method); delegates of NSWindow are automatically set to observe this notification; subclasses of NSWindow do not automatically receive this notification
- (void)windowDidUpdate:(NSNotification *)notification;
{
  id sender=[notification object]; //jg
    if (sender==myKernelViewPanel || sender==myFieldViewPanel) {
	[sender displayIfNeeded];
//#error WindowConversion: 'reenableDisplay' is obsolete.  You can probably remove this call.  Typically drawing should happen as part of the update mechanism after every event.  Display is now optimized using the View setNeedsDisplay: method.  See the conversion doc for more info.
//	[sender reenableDisplay];
    }
}

//#warning NotificationConversion: windowDidBecomeKey:(NSNotification *)notification is an NSWindow notification method (used to be a delegate method); delegates of NSWindow are automatically set to observe this notification; subclasses of NSWindow do not automatically receive this notification
- (void)windowDidBecomeKey:(NSNotification *)notification;
{
   id sender=[notification object]; // jg
    [[[self distributor] globalInspector] setManager:self];
    [[[self distributor] globalInspector] setSelected:selected];
//#warning This delegate message has changed to a notification.  If you are trying to simulate the sending of the delegate message, you may want to instead post a notification via [[NSNotificationCenter defaultCenter] postNotificationName:NSWindowDidBecomeKeyNotification object:sender]
    [super windowDidBecomeKey:sender];
}

//#warning NotificationConversion: windowDidResignKey:(NSNotification *)notification is an NSWindow notification method (used to be a delegate method); delegates of NSWindow are automatically set to observe this notification; subclasses of NSWindow do not automatically receive this notification
- (void)windowDidResignKey:(NSNotification *)notification
{
    //[[owner globalInspector] setManager:nil];
    //[[owner globalInspector] setSelected:nil];
//#warning This delegate message has changed to a notification.  If you are trying to simulate the sending of the delegate message, you may want to instead post a notification via [[NSNotificationCenter defaultCenter] postNotificationName:NSWindowDidResignKeyNotification object:sender]
//    NSWindow *theWindow = [notification object];
    [super windowDidResignKey:notification];
}

//#warning NotificationConversion: windowDidMiniaturize:(NSNotification *)notification is an NSWindow notification method (used to be a delegate method); delegates of NSWindow are automatically set to observe this notification; subclasses of NSWindow do not automatically receive this notification
- (void)windowDidMiniaturize:(NSNotification *)notification;
{
//    if (sender==myKernelViewPanel || sender==myFieldViewPanel) 
//#error WindowConversion: 'disableDisplay' is obsolete.  You can probably remove this call.  Typically drawing should happen as part of the update mechanism after every event.  Display is now optimized using the View setNeedsDisplay: method.  See the conversion doc for more info.
//	[sender disableDisplay];
}

//#warning NotificationConversion: windowDidDeminiaturize:(NSNotification *)notification is an NSWindow notification method (used to be a delegate method); delegates of NSWindow are automatically set to observe this notification; subclasses of NSWindow do not automatically receive this notification
- (void)windowDidDeminiaturize:(NSNotification *)notification;
{
  id sender=[notification object]; // jg
    if (sender==myKernelViewPanel || sender==myFieldViewPanel) {
	[sender displayIfNeeded];
//#error WindowConversion: 'reenableDisplay' is obsolete.  You can probably remove this call.  Typically drawing should happen as part of the update mechanism after every event.  Display is now optimized using the View setNeedsDisplay: method.  See the conversion doc for more info.
//	[sender reenableDisplay];
    }
}
// */

- (BOOL)windowShouldClose:(id)sender;
{
    if (sender==myWindow) {
	[[[self distributor] globalInspector] setManager:nil];
	[[[self distributor] globalInspector] setSelected:nil];
    }
    if (sender==myKernelViewPanel) {
	[sender setTitle:[NSString jgStringWithCString:KERNEL_PANEL_NAME]];
//#error WindowConversion: 'disableDisplay' is obsolete.  You can probably remove this call.  Typically drawing should happen as part of the update mechanism after every event.  Display is now optimized using the View setNeedsDisplay: method.  See the conversion doc for more info.
//	[sender disableDisplay];
    }
    if (sender==myFieldViewPanel) {
	[sender setTitle:[NSString jgStringWithCString:FIELD_PANEL_NAME]];
//#error WindowConversion: 'disableDisplay' is obsolete.  You can probably remove this call.  Typically drawing should happen as part of the update mechanism after every event.  Display is now optimized using the View setNeedsDisplay: method.  See the conversion doc for more info.
//	[sender disableDisplay];
    }
    return [super windowShouldClose:sender];
}


@end

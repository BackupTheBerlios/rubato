
#import "MetroRubetteDriver.h"
#import <Predicates/PredicateProtocol.h>
#import <Predicates/GenericForm.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubette/Weight.h>
#import "MetroWeightView.h"

@implementation MetroRubetteDriver
+ (const char *)rubetteName;
{
    return "Metro";
}

+ (id)rubetteObjectClass;
{
  return [MetroRubette class];
}

- init;
{
    [super init];
    return self;
}

- (void)closeRubetteWindows1;
{
  [myWeightFunctionPanel performClose:self];
  [myWeightFunctionPanel release]; myWeightFunctionPanel = nil;
  [myWeightViewPanel performClose:self];
  [myWeightViewPanel release]; myWeightViewPanel = nil;
  [myGraphicPrefsPanel performClose:self];
  [myGraphicPrefsPanel release]; myGraphicPrefsPanel = nil;
}
- (void)closeRubetteWindows;
{
  [self closeRubetteWindows1];
  [super closeRubetteWindows];
}

- (void)dealloc;
{
  [self closeRubetteWindows1];
  [super dealloc];
}

- (MetroRubette *)metroObject;
{
  return (MetroRubette *)rubetteObject;
}

- customAwakeFromNib;
{
    [myWeightFunctionPanel setFrameUsingName:[myWeightFunctionPanel title]];
    [myWeightFunctionPanel setBecomesKeyOnlyIfNeeded:YES];
    
    [myWeightViewPanel setFrameUsingName:[myWeightViewPanel title]];
    [myWeightViewPanel setBecomesKeyOnlyIfNeeded:YES];
    
    return self;
}

- (void)readCustomData;
{
    const char *str;
//jg    id aPredicate;
    id rubetteData=[self rubetteData];
    [rubetteObject readCustomData];

    [myMetricalProfileField setDoubleValue:[[self metroObject] metricalProfile]];
    [myLowerLengthLimitField setIntValue:[[self metroObject] lowerLengthLimit]];
    [myAutomaticMeshSwitch setIntValue:[[self metroObject] automaticMesh]];

    [self updateFieldsWithBrowser:myBrowser];
    
    str=[rubetteData stringValueOf:METRO_DIST];
    if (str)
      [myDistValueField setStringValue:[NSString jgStringWithCString:str]];
    else
      [myDistValueField setStringValue:@""];

/*
    aPredicate = [rubetteData getFirstPredicateOfNameString:METRO_WEIGHT_ONSETS];

    myWeightList.length = [aPredicate count];
    myWeightList.wP = realloc(myWeightList.wP, myWeightList.length*sizeof(weightPoint));
    for (i=0; i<myWeightList.length; i++) 
	myWeightList.wP[i].param = [aPredicate doubleValueAt:i];

    aPredicate = [rubetteData getFirstPredicateOfNameString:METRO_WEIGHT_VALUES];

    for (i=0; i<myWeightList.length; i++) 
	myWeightList.wP[i].weight = [aPredicate doubleValueAt:i];

    browserValid = NO;
    [myBrowser validateVisibleColumns];
    browserValid = YES;

    [self showWeightText];    
    [myWeightView displayWeightList:myWeightList];
*/
}

- (void)writeCustomData;
{
  [[self rubetteObject] writeCustomData];
  /*
    aValue = [rubetteData getValueOf:METRO_WEIGHT_ONSETS];
    for (;myWeightList.length<[aValue count];) {
	[aValue deleteValue:[aValue getValueAt:myWeightList.length]];
    }
    for (i=0; i<myWeightList.length;i++) {
	if (![aValue hasPredicateAt:i])
	    [aValue setValue:[[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:"E"]];
			    
	[aValue setDoubleValueAt:i to:myWeightList.wP[i].param];
    }

    aValue = [rubetteData getValueOf:METRO_WEIGHT_VALUES];
    for (;myWeightList.length<[aValue count];) {
	[aValue deleteValue:[aValue getValueAt:myWeightList.length]];
    }
    for (i=0; i<myWeightList.length;i++) {
	if (![aValue hasPredicateAt:i])
	    [aValue setValue:[[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:METRO_WEIGHT]];
	[aValue setDoubleValueAt:i to:myWeightList.wP[i].weight];
    }
*/    
}

- (void)readWeight;
{
    [super readWeight];
    [self makeWeightList];
}

- loadWeight:sender;
{
    [super loadWeight:sender];
    [self makeWeightList];
    return self;
}

- makeWeightList;
{
  [[self metroObject] makeWeightList];
  browserValid = NO;
  [myBrowser validateVisibleColumns];
  browserValid = YES;

  [self showWeightText];    
  [myWeightView displayWeightList:[[self metroObject] weightList]];

    return self;
}


- (void)doSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
{
    browserValid = NO;
  [super doSearchWithFindPredicateSpecification:specification];
    [self makePredList];
    [self updateFieldsWithBrowser:myBrowser]; // jg: this was not in the original, but needed to display distributor...
    [myBrowser validateVisibleColumns];
    browserValid = YES;
}

- (void)initSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
{
    browserValid = NO;
  [super initSearchWithFindPredicateSpecification:specification];
    [self makePredList];
    [self updateFieldsWithBrowser:nil];
    [myBrowser validateVisibleColumns];
    browserValid = YES;
}

- (void)makePredList;
{
  [[self metroObject] makePredList];
}

- doCalculateWeight:sender;
{
    [self makePredList];
    [self calculateWeight];
    [myWeightView displayWeightList:[[self metroObject] weightList]];
    
    [self showWeightText];    
    [self doWriteData:self];

    return self;
}

- (void)calculateWeight;
{
  [[self metroObject] calculateWeight];
  [self afterCreatingNewWeight];
}


- showWeightText;
{
   [myMetroWeightText setString:[[self metroObject] weightText]];
    return self;
}

- (void)updateFieldsWithBrowser:(id)aBrowser
{ // called by setSelectedCell: and intern.
    if (aBrowser && [aBrowser selectedColumn]!=NSNotFound) 
	selPredIndex = [[aBrowser matrixInColumn:[aBrowser selectedColumn]] selectedRow];
    else
	selPredIndex = NSNotFound;

    if (selPredIndex!=NSNotFound) {
      double *distValues=[[self metroObject] distValues];
      grid *gridValues=[[self metroObject] gridValues];
	[myDistValueField setEnabled:YES];
	[myDistValueField setDoubleValue:distValues[selPredIndex]];
	[myQuantOriginField setEnabled:YES];
	[myQuantOriginField setDoubleValue:gridValues[selPredIndex].origin];
	[myQuantMeshField setEnabled:YES];
        [myConverter setFractValue:gridValues[selPredIndex].mesh];
	[myQuantMeshField setStringValue:[myConverter stringValue]];
	[myAutomaticMeshSwitch setEnabled:YES];

    } else {
    	[myDistValueField setEnabled:NO];
	[myDistValueField setStringValue:@"none"];
	[myQuantOriginField setEnabled:NO];
	[myQuantOriginField setStringValue:@"none"];
	[myQuantMeshField setEnabled:NO];
	[myQuantMeshField setStringValue:@"none"];
	[myAutomaticMeshSwitch setEnabled:NO];
    }
}

- (void)setSelectedCell:sender;
{ // called by IB
  [self updateFieldsWithBrowser:sender];
}

- setDistValue:sender;
{
    if ([sender respondsToSelector:@selector(doubleValue)]) {
	if (selPredIndex!=NSNotFound) {
           double *distValues=[[self metroObject] distValues];
	    distValues[selPredIndex] = [sender doubleValue];
	}
    }
    return self;
}


- setMetricalProfile:sender;
{
    if ([sender respondsToSelector:@selector(doubleValue)]) {
      double d=[sender doubleValue];
	[[self rubetteData] setDoubleValueOf:METRO_PROFILE to:d];
        [[self metroObject] setMetricalProfile:d];
    }
    return self;
}

- setLowerLengthLimit:sender;
{
    if ([sender respondsToSelector:@selector(intValue)]) {
      int val=([sender intValue]>0 ? [sender intValue] : 2);
	[[self rubetteData] setIntValueOf:METRO_CARD to:val];
        [[self metroObject] setLowerLengthLimit:val];
    }
    return self;
}

- setQuantMesh:sender;
{
    if ([sender respondsToSelector:@selector(stringValue)]) {
	if (selPredIndex!=NSNotFound) {
          grid *gridValues=[[self metroObject] gridValues];
          [myConverter setStringValue:[sender stringValue]];
	    gridValues[selPredIndex].mesh = [myConverter fractValue];
	}
    }
    return self;
}

- setQuantOrigin:sender;
{
    if ([sender respondsToSelector:@selector(doubleValue)]) {
      if (selPredIndex!=NSNotFound) {
        grid *gridValues=[[self metroObject] gridValues];
	gridValues[selPredIndex].origin = [sender doubleValue];
      }
    }
    return self;
}

- setQuantAutoMesh:sender;
{
    if ([sender respondsToSelector:@selector(intValue)]) {
      int val=[sender intValue];
	[[self rubetteData] setBoolValueOf:METRO_QUANT_AUTO_MESH to:val];
        [[self metroObject] setAutomaticMesh:val];

    }
    return self;
}

/* methods to be overridden by subclasses */
- insertCustomMenuCells;
{
    [[myMenu addItemWithTitle:@"Weight Function" action:@selector(makeKeyAndOrderFront:) keyEquivalent:@""] setTarget:myWeightFunctionPanel];
    [[myMenu addItemWithTitle:@"Weight View" action:@selector(makeKeyAndOrderFront:) keyEquivalent:@""] setTarget:myWeightViewPanel];
    [[myMenu addItemWithTitle:@"Load Weight" action:@selector(loadWeight:) keyEquivalent:@""] setTarget:self];
    [[myMenu addItemWithTitle:@"Save Weight As" action:@selector(saveWeightAs:) keyEquivalent:@""] setTarget:self];
    [[myMenu addItemWithTitle:@"Graphic Preferences" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myGraphicPrefsPanel];
    return self;
}

+ (NSString *)nibFileName;
{
  return @"MetroRubette.nib";
}


/* window management */
- (IBAction)showWindow:(id)sender;
{
    [myWeightFunctionPanel makeKeyAndOrderFront:nil];
    [myWeightViewPanel makeKeyAndOrderFront:nil];
    [super showWindow:sender];
}

- hideWindow:sender;
{
    [myWeightFunctionPanel orderOut:self];
    [myWeightViewPanel orderOut:self];
    [myGraphicPrefsPanel orderOut:sender];
    return [super hideWindow:sender];
}


@end

@implementation MetroRubetteDriver(BrowserDelegate)
/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    if (column)
	return 0;
    else
	return [[self lastFoundPredicates] count];
}

//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    if (!column) {
	id predicate = [[self lastFoundPredicates] getValueAt:row];
	id image, imageString = [[StringConverter alloc]init];
	if (predicate) {
            if ([predicate isKindOfClass:NSClassFromString(@"ValuePredicate")]) {
		const char *pnam=[predicate nameString], *pval=[[predicate stringValue] cString],
				    *delim = ": ";
		char * str = malloc(strlen(pnam)+strlen(pval)+strlen(delim)+1);
		strcpy(str, pnam);
		strcat(str, delim);
		strcat(str, pval);
		[cell setLoaded:YES];
		[cell setStringValue:[NSString jgStringWithCString:str]];
		[cell setLeaf:YES];
		free(str);
	    } else {
		[cell setLoaded:YES];
		[cell setStringValue:[NSString jgStringWithCString:[predicate nameString]]];
		[cell setLeaf:YES];
		[imageString setStringValue:[NSString jgStringWithCString:[predicate typeString]]];
		image = [NSImage imageNamed:[imageString stringValue]];
		if (image) 
		    [cell setImage:[image copy]];
		[imageString concat:"H"];
		image = [NSImage imageNamed:[imageString stringValue]];
		if (image) 
		    [cell setAlternateImage:[image copy]];
	    }
	}
	[imageString release];
    }
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
{
    BOOL retVal;
    if (column) retVal = YES;
    else {
	retVal = ([NSView focusView] == [sender matrixInColumn:column]) ? YES : browserValid;
	//browserValid = YES;
    }
    return retVal;
}

@end




#import <RubatoDeprecatedCommonKit/commonkit.h>

#import <Rubato/RubatoTypes.h>
#import <Predicates/PredicateProtocol.h>
#import <Predicates/PredicateDelimiter.h>
#import <Rubette/Weight.h>
#import <Rubette/MatrixEvent.h>
#import <Rubette/space.h>

#import "PrimaVistaRubetteDriver.h"
#import <RubatoAnalysis/PrimaVistaPreferences.h>
#import <RubatoAnalysis/PrimaVista.h>


@implementation PrimaVistaRubetteDriver

- (void)closeRubetteWindows1;
{
  [myArpeggioPrefsPanel performClose:self];
  [myArpeggioPrefsPanel release]; myArpeggioPrefsPanel = nil;
  [myArticulationPrefsPanel performClose:self];
  [myArticulationPrefsPanel release]; myArticulationPrefsPanel = nil;
  [myRelDynamicPrefsPanel performClose:self];
  [myRelDynamicPrefsPanel release]; myRelDynamicPrefsPanel = nil;
  [myAbsDynamicPrefsPanel performClose:self];
  [myAbsDynamicPrefsPanel release]; myAbsDynamicPrefsPanel = nil;
  [myOrnamentPrefsPanel performClose:self];
  [myOrnamentPrefsPanel release]; myOrnamentPrefsPanel = nil;
  [myRelTempoPrefsPanel performClose:self];
  [myRelTempoPrefsPanel release]; myRelTempoPrefsPanel = nil;
  [myTuningPrefsPanel performClose:self];
  [myTuningPrefsPanel release]; myTuningPrefsPanel = nil;
  [myOtherPrefsPanel performClose:self];
  [myOtherPrefsPanel release]; myOtherPrefsPanel = nil;
  [myOrnamentTypesPanel performClose:self];
  [myOrnamentTypesPanel release]; myOrnamentTypesPanel = nil;
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

- customAwakeFromNib;
{
    //[myOrnamentTypesPanel setFrameUsingName:[myOrnamentTypesPanel title]];
    //[myOrnamentTypesPanel setBecomeKeyOnlyIfNeeded:YES];
    
// why should not be these from NSPopUpButton??? Happed to be after Conversion.
/*
    if (![myCoordPopUp1 isKindOfClass:[NSPopUpButton class]]) {
	[myCoordPopUp1 selectItemAtIndex:[[myCoordPopUp1 target] indexOfItem:[myCoordPopUp1 title]]];
	myCoordPopUp1 = [myCoordPopUp1 target];
    }
    if (![myCoordPopUp2 isKindOfClass:[NSPopUpButton class]]) {
    	[myCoordPopUp2 selectItemAtIndex:[[myCoordPopUp2 target] indexOfItem:[myCoordPopUp2 title]]];
	myCoordPopUp2 = [myCoordPopUp2 target];
    }
*/
    [myValueNameField setStringValue:[NSString jgStringWithCString:CUSTOM_PV_VALUE_NAME]];
    return self;
}


- findArtiEvents:sender;
{
    [self initSearchWithFindPredicateSpecification: findPredicatesWindowController];
    [findPredicatesWindowController setCascadeSearch:NO];
    
    [findPredicatesWindowController setFindString:@"Note"];
    [self doSearchWithFindPredicateSpecification:findPredicatesWindowController];
    
    return self;
}

- findAbsDynEvents:sender;
{
    int i;
    [self initSearchWithFindPredicateSpecification: findPredicatesWindowController];
    [findPredicatesWindowController setCascadeSearch:NO];
    for (i=0; i<ABSDYN_RANGE; i++) {
	[findPredicatesWindowController setFindString:[NSString jgStringWithCString:[myPreferences stringValueOfParameter:[myPreferences absDynParaNameNameAt:i]]]];
	[self doSearchWithFindPredicateSpecification:findPredicatesWindowController];
    }
    return self;
}

- findRelDynEvents:sender;
{
    int i;
    [self initSearchWithFindPredicateSpecification: findPredicatesWindowController];
    [findPredicatesWindowController setCascadeSearch:NO];
    for (i=0; i<RELDYN_RANGE; i++) {
	[findPredicatesWindowController setFindString:[NSString jgStringWithCString:[myPreferences stringValueOfParameter:[myPreferences relDynParaNameNameAt:i]]]];
	[self doSearchWithFindPredicateSpecification:findPredicatesWindowController];
    }
    return self;
}

- findAbsTpoEvents:sender;
{
    [self initSearchWithFindPredicateSpecification: findPredicatesWindowController];
    [findPredicatesWindowController setCascadeSearch:NO];
    
    [findPredicatesWindowController setFindString:[NSString jgStringWithCString:ABS_TPO_VALUE_NAME]];
    [self doSearchWithFindPredicateSpecification:findPredicatesWindowController];

    [findPredicatesWindowController setFindString:[NSString jgStringWithCString:ABS_TPO_NAME]];
    [self doSearchWithFindPredicateSpecification:findPredicatesWindowController];
    
    return self;
}

- findRelTpoEvents:sender;
{
    int i;
    [self initSearchWithFindPredicateSpecification: findPredicatesWindowController];
    [findPredicatesWindowController setCascadeSearch:NO];
    for (i=0; i<RELTPO_RANGE; i++) {
	[findPredicatesWindowController setFindString:[NSString jgStringWithCString:[myPreferences stringValueOfParameter:[myPreferences relTpoParaNameNameAt:i]]]];
	[self doSearchWithFindPredicateSpecification:findPredicatesWindowController];
    }
    return self;
}

- findCustomEvents:sender;
{
    [self initSearchWithFindPredicateSpecification: findPredicatesWindowController];
    [findPredicatesWindowController setCascadeSearch:NO];
    
    [self doSearchWithFindPredicateSpecification:findPredicatesWindowController];
    
    return self;
}

- makeEventListOfType:(int)PVType;
{
    id predicate, event=nil;
    int tag=NSNotFound;
    unsigned int i, j, prediCount, lastPrediCount = [[self lastFoundPredicates] count];
    BOOL hasTpo = NO;
    
    [myEventList release]; myEventList = nil;
    myEventList = [[[OrderedList alloc]init]ref];
   
    if (PVType==PV_Custom_1D || PVType==PV_Custom_2D) {
	for (i=0; i<lastPrediCount; i++) {
	    /* first clean up the predicates*/
	    for (j=0, prediCount=[[[self lastFoundPredicates] getValueAt:i] count]; j<prediCount; j++) {
		predicate = [[[self lastFoundPredicates] getValueAt:i]getValueAt:j];
		if (![predicate hasPredicateOfNameString:[[myCoordPopUp1 titleOfSelectedItem] cString]] 
		|| (PVType==PV_Custom_2D && ![predicate hasPredicateOfNameString:[[myCoordPopUp2 titleOfSelectedItem] cString]])
		|| ![predicate hasPredicateOfNameString:[[myValueNameField stringValue] cString]]) {
		    [[self lastFoundPredicates] removeValue:predicate];
		    prediCount--;
		    j--;
		} else {
		    event = [[[MatrixEvent alloc]init]setSpaceTo:spaceOfIndex([[myCoordPopUp1 selectedItem]tag])];
		    [event setDoubleValue:[predicate doubleValueOf:[[myCoordPopUp1 titleOfSelectedItem] cString]]
			atIndex:[[myCoordPopUp1 selectedItem]tag]];
		    if (PVType==PV_Custom_2D) {
			[event setSpaceAt:[[myCoordPopUp2 selectedItem]tag] to:YES];
			[event setDoubleValue:[predicate doubleValueOf:[[myCoordPopUp2 titleOfSelectedItem] cString]]
			    atIndex:[[myCoordPopUp2 selectedItem]tag]];
		    }
		    [event setDoubleValue:[predicate doubleValueOf:[[myValueNameField stringValue] cString]]];
		    [myEventList addObject:event];
		}
	    }
	}
    } else if (PVType==PV_Articulation) {
	for (i=0; i<lastPrediCount; i++) {
	    /* first clean up the predicates*/
	    for (j=0, prediCount=[[[self lastFoundPredicates] getValueAt:i] count]; j<prediCount; j++) {
		predicate = [[[self lastFoundPredicates] getValueAt:i]getValueAt:j];
		if (![predicate hasPredicateOfNameString:strE] 
		&& (![predicate hasPredicateOfNameString:strH])) {
		    [[self lastFoundPredicates] removeValue:predicate];
		    prediCount--;
		    j--;
		} else {
		    tag = [myPreferences indexOfArtiName:[predicate stringValueOf:"Art"]];
		    event = [[[MatrixEvent alloc]init]setSpaceTo:EH_space];
		    if ([predicate hasPredicateOfNameString:strD]) {
			[event setSpaceAt:indexD to:spaceOfIndex(indexD)];
			[event setDoubleValue:[predicate doubleValueOf:strD] atIndex:indexD];
		    }
		    if ([predicate hasPredicateOfNameString:strG]) {
			[event setSpaceAt:indexG to:spaceOfIndex(indexG)];
			[event setDoubleValue:[predicate doubleValueOf:strG] atIndex:indexG];
		    }
		    [event setDoubleValue:[predicate doubleValueOf:strE] atIndex:indexE];
		    [event setDoubleValue:[predicate doubleValueOf:strH] atIndex:indexH];
		    [event setDoubleValue:tag];
		    [myEventList addObject:event];
		}
	    }
	}
    } else {
	/* first clean up the predicates*/
	for (i=0; i<lastPrediCount; i++) {
	    for (j=0, prediCount=[[[self lastFoundPredicates] getValueAt:i] count]; j<prediCount; j++) {
		predicate = [[[self lastFoundPredicates] getValueAt:i]getValueAt:j];
		if (![predicate hasPredicateOfNameString:strE] 
		&& (hasTpo || !(hasTpo=[predicate isPredicateOfNameString:ABS_TPO_VALUE_NAME]))) {
		    [[self lastFoundPredicates] removeValue:predicate];
		    prediCount--;
		    j--;
		} else {
		    switch (PVType) {
			case PV_AbsDynamic:
			    tag = [myPreferences indexOfAbsDynName:[predicate nameString]];
			    break;
			case PV_RelDynamic:
			    tag = [myPreferences indexOfRelDynName:[predicate nameString]];
			    break;
			case PV_AbsTempo:
			    tag = 0;
			    break;
			case PV_RelTempo: 
			    tag = [myPreferences indexOfRelTpoName:[predicate nameString]];
			    break;
		    }
		    if (tag!=NSNotFound) {
			event = [[[MatrixEvent alloc]init]setSpaceTo:E_space];
			if ([predicate hasPredicateOfNameString:strE]) 
			    [event setDoubleValue:[predicate doubleValueOf:strE] atIndex:indexE];
			else
			    [event setDoubleValue:-1.0 atIndex:indexE];
			if ([predicate hasPredicateOfNameString:strD] && PVType!=PV_Articulation) {
			    [event setSpaceAt:indexD to:YES];
			    [event setDoubleValue:[predicate doubleValueOf:strD] atIndex:indexD];
			}
			
			if (PVType==PV_AbsTempo)
			    if ([predicate hasPredicateOfNameString:ABS_TPO_VALUE_NAME])
				[event setDoubleValue:[predicate doubleValueOf:ABS_TPO_VALUE_NAME]];
			    else
				[event setDoubleValue:[predicate doubleValue]];
			else
			    [event setDoubleValue:tag];
			[myEventList addObject:event];
		    }
		}
	    }
	}
    }

	
    [myEventList sort];
    return self;
}

- doMakeTempoWeight:sender;
{
    [self setWeight:nil];    
    [self findAbsTpoEvents:sender];
    [self makeEventListOfType:PV_AbsTempo];
    [myPVObject setAbsTpoEventList:myEventList];
    
    [self findRelTpoEvents:sender];
    [self makeEventListOfType:PV_RelTempo];
    [myPVObject setRelTpoEventList:myEventList];
    
    [self setWeight: [[myPVObject makeTpoWeight]ref]];
    [[self weight] setRubetteName:[[self class] rubetteName]];
    [weightName setEnabled:YES];
    [weightName setStringValue:[NSString jgStringWithCString:[[self weight] nameString]]];
    [self setDataChanged:YES];
    return self;
}

- doMakeArtiWeight:sender;
{
  [self setWeight:nil];    
    
    [self findArtiEvents:sender];
    [self makeEventListOfType:PV_Articulation];
    [myPVObject setArtiEventList:myEventList];
    [self setWeight: [[myPVObject makeArtiWeight]ref]];
    [[self weight] setRubetteName:[[self class] rubetteName]];
    [weightName setEnabled:YES];
    [weightName setStringValue:[NSString jgStringWithCString:[[self weight] nameString]]];
    [self setDataChanged:YES];
    return self;
}

- doMakeDynaWeight:sender;
{
  [self setWeight:nil];    
   
    [self findAbsDynEvents:sender];
    [self makeEventListOfType:PV_AbsDynamic];
    [myPVObject setAbsDynEventList:myEventList];
    
    [self findRelDynEvents:sender];
    [self makeEventListOfType:PV_RelDynamic];
    [myPVObject setRelDynEventList:myEventList];
    
    [self setWeight: [[myPVObject makeDynWeight]ref]];
    [[self weight] setRubetteName:[[self class] rubetteName]];
    [weightName setEnabled:YES];
    [weightName setStringValue:[NSString jgStringWithCString:[[self weight] nameString]]];
    [self setDataChanged:YES];
    return self;
}


- doMakeCustom1DWeight:sender;
{
    int i, c;
  [self setWeight:nil];    
   
    [self findCustomEvents:sender];
    [self makeEventListOfType:PV_Custom_1D];
    if (c=[myEventList count]) {
	[self setWeight: [[[[Weight alloc]init]sort]ref]];
	[[self weight] setSpaceTo:[[myEventList objectAt:0]space]];
	for (i=0; i<c; i++)
	    [[self weight] addEvent:[myEventList objectAt:i]];
	
	[[self weight] setRubetteName:[[self class] rubetteName]];
	[[self weight] setNameString:CSTM1D_WEIGHT_NAME];
	[weightName setEnabled:YES];
	[weightName setStringValue:[NSString jgStringWithCString:[[self weight] nameString]]];
	[self setDataChanged:YES];
    }
    return self;
}


- doMakeCustom2DWeight:sender;
{
    int i, c;
    [self setWeight:nil];    
    [self setWeight: [[[[Weight alloc]init]sort]ref]];
    [self findCustomEvents:sender];
    [self makeEventListOfType:PV_Custom_2D];
    c= [myEventList count];
    [[self weight] setSpaceTo:[[myEventList objectAt:0]space]];
    for (i=0; i<c; i++)
	[[self weight] addEvent:[myEventList objectAt:i]];
    
    [[self weight] setRubetteName:[[self class] rubetteName]];
    [[self weight] setNameString:CSTM2D_WEIGHT_NAME];
    [weightName setEnabled:YES];
    [weightName setStringValue:[NSString jgStringWithCString:[[self weight] nameString]]];
    [self setDataChanged:YES];
    return self;
}


/* window management */
- (IBAction)showWindow:(id)sender;
{
    [super showWindow:sender];
    //[myRelTempoPrefsPanel orderFront:sender];
    //[myTuningPrefsPanel orderFront:sender];
    //[myRelDynamicPrefsPanel orderFront:sender];
    //[myAbsDynamicPrefsPanel orderFront:sender];
    //[myOtherPrefsPanel orderFront:sender];
    //[myOrnamentPrefsPanel orderFront:sender];
    //[myArticulationPrefsPanel orderFront:sender];
    //[myArpeggioPrefsPanel orderFront:sender];
    //[myOrnamentTypesPanel orderFront:sender];
    //[myNormalisationPanel orderFront:sender];
}

- hideWindow:sender;
{
    [myRelTempoPrefsPanel orderOut:sender];
    [myTuningPrefsPanel orderOut:sender];
    [myRelDynamicPrefsPanel orderOut:sender];
    [myAbsDynamicPrefsPanel orderOut:sender];
    [myOtherPrefsPanel orderOut:sender];
    [myOrnamentPrefsPanel orderOut:sender];
    [myArticulationPrefsPanel orderOut:sender];
    [myArpeggioPrefsPanel orderOut:sender];
    [myOrnamentTypesPanel orderOut:sender];

    [super hideWindow:sender];
    return self;
}

- showArpeggio:sender;
{
    if (!myArpeggioPrefsPanel) {
	[self loadNibSection: "Arpeggio.nib"];
	[myArpeggioPrefsPanel setFrameUsingName:[myArpeggioPrefsPanel title]];
    }
    [myArpeggioPrefsPanel orderFront:self];
    return self;
}

- showArticulation:sender;
{
    if (!myArticulationPrefsPanel) {
	[self loadNibSection: "Articulation.nib"];
	[myArticulationPrefsPanel setFrameUsingName:[myArticulationPrefsPanel title]];
    }
    [myArticulationPrefsPanel orderFront:self];
    return self;
}

- showRelDynamics:sender;
{
    [myRelDynamicPrefsPanel orderFront:self];
    return self;
}

- showAbsDynamics:sender;
{
    [myAbsDynamicPrefsPanel orderFront:self];
    return self;
}

- showOrnaments:sender;
{
    if (!myOrnamentPrefsPanel) {
	[self loadNibSection: "Ornaments.nib"];
	[myOrnamentPrefsPanel setFrameUsingName:[myOrnamentPrefsPanel title]];
    }[myOrnamentPrefsPanel orderFront:self];
    return self;
}

- showRelTempo:sender;
{
    [myRelTempoPrefsPanel orderFront:self];
    return self;
}

- showTuning:sender;
{
    if (!myTuningPrefsPanel) {
	[self loadNibSection: "Tuning.nib"];
	[myTuningPrefsPanel setFrameUsingName:[myTuningPrefsPanel title]];
    }
    [myTuningPrefsPanel orderFront:self];
    return self;
}

- showOthers:sender;
{
    if (!myOtherPrefsPanel) {
	[self loadNibSection: "Other.nib"];
	[myOtherPrefsPanel setFrameUsingName:[myOtherPrefsPanel title]];
    }
    [myOtherPrefsPanel orderFront:self];
    return self;
}


/* methods to be overridden by subclasses */
- insertCustomMenuCells;
{
    //[[myMenu addItem:"Arpeggio & Tie Prefs¼" action:@selector(showArpeggio:) keyEquivalent:@""]setTarget:self];
    [[myMenu addItemWithTitle:@"Articulation Prefs" action:@selector(showArticulation:) keyEquivalent:@""] setTarget:self];
    [[myMenu addItemWithTitle:@"Absolute Dynamic Prefs" action:@selector(showAbsDynamics:) keyEquivalent:@""] setTarget:self];
    [[myMenu addItemWithTitle:@"Relative Dynamic Prefs" action:@selector(showRelDynamics:) keyEquivalent:@""] setTarget:self];
    //[[myMenu addItem:"Ornament Prefs¼" action:@selector(showOrnaments:) keyEquivalent:@""]setTarget:self];
    [[myMenu addItemWithTitle:@"Tempo Prefs" action:@selector(showRelTempo:) keyEquivalent:@""] setTarget:self];
    //[[myMenu addItem:"Tuning Prefs¼" action:@selector(showTuning:) keyEquivalent:@""]setTarget:self];
    //[[myMenu addItem:"Other Prefs¼" action:@selector(showOthers:) keyEquivalent:@""]setTarget:self];

    //[[myMenu addItem:"Ornament Types¼" action:@selector(orderFront:) keyEquivalent:@""]setTarget:myOrnamentTypesPanel];
    //[[myMenu addItem:"Normalization¼" action:@selector(orderFront:) keyEquivalent:@""]setTarget:myNormalisationPanel];

    [[myMenu addItemWithTitle:@"Load Preferences" action:@selector(openPrefsFile:) keyEquivalent:@""] setTarget:myPreferences];
    [[myMenu addItemWithTitle:@"Save Preferences As" action:@selector(savePrefsFileAs:) keyEquivalent:@""] setTarget:myPreferences];
    
    [[myMenu addItemWithTitle:@"Save Weight As" action:@selector(saveWeightAs:) keyEquivalent:@""] setTarget:self];
    return self;
}

/* class methods to be overriden */
+ (NSString *)nibFileName;
{
  return @"PrimaVistaRubette.nib";
}

+ (const char *)rubetteName;
{
    return "PrimaVista";
}

+ (const char *)rubetteVersion;
{
    return "2.0";
}

+ (spaceIndex) rubetteSpace;
{
    return 1;
}

@end

@implementation PrimaVistaRubetteDriver(WindowDelegate)
/* (WindowDelegate) methods */

//#warning NotificationConversion: windowDidResignKey:(NSNotification *)notification is an NSWindow notification method (used to be a delegate method); delegates of NSWindow are automatically set to observe this notification; subclasses of NSWindow do not automatically receive this notification
- (void)windowDidResignKey:(NSNotification *)notification
{ 
// jg jg was return self;
//    NSWindow *theWindow = [notification object];
}

@end
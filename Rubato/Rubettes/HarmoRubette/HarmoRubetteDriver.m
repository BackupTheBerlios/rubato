
#import "HarmoRubetteDriver.h"
#import <RubatoAnalysis/ChordSequence.h>
#import <RubatoAnalysis/Chord.h>
#import "HarmoPreferences.h"
#import <Rubette/MatrixEvent.h>
#import <Rubette/Weight.h>
#import <Rubette/WeightView.h>
#import <Rubette/space.h>
#import <Rubato/RubatoController.h>
#import <Rubato/GenericObjectInspector.h>
#import <Predicates/PredicateProtocol.h>

#define EHD_space 11

#import <RubatoAnalysis/JGChordProbabilityController.h>

@interface HarmoRubetteDriver (ViterbiSupport)
- (void)viterbiInit;
- (void)viterbiAfterMakeChords;
- (void)viterbiAfterMakeRiemannLogic;
- (void)viterbiAfterCalculatePath;
@end

@implementation HarmoRubetteDriver (ViterbiSupport)
- (void)viterbiInit;
{
  chordProbabilityController=[[JGChordProbabilityController newInstanceWithDefaultNib] retain];
  ((JGChordProbabilityController *)chordProbabilityController)->harmoRubetteDriver=self;
}
- (void)viterbiAfterMakeChords;
{
  JGViterbiContext *viterbiContext=[myChordSequence makeViterbiContextUseLevelMatrix:YES];
  [viterbiContext->viterbi viterbiAllocateDelta];
  [chordProbabilityController setViterbi:viterbiContext->viterbi];
  [chordProbabilityController setValuesForNewViterbi];
  [myChordSequence setViterbiContext:viterbiContext];
  [chordProbabilityController updateAll];
}
- (void)viterbiAfterMakeRiemannLogic
{
  JGViterbiContext *viterbiContext=[myChordSequence viterbiContext];
  JGViterbi *vit=viterbiContext->viterbi;
  [viterbiContext->processedSymbols release];
  viterbiContext->processedSymbols=[[NSMutableSet alloc] init];
  viterbiContext->nextObservationPosition=0;
  vit->nextT=0;
  [myChordSequence addProbabilitiesToViterbiContext:viterbiContext];
  [chordProbabilityController updateAll];
}
- (void)viterbiAfterCalculatePath;
{
  [chordProbabilityController updateAll];
}
@end


@implementation HarmoRubetteDriver

- init;
{
    [super init];
    
    myEventList = [[[OrderedList alloc]init]ref];
    myChordSequence = [[[ChordSequence alloc]init]ref];
    myChordWeight=nil;
    [self viterbiInit];
    return self;
}

- (void)closeRubetteWindows1;
{
  [myWeightFunctionPanel performClose:self];
  [myWeightFunctionPanel release]; myWeightFunctionPanel = nil;
  [myWeightViewPanel performClose:self];
  [myWeightViewPanel release]; myWeightViewPanel = nil;
  [myRiemannGraphPanel performClose:self];
  [myRiemannGraphPanel release]; myRiemannGraphPanel = nil;
  [myGraphicPrefsPanel performClose:self];
  [myGraphicPrefsPanel release]; myGraphicPrefsPanel = nil;
}
- (void)closeRubetteWindows2;
{
  [myRiemannPrefsPanel performClose:self];
  [myRiemannPrefsPanel release]; myRiemannPrefsPanel = nil;
  [myTonalityPrefsPanel performClose:self];
  [myTonalityPrefsPanel release]; myTonalityPrefsPanel = nil;
  [myGeneralPrefsPanel performClose:self];
  [myGeneralPrefsPanel release]; myGeneralPrefsPanel = nil;
  [myNollPrefsPanel performClose:self];
  [myNollPrefsPanel release]; myNollPrefsPanel = nil;
}
- (void)closeRubetteWindows;
{
  [self closeRubetteWindows1];
  [self closeRubetteWindows2];
  [super closeRubetteWindows];
}
- (void)dealloc;
{
    [self updateFieldsWithBrowser:nil];
    [myEventList release]; myEventList = nil;
    [myChordSequence release]; myChordSequence = nil;
    [myChordWeight release]; myChordWeight = nil;

    [self closeRubetteWindows1];
    [myPreferences release]; myPreferences = nil;
    [self closeRubetteWindows2];
    [chordProbabilityController release];
    [super dealloc];
}



- chordSequence;
{
    return myChordSequence;
}

- (void)readCustomData;
{
    [super readCustomData];
    [self update];
}

- (void)doSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
{
    browserValid = NO;
  [super doSearchWithFindPredicateSpecification:specification];
}


- makeEventList;
{
    id predicate, event;
    unsigned int i, prediCount = [[self foundPredicates] count];
    
    [myEventList freeObjects];
    
    /* first clean up the predicates*/
    for (i=0; i<prediCount; i++) {
	predicate = [[self foundPredicates] getValueAt:i];
	if (!([predicate hasPredicateOfNameString:"E"] &&
	    [predicate hasPredicateOfNameString:"H"])) {
	    [[self foundPredicates] removeValue:predicate];
	    prediCount--;
	    i--;
	}
    }

    for (i=0; i<prediCount; i++) {
	predicate = [[self foundPredicates] getValueAt:i];
	event = [[[MatrixEvent alloc]init]setSpaceTo:EHD_space];
	[event setDoubleValue:[predicate doubleValueOf:"E"] atIndex:indexE];
	[event setDoubleValue:[predicate doubleValueOf:"H"] atIndex:indexH];
	[event setDoubleValue:[predicate doubleValueOf:"D"] atIndex:indexD];
	[myEventList addObject:event];
    }
    return self;
}

- makeChordWeight;
{
    int i, c=[myChordSequence count];
    if (!myChordWeight || [myChordWeight count]) {
	[myChordWeight release];
	myChordWeight = [[[Weight alloc]init]setSpaceTo:spaceOfIndex(indexE)];
    }
    for (i=0; i<c; i++) {
	id iChord = [myChordSequence chordAt:i];
	[myChordWeight addWeight:[iChord bestWeight] at:[iChord onset] :0.0 :0.0 :0.0 :0.0 :0.0];
    }
    return self;
}


- debugShortRL;
{
   static int nr=0;
   if (nr<1) return self;
   [myPreferences resetChordSequence:self];
   if (nr<2) return self;
   [myChordSequence generateRiemannLogic];
   if (nr<3) return self;
   [myCalcAmountField setFloatValue:[myChordSequence approxCalculations]];
   if (nr<4) return self;
   [self showRiemannGraph];
   if (nr<5) return self;
   [self update];
   if (nr<6) return self;
   [[[self distributor] globalInspector] update];
   return self;
}

- doMakeChordSequence:sender;
{
    [self updateFieldsWithBrowser:nil]; /* deselect a shown chord */
    
    [self makeEventList];
    if ([myPreferences useDuration])
	[myChordSequence generateChordsFromEHDList:myEventList];
    else
	[myChordSequence generateChordsFromEHList:myEventList];
    
    [myChordSequence installThirdStreams];
    
    [[myBrowser matrixInColumn:0] selectCellAtRow:-1 column:-1];
    [myBrowser loadColumnZero];
    [myBrowser validateVisibleColumns];
    browserValid = YES;

    [self newWeight];
    [myChordSequence addHarmoWeightsToWeight:[self weight]];
    [self showWeight:self];
    [self showWeightText];
    
    [myCalcAmountField setFloatValue:[myChordSequence approxCalculations]];
    [self update];
    [self debugShortRL];
    [self viterbiAfterMakeChords];
    return self;
}


- doCalculateRiemannLogic:sender;
{
    [myPreferences resetChordSequence:self];
    [myChordSequence generateRiemannLogic];
    [myCalcAmountField setFloatValue:[myChordSequence approxCalculations]];
    [self showRiemannGraph];
    [self update];
    [[[self distributor] globalInspector] update];
    [self viterbiAfterMakeRiemannLogic];
    return self;
}


- doCalculatePath:sender;
{
    [myChordSequence calcBestPath];
    [self update];
    [self setDataChanged:YES];
    [self viterbiAfterCalculatePath];
    return self;
}


- doCalculateWeight:sender;
{
    [self newWeight];
    [myPreferences setWeightPrefs:self];
    [myChordSequence addHarmoWeightsToWeight:[self weight]];
    
    [self makeChordWeight];
    
    [self showWeight:self];
    [self showWeightText];
    [self update]; 
    
    [self setDataChanged:YES];
    return self;
}


- doCalculate:sender;
{
    [self doCalculateRiemannLogic:sender];
    [self doCalculatePath:sender];
    [self doCalculateWeight:sender];
    [self showRiemannGraph];
    [self update];
    [[[self distributor] globalInspector] displayPatient:self];
    return self;
}


- (void)update;
{
    [myRiemannLogicButton setEnabled:![myChordSequence isRiemannLogicOK]];
    [myCalcBestPathButton setEnabled:![myChordSequence isWeightCalculated]];
}

- (void)setSelectedCell:sender;
{ // called by IB
[self updateFieldsWithBrowser:sender];
}


- showWeightText;
{
    if ([[self weight] count]) {
	int i, p;
	id iChord;
	NSMutableString *mutableString = [NSMutableString new];
	
	[mutableString appendFormat:@"%s", "Onset"];
	[mutableString appendFormat:@"%c", '\t'];
	[mutableString appendFormat:@"%s", "Pitch"];
	[mutableString appendFormat:@"%c", '\t'];
	[mutableString appendFormat:@"%s", "Weight"];
	[mutableString appendFormat:@"%c", '\n'];
	for (i=0; i<[[self weight] count]; i++) {
	    [mutableString appendFormat:@"%.5f", [[[self weight] eventAt:i]doubleValueAtIndex:indexE]];
	    [mutableString appendFormat:@"%c", '\t'];
	    [mutableString appendFormat:@"%.5f", [[[self weight] eventAt:i]doubleValueAtIndex:indexH]];
	    [mutableString appendFormat:@"%c", '\t'];
	    [mutableString appendFormat:@"%.5f", [[[self weight] eventAt:i]doubleValue]];
	    [mutableString appendFormat:@"%c", '\n'];
	}
	
	[mutableString appendFormat:@"%s", "\nRiemann Function List\n"];
	
	for (i=0; i<[myChordSequence count]; i++) {
	    iChord = [myChordSequence chordAt:i];
	    p=[iChord locusOfPath:0];
	    [mutableString appendFormat:@"%.5f", [iChord onset]];
	    [mutableString appendFormat:@"%c", '\t'];
	    if (p<MAX_LOCUS) {
		[mutableString appendFormat:@"%s (", pitchClassName(locusOf(p).RieTon)];
                [mutableString appendFormat:@"%s)", riemannFunctionName(locusOf(p).RieVal)];
	    } else
		[mutableString appendFormat:@"%s", "Out of harmonic context"];
	    
	    [mutableString appendFormat:@"%c", '\t'];
	    [mutableString appendFormat:@"%.5f", [iChord bestWeight]];
	    [mutableString appendFormat:@"%c", '\n'];
	}

	[myWeightText setString:mutableString];
    } else
	[myWeightText setString:@""];    
    return self;
}


- showRiemannGraph;
{
    id iChord, cell;
    int count, r, p, c;
    
    [myRiemannGraphMatrix getNumberOfRows:&r columns:&c];
    
    count = [myChordSequence count];
    [myRiemannGraphMatrix renewRows:r columns:count];
    
//    if (NO /* was [<view> isAutoDisplay] */) 
//#error ViewConversion: 'setAutodisplay:' is obsolete
//	[myRiemannGraphMatrix setAutodisplay:NO];
    for (c=0; c<count; c++) {
	iChord = [myChordSequence chordAt:c];
	p=[iChord locusOfPath:0];
	cell = [myRiemannGraphMatrix cellAtRow:0 column:c];
	[cell setIntValue:c+1];
//#warning ColorConversion: [cell setDrawsBackground:NO] was [cell setBackgroundGray:-1]
	[cell setDrawsBackground:NO]; /* make it transparent */
	[cell setBordered:YES];
	
	cell = [myRiemannGraphMatrix cellAtRow:1 column:c];
	[cell setDoubleValue:[iChord onset]];
//#warning ColorConversion: [cell setDrawsBackground:NO] was [cell setBackgroundGray:-1]
	[cell setDrawsBackground:NO]; /* make it transparent */
	[cell setBordered:YES];
	
	for (r=0; r<MAX_TONALITY; r++) {
	    cell = [myRiemannGraphMatrix cellAtRow:r+2 column:c];
	    [cell setBordered:YES];
	    if (p<MAX_LOCUS && locusOf(p).RieTon==modTwelve(-((r-6)*7))) {
		/* modTwelve(-((r-6)*7)) gives the index counting down in fifths from F# in row 0 */
		[cell setStringValue:[NSString jgStringWithCString:riemannFunctionName(locusOf(p).RieVal)]];
		[cell setBackgroundColor:[NSColor lightGrayColor]];
	    } else {
//#warning ColorConversion: [cell setDrawsBackground:NO] was [cell setBackgroundGray:-1]
		[cell setDrawsBackground:NO]; /* make it transparent */
		[cell setStringValue:@""];
	    }
	}
    }
    [myRiemannGraphMatrix sizeToCells];
    [[myRiemannGraphMatrix superview] display];
    /* so the scroller which contains myRiemannGraphMatrix
     * also is refreshed, just in case myRiemannGraphMatrix
     * is smaller than before.
     */ 
    return self;
}


- showWeight:sender;
{
    if ([myChordWeightSwitch intValue]) {
	[myWeightView displayWeight:myChordWeight];
    } else {
	[myWeightView displayWeight:[self weight]];
    }
    return self;
}

- (void)updateFieldsWithBrowser:sender;
{
    if ([sender isKindOfClass:[NSBrowser class]] && [sender selectedColumn]!=NSNotFound) 
	selRowIndex = [[sender matrixInColumn:[sender selectedColumn]] selectedRow];
    else
	selRowIndex = NSNotFound;

    if (selRowIndex!=NSNotFound) {
	[[[self distributor] globalInspector] setSelected:[myChordSequence chordAt:selRowIndex]];
	browserValid = NO;
	[myBrowser validateVisibleColumns];
    } else {
	int i, c = [myChordSequence count];
	for (i=0; i<c && [myChordSequence chordAt:i]!=[[[self distributor] globalInspector] patient]; i++);
	if (i<c)
	    [[[self distributor] globalInspector] setSelected:nil];
    }
    browserValid = YES;
}


- resetRiemannDefaultValues:sender;
{
    [myChordSequence resetRiemannDefaultValues];
    [myPreferences takePreferencesFrom:myChordSequence];
    return self;
}

- resetTonalityDefaultValues:sender;
{
    [myChordSequence resetTonalityDefaultValues];
    [myPreferences takePreferencesFrom:myChordSequence];
    return self;
}

- resetNollDefaultValues:sender;
{
    [myChordSequence resetNollDefaultValues];
    [myPreferences takePreferencesFrom:myChordSequence];
    return self;
}


/* manage, read & write Rubettes weights */
- (void)readWeightParameters;
{
    [super readWeightParameters];
    [myPreferences readWeightParametersFrom:[self weight]];
}

- (void)writeWeightParameters;
{
    [super writeWeightParameters];
    if ([myPreferences includeChordSequence])
	[[self weight] setParameterObject:myChordSequence requiredBundles:[NSBundle bundleForClass:[self class]]];
    else
	[[self weight] setParameterObject:nil requiredBundles:nil];
    [myPreferences writeWeightParametersTo:[self weight]];
}


- (void)newWeight;
{
    [super newWeight];
    [self makeChordWeight];
}

- loadWeight:sender;
{
    if ([super loadWeight:sender]) {
	[self updateFieldsWithBrowser:nil];
	[myChordSequence release];
	myChordSequence = nil;
	if ([[[self weight] parameterObject] isKindOfClass:[ChordSequence class]])
	    myChordSequence = [[[self weight] parameterObject]retain]; // jg 6.7.2002 retain was ref
	if (!myChordSequence)
	    myChordSequence = [[[ChordSequence alloc]init]retain]; // jg 6.7.2002 retain was ref
	
	[self makeChordWeight];
	[[myBrowser matrixInColumn:0] selectCellAtRow:-1 column:-1];
	[myBrowser loadColumnZero];
	[myBrowser validateVisibleColumns];
	browserValid = YES;
	[self showWeight:self];
	[self showWeightText];
	[self showRiemannGraph];
	[self update];
	return self;
    } 
    return nil;
}



/* methods to be overridden by subclasses */
- insertCustomMenuCells;
{
[[myMenu addItemWithTitle:@"General Preferences" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myGeneralPrefsPanel];
    [[myMenu addItemWithTitle:@"Riemann Preferences" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myRiemannPrefsPanel];
    [[myMenu addItemWithTitle:@"Tonality Preferences" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myTonalityPrefsPanel];
    [[myMenu addItemWithTitle:@"Noll Preferences" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myNollPrefsPanel];
    [[myMenu addItemWithTitle:@"Riemann Graph" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myRiemannGraphPanel];
    [[myMenu addItemWithTitle:@"Viterbi Settings" action:@selector(showWindow:) keyEquivalent:@""] setTarget:chordProbabilityController];
    
    [[myMenu addItemWithTitle:@"Weight Function" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myWeightFunctionPanel];
    [[myMenu addItemWithTitle:@"Weight View" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myWeightViewPanel];
    [[myMenu addItemWithTitle:@"Load Weight" action:@selector(loadWeight:) keyEquivalent:@""] setTarget:self];
    [[myMenu addItemWithTitle:@"Save Weight As" action:@selector(saveWeightAs:) keyEquivalent:@""] setTarget:self];
    [[myMenu addItemWithTitle:@"Graphic Preferences" action:@selector(orderFront:) keyEquivalent:@""] setTarget:myGraphicPrefsPanel];
    
    return self;
}


+ (NSString *)nibFileName;
{
    return @"HarmoRubette.nib";
}

+ (const char *)rubetteName;
{
    return "Harmo";
}

+ (const char *)rubetteVersion;
{
    return "1.0";
}

+ (spaceIndex)rubetteSpace;
{
    return (spaceIndex)3;
}

@end

@implementation HarmoRubetteDriver(BrowserDelegate)
/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    int retVal;
    switch(column) {
	case 0:
	    retVal = [myChordSequence count];
	    break;
	case 1:
	{
		retVal = 2;
	    break;
	}
	default:
	    retVal = 0;
	    break;
    }
    return retVal;
}

//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    switch(column) {
	case 0: 
	{
	    if (row<=[myChordSequence count]) {
		[myConverter setStringValue:@"Chord ("];
                [myConverter concatInt:row+1];
                [myConverter concat:")"];
		[cell setLoaded:YES];
		[cell setStringValue:[myConverter stringValue]];
		[cell setLeaf:NO];
	    }
	    break;
	}
	case 1:
	{
	    switch(row) {
		case 0:
		{
		    [myConverter setStringValue:@"E:"];
                    [myConverter
			concatDouble:[[myChordSequence chordAt:[[sender matrixInColumn:0]selectedRow]]onset]];
		    break;
		}
		case 1:
		{
		    [myConverter setStringValue:@"Size:"];
		    [myConverter 
			concatInt:[[myChordSequence chordAt:[[sender matrixInColumn:0]selectedRow]]pitchCount]];
		    break;
		}
	    }
	    [cell setLoaded:YES];
	    [cell setStringValue:[myConverter stringValue]];
	    [cell setLeaf:YES];
	    break;
	}
    }
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
{
    BOOL retVal;
//#error ViewConversion: '-focusView' in NSApplication has been replaced by '+focusView' in NSView
    retVal = ([NSView focusView] == [sender matrixInColumn:column]) ? YES : browserValid;
    return retVal;
}

@end

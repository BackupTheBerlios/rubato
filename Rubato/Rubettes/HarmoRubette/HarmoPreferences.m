/* HarmoPreferences.m */


#import "HarmoPreferences.h"
#import "HarmoRubetteDriver.h"
#import <RubatoAnalysis/ChordSequence.h>
#import <AppKit/NSPopUpButton.h>
#import <RubatoDeprecatedCommonKit/JGNXCompatibleUnarchiver.h>
#import <Rubato/JGTitledScrollView.h>

#import <FScript/FScript.h>

@implementation HarmoPreferences

- init;
{
    [super init];
    myFiletype = HARMO_PREFS_FILE_TYPE;
    return self;
}

- (void)dealloc;
{
    [super dealloc];
}


- (void)awakeFromNib;
{
    [super awakeFromNib];
    if (!useFile)
	[self takePreferencesFrom:[myOwner chordSequence]];
    
}


- takePreferencesFrom:sender;
{
    if ([sender isKindOfClass:[ChordSequence class]]) {
	int r,c;
      int pcCount=[sender pcCount];
      int tonalityCount=[sender tonalityCount];
      int functionCount=[sender functionCount];
      int modeCount=[sender modeCount];
      int modelessFunctionCount=[sender modelessFunctionCount];
      int locusCount=tonalityCount*functionCount;

      // jg? NEWHARMO resize Matrices 
	/* set general tonality values */
	for (r=0; r<modeCount; r++)
	    for (c=0; c<modeCount; c++)
		[[myModeDistanceMatrix cellAtRow:r column:c] setDoubleValue:[sender modeDistanceFrom:r to:c]];
	for (r=0; r<2; r++)
	    for (c=0; c<7; c++)
		[[myTonalityDistanceMatrix cellAtRow:r column:c] setDoubleValue:[sender tonalityDistanceAt:r:c]];
	
	/* set the RiemannMatrix specific values */
	[myPitchReferenceField setDoubleValue:[sender pitchReference]];
	[mySemitoneUnitField setDoubleValue:[sender semitoneUnit]];
	[myLocalLevelField setDoubleValue:[sender localLevel]];
	[myGlobalLevelField setDoubleValue:[sender globalLevel]];
	[self setMethod:[sender method]];
	for (r=0; r<functionCount; r++)
	    for (c=0; c<pcCount; c++)
		[[myFunctionScaleMatrix cellAtRow:r column:c] setDoubleValue:[sender scaleValueAt:r:c]];
	for (r=0; r<modelessFunctionCount; r++)
	    for (c=0; c<modelessFunctionCount; c++) {
		[[myModelessFunctionDistanceMatrix cellAtRow:r column:c] setDoubleValue:[sender functionDistanceFrom:r to:c]];
	    }
	for (c=0; c<locusCount; c++)
          [[myFunctionSwitchMatrix cellAtRow:FUNCTION_OF(c) column:TONALITY_OF(c)] setIntValue:[sender useFunctionAtLocus:c]];
	
	/* set weight specific values */
	[myWeightProfileField setDoubleValue:[sender weightProfile]];
	[myGlobalSlopeField setDoubleValue:[sender globalSlope]];
	[myIntraProfileField setDoubleValue:[sender intraProfile]];
	
	/* set path calc specific values */
	[myTransitionProfileField setDoubleValue:[sender transitionProfile]];
	[myCausalCardField setIntValue:[sender causalDepth]];
	[myFinalCardField setIntValue:[sender finalDepth]];
	
	/* set the Noll calculation specific values */
	for (r=0; r<8; r++)
	    for (c=0; c<7; c++) {
		[[myNollProfileMatrix cellAtRow:r column:c] setDoubleValue:[sender nollProfileAt:r:c]];
	    }
    
//#warning ViewConversion:  The View 'update' method is obsolete; if the receiver of this method is an NSView convert to [<theView> setNeedsDisplay:YES]
	[myOwner update];
	
	[self collectPrefs];
    }
    return self;
}

- (IBAction)loadNewSpace:(id)sender;
{
  static NSString *fileName=nil;
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
  NSString *key=@"HarmoRubetteSpaceStandardDirectory";
  BOOL found;
  int result;
  if (!fileName) {
    fileName=[[standardUserDefaults objectForKey:key] retain];
    if (!fileName)
      fileName=[@"~/Library/Application Support/Rubato/HarmoRubette/HarmoSpaces" retain];
  }
  result=[openPanel runModalForDirectory:fileName file:nil types:[NSArray arrayWithObjects:@"harmoSpace",@"fscript",nil]];
  [fileName release];
  fileName=[[openPanel filename] copy];
  [standardUserDefaults setObject:fileName forKey:key];
  if(result == NSOKButton) {
    FSInterpreter *interpreter=[myOwner fsInterpreterCreateIfNecessary:YES];
    System *s=[interpreter objectForIdentifier:@"sys" found:&found];
    if ([s isKindOfClass:NSClassFromString(@"System")]) {
      [harmoFileNameTextField setStringValue:[fileName lastPathComponent]];
      [s load:fileName];
    } else {
      NSBeep();
      NSLog(@"No valid System instance 'sys' in current FScript-Interpreter");
    }
  }
}

- (IBAction)resetRiemannLogic:(id)sender;
{

  ChordSequence *aChordSequence = [myOwner chordSequence];
  int newTag;

  newTag=[[summationFormulaNumberPopUpButton selectedItem] tag];
  if (newTag==3) {
    // command is evaluated each time something changes! Is this desired?
    NSString *command=[summationFormulaNumberTextField stringValue];
    NSString *key=@"ChordSummationFormulaBlock:";
    Block *block=nil;
    NSMutableDictionary *fsBlocks=[aChordSequence fsBlocks];
    if (![command length]) {
      [fsBlocks removeObjectForKey:key];
    } else {
      NSString *errMsg=nil;
      FSInterpreter *interpreter=[myOwner fsInterpreterCreateIfNecessary:YES];
      FSInterpreterResult *result=[interpreter execute:command]; // better: (command asBlock), but needs to wrap command within '' which can lead to problems.
      if ([result isOk]) {
        block=[result result];
        if ([block isKindOfClass:NSClassFromString(@"Block")]) {
          if ([block argumentCount]!=1) {
            errMsg=@"Block does not have exactly one argument";
          }
        } else {
          errMsg=@"Return value is not a F-Script Block";
        }
      } else {
        errMsg=[result errorMessage];
        [result inspectBlocksInCallStack];
      }
      if (errMsg) {
        newTag=aChordSequence->summationFormulaNumber; // oldTag
        [summationFormulaNumberPopUpButton selectItemAtIndex:[summationFormulaNumberPopUpButton indexOfItemWithTag:newTag]];
        errMsg=[@"Change Block text and reselect 'F-Script Block' in PopUpButton. Error description: " stringByAppendingString:errMsg];
        NSRunAlertPanel(@"HarmoRubette Theory Settings Error", errMsg, @"OK",nil, nil);
      } else {
        [fsBlocks setObject:block forKey:key];
      }
    }
  }
  aChordSequence->summationFormulaNumber=newTag;
//  aChordSequence->useThirdChainFlag=[[myMethodMatrix selectedCell] tag]; // setMethod
  //      aChordSequence->useMorphology;
  [self resetChordSequence:nil]; // should be replaced later, if riemann logic and riemann tensor influencing parts are splitted.
}

// jg: this method should be split into resetRiemannLogic and resetRiemannTensor.
- (IBAction)resetChordSequence:(id)sender;
{
    int r, c;
    ChordSequence *aChordSequence = [myOwner chordSequence]; // jg is here also possible sender instead of myOwner? 
// called by HarmoRubetteDriver:doCalculateRiemanLogic. myOwner is also probably
// this HarmoRubetteDriver, because the Method is not defined anywhere else. 

    int pcCount=[aChordSequence pcCount];
    int tonalityCount=[aChordSequence tonalityCount];
    int functionCount=[aChordSequence functionCount];
    int modeCount=[aChordSequence modeCount];
    int modelessFunctionCount=[aChordSequence modelessFunctionCount];
    int locusCount=tonalityCount*functionCount;


    
    /* set general tonality values */
    for (r=0; r<modeCount; r++)
	for (c=0; c<modeCount; c++)
	    [aChordSequence setModeDistance:
		[[myModeDistanceMatrix cellAtRow:r column:c]doubleValue] from:r to:c];
    for (r=0; r<2; r++)
	for (c=0; c<7; c++)
	    [aChordSequence setTonalityDistance:
		[[myTonalityDistanceMatrix cellAtRow:r column:c]doubleValue] at:r:c];
    
    /* set the RiemannMatrix specific values */
    [aChordSequence setPitchReference:[myPitchReferenceField doubleValue]];
    [aChordSequence setSemitoneUnit:[mySemitoneUnitField doubleValue]];
    [aChordSequence setLocalLevel:[myLocalLevelField doubleValue]];
    [aChordSequence setGlobalLevel:[myGlobalLevelField doubleValue]];

     
    for (r=0; r<functionCount; r++)
	for (c=0; c<pcCount; c++) 
	    [aChordSequence setScaleValue:
		[[myFunctionScaleMatrix cellAtRow:r column:c]doubleValue] at:r:c];
    for (r=0; r<modelessFunctionCount; r++)
	for (c=0; c<modelessFunctionCount; c++)
	    [aChordSequence setFunctionDistance:
		[[myModelessFunctionDistanceMatrix cellAtRow:r column:c]doubleValue] from:r to:c];
    for (c=0; c<locusCount; c++)
	[aChordSequence setUseFunction:
	    [[myFunctionSwitchMatrix cellAtRow:FUNCTION_OF(c) column:TONALITY_OF(c)] intValue] atLocus:c];

    [aChordSequence setMethod:[self method]];
    
    [self setWeightPrefs:self];
    
    /* set path calc specific values */
    [aChordSequence setCausalDepth:[myCausalCardField intValue]];
    [aChordSequence setFinalDepth:[myFinalCardField intValue]];
    
    /* set the Noll calculation specific values */
    for (r=0; r<8; r++)
	for (c=0; c<7; c++) {
	    [aChordSequence setNollProfile:
		[[myNollProfileMatrix cellAtRow:r column:c]doubleValue] at:r:c];
	}
    
//#warning ViewConversion:  The View 'update' method is obsolete; if the receiver of this method is an NSView convert to [<theView> setNeedsDisplay:YES]
    [myOwner update];
}

- setWeightPrefs:sender;
{
    /* set weight specific values */
    [[myOwner chordSequence] setWeightProfile:[myWeightProfileField doubleValue]];
    [[myOwner chordSequence] setGlobalSlope:[myGlobalSlopeField doubleValue]];
    [[myOwner chordSequence] setIntraProfile:[myIntraProfileField doubleValue]];
    [[myOwner chordSequence] setTransitionProfile:[myTransitionProfileField doubleValue]];
    
//#warning ViewConversion:  The View 'update' method is obsolete; if the receiver of this method is an NSView convert to [<theView> setNeedsDisplay:YES]
    [myOwner update];
    return self;
}

// jg added
- (void)takeCalcBestPathMethodFrom:(id)sender;
{
  SEL sel=NULL;
  if ([sender tag]==2) {// Viterbi
     sel=@selector(viterbiCalcBestPathUseLevelMatrix);
    [myCausalCardField setEnabled:NO];
    [myFinalCardField  setEnabled:NO];
  } else {
    [myCausalCardField setEnabled:YES];
    [myFinalCardField  setEnabled:YES];    
  }
    
  [[myOwner chordSequence] setCalcBestPathSelector:sel];
}

- takeMethodFrom:sender;
{
//    [[myOwner chordSequence] setMethod:[[sender selectedCell]tag]];
  [[myOwner chordSequence] setMethod:[sender tag]];
//#warning ViewConversion:  The View 'update' method is obsolete; if the receiver of this method is an NSView convert to [<theView> setNeedsDisplay:YES]
    [myOwner update];
    return self;
}

- setMethod:(int)aMethod;
{
  if (myMethodPopUpBtn) { // old interface
    //#warning PopUpConversion: Consider NSPopUpButton methods instead of using itemMatrix to access items in a pop-up list.
    //    id popUpMatrix = [myMethodPopUpBtn itemMatrix];
    //    [popUpMatrix selectCellWithTag:aMethod];
    [myMethodPopUpBtn selectItemAtIndex:[myMethodPopUpBtn indexOfItemWithTag:aMethod]];
    [myMethodPopUpBtn setTitle:[myMethodPopUpBtn titleOfSelectedItem]];
  } else if (myMethodMatrix) { // new interface 
    [myMethodMatrix selectCellWithTag:aMethod];    
  }
  return self;
}

- (int) method;
{
  if (myMethodPopUpBtn) { // old interface
    return [[myMethodPopUpBtn selectedItem]tag];
  } else if (myMethodMatrix) { // new interface
    return [[myMethodMatrix selectedCell] tag];
  } else {
    NSParameterAssert(myMethodPopUpBtn||myMethodMatrix);
    return 0;
  }
}

- (BOOL)useDuration;
{
    return [myDurationSwitch state];
}

- (BOOL)includeChordSequence;
{
    return [mySaveChordSeqSwitch state];
}



- loadRiemannSet:sender;
{
    return [self loadSetType:RIEMANN_PREFS_FILE_TYPE];
}

- saveRiemannSet:sender;
{
    return [self saveSetType:RIEMANN_PREFS_FILE_TYPE];
}

- loadTonalitySet:sender;
{
    return [self loadSetType:TONALITY_PREFS_FILE_TYPE];
}

- saveTonalitySet:sender;
{
    return [self saveSetType:TONALITY_PREFS_FILE_TYPE];
}

- loadNollSet:sender;
{
    return [self loadSetType:NOLL_PREFS_FILE_TYPE];
}

- saveNollSet:sender;
{
    return [self saveSetType:NOLL_PREFS_FILE_TYPE];
}


- loadSetType:(const char*)filetype;
{
    char cpath[MAXPATHLEN+1];
    NSString *path;
    NSArray *types = [NSArray arrayWithObject:[NSString jgStringWithCString:filetype]];
    id openPanel;

    if (myFilename) {
	if (rindex(myFilename, '/')) 
	    strncpy(cpath, myFilename, rindex(myFilename, '/')-myFilename+1);
	else
	    strcpy(cpath, myFilename);
	path=[NSString jgStringWithCString:cpath];
    }
    else {
	path = [[NSBundle bundleForClass:[self class]] pathForResource:@"" ofType:[NSString jgStringWithCString:filetype]];
    }

    openPanel = [NSOpenPanel openPanel];
    [openPanel setTreatsFilePackagesAsDirectories:YES];
    if([openPanel runModalForDirectory:path file:@"" types:types]) {
	NSUnarchiver *stream;
	stream = [[JGNXCompatibleUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:[openPanel filename]]];
	if (stream) {
	    if (!strcmp(filetype, RIEMANN_PREFS_FILE_TYPE))
		[self readRiemannPrefsFromStream:stream];
	    if (!strcmp(filetype, TONALITY_PREFS_FILE_TYPE))
		[self readTonalityPrefsFromStream:stream];
	    if (!strcmp(filetype, NOLL_PREFS_FILE_TYPE))
		[self readNollPrefsFromStream:stream];
	    [stream release];
	    return self;
	}
    }
    return nil;

}

- saveSetType:(const char*)filetype;
{
    id	panel;
    char cpath[MAXPATHLEN+1];
    NSString *path;
    /* prompt user for filename and save to that file */
    if (myFilename) {
 	if (rindex(myFilename, '/')) 
	    strncpy(cpath, myFilename, rindex(myFilename, '/')-myFilename+1);
	else
	    strcpy(cpath, myFilename);
        path=[NSString jgStringWithCString:cpath];

    }
    else {
	path = [[NSBundle bundleForClass:[self class]] pathForResource:@"" ofType:[NSString jgStringWithCString:filetype]];
    }

    panel = [NSSavePanel savePanel];
    [panel setRequiredFileType:[NSString jgStringWithCString:filetype]];
    [panel setTreatsFilePackagesAsDirectories:YES];
    if ([panel runModalForDirectory:@"" file:@""]) {
	NSArchiver *stream; // jg: better rewrite this archiving as to write to plist format.
	stream = [[NSArchiver alloc] initForWritingWithMutableData:[NSMutableData data]];
	if (stream) {
	    if (!strcmp(filetype, RIEMANN_PREFS_FILE_TYPE))
		[self writeRiemannPrefsToStream:stream];
	    if (!strcmp(filetype, TONALITY_PREFS_FILE_TYPE))
		[self writeTonalityPrefsToStream:stream];
	    if (!strcmp(filetype, NOLL_PREFS_FILE_TYPE))
		[self writeNollPrefsToStream:stream];
	    [[stream archiverData] writeToFile:[panel filename] atomically:YES];
	    [stream release];
	    return self;
	}
    }
    return nil; /*didn't save */
}


- collectPrefs;
{
    [self collectGeneralPrefs];
    [self collectTonalityPrefs];
    [self collectRiemannPrefs];
    [self collectWeightPrefs];
    [self collectPathPrefs];
    [self collectNollPrefs];
    return self;
}

- displayPrefs;
{
    [self displayGeneralPrefs];
    [self displayTonalityPrefs];
    [self displayRiemannPrefs];
    [self displayWeightPrefs];
    [self displayPathPrefs];
    [self displayNollPrefs];
    return self;
}

- collectGeneralPrefs;
{
    /* get the general values */
    [self setParameter:USE_DURATION toBoolValue:[myDurationSwitch intValue]];
    
    return self;
}

- collectRiemannPrefs;
{
    /* get the RiemannMatrix specific values */
    [self setParameter:PITCH_REF toDoubleValue:[myPitchReferenceField doubleValue]];
    [self setParameter:SEMITONE_UNIT toDoubleValue:[mySemitoneUnitField doubleValue]];
    [self setParameter:LOCAL_LEVEL toDoubleValue:[myLocalLevelField doubleValue]];
    [self setParameter:GLOBAL_LEVEL toDoubleValue:[myGlobalLevelField doubleValue]];

    [self setParameter:FUNC_SCALE_MATRIX toMatrix:myFunctionScaleMatrix];
    [self setParameter:FUNC_DIST_MATRIX toMatrix:myModelessFunctionDistanceMatrix];
    [self setParameter:FUNC_SWITCH_MATRIX toMatrix:myFunctionSwitchMatrix];
    
    [self setParameter:HARMO_CALC_METHOD toIntValue:[self method]];
    return self;
}

- collectTonalityPrefs;
{
    [self setParameter:MODE_DIST_MATRIX toMatrix:myModeDistanceMatrix];
    [self setParameter:TON_DIST_MATRIX toMatrix:myTonalityDistanceMatrix];
    
    return self;
}

- collectWeightPrefs;
{
    /* get weight specific values */
    [self setParameter:WEIGHT_PROFILE toDoubleValue:[myWeightProfileField doubleValue]];
    [self setParameter:GLOBAL_SLOPE toDoubleValue:[myGlobalSlopeField doubleValue]];
    [self setParameter:INTRA_PROFILE toDoubleValue:[myIntraProfileField doubleValue]];

    return self;
}

- collectPathPrefs;
{
    /* get path calc specific values */
    [self setParameter:TRANS_PROFILE toDoubleValue:[myTransitionProfileField doubleValue]];
    [self setParameter:CAUSAL_CARD toIntValue:[myCausalCardField intValue]];
    [self setParameter:FINAL_CARD toIntValue:[myFinalCardField intValue]];

    return self;
}

- collectNollPrefs;
{
    /* get Noll's calculation specific values */
    [self setParameter:NOLL_PROFILE_MATRIX toMatrix:myNollProfileMatrix];
    
    return self;
}

- displayGeneralPrefs;
{
    /* get the RiemannMatrix specific values */
//  [myDurationSwitch setIntValue:[self intValueOfParameter:USE_DURATION]]; // jg 12.7.02 old
    [myDurationSwitch setState:[self boolValueOfParameter:USE_DURATION]]; // jg 12.7.02 new

    return self;
}

- displayRiemannPrefs;
{
    [myPitchReferenceField setDoubleValue:[self doubleValueOfParameter:PITCH_REF]];
    [mySemitoneUnitField setDoubleValue:[self doubleValueOfParameter:SEMITONE_UNIT]];
    [myLocalLevelField setDoubleValue:[self doubleValueOfParameter:LOCAL_LEVEL]];
    [myGlobalLevelField setDoubleValue:[self doubleValueOfParameter:GLOBAL_LEVEL]];

    [self getParameter:FUNC_SCALE_MATRIX forMatrix:myFunctionScaleMatrix];
    [self getParameter:FUNC_DIST_MATRIX forMatrix:myModelessFunctionDistanceMatrix];
    [self getParameter:FUNC_SWITCH_MATRIX forMatrix:myFunctionSwitchMatrix];
    
    [self setMethod:[self intValueOfParameter:HARMO_CALC_METHOD]];
    return self;
}

- displayTonalityPrefs;
{
    [self getParameter:MODE_DIST_MATRIX forMatrix:myModeDistanceMatrix];
    [self getParameter:TON_DIST_MATRIX forMatrix:myTonalityDistanceMatrix];
    
    return self;
}

- displayWeightPrefs;
{
    [myWeightProfileField setDoubleValue:[self doubleValueOfParameter:WEIGHT_PROFILE]];
    [myGlobalSlopeField setDoubleValue:[self doubleValueOfParameter:GLOBAL_SLOPE]];
    [myIntraProfileField setDoubleValue:[self doubleValueOfParameter:INTRA_PROFILE]];

    return self;
}

- displayPathPrefs;
{
    [myTransitionProfileField setDoubleValue:[self doubleValueOfParameter:TRANS_PROFILE]];
    [myCausalCardField setIntValue:[self intValueOfParameter:CAUSAL_CARD]];
    [myFinalCardField setIntValue:[self intValueOfParameter:FINAL_CARD]];

    return self;
}



- displayNollPrefs;
{
    [self getParameter:NOLL_PROFILE_MATRIX forMatrix:myNollProfileMatrix];
    
    return self;
}

- (void)readWeightParametersFrom:aWeight;
{
/* jg was:
    NXHashState aState;
    const void *aKey, *aVal;
    aState = [myParameterTable initState];
    while([myParameterTable nextState:&aState key:&aKey value:&aVal]) {
        [self setParameter:aKey toStringValue:[aWeight stringValueOfParameter:aKey]];
    }
*/
// jg added from here
    NSEnumerator *enumerator = [myParameterTable keyEnumerator];  // NSDictionary
    id key;
    while  ((key = [enumerator nextObject])) { //jg? is it correct, that only the keys are used?
	[self setParameter:[key cString] toStringValue:[aWeight stringValueOfParameter:[key cString]]];
   }
// jg added to here
   [self displayPrefs];
}

- (void)writeWeightParametersTo:aWeight;
{
/*jg old
    NXHashState aState;
    const void *aKey, *aVal;
    [self collectPrefs];    
    aState = [myParameterTable initState];
    while([myParameterTable nextState:&aState key:&aKey value:&aVal]) {
	[aWeight setParameter:aKey toStringValue:aVal];
    }
*/
// jg new
  NSEnumerator *enumerator;
  id key;
  [self collectPrefs];
  enumerator = [myParameterTable keyEnumerator];  // NSDictionary
  while  ((key = [enumerator nextObject])) { 
    [aWeight setParameter:[key cString] toStringValue:[[myParameterTable objectForKey:key] cString]];
  }
}

// jg? problematic in NEWHARMO ! (there is no top object in the archive, even no object!)
// better: allow copy paste of table data from text file.
// the matrices of the current interface must match the saved file.
- writeRiemannPrefsToStream:(NSArchiver *)stream;
{
    int r,c, iVal;
    double dVal;

    int functionCount1, functionCount2, pcCount, tonalityCount, modelessFunctionCount, locusCount;
    [myFunctionScaleMatrix getNumberOfRows:&functionCount1 columns:&pcCount];
    modelessFunctionCount=[myModelessFunctionDistanceMatrix numberOfRows];
    [myFunctionSwitchMatrix getNumberOfRows:&functionCount2 columns:&tonalityCount];
    locusCount=functionCount2*tonalityCount;

    /* get the RiemannMatrix specific values */
    dVal = [myPitchReferenceField doubleValue];
    [stream encodeValueOfObjCType:"d" at:&dVal];
    dVal = [mySemitoneUnitField doubleValue];
    [stream encodeValueOfObjCType:"d" at:&dVal];
    dVal = [myLocalLevelField doubleValue];
    [stream encodeValueOfObjCType:"d" at:&dVal];
    dVal = [myGlobalLevelField doubleValue];
    [stream encodeValueOfObjCType:"d" at:&dVal];
    for (r=0; r<functionCount1; r++)
	for (c=0; c<pcCount; c++) {
	    dVal = [[myFunctionScaleMatrix cellAtRow:r column:c]doubleValue];
	    [stream encodeValueOfObjCType:"d" at:&dVal];
	}
    for (r=0; r<modelessFunctionCount; r++)
	for (c=0; c<modelessFunctionCount; c++) {
	    dVal = [[myModelessFunctionDistanceMatrix cellAtRow:r column:c]doubleValue];
	    [stream encodeValueOfObjCType:"d" at:&dVal];
	}
    for (c=0; c<functionCount2*tonalityCount; c++) {
	iVal = [[myFunctionSwitchMatrix cellAtRow:FUNCTION_OF(c) column:TONALITY_OF(c)] intValue];
	[stream encodeValueOfObjCType:"i" at:&iVal];
    }
    
    iVal = [self method];
    [stream encodeValueOfObjCType:"i" at:&iVal];
    return self;
}

// jg? problematic in NEWHARMO !
- writeTonalityPrefsToStream:(NSArchiver *)stream;
{
    int r,c;
    double dVal;
    int modeCount=[myModeDistanceMatrix numberOfRows];
    
    /* get general tonality values */
    for (r=0; r<modeCount; r++)
	for (c=0; c<modeCount; c++) {
	    dVal = [[myModeDistanceMatrix cellAtRow:r column:c]doubleValue];
	    [stream encodeValueOfObjCType:"d" at:&dVal];
	}
    for (r=0; r<2; r++)
	for (c=0; c<7; c++) {
	    dVal = [[myTonalityDistanceMatrix cellAtRow:r column:c]doubleValue];
	    [stream encodeValueOfObjCType:"d" at:&dVal];
	}
    
    return self;
}

- (void)writeWeightPrefsToStream:(NSArchiver *)stream;
{
    double dVal;
    /* get weight specific values */
    dVal = [myWeightProfileField doubleValue];
    [stream encodeValueOfObjCType:"d" at:&dVal];
    dVal = [myGlobalSlopeField doubleValue];
    [stream encodeValueOfObjCType:"d" at:&dVal];
    dVal = [myIntraProfileField doubleValue];
    [stream encodeValueOfObjCType:"d" at:&dVal];
}

- writePathPrefsToStream:(NSArchiver *)stream;
{
    int iVal;
    double dVal;
    /* get path calc specific values */
    dVal = [myTransitionProfileField doubleValue];
    [stream encodeValueOfObjCType:"d" at:&dVal];
    iVal = [myCausalCardField intValue];
    [stream encodeValueOfObjCType:"i" at:&iVal];
    iVal = [myFinalCardField intValue];
    [stream encodeValueOfObjCType:"i" at:&iVal];
    
    return self;
}

- writeNollPrefsToStream:(NSArchiver *)stream;
{
    int r,c;
    double dVal;
    /* get the Noll calculation specific values */
    for (r=0; r<8; r++)
	for (c=0; c<7; c++) {
	    dVal = [[myNollProfileMatrix cellAtRow:r column:c]doubleValue];
	    [stream encodeValueOfObjCType:"d" at:&dVal];
	}
    
    return self;
}


- readRiemannPrefsFromStream:(NSUnarchiver *)stream;
{
    int r,c, iVal;
    double dVal;

    int functionCount1, functionCount2, pcCount, tonalityCount, modelessFunctionCount, locusCount;
    [myFunctionScaleMatrix getNumberOfRows:&functionCount1 columns:&pcCount];
    modelessFunctionCount=[myModelessFunctionDistanceMatrix numberOfRows];
    [myFunctionSwitchMatrix getNumberOfRows:&functionCount2 columns:&tonalityCount];
    locusCount=functionCount2*tonalityCount;

    /* set the RiemannMatrix specific values */
    [stream decodeValueOfObjCType:"d" at:&dVal];
    [myPitchReferenceField setDoubleValue:dVal];
    [stream decodeValueOfObjCType:"d" at:&dVal];
    [mySemitoneUnitField setDoubleValue:dVal];
    [stream decodeValueOfObjCType:"d" at:&dVal];
    [myLocalLevelField setDoubleValue:dVal];
    [stream decodeValueOfObjCType:"d" at:&dVal];
    [myGlobalLevelField setDoubleValue:dVal];
    for (r=0; r<functionCount1; r++)
	for (c=0; c<pcCount; c++) {
	    [stream decodeValueOfObjCType:"d" at:&dVal];
	    [[myFunctionScaleMatrix cellAtRow:r column:c] setDoubleValue:dVal];
	}
    for (r=0; r<modelessFunctionCount; r++)
	for (c=0; c<modelessFunctionCount; c++) {
	    [stream decodeValueOfObjCType:"d" at:&dVal];
	    [[myModelessFunctionDistanceMatrix cellAtRow:r column:c] setDoubleValue:dVal];
	}
    for (c=0; c<locusCount; c++) {
	[stream decodeValueOfObjCType:"i" at:&iVal];
	[[myFunctionSwitchMatrix cellAtRow:FUNCTION_OF(c) column:TONALITY_OF(c)] setIntValue:iVal];
    }
        
    [stream decodeValueOfObjCType:"i" at:&iVal];
    [self setMethod:iVal];
    return self;
}

- readTonalityPrefsFromStream:(NSUnarchiver *)stream;
{
    int r,c;
    double dVal;
    int modeCount=[myModeDistanceMatrix numberOfRows];

    /* set general tonality values */
    for (r=0; r<modeCount; r++)
	for (c=0; c<modeCount; c++) {
	    [stream decodeValueOfObjCType:"d" at:&dVal];
	    [[myModeDistanceMatrix cellAtRow:r column:c] setDoubleValue:dVal];
	}
    for (r=0; r<2; r++)
	for (c=0; c<7; c++) {
	    [stream decodeValueOfObjCType:"d" at:&dVal];
	    [[myTonalityDistanceMatrix cellAtRow:r column:c] setDoubleValue:dVal];
	}
    
    return self;
}

- (void)readWeightPrefsFromStream:(NSUnarchiver *)stream;
{
    double dVal;
    /* set weight specific values */
    [stream decodeValueOfObjCType:"d" at:&dVal];
    [myWeightProfileField setDoubleValue:dVal];
    [stream decodeValueOfObjCType:"d" at:&dVal];
    [myGlobalSlopeField setDoubleValue:dVal];
    [stream decodeValueOfObjCType:"d" at:&dVal];
    [myIntraProfileField setDoubleValue:dVal];
}

- readPathPrefsFromStream:(NSUnarchiver *)stream;
{
    int iVal;
    double dVal;
    /* set path calc specific values */
    [stream decodeValueOfObjCType:"d" at:&dVal];
    [myTransitionProfileField setDoubleValue:dVal];
    [stream decodeValueOfObjCType:"i" at:&iVal];
    [myCausalCardField setIntValue:iVal];
    [stream decodeValueOfObjCType:"i" at:&iVal];
    [myFinalCardField setIntValue:iVal];
    
    return self;
}


- readNollPrefsFromStream:(NSUnarchiver *)stream;
{
    int r,c;
    double dVal;
    
    /* set the Noll calculation specific values */
    for (r=0; r<8; r++)
	for (c=0; c<7; c++) {
	    [stream decodeValueOfObjCType:"d" at:&dVal];
	    [[myNollProfileMatrix cellAtRow:r column:c] setDoubleValue:dVal];
	}
        
    return self;
}

- (void)setHarmoSpace:(NSDictionary *)dict;
{
  //  int newFunctionCount=functionCount;
  //  int newTonalityCount=tonalityCount;
  id entry;
  entry=[dict objectForKey:@"PitchClasses"];
  if (entry) {
    [[myFunctionScaleMatrix jgTitledScrollView] setHorizontalTitles:entry];
  }
  entry=[dict objectForKey:@"Functions"];
  if (entry) {
    [[myFunctionScaleMatrix jgTitledScrollView] setVerticalTitles:entry];
    [[myFunctionSwitchMatrix jgTitledScrollView] setVerticalTitles:entry];
  }
  entry=[dict objectForKey:@"Tonalities"];
  if (entry) {
    [[myFunctionSwitchMatrix jgTitledScrollView] setHorizontalTitles:entry];
  }
  entry=[dict objectForKey:@"Modes"];
  if (entry) {
    [[myModeDistanceMatrix jgTitledScrollView] setHorizontalTitles:entry verticalTitles:entry];
  }
  entry=[dict objectForKey:@"ModelessFunctions"];
  if (entry) {
    [[myModelessFunctionDistanceMatrix jgTitledScrollView] setHorizontalTitles:entry verticalTitles:entry];
  }
  
  entry=[dict objectForKey:@"Loci"];
  if (entry) {
    id chordSeq=[myOwner chordSequence];
    NSAssert([entry count]==[chordSeq tonalityCount]*[chordSeq functionCount],@"ChordSequence -setHarmoSpace: number of Loci entries does not reflect tonalityCount*functionCount");
  }
}  
@end
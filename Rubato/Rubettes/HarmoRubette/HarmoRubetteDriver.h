
#import <AppKit/AppKit.h>

#import <Rubette/RubetteDriver.h>

@interface HarmoRubetteDriver:RubetteDriver
{
    id	myWeightFunctionPanel;
    id	myWeightViewPanel;
    id	myWeightView;
    id	myWeightText;
    id	myGraphicPrefsPanel;
    id	myRiemannPrefsPanel;
    id	myTonalityPrefsPanel;
    id	myGeneralPrefsPanel;
    id	myNollPrefsPanel;
    id	myRiemannGraphPanel;
    id	myRiemannGraphMatrix; //NSMatrix (IB-Element)
    
    id	myCalcAmountField;
    
    id	myChordSequenceButton;
    id	myRiemannLogicButton;
    id	myCalcBestPathButton;
    id	myChordWeightSwitch;

    id	myPreferences;
    
    id	myEventList;
    id	myChordSequence;
    id	myChordWeight;
    
    id	myBrowser;
    int	selRowIndex;
    BOOL browserValid;

    id chordProbabilityController;
}

- init;
- (void)dealloc;
- (void)closeRubetteWindows;

- chordSequence;

- (void)doSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
- makeEventList;
- doMakeChordSequence:sender;
- doCalculateRiemannLogic:sender;
- doCalculatePath:sender;
- doCalculateWeight:sender;
- doCalculate:sender;
- (void)update;
- showWeightText;
- showRiemannGraph;
- (void)updateFieldsWithBrowser:(id)aBrowser;

- showWeight:sender;
- (void)setSelectedCell:sender;
- resetRiemannDefaultValues:sender;
- resetTonalityDefaultValues:sender;
- resetNollDefaultValues:sender;

/* manage, read & write Rubettes weights */
- (void)readWeightParameters;
- (void)writeWeightParameters;
- (void)newWeight;
- loadWeight:sender;

/* methods to be overridden by subclasses */
- insertCustomMenuCells;
+ (NSString *)nibFileName;
+ (const char *)rubetteName;
+ (const char *)rubetteVersion;
+ (spaceIndex)rubetteSpace;

@end

@interface HarmoRubetteDriver(BrowserDelegate)
/* (BrowserDelegate) methods */

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;

@end
#import "JGChordProbabilityController.h"

#define SHOW_LEVELMATRIX_MODE 0
#define SHOW_RIEMANNMATRIX_MODE 1
#define SHOW_FACTORS_MODE 2
#define SHOW_RESULTS_MODE 3

@interface HarmoRubetteShort
- (ChordSequence *)chordSequence;
- (int)selectedChordIndex;
- (void)selectChordAtIndex:(int)idx;
@end

@implementation JGChordProbabilityController
+ (id)newInstanceWithDefaultNib;
{
  JGChordProbabilityController *result=[[self alloc] init];
  [NSBundle loadNibNamed:@"JGChordProbabilityController.nib" owner:result];
  return result;
}

- (id)init;
{
  [super init];
  harmoRubetteDriver=nil;
  probabilityValues=NULL;
  viterbi=nil;
  selectedT=-1;
  displayMode=SHOW_LEVELMATRIX_MODE;
  selectionChangedEntered=NO;
  updateInspector=NO; // done by harmoRubetteDriver
  return self;
}

- (void)dealloc;
{
  [viterbi release];
//  [harmoRubetteDriver release]; dont do this!
  [window release];
  [super dealloc];
}

- (NSMatrix *)probabilityMatrix;
{
  return probabilityMatrix;
}

- (void)setValuesForNewViterbi;
{
  if (viterbi) {
    if (viterbi->N>=0)
      selectedT=0;
    else
      selectedT=-1;    
  }
}

- (void)setViterbi:(JGViterbi *)newViterbi;
{
  [newViterbi retain];
  [viterbi release];
  viterbi=newViterbi;
}

- (void)showWindow:(id)sender;
{
  [window makeKeyAndOrderFront:nil];
}

- (id)comboBox:(NSComboBox *)comboBox objectValueForT:(int)t;
{
  if (comboBox==allOnsetsComboBox)
    return [NSString stringWithFormat:@"%d",t+1];
  else if (comboBox==restrictedOnsetsComboBox)
    return [NSString stringWithFormat:@"%d",t+1];
  // nicer:   return [NSString stringWithFormat:@"#%d (%.3fs)",t,[chord[t] onset]];
  NSParameterAssert((comboBox==allOnsetsComboBox) || (comboBox==restrictedOnsetsComboBox));
  return nil;
}

- (int)comboBox:(NSComboBox *)comboBox tValueForObjectValue:(id)objectValue;
{
  if (comboBox==allOnsetsComboBox)
    return [objectValue intValue]-1;
  else if (comboBox==restrictedOnsetsComboBox)
    return [objectValue intValue]-1;
  return -1;
}

- (int)tValueOfComboBox:(NSComboBox *)comboBox;
{
  NSString *str=[comboBox stringValue];
  int idx=[comboBox indexOfItemWithObjectValue:str];
  int t;
  t=[self comboBox:comboBox tValueForObjectValue:str];
  if (idx==NSNotFound) {
    int bestT=-1;
    int bestTIdx=-1;
    int i,c=[comboBox numberOfItems];
    for (i=0;i<c;i++) {
      int t1;
      str=[comboBox itemObjectValueAtIndex:i];
      t1=[self comboBox:comboBox tValueForObjectValue:str];
      if ((t1<t) && (t1>bestT)) {
        bestT=t1;
        bestTIdx=i;
      }
    }
    if (bestTIdx==-1) {
      [comboBox setStringValue:@"invalid"];
    } else {
      [comboBox selectItemAtIndex:bestTIdx];
    }
    t=bestT;
  }
  return t;
}

- (void)updateComboBox:(NSComboBox *)comboBox;
{
  int t;
  double **customFactors=viterbi->customFactors;
  [comboBox removeAllItems];
  if (customFactors) {
    for (t=0;t<viterbi->nextT;t++) {
      if ((displayMode!=SHOW_RESULTS_MODE) || [viterbi deltaAtT:t]) {
        if (comboBox==allOnsetsComboBox) {
          [comboBox addItemWithObjectValue:[self comboBox:comboBox objectValueForT:t]];
        } else if (comboBox==restrictedOnsetsComboBox) {
          if (customFactors[t])
            [comboBox addItemWithObjectValue:[self comboBox:comboBox objectValueForT:t]];
        }         
      }
    }
  }
}


- (void)updateSelectionOfComboBox:(NSComboBox *)comboBox;
{
  int idx;
  if (selectedT>0)
    idx=[comboBox indexOfItemWithObjectValue:[self comboBox:comboBox objectValueForT:selectedT]];
  else
    idx=NSNotFound;
  if (idx==NSNotFound) {
    idx=[comboBox indexOfSelectedItem];
    if (idx!=-1)
      [comboBox deselectItemAtIndex:idx];
  } else {
    [comboBox selectItemAtIndex:idx];    
  }
}

- (void)setInputEnabled:(BOOL)yn;
{
  [probabilityMatrix setEnabled:yn];
  [restrictOnsetButton setEnabled:yn];
  [setAllEntriesToDefaultButton setEnabled:yn];
  if (!yn)
    [restrictOnsetButton setEnabled:NO];
}

- (void)updateDataAndViews;
{
  if (displayMode==SHOW_RESULTS_MODE) {
    [self setInputEnabled:NO];
    
    if (selectedT>=0)
      probabilityValues=[viterbi deltaAtT:selectedT];
    else
      probabilityValues=NULL;
  } else if ((displayMode==SHOW_LEVELMATRIX_MODE) || (displayMode==SHOW_RIEMANNMATRIX_MODE)) {
    [self setInputEnabled:(displayMode==SHOW_LEVELMATRIX_MODE)]; // enable editing of level-Matrix
    probabilityValues=NULL;
    if (selectedT>=0) {
      Chord *chord=[[harmoRubetteDriver chordSequence] chordAt:selectedT];
      if (chord) {
        double **ppMatrix=((displayMode==SHOW_LEVELMATRIX_MODE) ? [chord levelMatrix] : [chord riemannMatrix]);
        if (ppMatrix) // should always be there in a chord
          probabilityValues=ppMatrix[0]; // all Matrix values start here and are arranged continuesly
      }
    }
  } else if (displayMode==SHOW_FACTORS_MODE) {
    double **customFactors=viterbi->customFactors;
    if (customFactors) {
      if (selectedT>=0) {
        probabilityValues=customFactors[selectedT];
        if (probabilityValues)
          [self setInputEnabled:YES];
        else 
          [self setInputEnabled:NO];
      } else {
        probabilityValues=NULL;
        [self setInputEnabled:NO];
      }
    } else {
      [probabilityMatrix setEnabled:NO];
      probabilityValues=NULL;
    }
  }
  [restrictOnsetButton setEnabled:((displayMode==SHOW_FACTORS_MODE) && (probabilityValues==NULL))];
  [self updateViewsWithData];
  if (updateInspector)
    [self updateInspector]; // is probably invoked allready in harmoRubetteDriver
}

- (void)updateAll;
{
  [self updateComboBox:allOnsetsComboBox];
  [self updateSelectionOfComboBox:allOnsetsComboBox];
  [self updateComboBox:restrictedOnsetsComboBox];
  [self updateSelectionOfComboBox:restrictedOnsetsComboBox];
  [self updateDataAndViews];
}

// IB Actions
- (IBAction)selectionChanged:(id)sender
{
  if (selectionChangedEntered)
    return;
  selectionChangedEntered=YES;
  if (sender==definitionsResultsRadioMatrix) {
    id selectedCell=[definitionsResultsRadioMatrix selectedCell];
    displayMode=[selectedCell tag];  
    [self updateAll];
  } else {
    // a combo box is sender (it might be the textfield that sends, so it is not correct, only to ask for the selection
//    int idx=[sender indexOfSelectedItem];
    if (sender==allOnsetsComboBox) {
      selectedT=[self tValueOfComboBox:allOnsetsComboBox];
      [self updateSelectionOfComboBox:restrictedOnsetsComboBox];
      [harmoRubetteDriver selectChordAtIndex:selectedT];
    } else if (sender==restrictedOnsetsComboBox) {
      selectedT=[self tValueOfComboBox:restrictedOnsetsComboBox];
      [self updateSelectionOfComboBox:allOnsetsComboBox];
      [harmoRubetteDriver selectChordAtIndex:selectedT];
    } else if (sender==harmoRubetteDriver) {
      selectedT=[harmoRubetteDriver selectedChordIndex];
      if (selectedT==NSNotFound)
        selectedT=-1;
      [self updateSelectionOfComboBox:restrictedOnsetsComboBox];
      [self updateSelectionOfComboBox:allOnsetsComboBox];      
    }
    [self updateDataAndViews];
  }
  selectionChangedEntered=NO;
}

- (IBAction)setAllEntriesToDefaultPressed:(id)sender
{
  int i,N;
  double value=[defaultValueTextField doubleValue];
  NSParameterAssert(probabilityValues!=NULL);
  N=viterbi->N;
  for (i=0;i<N;i++)
    probabilityValues[i]=value;
  [self updateViewsWithData];
}

- (IBAction)restrictOnsetPressed:(id)sender;
{
  NSParameterAssert(selectedT>=0);
  [viterbi viterbiAllocateCustomFactorsForT:selectedT];
  [self updateComboBox:restrictedOnsetsComboBox];
  [self updateSelectionOfComboBox:restrictedOnsetsComboBox];
  [self updateDataAndViews];
}
- (IBAction)unrestrictOnsetPressed:(id)sender;
{
  NSParameterAssert(selectedT>=0);
  [viterbi viterbiDeallocateCustomFactorsForT:selectedT];
  [self updateComboBox:restrictedOnsetsComboBox];
  [self updateSelectionOfComboBox:restrictedOnsetsComboBox];
  [self updateDataAndViews];  
}
@end

@interface HarmoRubetteDriver
- (ChordSequence *)chordSequence;
- (id)doCalculate:(id)sender;
- (id)distributor;
@end
@interface Distributor
- (id)globalInspector;
@end
//@interface Inspector
//- (void)setSelected:(id)selected;
//@end


@implementation JGChordProbabilityController (HarmoRubetteSpecific)
- (IBAction)recalculatePressed:(id)sender
{
  ChordSequence *cs=[harmoRubetteDriver chordSequence];
  cs->isBestPathCalculated=NO;
  [harmoRubetteDriver doCalculate:nil];
}
// User Interface actions
- (IBAction)probabilityMatrixChanged:(id)sender
{
  [self setValuesWithMatrix];
}

- (void)setValuesWithMatrix;
{
  int state=0;
  int r,c;
  int functionCount, tonalityCount;
  [probabilityMatrix getNumberOfRows:&functionCount columns:&tonalityCount];

  if (probabilityValues) {
    for (r=0; r<functionCount; r++) {
      for (c=0; c<tonalityCount; c++) {
        probabilityValues[state]=[[probabilityMatrix cellAtRow:r column:c] doubleValue];
        state++;
      }
    }
  }
}

- (void)updateViewsWithData;
{
  int state=0;
  int r,c;
  int functionCount, tonalityCount;
  [probabilityMatrix getNumberOfRows:&functionCount columns:&tonalityCount];
  for (r=0; r<functionCount; r++) {
    for (c=0; c<tonalityCount; c++) {
      id dest=[probabilityMatrix cellAtRow:r column:c];
      if (probabilityValues)
        [dest setDoubleValue:probabilityValues[state]];
      else
        [dest setStringValue:@"invalid"];
      state++;
    }
  }
}

- (void)updateInspector;
{
  id chordSequence=[harmoRubetteDriver chordSequence];
  id chord=nil;
  if ((selectedT>0) && (selectedT<[chordSequence count]))
    chord=[chordSequence chordAt:selectedT];
  [[[harmoRubetteDriver distributor] globalInspector] setSelected:chord];
}

- (void)closeWindow;
{
  [window close];
}

@end

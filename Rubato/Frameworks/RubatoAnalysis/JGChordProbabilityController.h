/* JGChordProbabilityController */

#import <Cocoa/Cocoa.h>

#import "JGViterbi.h"

@interface JGChordProbabilityController : NSObject
{
    IBOutlet NSWindow *window;

    IBOutlet NSMatrix *probabilityMatrix;
    IBOutlet NSComboBox *allOnsetsComboBox;

    IBOutlet NSComboBox *restrictedOnsetsComboBox;
    IBOutlet NSButton *restrictOnsetButton;
    IBOutlet NSButton *unrestrictOnsetButton;
    IBOutlet NSButton *recalculateButton;

    IBOutlet NSMatrix *definitionsResultsRadioMatrix;
    
    IBOutlet NSButton *setAllEntriesToDefaultButton;
    IBOutlet NSTextField *defaultValueTextField;

    double *probabilityValues;
    int selectedT; // index of chord resp. t index in viterbi
    BOOL displayMode;
    // int modelChangedFromT; // keep track of minimum t, for which viterbi must be recalculated
    BOOL selectionChangedEntered; // avoid update cylces
    BOOL updateInspector;

@public
    id harmoRubetteDriver;
    JGViterbi *viterbi;
}
+ (id)newInstanceWithDefaultNib;

- (NSMatrix *)probabilityMatrix;

- (void)setValuesForNewViterbi;
- (void)setViterbi:(JGViterbi *)newViterbi;
- (IBAction)showWindow:(id)sender;

- (IBAction)selectionChanged:(id)sender;
- (IBAction)setAllEntriesToDefaultPressed:(id)sender;
- (IBAction)restrictOnsetPressed:(id)sender;
- (IBAction)unrestrictOnsetPressed:(id)sender;

- (void)updateAll;

//@private
- (id)comboBox:(NSComboBox *)comboBox objectValueForT:(int)t;
- (void)updateComboBox:(NSComboBox *)comboBox;
- (void)updateSelectionOfComboBox:(NSComboBox *)comboBox;
- (void)setInputEnabled:(BOOL)yn;
- (void)updateDataAndViews;
@end

@interface JGChordProbabilityController (HarmoRubetteSpecific)
- (IBAction)recalculatePressed:(id)sender;
- (IBAction)probabilityMatrixChanged:(id)sender;
- (void)setValuesWithMatrix;
- (void)updateViewsWithData;
- (void)updateInspector;

- (void)closeWindow;
@end

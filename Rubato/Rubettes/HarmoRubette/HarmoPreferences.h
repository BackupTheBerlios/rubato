/* HarmoPreferences.h */

#import <AppKit/AppKit.h>
#import <Rubato/Preferences.h>

#define HARMO_PREFS_FILE_TYPE "HarmoPrefs"

#define FUNC_SCALE_MATRIX "Function Scale Matrix"
#define FUNC_DIST_MATRIX "Function Distance Matrix"
#define MODE_DIST_MATRIX "Mode Distance Matrix"
#define TON_DIST_MATRIX "Tonality Distance Matrix"
#define FUNC_SWITCH_MATRIX "Function Enable Matrix"
#define NOLL_PROFILE_MATRIX "Noll Profile Matrix"

#define PITCH_REF "Pitch Reference"
#define SEMITONE_UNIT "Semitone Unit"
#define LOCAL_LEVEL "Local Level"
#define GLOBAL_LEVEL "Global Level"
#define CAUSAL_CARD "Causal Cardinality"
#define FINAL_CARD "Final Cardinality"
#define CAUSAL_SPAN "Causal Span"
#define FINAL_SPAN "Final Span"
#define TRANS_PROFILE "Path Transition Profile"
#define WEIGHT_PROFILE "Interchord Weight Profile"
#define INTRA_PROFILE "Intrachord Weight Profile"
#define GLOBAL_SLOPE "Global Weight Slope"
#define USE_DURATION "Use Duration"

#define HARMO_CALC_METHOD "Method"

#define RIEMANN_PREFS_FILE_TYPE "RieSet"
#define TONALITY_PREFS_FILE_TYPE "TonSet"
#define WEIGHT_PREFS_FILE_TYPE "WgtSet"
#define NOLL_PREFS_FILE_TYPE "NollSet"


@interface HarmoPreferences:Preferences
{
// myOwner probably HarmoRubetteDriver?
    id	myFunctionScaleMatrix;
    id	myModelessFunctionDistanceMatrix;
    id	myModeDistanceMatrix;
    id	myTonalityDistanceMatrix;
    id	myFunctionSwitchMatrix;
    id	myNollProfileMatrix;
   
    id	myPitchReferenceField;
    id	mySemitoneUnitField;
    id	myLocalLevelField;
    id	myGlobalLevelField;
    
    id	myCausalCardField;
    id	myFinalCardField;
    id	myCausalSpanField;
    id	myFinalSpanField;
    id	myWeightProfileField;
    id	myTransitionProfileField;
    id	myGlobalSlopeField;
    id	myIntraProfileField;
    
    id	myDurationSwitch;
    id	mySaveChordSeqSwitch;
    id	myMethodPopUpBtn; // alternative: myMethodMatrix

    IBOutlet NSTextField *harmoFileNameTextField;
    IBOutlet NSMatrix *myMethodMatrix; // alternative: myMethodPopUpBtn
    IBOutlet NSPopUpButton *summationFormulaNumberPopUpButton;
    IBOutlet NSTextField *summationFormulaNumberTextField;
}

- init;
- (void)dealloc;
- (void)awakeFromNib;

- takePreferencesFrom:sender;
- (IBAction)resetRiemannLogic:(id)sender;
- (IBAction)resetChordSequence:(id)sender;
- setWeightPrefs:sender;

- (void)takeCalcBestPathMethodFrom:(id)sender; // jg added
- takeMethodFrom:sender;
- setMethod:(int)aMethod;
- (int) method;
- (BOOL)useDuration;
- (BOOL)includeChordSequence;

- loadRiemannSet:sender;
- saveRiemannSet:sender;
- loadTonalitySet:sender;
- saveTonalitySet:sender;
- loadNollSet:sender;
- saveNollSet:sender;

- loadSetType:(const char*)filetype;
- saveSetType:(const char*)filetype;

- collectPrefs;
- displayPrefs;

- collectGeneralPrefs;
- collectRiemannPrefs;
- collectTonalityPrefs;
- collectWeightPrefs;
- collectPathPrefs;
- collectNollPrefs;

- displayGeneralPrefs;
- displayRiemannPrefs;
- displayTonalityPrefs;
- displayWeightPrefs;
- displayPathPrefs;
- displayNollPrefs;

- (void)readWeightParametersFrom:aWeight;
- (void)writeWeightParametersTo:aWeight;

- writeRiemannPrefsToStream:(NSArchiver *)stream;
- writeTonalityPrefsToStream:(NSArchiver *)stream;
- (void)writeWeightPrefsToStream:(NSArchiver *)stream;
- writePathPrefsToStream:(NSArchiver *)stream;
- writeNollPrefsToStream:(NSArchiver *)stream;
- readRiemannPrefsFromStream:(NSUnarchiver *)stream;
- readTonalityPrefsFromStream:(NSUnarchiver *)stream;
- (void)readWeightPrefsFromStream:(NSUnarchiver *)stream;
- readPathPrefsFromStream:(NSUnarchiver *)stream;
- readNollPrefsFromStream:(NSUnarchiver *)stream;

- (void)setHarmoSpace:(NSDictionary *)dict;
- (IBAction)loadNewSpace:(id)sender;
@end

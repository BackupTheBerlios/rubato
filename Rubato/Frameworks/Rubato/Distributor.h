
#import <AppKit/AppKit.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import "AbstractDistributor.h"
//#import <JGAppKit/JGActivationSubDocument.h>

@interface Distributor : AbstractDistributor
{
  NSString *archiverClassName;
  NSString *unarchiverClassName;
  NSMutableDictionary *tools;
  
    id	alertPanel;
    id	infoPanel;
    id	preferences;
    id	editWindow;
    id	globalInspector;  // ObjectInspectorDriver
    id	predicateBrowser;
    id	prediBase;
    id	predicateFinder;
    id	makroPalette;
    id	globalFormManager;
    id	globalFormBrowser;

//    NSMutableArray *myRubetteList;
    id	activeRubette;

    id formatBox;
    id formatRadio;

    /* document Menu */
    id documentMenuCell;
    id saveMenuCell;
    id saveAsMenuCell;
    id revertToSavedMenuCell;

    /* Edit Menu */
    id	editMenuCell;
    id	undoMenuCell;  // undo and redo not implemented.
    id	redoMenuCell;  // Only used in applicationDidFinishLaunching, to show the Status of the Item.

    /* Rubettes Menu */
    id	rubettesMenuCell; // NSMenuItem

    id subDocumentController; // jg see JGActivationSubDocument.h
    
  // FScript
  IBOutlet NSWindow *interpreterWindow;
  IBOutlet id interpreterView;
}
- (void)awakeFromNib;
- (id)interpreterView;
- (id)interpreterWindow;

+ (void)menu:(NSMenu *)m insertItemsForPlugInsOfType:(NSString *)type action:(SEL)selector target:(id)target;
- (void)insertBuildInRubetteMenuItems;
- (IBAction)loadBuildInRubette:(id)buildInMenuItem;
- (void)loadAllBuildInRubettes:(id)sender;

- (NSString*) archiverClassName;
- (void) setArchiverClassName:(NSString*)newArchiverClassName;
- (NSString*) unarchiverClassName;
- (void) setUnarchiverClassName:(NSString*)newUnarchiverClassName;

- (id<Inspector>)globalInspector;
- (id)predicateFinder;
- (id)globalFormManager;

- (NSString *)fileDirectory;
//- openFile:(id)sender;
//- saveAll:sender;
//- (int)countEditedWindows;

/* managing Rubettes */
- (NSString *)rubetteDirectory;
- (NSString *)operatorDirectory;
- (NSString *)stemmaDirectory;
- (NSString *)weightDirectory;

/* menu management */
- (void)setupRubetteMenuCell;
- (id)rubettesMenuCell;
- (BOOL)menuActive:menuCell;
- (BOOL)validateMenuItem:(NSMenuItem *)anItem;

// hmm?
- (id)globalFormBrowser;
@end
@interface Distributor (Overridden)
- (void)setPrediBase:(id<PrediBase>)pb;
- (id<PrediBase>)prediBase;
- (NSMenuItem *)toolsMenuItem; // where to put the toolMenuItems
- (NSMutableDictionary *)toolDictionary; // where to put the tools
- (void)setActiveRubette:(id<RubetteDriver>)newActiveRubette;
- activeRubette;
@end
@interface Distributor (DistributorDebugAdditions)
//jg begin
- debugOpenStandardFile:(id)sender;
- debugLoadMetroRubette:(id)sender;
- debugLoadPerformanceRubette:(id)sender;
- debugLoadMeloRubette:(id)sender;
- debugLoadHarmoRubette:(id)sender;
- debugLoadPrimaVistaRubette:(id)sender;
@end

@interface Distributor (DistributorInterfaceAdditions)
/* show window calls */
- (void)showAlertPanel:sender;
- (void)showInfoPanel:sender;
- (void)showEditWindow:sender;
- (void)showPredicateBrowser:sender;
- (void)showInspector:sender;
- (void)showPredicateFinder:sender;
- (void)showMakroPalette:sender;
- (void)showFormBrowser:sender;
@end


@interface Distributor(ApplicationDelegate)
/* ApplicationDelegate methods */
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
//- (BOOL)applicationShouldTerminate:(id)sender;

@end

@interface Distributor(NibLoading)
- (BOOL)loadNibNamed:(NSString *)nibName forClass:(id)cls;
- (BOOL)loadNibNamed:(NSString *)nibName forClassName:(NSString *)className;
@end

#import <AppKit/AppKit.h>

#import <Rubette/Rubettes.h>

@interface PerformanceRubetteDriver:RubetteDriver
{
    id	performanceScore;
    id	myPerformanceManager;
    id	myKernel;
    id	myKernelViewPanel;
    id	myKernelView;
    id	myFieldViewPanel;
    id	myFieldView;
    id	myWeightListManager;
    id	myWeightWatcherInspector;

    id	myOperatorMenu;
    id  myLoadOperatorPopUpButton;
    id	myOperatorClassList;
    
    id	myFindPanel;
    
    id	myGraphicPrefsPanel;
    
    id	myPerformButton;
    id	myBrowser;
    id	selected;
    int	selIndex;
    BOOL browserValid;
}
- debugLoadAllOperators:sender;
- (void) debugLoadAllOperatorsWithFilenames;

- init;
- (void)dealloc;

- customAwakeFromNib;

- performanceManager;
- weightListManager;
- weightWatcherInspector;

- makeKernel;
- setKernel:sender;
- newPerformanceScore:sender;
- setPerformanceScore:anLPS;
- deletePerformanceScore;
- performanceScore;
- deleteDaughter:sender;

- (void)loadOperatorWithFilename:(NSString *)filename;
- loadOperator:sender;
- applyOperator:sender;

- (void)insertBuildInOperatorMenuItems;
- (void)loadBuildInOperator:(id)buildInMenuItem;
- (void)loadAllBuildInOperators:(id)sender;

- loadWeight:sender;
- (BOOL)canLoadWeight:aWeight;
- (void)readWeight;

- (void)setSelectedCell:sender;
- selectedAtColumn:(int)column;
- (void)setSelected:anLPS;
- selected;

- (void)setLPSEdited:(BOOL)flag;
- (void)setDocumentEdited:(BOOL)flag;

- displayLPS:anLPS;
- showOperatorInspectorPanel:sender;

- insertCustomMenuCells;
+ (NSString *)nibFileName;
+ (const char *)rubetteName;
+ (const char *)rubetteVersion;
+ (spaceIndex)rubetteSpace;

@end

@interface PerformanceRubetteDriver(BrowserDelegate)
/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;


@end

@interface PerformanceRubetteDriver(WindowDelegate)
/* jg? commented out because of the many error messages. to be reviewed.
// (WindowDelegate) methods 
//#warning NotificationConversion: windowDidUpdate:(NSNotification *)notification is an NSWindow notification method (used to be a delegate method); delegates of NSWindow are automatically set to observe this notification; subclasses of NSWindow do not automatically receive this notification
- (void)windowDidUpdate:(NSNotification *)notification;
//#warning NotificationConversion: windowDidBecomeKey:(NSNotification *)notification is an NSWindow notification method (used to be a delegate method); delegates of NSWindow are automatically set to observe this notification; subclasses of NSWindow do not automatically receive this notification
- (void)windowDidBecomeKey:(NSNotification *)notification;
//#warning NotificationConversion: windowDidResignKey:(NSNotification *)notification is an NSWindow notification method (used to be a delegate method); delegates of NSWindow are automatically set to observe this notification; subclasses of NSWindow do not automatically receive this notification
- (void)windowDidResignKey:(NSNotification *)notification;
//#warning NotificationConversion: windowDidMiniaturize:(NSNotification *)notification is an NSWindow notification method (used to be a delegate method); delegates of NSWindow are automatically set to observe this notification; subclasses of NSWindow do not automatically receive this notification
- (void)windowDidMiniaturize:(NSNotification *)notification;
//#warning NotificationConversion: windowDidDeminiaturize:(NSNotification *)notification is an NSWindow notification method (used to be a delegate method); delegates of NSWindow are automatically set to observe this notification; subclasses of NSWindow do not automatically receive this notification
- (void)windowDidDeminiaturize:(NSNotification *)notification;
*/
- (BOOL)windowShouldClose:(id)sender;
@end


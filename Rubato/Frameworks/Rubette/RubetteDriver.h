
#import <AppKit/AppKit.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>

#import "NibDrivenRubetteDriver.h"
#import "FindPredicatesWindowController.h"

#import "RubetteObject.h"
#import <Rubato/RubetteTypes.h>

#import <Predicates/PredicateProtocol.h>

// to be replaced:
#define VERS_NAME "Version"
#define PREF_NAME "Preferences"
#define RSLT_NAME "Results"
#define LAST_FOUND_NAME "LastFoundPredicates"
#define FIND_TEXT "FindText"
#define FIND_LEVELS "FindLevels"

#define PERF_SCORE "PerformanceScore"
#define PHYS_SCORE "PhysicalScore"

#define DEFAULT_FIND_TEXT "Note"
#define DEFAULT_FIND_LEVELS -2

// substitutions
#define ns_VERS_NAME @"Version"
#define ns_PREF_NAME @"Preferences"
#define ns_RSLT_NAME @"Results"
#define ns_LAST_FOUND_NAME @"LastFoundPredicates"
#define ns_FIND_TEXT @"FindText"
#define ns_FIND_LEVELS @"FindLevels"

#define ns_PERF_SCORE @"PerformanceScore"
#define ns_PHYS_SCORE @"PhysicalScore"

#define ns_DEFAULT_FIND_TEXT @"Note"

#define CLEANUP02032001

@interface RubetteDriver : NibDrivenRubetteDriver
{  
    id	input;
    id	output;
    id	weightName;  // IB field
    id	myWindow;
    id	myInfoPanel;
//    id	myListForm;
//    id	myValueForm;

#ifdef WITHMODELOBJECT
#else
    id	rubetteData;
    id	myWeight;
    id	foundPredicates;  
    id	lastFoundPredicates; 
#endif
    // IB-Objects:
    FindPredicatesWindowController *findPredicatesWindowController; // replaces the items below:
/*    
    id	findName; 
    id	findLevels;
    id	findLevelsMenu;
    id	findWhat;
    id	findHow;
    id  findSource;
    BOOL cascadeSearch;
    BOOL newSearch;
*/
    BOOL isAwake;
//    BOOL myDataChanged;
        
    id myConverter;
    
    char* weightfile;
    unsigned long weightCount;

    BOOL isInitializingForDocument;
}
/* class methods */
#ifndef CLEANUP02032001
+ (void)initialize;
+ (NSString *)directory;
+ (NSString *)helpDirectory;
+ (BOOL)getHelpPath:(char *)path; // jg? mad Semantic.
#endif
+ (id)rubetteObjectClass;

/* instance methods */
- init;
- (void)dealloc;
- (void)forwardInvocation:(NSInvocation *)invocation;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector; //necessary fuer forwardInvocation

// cleanup
- (void)closeRubetteWindows;

// Setting up the interface
- (void)wasAwakeFromNib:(id)aDistributor;
- customAwakeFromNib;

// hmmm
- loadNibSection:(const char *)name; // used by Primavista-Rubette

// Doubling of the class methods
- (id)rubetteObjectClass;
- (NSString *)directory;
- (NSString *)helpDirectory;
- (BOOL)getHelpPath:(char *)path;

// input & output management for searching
// jg removed

// read & write Rubettes results, defaults etc. from open .pred file 
- (void)readRubetteData;
- (void)writeRubetteData;
- (void)readCustomData;  // call rubetteObjects readCustomData within it (override)
- (void)writeCustomData; // call rubetteObjects writeCustomData within it (override)

/* manage, read & write Rubettes weights */
- (void)newWeight;
- (void)afterCreatingNewWeight;
- takeWeightNameFrom:sender;
- (void)readWeight;
- (void)writeWeight;
- loadWeight:sender;
- (BOOL)canLoadWeight:aWeight;
- saveWeight:sender;
- saveWeightAs:sender;

/* finding predicates */
- (void)doSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
- (id)searchForPredicatesWithFindPredicateSpecification: (id<FindPredicateSpecification>)specification;
//- changeFindSource:sender;
//- changeFindLevels:sender;
//- setCascadeSearch:sender;
- (void)initSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;

- (void)closeRubette;
@end

@interface RubetteDriver(IBObjects)
- closeRubette:sender;
- doReadData:sender; /* action method for read data buttons */
- doWriteData:sender; /* action method for write data buttons */

  /* window management */
  - (IBAction)showWindow:(id)sender;
  - hideWindow:sender;
  - showRubetteInfoPanel:sender;
  - showRubetteHelpPanel:sender;

- (IBAction)showFindPredicatesWindow:(id)sender;
@end

@interface RubetteDriver(WindowDelegate)
/* (WindowDelegate) methods */
- (void)windowDidBecomeKey:(NSNotification *)notification;
- (void)windowDidResignKey:(NSNotification *)notification;
- (BOOL)windowShouldClose:(id)sender;
@end

@interface RubetteDriver (ToolbarController)
- (void) setupToolbar;
- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted;
- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar;
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar;
@end

@interface RubetteDriver(NowRubetteObject)
+ (const char *)rubetteVersion;
+ (spaceIndex) rubetteSpace;
- (const char *)rubetteVersion;
- (spaceIndex) rubetteSpace;

- (id)rubetteData;
- (void)setRubetteData:(id)fp;
- (id)foundPredicates;
- (void)setFoundPredicates:(id)fp;
- (id)lastFoundPredicates;
- (void)setLastFoundPredicates:(id)fp;
- (id)weight;
- (void)setWeight:(id)weight;
@end

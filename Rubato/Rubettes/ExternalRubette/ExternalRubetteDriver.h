
#import <AppKit/AppKit.h>

#import <Rubette/Rubettes.h>
#import "ExternalRubette.h"
//#import <JGAppKit/JGTableDataViewController.h>

@interface ExternalRubetteDriver:RubetteDriver
{
  IBOutlet NSTableView *tableView;
  id tableViewController;
  IBOutlet NSWindow *interpreterWindow;
  IBOutlet id interpreterView;
}
+ (const char *)rubetteName;
+ (id)rubetteObjectClass;

- init;
- (void)dealloc;

- (ExternalRubette *)externalObject; // casting of RubetteDrivers modelObject

- customAwakeFromNib;

/* read & write Rubettes results, defaults etc. from open .pred file */
- (void)readCustomData;
- (void)writeCustomData;

/* manage, read & write Rubettes weights */
- (void)readWeight;
- loadWeight:sender;

/* finding predicates */
- (void)doSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
- (void)initSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;

/* The real Work */
- (void)makePredList;
- doCalculateWeight:sender;
- (void)calculateWeight;


/* methods to be overridden by subclasses */
- insertCustomMenuCells;

/* class methods to be overriden */
+ (NSString *)nibFileName;

/* window management */
- (IBAction)showWindow:(id)sender;
- hideWindow:sender;

// Interpreter
- (id)interpreter;
- (id)interpreterView;
- (NSWindow *)interpreterWindow;
- (id)interpreterWindowLoadIfNeeded:(BOOL)loadIfNeeded;
- (IBAction)showInterpreterWindow:(id)sender;

- (IBAction)showTableViewTextController:(id)sender;
@end

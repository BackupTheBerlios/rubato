/* PredicateManager.h */

#import <AppKit/AppKit.h>
#import <JGAppKit/JGActivationSubDocument.h>
#import <JGAppKit/JGSubDocumentWindowController.h>
#import "PrediBaseDocument.h"
#import <Rubato/RubatoController.h>

@interface PredicateManager: JGSubDocumentWindowController
{
    id	browser;
    id	selectedCell;
    id	selectedPredicate;

    GenericPredicate *rootPredicate;
    BOOL browserIsValid;
}

/* standard object methods to be overridden */
//- init;
- (void)dealloc;

- (id)initWithWindowNibName:(NSString *)nibName;
//- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName;
//- (void)updateTitle;  // JGSubDocumentWindowController

- (id/* <Distributor> */)distributor;
- (id)browser;
- (id)browserWindow;  // for backward compatibility. It is [self window]

/* access methods to instance variables */
- (void)setBrowserIsValid:(BOOL)v;
- (void) setRootPredicate:(GenericPredicate *)pred;
- rootPredicate;
//- formList;  // obsolete?
- predicateList;
//- rubetteList;
//- weightList;

/* copy & paste methods */
- copyToPasteboard:pboard;
- (void)copy:(id)sender;
- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type;
- (void)cut:(id)sender;
- (void)paste:(id)sender;

/* predicate list management */
- before: aPredicate;
- after: aPredicate;
- removePredicate: aPredicate;
- removePredicateAt:(unsigned int)index;
- deletePredicate: aPredicate;
- deletePredicateAt:(unsigned int)index;

/* form list management */
//- addPredicateForm:aForm;
//- addForm:aForm;

/* browser management */
- (void)row:(int *)aRow andColumn:(int *)aCol ofPredicate:(id)aPredicate;
- (void)selectPredicate: aPredicate;
- (void)setSelectedFrom:sender;
- selectedPredicate;
- (void)setSelectedPredicate:(id)newPredicate;
- (void)setSelectedPredicateAndNotify:(id)newPredicate;
- selected; // same as selectedPredicate
- (void)setNewSelectedCell:(id)newCell; // better rename to setSelectedCell:
- (void)setSelectedCell:sender; // where is this called? rename to setSelectedCellWithSender:
- selectedCell;

- selectedInColumn:(int)column;
- browser:sender selectedInColumn: (int)column;
- browser:sender predicateAtRow:(int)row inColumn:(int)column;

- (void)invalidate;

/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
//- (const char *)browser:sender titleOfColumn:(int)column;
- (BOOL)browser:sender selectCellWithString:(NSString *)title inColumn:(int)column;
- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;

- (void)addSubDocumentsBrowser:(id)sender;
- (void)addPredicateBrowser:(id)sender;
- (void)addRubetteBrowser:(id)sender;

@end

@interface PredicateManager(WindowDelegate)
#ifdef DEPRECATED_CLOSING
- (BOOL)windowShouldClose:(id)sender;
#else
- (void)windowWillClose:(NSNotification *)notification;
#endif
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (void)windowDidLoad; // jg 14.6.
- (void)windowWillLoad; // jg 14.6.
- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName;
@end
#import <AppKit/AppKit.h>
#import <JGAppKit/JGActivationSubDocument.h>
#import <Rubato/FormListProtocol.h>
#import <Rubato/RubatoController.h>
#import <Rubato/PrediBaseDocumentBasics.h>

#undef OLDPREDICATEMANAGER
#define NEWPREDICATEMANAGER
#define CLEANPREDICATEMANAGER

@class GenericPredicate;

@interface PrediBaseDocument : PrediBaseDocumentBasics  <FormListProtocol>
{
  BOOL useOwnDistributor;
  id myDistributor;
  BOOL mustInvalidate;
}

- (void)close; // (called in NSDocument framework) remove all Rubettes before closing self.

- (void)invalidate;
- (void)invalidateSetRoot:(BOOL)sr;
- (void)willSetPredicate:(id)object forKey:(NSString *)key; // hook
- (void)didSetPredicate:(id)object forKey:(NSString *)key; // hook

// convention for putting scores
- (id)scorePredicate;

/* access methods to instance variables */
- (id)predicateList; // rename to userPredicates? All Predicates from predicateDictionary?
// - (id)rubetteList;   // rename to rubettePredicates // no, skip this in favor of predicateForKey etc.

/* form list management */
//- addPredicateForm:aForm;
//- addForm:aForm;
- addPredicate: aPredicate;
- addPredicate: aPredicate Before: bPredicate;
- (id)formList;


- (void)setDocumentEdited:(BOOL)flag;

- (void)addPredicateBrowserForPredicate:(GenericPredicate *)pred;
- (void)addPredicateBrowser;
- (void)addPredicateBrowser:(id)sender;
- (void)addRubetteBrowser:(id)sender;

- (void)makeWindowControllers;
@end
//- (id)formManager;
/* save & load methods */
//- (void)setFileName:(NSString *) aFileName;  // overridden

//- (NSData *)dataRepresentationOfPredibase;
//- (NSData *)dataRepresentationOfType:(NSString *)aType;
//- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType;

//- (BOOL)loadFileWithData:(NSData *)data;

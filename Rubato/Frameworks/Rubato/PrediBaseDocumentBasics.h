#import <AppKit/AppKit.h>
#import <JGAppKit/JGActivationSubDocument.h>
#import <JGAppKit/JGFileDictionary.h>
#import <Rubato/FormListProtocol.h>
#import <Rubato/RubatoController.h>

#undef OLDPREDICATEMANAGER
#define NEWPREDICATEMANAGER
#define CLEANPREDICATEMANAGER

@class GenericPredicate;

// We use a persistDict and tempDict instead of concrete instances for better
// extensibility. Just add a Category for each other Data type, that requires
// bundles. The Loaded Data is only unarchived, when accessed. So a bundle that
// accesses some data and links to Frameworks, that contain the needed classes
// should be able to successfully load the data.

@interface PrediBaseDocumentBasics:JGActivationSubDocument <PrediBase>
{
    JGFileDictionary *persistDict;
    NSMutableDictionary *tmpDict;
/*
    NSMutableDictionary *predicateDictionary;
    NSMutableDictionary *customObjectDictionary;
    NSMutableDictionary *weightDictionary;
*/
    id selected;
}

/* standard object methods to be overridden */
- init;
- (void)dealloc;

- (id/* <Distributor> */)distributor;

  /* access methods to instance variables */
- (id)selected;  // noch Predicate, spaeter MutableDictionary
- (void)setSelected:(id)aPredicate;

  // Rubettes use this to put non-shared state information (Non Predicates) under their key
// Used to share the same window between differen PrediBases; Rubette window reads Predicates and
// custom object to restore its state.
- (id)customObjectForKey:(NSString *)key;
- (void)setCustomObject:(id)object forKey:(NSString *)key;
- (void)removeCustomObjectForKey:(NSString *)key;

// jg:
// might be overridden to assure save access (return copy of Predicates)
// Faster Rubette-Change possible with the following modification:
// Rubettes only write their Predicate-Data, if it is accessed from somewhere.
// Even possible to lookup the values in the Rubettes rather than in myRubetteList.
- (id)predicateForKey:(NSString *)key;
- (void)setPredicate:(id)object forKey:(NSString *)key;
- (void)removePredicateForKey:(NSString *)key;

- (id)weightForKey:(NSString *)key;
- (void)setWeight:(id)object forKey:(NSString *)key;
- (void)removeWeightForKey:(NSString *)key;

- (NSArray *)weightList;

- (void)willSetPredicate:(id)object forKey:(NSString *)key; // hook
- (void)didSetPredicate:(id)object forKey:(NSString *)key; // hook

//@protected
- (void)setPersistDict:(JGFileDictionary *)newDict;
- (JGFileDictionary *)persistDictDictWithKey:(NSString *)key create:(BOOL)yn;
- (NSMutableDictionary *)tmpDictDictWithKey:(NSString *)key create:(BOOL)yn;
- (JGFileDictionary *)predicateDictionary;
- (JGFileDictionary *)weightDictionary;
- (NSMutableDictionary *)customObjectDictionary;

@end

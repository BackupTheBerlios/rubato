#import <Rubato/RubatoController.h>
#import <AppKit/AppKit.h>

// A NibDrivenRubetteDriver provides an easy interface for building a Rubette
// while not having the Predicate&Weight overhead of the RubetteDriver-class

@protocol ExtendedRubetteDriver <RubetteDriver>
- (const char *)rubetteName; 
//- (const char *)rubetteVersion;
- (BOOL)dataChanged;
- (void)setDataChanged:(BOOL)yn;
- (id/* <Distributor> */)distributor; 

// ?? 7.3.2001 to be removed. use RubetteObject instead.
// kept here because old rubettes override these
- (void)readWeightParameters;
- (void)writeWeightParameters;
@end

@protocol RubetteObjectInitialization
// call a new allocatet rubetteObject with
- (id)initWithExtendedRubetteDriver:(id<ExtendedRubetteDriver>)rubetteDriver;
- (void) setExtendedRubetteDriver:(id<ExtendedRubetteDriver>)newExtendedRubetteDriver;
@end


// A RubetteDriver contained in a Nib file
@interface NibDrivenRubetteDriver : NSObject <RubetteBundlePrincipalClass,ExtendedRubetteDriver>
{
  id	owner; // <Distributor> set with +initializeBundle and Nib
  NSString *rubetteKey;
  id<PrediBase>	prediBase; // holds the old state when changing predibases. So not just [distributor prediBase]
  id rubetteObject; // for exported data attached to [prediBase setCustomObjectForKey:rubetteKey]
  id	myMenu;
  id toolMenuItem;
  BOOL writeRubetteDataOnToolChange;
  BOOL myDataChanged;
}
/*" initialization (implements <RubetteBundlePrincipalClass> "*/
+ (void)initializeBundle:(NSBundle *)bundle withDistributor:(id/* <Distributor> */)distributor display:(BOOL)display;
+ (NSString *)nibFileName;
+ (const char *)rubetteName;
//+ (const char *)rubetteVersion;
// derived, but can be overridden
- (NSString *)nibFileName; //+[self nibFileName]
- (const char *)rubetteName; //+[self rubetteName]
//- (const char *)rubetteVersion; //+[self rubetteVersion]

- init; // associates rubetteKey with +rubetteName
- (void)dealloc;
// Building a Rubette-Menu
- setUpMenu;
- rubetteMenu;
- (NSMenuItem *)toolMenuItem;
- insertCustomMenuCells; // to be overridden

/* InterRubetteCommunication */
- (NSString*) rubetteKey; // with +[self rubetteName] initialized
- (void) setRubetteKey:(NSString*)newRubetteKey;
- (id<PrediBase>)prediBase;
- (void)setPrediBase:(id<PrediBase>)aPrediBase; // non retained.
- (void)rubetteChanged:(id<RubetteDriver>)newActiveRubette;
// derived, but can be overridden
- (id/* <Distributor> */)distributor; // [prediBase distributor]

// operates on PrediBase or is this just a helper object?
- (id)rubetteObjectClass; // to be overridden
- (id)rubetteObject;
- (void)setRubetteObject:(id)object;

- (BOOL)dataChanged;
- (void)setDataChanged:(BOOL)yn;
- (void)readWeightParameters;
- (void)writeWeightParameters;
- (BOOL) writeRubetteDataOnToolChange;
- (void) setWriteRubetteDataOnToolChange:(BOOL)newWriteRubetteDataOnToolChange;
- (void)writeRubetteData; // to be overridden.
@end
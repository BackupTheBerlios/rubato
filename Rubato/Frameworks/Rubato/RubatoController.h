#import <AppKit/AppKit.h>
//#import <RubatoDeprecatedCommonKit/commonkit.h>
#import "Inspectable.h"

//compiler does not support forward protocol declarations "@protocol x;" as described in /Documentation/Developer/YellowBox/TasksAndConcepts/ObjectiveC/moreobjc.htm
//@protocol PrediBase
//@protocol RubetteDriver;

// common Database for Tools associated with -distributor
@protocol PrediBase <NSObject>
- (id/*<Distributor>*/)distributor; // protocol removed (s.o.)
 
- (id)customObjectForKey:(NSString *)key;
- (void)setCustomObject:(id)object forKey:(NSString *)key;
- (void)removeCustomObjectForKey:(NSString *)key;

- (id)predicateForKey:(NSString *)key;
- (void)setPredicate:(id)object forKey:(NSString *)key;
- (void)removePredicateForKey:(NSString *)key;

- (id)weightForKey:(NSString *)key;
- (void)setWeight:(id)object forKey:(NSString *)key;
- (void)removeWeightForKey:(NSString *)key;
- (NSArray *)weightList; // to be replaced by accessor methods (s.o.)
@end

@protocol ResourceDirectories
- (NSString *)rubetteDirectory;
- (NSString *)operatorDirectory;
- (NSString *)stemmaDirectory;
- (NSString *)weightDirectory;
@end

@protocol RubetteDriver <NSObject>
// methods used when inserting RubetteDriver into Distributor
- (NSString *)rubetteKey;
- (void)setRubetteKey:(NSString*)newRubetteKey; 

// methods that Rubettes must implement to respond to activation messages send by their distributor:
- (id<PrediBase>)prediBase; // prediBase to which self writes its data
- (void)setPrediBase:(id<PrediBase>)prediBase; // do not retain prediBase
- (void)rubetteChanged:(id<RubetteDriver>)newActiveRubette;
  // newActiveRubette is the Rubette which changed or was set to front. Possible to write back data in this method
@end

@protocol CommonArchiverInterface
- (NSData *)archivedDataWithRootObject:(id)obj;
@end
@protocol CommonUnarchiverInterface
- (id)unarchiveObjectWithData:(NSData *)data;
@end
@protocol RubatoArchivers
- (id<CommonArchiverInterface>)archiverForType:(NSString *)aType;
- (id<CommonUnarchiverInterface>)unarchiverForType:(NSString *)aType;
@end

@protocol HaveMenuItem
- (NSMenuItem *)toolMenuItem;
@end

@protocol AddingTools
// primitives
- (NSMenuItem *)toolsMenuItem; // where to put the toolMenuItems
- (NSMutableDictionary *)toolDictionary; // where to put the tools

// more complex
- (void)addToolMenuItem:(NSMenuItem *)menuItem;
- (void)removeToolMenuItem:(NSMenuItem *)menuItem;
// newTool or oldTool might <HaveMenuItem>, in which case the methods above are applied.
- (void)setTool:(id)newTool forKey:(NSString *)key replaceOld:(BOOL)yn;
- (id)toolForKey:(NSString *)key;
@end

@protocol RubetteLogin
+ (NSString *)rubetteIndexSeparator;
- (BOOL)rubetteIsLoaded:(id<RubetteDriver>)sender;
- (BOOL)signInRubette:(id<RubetteDriver>)rubetteDriver;
- (void)signOutRubette:(id<RubetteDriver>)rubetteDriver;
- (void)addRubette:(id<RubetteDriver>)rubetteDriver replaceOld:(BOOL)yn;
- (void)removeRubette:(id<RubetteDriver>)rubetteDriver;
- (NSArray *)rubetteList; // Array of RubetteDrivers
@end

@protocol RubetteLoading
- (void)loadRubette:(id)sender;
- (void)loadRubetteByFilename:(NSString *)fname;
- (NSArray *)rubettesSpecifiedInInfoDictionaryOfBundle:(NSBundle *)bundle;
- (NSArray *)rubettesSpecifiedAsResourcesOfBundle:(NSBundle *)bundle;
- (void)defaultLoadBundle:(NSBundle *)bundle;
- (void)loadBundleContainer:(NSBundle *)bundle;
- (void)loadRubetteBundle:(NSBundle *)bundle;
@end

@protocol DistributorAppKit
- (id<Inspector>)globalInspector;
- (id)predicateFinder;
- (id)globalFormManager;
@end

@protocol RubetteActivation
- (id<PrediBase>)prediBase; // results the PrediBase (PrediBaseDocument)
- (void)setPrediBase:(id<PrediBase>)pb;

// will notify other Rubettes in Distributor with setPrediBase: and rubetteChanged:
- (void)setActiveRubette:(id<RubetteDriver>)newlyActivatedRubette;
- (id)activeRubette;//returns the currently active Rubette
@end

@protocol RubettePerformation
- (void)makeRubettesPerformSelector:(SEL)sel;
- (void)makeRubettesPerformSelector:(SEL)sel withObject:(id)obj;
@end

@protocol Distributor <NSObject, RubatoArchivers, AddingTools, RubetteLogin, RubetteLoading, DistributorAppKit, RubetteActivation,ResourceDirectories>
@end

// method called on the pricipal class when opening a Rubette-Bundle
@protocol RubetteBundlePrincipalClass
+ (void)initializeBundle:(NSBundle *)bundle withDistributor:(id/* <Distributor> */)distributor display:(BOOL)display;
@end



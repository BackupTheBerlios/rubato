
#import <AppKit/AppKit.h>

#import <Rubette/Rubettes.h>
#if 0
#include <RubatoAnalysis/metro.h>
#endif
#import "MetroRubette.h"

@interface MetroRubetteDriver:RubetteDriver
{
    id	myWeightFunctionPanel;
    id	myWeightViewPanel;
    id	myWeightView;
    id	myGraphicPrefsPanel;
    id	myBrowser;
    id	myMetroWeightText;
    
    id	myMetricalProfileField;
    id	myLowerLengthLimitField;
    id	myQuantMeshField;
    id	myQuantOriginField;
    id	myAutomaticMeshSwitch;
    id	myDistValueField;
    
    BOOL browserValid;
    
    int	selPredIndex;

#if 0
	/* Variables for the MetroWeight calculation */
	FractList *predList; 	/*list of onset (projections of )predicates*/
	double *distValues;		/*list of distributor values*/
	grid *gridValues;		/*list of grids*/
//	int lim;				/*limit for local meters*/
//	double prof;			/*profile*/
	int prediCount;				/*common length of these lists*/
	weightList myWeightList;
#endif
}
+ (const char *)rubetteName;
+ (id)rubetteObjectClass;

- init;
- (void)dealloc;

- (MetroRubette *)metroObject; // casting of RubetteDrivers modelObject


- customAwakeFromNib;

/* read & write Rubettes results, defaults etc. from open .pred file */
- (void)readCustomData;
- (void)writeCustomData;

/* manage, read & write Rubettes weights */
- (void)readWeight;
- makeWeightList;
- loadWeight:sender;

/* finding predicates */
- (void)doSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
- (void)initSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;

/* The real Work */
- (void)makePredList;
- doCalculateWeight:sender;
- (void)calculateWeight;
- showWeightText;
- (void)updateFieldsWithBrowser:(id)aBrowser;

- (void)setSelectedCell:sender;
- setDistValue:sender;
- setMetricalProfile:sender;
- setLowerLengthLimit:sender;
- setQuantMesh:sender;
- setQuantOrigin:sender;
- setQuantAutoMesh:sender;

/* methods to be overridden by subclasses */
- insertCustomMenuCells;

/* class methods to be overriden */
+ (NSString *)nibFileName;

/* window management */
- (IBAction)showWindow:(id)sender;
- hideWindow:sender;

@end

@interface MetroRubetteDriver(BrowserDelegate)
/* (BrowserDelegate) methods */

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;

@end

#import <AppKit/AppKit.h>

#import <Rubette/Rubettes.h>
#import <RubatoAnalysis/melo.h>

@interface MeloRubetteDriver:RubetteDriver
{
    id	myWeightFunctionPanel;
    id	myWeightViewPanel;
    id	myWeightView;
    id	myMotifViewPanel;
    id	myMotifView;
    id	myGraphicPrefsPanel;
    id	myMeloWeightText;
    
    id	myNeighbourhoodField;
    id	myMotifSpanField;
    id	myMotifCardField;
    id	mySymmetryPopUp;
    id	myParadigmPopUp;
    
    id	myBrowser;
    int	selPredIndex;
    BOOL browserValid;

    M2D_compList meloList; /*A "melody" predicate containing 
			    *double-parametrized 2D resp. onset-pitch points. 
			    *The list contains its points only once, and, 
			    *if possible, but not necessarily, ordered according to
			    *the lexicographic order of (onset,pitch).
			    */
    double epsilon;	   /*The neighborhood radius*/
    int paradigm;	   /*The integer representing one of the three types of shape and distance.
			    *1 = diastematic index, 2 = elastic, 3 = rigid.*/
    int group;		   /*Ond of the usual subgroups of the counterpoint group:
			    * IDENTITY, RETROGRADE, INVERSION, COUNTERPOINT
			    */
    int card;		   /*The lower limit of cardinality of motifs to be considered, card= 2 is default*/
/* Noll: Is not the field Cardinality in the Nib*/
    double span;	   /*The upper limit of distance between first and last onset of a motif©s point*/
    M2D_weightList myWeightList;
    M2D_motifList myMotifList;

}

- init;
- (void)dealloc;
- customAwakeFromNib;

/* read & write Rubettes results, defaults etc. from open .pred file */
- (void)readCustomData;
- readMotifList;
- (M2D_powcomList) readLayer:(int)index ofMotifList: aList;
- (void)readWeightList;
- (void)writeCustomData;
- writeMotifList;
- (void)writeWeightList;

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
- doMakeAllMotifs:sender;
- makeMotifList;
- doCalculateMotifWeights:sender;
- calculateMotifListWeights;
- (void)updateFieldsWithBrowser:(id)aBrowser;
- (void)setSelectedCell:sender;
- (void)setSelectedMotif:sender;

/* window management */
- (IBAction)showWindow:(id)sender;
- hideWindow:sender;

/* methods to be overridden by subclasses */
- insertCustomMenuCells;

/* class methods to be overridden by subclasses */
+ (NSString *)nibFileName;
+ (const char *)rubetteName;
+ (const char *)rubetteVersion;
+ (spaceIndex)rubetteSpace;

@end

@interface MeloRubetteDriver(BrowserDelegate)
/* (BrowserDelegate) methods */

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;

@end
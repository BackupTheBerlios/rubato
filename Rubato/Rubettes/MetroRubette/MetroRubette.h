// #import <Rubette/RubetteDocument.h>
#import <Foundation/Foundation.h>
#import <Rubette/Rubettes.h>
#import <RubatoAnalysis/metro.h>

#define METRO_WEIGHT "MetroWeight"
#define METRO_WEIGHT_ONSETS "MetroWeight Onsets"
#define METRO_WEIGHT_VALUES "MetroWeight Values"
#define METRO_PROFILE "MetroWeight Profile"
#define METRO_CARD "MetroWeight Lower Cardinality"
#define METRO_QUANT "MetroWeight Float Quantization"
#define METRO_QUANT_MESH "MetroWeight Float Quantization Mesh"
#define METRO_QUANT_MESH_VAL "MetroRubette Quant Mesh Val"
#define METRO_QUANT_ORIGIN "MetroWeight Float Quantization Origin"
#define METRO_QUANT_ORIGIN_VAL "MetroWeight Quant Origin Val"
#define METRO_QUANT_AUTO_MESH "MetroWeight Automatic Mesh"
#define METRO_DIST "MetroWeight Distributor"
#define METRO_DIST_VAL "MetroWeight Distributor Value"

@interface MetroRubette : RubetteObject
{
  double metricalProfile;
  int	lowerLengthLimit;
  int automaticMesh;
//  int	selPredIndex;

  /* Variables for the MetroWeight calculation */
  FractList *predList; 	/*list of onset (projections of )predicates*/
  double *distValues;		/*list of distributor values*/
  grid *gridValues;		/*list of grids*/
//	int lim;				/*limit for local meters*/
//	double prof;			/*profile*/
  int prediCount;				/*common length of these lists*/
  weightList myWeightList;
}
+ (const char *)rubetteVersion;
+ (spaceIndex)rubetteSpace;


- init;
- (void)dealloc;

- (double)metricalProfile;
- (void)setMetricalProfile:(double)val;
- (int)lowerLengthLimit;
- (void)setLowerLengthLimit:(int)val;
- (int)automaticMesh;
- (void)setAutomaticMesh:(int)val;

- (int)prediCount;
- (weightList)weightList;
- (double *)distValues;
- (grid *)gridValues;

/* manage, read & write Rubettes weights */
#if 0
- (void)readWeight;
- makeWeightList;
- loadWeight:sender;
#endif

/* The real Work */
- (void)makePredList;
- (void)calculateWeight;
- weightText;

  /* manage, read & write Rubettes weights */
- (void)makeWeightList;


#if 0
- (void)setMetricalProfile:(double)value;
- (void)setLowerLengthLimit:(int)value;
- (void)setQuantMesh:sender;
- (void)setQuantOrigin:sender;
- (void)setQuantAutoMesh:sender;
#endif

@end

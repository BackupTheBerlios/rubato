#import <AppKit/AppKit.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import "HarmoTypes.h"

#define MAZZOLA 1 
#define NOLL 2 
#define DIRECT_HARMO 3
#define THIRDCHAIN_HARMO 4

@interface ChordSequence:JgRefCountObject
{
@public
  // functionCount*tonalityCount==locusCount AND modeCount*modelessFunctionCount==functionCount
  int functionCount,tonalityCount,locusCount,modeCount,modelessFunctionCount,pcCount;
  int summationFormulaNumber, useMorphology;

#ifdef  CHORDSEQ_DYN
    double **myFunctionScale; /* [MAX_FUNCTION][MAX_TONALITY] 6x12 matrix with the TDS major and minor values of each tone     */
#else
    double myFunctionScale[MAX_FUNCTION][MAX_TONALITY]; // Function PitchClass
#endif 
    double ***myNollMatrix;
    double ***harmonicProfile; /* functionCount x tonalityCount x pcCount, e.g. 6x12x12 Function x Tonalities x TwelveVector (for scalar multiplication with chord twelve vector), not persistent */

//@protected
    id myChords; /* list of chord objects */
#ifdef  CHORDSEQ_DYN
    double **myModelessFunctionDist; /* [MAX_MODELESS_FUNCTION][MAX_MODELESS_FUNCTION] 3x3 matrix of nine distances for TDS-walks T~0, D~1, S~2 walks are row->col */
#else
    double myModelessFunctionDist[3][3]; /* 3x3 matrix of nine distances for TDS-walks T~0, D~1, S~2 walks are row->col */
#endif
#ifdef  CHORDSEQ_DYN
    double **myModeDist; /* [MAX_MODE][MAX_MODE] 2x2 matrix of four distances for Major-Minor-walks */
#else
    double myModeDist[2][2]; /* 2x2 matrix of four distances for Major-Minor-walks */
#endif
    double myTonalityDist[2][7]; /* 2x7 matrix of tonality walks with fourth and fifth direction */
#ifdef  CHORDSEQ_DYN
    double **myDistanceMatrix; /* [MAX_LOCUS][MAX_LOCUS] 72x72 matrix of distance */
#else
    double myDistanceMatrix[MAX_LOCUS][MAX_LOCUS];
#endif
    double myPitchReference; /* reference pitch for quantization */
    double mySemitoneUnit; /* unit pitch step for quantization */
    double myGlobalLevel; /* global level for path calculations */
    double myLocalLevel; /* local relative level for path calculations */
#ifdef  CHORDSEQ_DYN
    BOOL   *myUseFunctionList; /* [MAX_LOCUS] */
#else
    BOOL   myUseFunctionList[MAX_LOCUS];
#endif
    double myWeightProfile; /* contribution of the weights to the path weights */
    double myTransitionProfile; /* contribution of the transitions to the path weights */
    double myStartWeight; /* first non-vanishing weight from best path */
    double myEndWeight; /* first non-vanishing weight from best path */
    int myCausalDepth; /* contribution of preceding chords */
    int myFinalDepth; /* contribution of following chords */
    double myGlobalSlope; /* the difference of weight level from start = 1.0 to end = myGlobalSlope */
    double myIntraProfile; /* tells the relative level (0<=l<1) of minimal weights with respect to chord©s weight */
    BOOL isRiemannCalculated; /* to check the calculation status of the Riemann logic*/
    BOOL isLevelCalculated; /* to check the calculation status of the level matrices*/
    BOOL isDistanceCalculated; /* to check the calculation status of the distance matrix*/
    BOOL isBestPathCalculated; /* to check the calculation status of the best path*/
    double myNollProfile[8][7]; /* Noll©s profile function */
    int   myMethod; /* selection of the calculation method */

    // jg added for quicker best patch calculation
    SEL calcBestPathSelector;
    id viterbiContext;
    NSMutableDictionary *fsBlocks; // Hooks, not persistent
    NSDictionary *harmoSpace; // not yet persistent. Values are Arrays of Name.
}
- (NSDictionary *)harmoSpace;
- (void)setHarmoSpace:(NSDictionary *)dict;
- (NSMutableDictionary *)fsBlocks;

- (void)allocFunctionScale:(double **)otherFunctionScale useFunctionList:(BOOL *)otherUseFunctionList distanceMatrix:(double **)otherDistanceMatrix doInit:(BOOL)doInit;
- (void)allocModelessFunctionDist:(double **)otherModelessFunctionDist doInit:(BOOL)doInit;
- (void)allocModeDist:(double **)otherModeDist doInit:(BOOL)doInit;
- (void)allocModelessFunctionDist:(double **)otherModelessFunctionDist modeDist:(double **)otherModeDist doInit:(BOOL)doInit;
- (void)allocNollMatrix:(double ***)otherNollMatrix doInit:(BOOL)doInit;

- init;
- (void)dealloc;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (id)viterbiContext;
- (void)setViterbiContext:(id)newViterbi;

- resetToDefaultValues;
- resetGeneralDefaultValues;
- resetRiemannDefaultValues;
- resetTonalityDefaultValues;
- resetWeightDefaultValues;
- resetNollDefaultValues;
- resetMethod;

/* suppose that anEventList built from EH-MatrixEvents is deduced from the predicate */
- generateChordsFromEHList:anEventList;
/* suppose that anEventList built from EHD-MatrixEvents is deduced from the predicate */
- generateChordsFromEHDList:anEventList;
- installThirdStreams;

- (double)onsetAt:(int)index;
- chordAt:(int)index;
- (unsigned int)count;

/*read and write of instance variables */
/* Riemann and level data */
- (double)scaleValueAt:(int)function:(int)tone;
- setScaleValue:(double)value at:(int)function:(int)tone;
- (const double**)functionScale;
- (double)pitchReference;
- setPitchReference:(double)aDouble;
- (double)semitoneUnit;
- setSemitoneUnit:(double)aDouble;
- (double)localLevel;
- setLocalLevel:(double)level;
- (double)globalLevel;
- setGlobalLevel:(double)level;
- (BOOL)useFunctionAtLocus:(int)locus;
- setUseFunction:(BOOL)flag atLocus:(int)locus;

/* calculation maintenance */
- invalidate;
- invalidateChords;
- invalidateWeights;

/* generating the Riemann logic background if necessary */
- generateRiemannLogic;
- (BOOL)isRiemannLogicOK;

- (double)functionDistanceFrom:(int)startFunction to:(int)targetFunction;
- setFunctionDistance:(double)dist from:(int)startFunction to:(int)targetFunction;
- (double)modeDistanceFrom:(int)startMode to:(int)targetMode;
- setModeDistance:(double)dist from:(int)startMode to:(int)targetMode;
- (double)tonalityDistanceAt:(int)intervalRow:(int)tonalityCol;
- setTonalityDistance:(double)dist at:(int)intervalRow:(int)tonalityCol;
- (double)nollProfileAt:(int)row :(int)col;
- setNollProfile:(double)prof at:(int)row:(int)col;
- (double)tonalityDistanceFrom:(int)startTonality to:(int)targetTonality;
- setTonalityDistance:(double)dist from:(int)startTonality to:(int)targetTonality;
- (int)causalDepth;
- setCausalDepth:(int)chordCard;
- (int)finalDepth;
- setFinalDepth:(int)chordCard;
- (double)weightProfile;
- setWeightProfile:(double)weightProfile;
- (double)transitionProfile;
- setTransitionProfile:(double)transitionProfile;
- (double)globalSlope;
- setGlobalSlope:(double)slope;
- (double)intraProfile;
- setIntraProfile:(double)intraProfile;
- (int)method;
- setMethod:(int)aMethod;
- (int)locusStartAt:(int)sequenceIndex;
- setWorkPathToSupportStartAround:(int)sequenceIndex;
- resetWorkPathToSupportStart;
- (int)workLocusAt:(int)sequenceIndex;

/* distance calculation between two points in function-mode-tonality space */
- (double)calcDistanceFrom:	(int)startFunction:(int)startMode:(int)startTonality to:
				(int)targetFunction:(int)targetMode:(int)targetTonality;

/* distance  calculation between two points in Riemann-Locus space */
- (double)calcDistanceFrom:(int) startLocus to:(int)targetLocus;

- (double)distanceFrom:(int) startLocus to:(int)targetLocus;


- (int)firstIndex;
- (int)lastIndex;

/* weight of chord at sequenceIndex on path of index = pathNumber and myCausalDepth, myFinalDepth*/
- (double)pathWeightDifferenceAround:(int)sequenceIndex:(int)diffIndex;

/* produces the next working path and returns non-negative index of local increase or -1 if it©s a maximal path */
- (int)increaseIndexAround:(int)sequenceIndex;

/* the locus ranking for the chord at sequenceIndex */
- calcBestPathAt:(int)sequenceIndex;

/* this one performs all the preceding index-specific tasks */
- calcBestPath;
- (BOOL)isBestPathCalculated;
- (SEL)calcBestPathSelector;
- (void)setCalcBestPathSelector:(SEL)sel; //allows for the inclusion of category methods.

/* weight calculations for best path */
- (double)bestPathWeightAt:(int)sequenceIndex;
- bestPathWeight;

- (double)firstWeight;
- (double)lastWeight;
- (double)normalizeFactorAt:(int)sequenceIndex;
/* this is the weight of chord at sequenceIndex */
- (double)normalizedbestPathWeightAt:(int)sequenceIndex;
- (double)relativeWeightAt:(int)sequenceIndex:(int)toneIndex;

/* perhaps the following three methods superfluous by the fourth! 
- weightedChordAt:(int)sequenceIndex;
- weightedChordSequence;
- harmoWeightList;
*/

/* this makes the harmoweight list at once, without first makein the weighted chords */
- addHarmoWeightsToWeight:aWeight;
- (BOOL)isWeightCalculated;

/* estimate calculation amount */
- (double)approxCalculations;

/* Noll Methods */
/* Methode for the calculation of the coeffizients of the Noll-Matrix; j++ = row 1...8; k++ = column 1...12 */
- (double *)profTable:(double *)table at:(int)j:(int)k;

/* caclulation method of the nollWeight 3D-Matrix 12 x 8 x 43 */
- calcNollMatrix;
- (double ***)nollMatrix;

- (int)locusCount;
- (int)tonalityCount;
- (int)functionCount;
- (int)modeCount;
- (int)modelessFunctionCount;
- (int)pcCount;
@end

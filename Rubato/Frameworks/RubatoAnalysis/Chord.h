#import <RubatoDeprecatedCommonKit/commonkit.h>
#import "HarmoTypes.h"
#import <Rubato/Inspectable.h>
#import "ChordSequence.h"

#define CHORD_DYN

@interface Chord:JgRefCountObject <Ordering, Inspectable>
{
@public
    int functionCount,tonalityCount,locusCount; // non inclusive
//@protected
    ChordSequence *myOwnerSequence; /* the ChordSequence Object, that contains this Chord instance */
    double *myPitchList; /* list object with Pitches of this chord */
    int myPitchCount;
    int myPitchClasses; /* bit sequence 0,1,...,11 from the right as usual (NEWHARMO: now holds space for 32 bits) */
    double myOnset;
    id myThirdStreamList; /* list of ThirdStream objects of the chord */
#ifdef CHORD_DYN
    double **myRiemannMatrix; /* [MAX_FUNCTION][MAX_TONALITY] a numeric 6x12 matrix */
    double **myLevelMatrix; /* [MAX_FUNCTION][MAX_TONALITY] level 6x12 Matrix for the level sensitivity for the calculation of paths */
#else
    double myRiemannMatrix[MAX_FUNCTION][MAX_TONALITY];
    double myLevelMatrix[MAX_FUNCTION][MAX_TONALITY];
#endif
    short mySupportStart; /*first non-zero locus (=index) of myLevelMatrix, is 72 iff all are zero */
    short myLocus[PATHNUMBER+1]; /* array of integers for the best PATHNUMBER paths,
    				the last entry is free for calculations, it©s the workpath */

#ifdef CHORD_DYN				
    double *myPitchClassWeights; /*[MAX_TONALITY]  wrong! should be [myPitchCount]*/
#else
    double myPitchClassWeights[MAX_TONALITY];
#endif  
    double myWeight;
    BOOL isWeightCalculated;
}

- (void)allocRiemannMatrix:(double **)otherRiemannMatrix levelMatrix:(double **)otherLevelMatrix pitchClassWeights:(double *)otherPitchClassWeights doInit:(BOOL)doInit;

// Designated Initializer
- (id)initOwner:(id)aChordSequence;
- (void)dealloc;
- copyWithZone:(NSZone*)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (NSString *)inspectorNibFile;

- ownerSequence;
- setOwnerSequence:aChordSequence;

/* tone management */
- (BOOL)hasPitchClass:(int)aPitchInt;
- (BOOL)hasPitch:(double)aPitch;
- (BOOL)hasToneEvent:anEvent;
- (double) onset;
- (const double *)pitchList;
- (int)pitchClasses;
- (int)fifthPitchClasses;/* chord Method for Fifth transformation */
- thirdStreamList;

- addToneEvent:anEvent;
- removeToneEvent:anEvent;
- addPitch:(double)aPitch;
- removePitch:(double)aPitch;

/* counting tones */
- (int)pitchCount;
- (int)pitchClassCount;

/* Weight and RiemannMatrix calculation maintenance */
- invalidate;
- invalidateWeight;
- updatePitchClasses;
- updateSupport;

/* management of subchords */
- (BOOL)isSubChordOfPitchClasses:(int)pitchClasses;
- (BOOL)isSubChordOf:aChord;
- (BOOL)isSubChordOfStream:aThirdStream;

- (int)locusOfPath:(int)pathNumber;
- (void)setLocusOfPath:(int)pathNumber toIndex:(int)idx;// jg added
- (int)workLocus;
- setRiemannLocusOf:(int)pathNumber to:(int)locus;
- setWorkLocus:(int)locus;
- retainWorkLocus;
- resetWorkLocusToSupportStart;
- calcThirdStreamList;
- (double)calcRiemannValueAtFunction:(int)function andTonic:(int)tonic;
- (double)calcRiemannValueAtLocus:(int)locus;
- (double)riemannAtLocus:(int)locus;
- calcRiemannMatrix;
/* Noll Methods */
- (double)calcNollRiemannValueAtFunction:(int)function andTonic:(int)tonic 
			genericWeight:(double ***)nollRiemannWeight;

- (double)maxRiemannValue;
- calcLevelMatrixWithLevel:(double)level;
- (double)levelAtFunction:(int)function andTonality:(int)tonality;
- setLevel:(double)level atFunction:(int)function andTonality:(int)tonality;
- (double)levelAtLocus:(int)locus;
- (double)levelAtPath:(int)pathNumber;
- (double)maxLevel;

- restrictLevelMatrixTo:(int)tonalities :(int)modeFunctions;
- restrictLevelMatrixAtFunction:(int)function andTonality:(int)tonality;
- restrictLevelMatrixAtLocus:(int)locus;

- (int)supportCard;
- (int)supportStart;
/* returns the next locus with non-vanishing level value; or 72 if it is the last or 72 */
- (int)nextSupportIndexTo:(int)index;
- (BOOL)maxSupportIndexAt:(int)index;
/* checks whether work index is maximal support */
- (BOOL)maxWorkSupportIndex;
- (int)calcSupportStart;
- (int)tonicAt:(int)index;
- (int)modeAt:(int)index; // not used anywhere
- (int)modelessFunctionAt:(int)index; // not used anywhere
- (int)functionAt:(int)index; // used instead

/* relative weights of tones of a chord */
- (double)relativeWeightOfTone:(int)toneIndex atLocus:(int)locus;
- (BOOL)isWeightCalculated;

/*best weight management*/
- (double)bestWeight;
- setBestWeight:(double)weight;
		
/* relative weights of tones of a chord */
- (double)relativeWeightOfTone:(int)toneIndex atLocus:(int)locus;

// additionals
- (NSString *)pitchListString; // as integers separated by ","
- (NSString *)pitchListStringWithPitchFormat:(NSString *)pf delimiter:(NSString *)delimiter asInt:(BOOL)asInt;
- (NSString *)pitchClassNameForIndex:(int)idx;
- (NSString *)functionNameForIndex:(int)idx;
- (NSString *)locusNameForIndex:(int)index;
- (NSString *)bestLocusName;
- (int)locusCount;
- (int)tonalityCount;
- (int)functionCount;

- (double **)riemannMatrix;
- (double **)levelMatrix;
@end

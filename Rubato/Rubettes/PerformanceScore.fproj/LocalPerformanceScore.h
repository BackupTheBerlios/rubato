/* LocalPerformanceScore.h */

//jg 30.10.00 #import <objc/HashTable.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubato/inspectorkit.h>

#import <Rubato/RubatoTypes.h>
#import <Rubette/MatrixEvent.h>
#import "LPSInitialSet.h"

#define Hierarchy_Size 64
#define FRAME_ORIGIN 0
#define FRAME_END 1

@interface LocalPerformanceScore:JgRefCountObject <Inspectable>
{
/*The inheritance references*/
    id	myName;		/*StringConverter object for user defined names*/
    id	myMother;	/*the creator LPS of this LPS*/
    id	myDaughters;    /* a List object */
    id	myInstrument;	/* Instrument object, whatsoever */

    id myInitialSet;	 /*InitialSet object*/

    BOOL myHierarchy[Hierarchy_Size];/*The local hierarchy*/
    
    LPS_Frame myFrame[MAX_SPACE_DIMENSION];


    id	myKernel;	/* list of predicates contained by kernel */
    id	myPerformanceKernel;/* performed Kernel events*/
    id	myPerformanceTable;/* hash table with key:sybolic value:performed events*/ // jg:now NSMutableDictionary
    BOOL isCalculated;
    id	curEvent;
    double curField[MAX_SPACE_DIMENSION];
    int myPerformanceDepth;


}

/* standard class methods to be overridden */
+ (void)initialize;

/* get the operator's nib file */
+ (NSString *)inspectorNibFile;

/* standard object methods to be overridden */
- init;
- initWithLPSFrame:(LPS_Frame *)aFrame;
- initWithLPSFrame:(LPS_Frame *)aFrame andBPInitialSetWithBasisSpace:(spaceIndex)basisSpace;
- (void)dealloc;
- copyWithZone:(NSZone*)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- setNameString: (const char *)aName;
- (const char *)nameString;
- getNameString;

/* get the operator's nib file */
- (NSString *)inspectorNibFile;

- setMother:aMother;/*can only be done once*/
- mother;

- operator;

- setOperatorIndex:(int)index;
- (int)operatorIndex;

- setInstrument:anInstrument;
- instrument;

- setKernel:aKernel;
- kernel;

- setFrame:(LPS_Frame *)aFrame at:(int)index;
- (LPS_Frame *)frameAt:(int)index;
- (LPS_Frame *)frame;
- setFrameOrigin:(double)aDouble at:(int)index;
- setFrameEnd:(double)aDouble at:(int)index;
- (double)frameOriginAt:(int)index;
- (double)frameEndAt:(int)index;
- setEdge:(int)edge ofFrameAt:(int)index to:(double)aDouble;
- (double)edge:(int)edge ofFrameAt:(int)index;
- (BOOL)frameContains:anEvent;
- extendFrameTo:anObject;
- extendFrameToInitialSet:anInitialSet;
- extendFrameToSimplex:aSimplex;
- extendFrameToKernel: aKernel;
- extendFrameToEvent:anEvent;
- resetFrameToKernel:aKernel;

/* InitialSet and Hierarchy access and maintenance */
//- adapt:initialSet; /* adaptation resp. restriction to a frame */
- setInitialSet:anInitialSet;
- initialSet;

- setHierarchy:(BOOL *)aHierarchy;
- (BOOL *) hierarchy;
- (BOOL)containsDefaultInitialSet:anInitialSet;
- setHierarchyAt:(int)index to:(BOOL)flag;
- (BOOL)hierarchyAt:(int)index;
- (spaceIndex)hierarchyTop; /*defines the top spaceIndex of the hierarchy*/
- (BOOL)hierarchyTopAt:(int)index;

- (spaceIndex)hierarchyClosureOfSpace:(spaceIndex)aSpace; /* get the smallest hierarchy index containing the index aSpace */
- (spaceIndex)hierarchyInteriorOfSpace:(spaceIndex)aSpace;
- (spaceIndex)fundamentOfSpace:(spaceIndex)aSpace;
- (BOOL)hasReducibleSpace:(spaceIndex)aSpace;
- (BOOL)isFundamentalSpace:(spaceIndex)aSpace;
- (BOOL)isDecomposableSpace:(spaceIndex)aSpace;

/* access to performance kernel */
- performanceKernel;
- setPerformanceDepth:(int)depth;
- (int)performanceDepth;

/*access & creation of daughters*/
- (int)daughterCount;
- daughterAt:(int)index;
- makeDaughterWithOperator:anOperator;
- mutateWithOperator:anOperator;
- abandonDaughter:aDaughter;
- killDaughter:aDaughter;

/*get the string representation of the operator*/
- (const char*)operatorString;

/* PERFORMANCE FIELD CALCULATION
 * Calculate the performance field components of this LPS/operator, 
 * to be implemented specifically, including events not in the total space!
 * For events not in the hierarchy spaces, the values go back to the mother©s values,
 * for the hierarchic ones, the component has to be implemented specifically.
 */
/* maintain calc optimization */
- (BOOL) calculateForEvent:anEvent;
- (int)hashTableSize;
- insertKeyEvent:keyEvent andPerformance:perfEvent;
- (void)invalidate;
- validate;
- (BOOL)isCalculated;

/* Calculate the Field of a LPS */
- (double *) performanceFieldPointerAt:anEvent;
- performanceFieldAt:anEvent;
/* below is the field calculation method to be overridden by subclasses */
- calcPerformanceField:(double *)field at:anEvent;
- (double) calcFieldComponent:(int)index at:anEvent;

/* Calculate the performed events of a LPS */
- performedEventAt:anEvent;
- (double) calcEventComponent:(int)index at:anEvent;

/* calculate the performed events of a LPS */
- initialSetPerformanceOfEvent:anEvent andInitialSet:anInitialSet;

/* Finds all leaves of the subtree defined by myRootLPS and searchDepth */
- collectLeavesAt:(int)depth;
- collectLeaves;
- makePerformedLPSList;

/* The heavy work: create the performance elements of myPerformanceKernel */
- doPerform; //integration of myField, symbEvent, and myInitialSet

@end
/* Weight.h */

#import <Foundation/NSObject.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubato/Inspectable.h>

#import <Rubato/RubatoTypes.h>
#import "MatrixEvent.h"
#import "SpaceProtocol.h"

#define MIN_VAL 0.00001

@interface Weight:JgObject <SpaceProtocol, RefCounting, Inspectable>
{
//    int myRefCount;
    id myParameterTable;
    id myParameterObject;
    id myParameterObjectBundles;
    id myWeightEvents;	/* this means myWeight list */ // Pairs of the form (Event,Weight)
    spaceIndex mySpace;					// defines with Bitvector the subset from EHLDGC
    
    id myBDWeight; /* a Weight for boiled down weight calculation */

    double myMinWeight;
    double myMaxWeight;
    double myMeanWeight;
    double myStartNorm;
    double myRange;
    double myTolerance;  // Width of margin of the Field. Outside the margin:1

    id myConverter;
}

/* standard class methods to be overridden */
+ (void)initialize;

/* get the operator's nib file */
+ (NSString *) inspectorNibFile;

/* standard object methods to be overridden */
- init;
- (void)dealloc;
- copyWithZone:(NSZone*)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

/* get the operator's nib file */
- (NSString *) inspectorNibFile;

/* Access to instance variables */
- setNameString: (const char *)aName;
- (const char *)nameString;
- (NSString *)name; // jg added

- setRubetteName: (const char *)aName;
- (const char *)rubetteName;

- setLowNorm:(double)aDouble;
- (double) lowNorm;

- setHighNorm:(double)aDouble;
- (double) highNorm;

- setRange:(double)aDouble;
- (double) range;

- setTolerance:(double)aDouble;
- (double) tolerance;

- (void)invert;
- setInversion:(BOOL)flag;
- (BOOL)isInverted;

- (double)originAt:(int)index;
- (double)endAt:(int)index;

/* Access to ParameterTable which lead to the weight */
- setParameter:(const char*)paraName toStringValue:(const char*)paraVal;
- setParameter:(const char*)paraName toIntValue:(int)paraVal;
- setParameter:(const char*)paraName toDoubleValue:(double)paraVal;
- setParameter:(const char*)paraName toBoolValue:(BOOL)paraVal;
- setParameter:(const char*)paraName toMatrix:aMatrix;
- setParameterObject:anObject requiredBundles:bundles;
- makeParametersUnique;
- (int)needsBundles:(char *)bundles;
- removeParameter:(const char*)paraName;
- removeParameterObject;
- (const char*)stringValueOfParameter:(const char*)paraName;
- (int)intValueOfParameter:(const char*)paraName;
- (double)doubleValueOfParameter:(const char*)paraName;
- (BOOL)boolValueOfParameter:(const char*)paraName;
- getParameter:(const char*)paraName forMatrix:aMatrix;
- parameterObject;
- writeParametersToString:(NSMutableString *)toString;
- readParameterObject:(NSCoder *)stream;
- writeParameterObject:(NSCoder *)stream;

/* Access to myWeightEvents */
-(unsigned int)count;
- eventAt:(unsigned int)index;
- (double)weightAt:(unsigned int)index;
- addWeight:(double)aWeightValue at:(double)E:(double)H:(double)L:(double)D:(double)G:(double)C;
- addWeight:(double)aWeightValue atEvent:anEvent;
- addEvent:anEvent;
- removeEvent:anEvent;

/* weight maintenance methods */
- (double)maxWeight;
- (double)minWeight;
- (double)meanWeight;
- (double)calcMaxWeight;
- (double)calcMinWeight;
- (double)calcMeanWeight;
- sort;

/* Get normalized weights */
- (double)normWeightAt:(unsigned int)index;
- (double)meanNormalizedWeight;


/* One and two dim. splines */
- (double)splineAt:anEvent;

/* boiled down weight */ // creates a new autoreleased instance
- bDWeightTo:(int)index;

/* boiled down splines */
- (double)bDSplineTo:(int)index at:anEvent;


/* partial derivatives of one or two dim. splines */
- (double)partial:(unsigned int)index ofSplineAt:anEvent;

/* One dim. cubic spline */
- (double)cubeSplineAt:anEvent;

/* partial derivatives techniques in dim one */
/*Derivation of cubic spline with tol etc. on the boundary*/
- (double)dCubeSplineAt:anEvent;

/* A better 2-dimensional technique for interpolations of degree 3 and extendable to any dimenson */
/* calculation of maximal an minimal second coordinates in a 2-dim weight */
- (double)maxCoordinate:(int)aCoordinate;
- (double)minCoordinate:(int)aCoordinate;

/* Here, anEvent is an object of the weight, i.e. a matrix of a priori dimension 2 */
- (double)twoDSplineAt:anEvent;

/* Partial derivatives of 2D splines.*/
- (double)partial:(unsigned int)index twoDSplineAt:anEvent;
/* deformation sensitive splines and their derivatives; deformation = 0 is the default (linear) setting */
/* deformation of splineAt:anEvent */
- (double)splineAt:anEvent deformation:(double)deformation;
- (double)splineAt:anEvent lowNorm:(double)loNorm highNorm:(double)hiNorm tolerance:(double)tolerance inversion:(BOOL)flag deformation:(double)deformation;
/* deformation of bdSplineTo:anEvent */
- (double)bDSplineAt:anEvent to:(int)index deformation:(double)deformation;
- (double)bDSplineAt:anEvent to:(int)index lowNorm:(double)loNorm highNorm:(double)hiNorm tolerance:(double)tolerance inversion:(BOOL)flag deformation:(double)deformation;
/* partial of deformation of splineAt:anEvent */
- (double)partial:(unsigned int)index ofSplineDeformationAt:anEvent:(double)deformation;
- (double)partial:(unsigned int)index ofSplineAt:anEvent lowNorm:(double)loNorm highNorm:(double)hiNorm tolerance:(double)tolerance inversion:(BOOL)flag deformation:(double)deformation;
@end

/* Simplex.h */

#import <Foundation/NSObject.h>
#import <Rubato/RubatoTypes.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>

//#import <MathMatrixKit/MathMatrix.h>
#import <Rubette/SpaceProtocol.h>


@interface Simplex:JgObject <SpaceProtocol>
{
    spaceIndex mySpace; /* should be the space of the points */
    //int myDimension; /* should be the number of columns - 1 */
    id myPoints; 	/* the 1 x (myDimension+1) matrix of matrix events 
		    (=the coefficients = columns, everything nicely dressed) */
    BOOL myRegularity; /* YES if the points are in general affine position */
    double myNeighborhood; /* a neighborhood for approximation purposes, also codified as doubleValue of myPoints */
    
    /* Instance variables for optimated calculation */
    id	curEvent; /* the event for which the last calcultation was done */
    id	curOrthoBaryCoord;
    id	curSimplexComponent;
    id	curOrthoComponent;
    id	curMinimalPoint;
}

/* Special Class methods */
+ simplexOfLineIn:aDirection from:anEvent;

/* standard object methods to be overridden */
- init;
- initWithSpace:(spaceIndex)aSpace andDimension:(unsigned int)aDimension;
- (void)dealloc;
- copyWithZone:(NSZone*)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

// access variables
- (id) curMinimalPoint;
- (void) setCurMinimalPoint:(id)newCurMinimalPoint;


/* space control */
- (int)simplexDimension;
- (int)rank;
- (BOOL)regularity;
- setRegularity:(BOOL)flag;
- (double)neighborhood;
- setNeighborhood:(double)aNeighborhood;


/* Simplex point access */
- insertPoint:aPoint at:(int)index;
- replacePointAt:(int)index with:aPoint;
- removePointAt:(int)index;
- addPoint:aPoint;
- pointAt:(int)index;
- face:(unsigned int)index;
- setDoubleValue:(double)aValue ofPointAt:(int)pointIndex atIndex:(int)index;
- (double) doubleValueOfPointAt:(int)pointIndex atIndex:(int)index;

/* maintain calc optimization */
- (BOOL) calculateForEvent:anEvent;

/* the following methods are introduced from HitPointMethoden.m */
/* returns the column matrix with the coefficients ot the simplex points yielding the
event©s orthogonal decomposition component coefficients of the simplex points */
- orthoBaryCoordinatesOf:anEvent;
/* returns the simplex MatrixEvent for the orthoBaryCoordinates */
- simplexComponentOf:anEvent;
- orthogonalComponentOf:anEvent;
- (BOOL)contains:anEvent; /* Simplex method to decide whether a simplex contains an event */

/* advanced methods */

- minimalSimplexPointTo:anEvent; /* 	gives a Point within the (here possibly degenerate!) 
					simplex with minimal distance to anEvent, as being 
					expressed in barycentric coordinates, together with the distance to
					anEvent fixed on the doubleValue! */


- (BOOL) isVeryNearTo:anEvent;
- (double)cosineFactorOf:anEvent in:aDirection;
- minimalSimplexPointTo:anEvent in:aDirection;
- (double)minimalSimplexParameterTo:anEvent in:aDirection;


@end

@interface Simplex (SpaceProtocolMethods)
/* overridden SpaceProtocolMethods */
- (spaceIndex)space;
- setSpaceAt:(int)index to:(BOOL)flag;
- setSpaceTo:(spaceIndex)aSpace;

@end

/* MatrixEvent.h */

#import <MathMatrixKit/mathmatrixkit.h>

#import <Rubato/RubatoTypes.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import "SpaceProtocol.h"


@interface MatrixEvent:MathMatrix <SpaceProtocol>
{
    spaceIndex mySpace;	//space of the event
    id mySatellites;	//List of this event's satellite events
}

/* special class methods */
+ newFromPointer:(double *)eventPointer withSpace:(spaceIndex)aSpace;

/* standard object methods to be overridden */
- init;
- initRows:(int)rowCount Cols:(int)colCount andValue:(double)value withCoefficients:(BOOL)cFlag;
- initIdentityMatrixOfWidth:(int)width;
- initElementaryMatrixWithRows:(int)rowCount Cols:(int)colCount andValue:(double)value at:(int)row:(int)col;

- initWithSpace:(spaceIndex)aSpace;
- initWithSpace:(spaceIndex)aSpace andValue:(double)value;
/* Transform a pointer into a MatrixEvent, the converse is makePointer method */
- initFromPointer:(double *)eventPointer withSpace:(spaceIndex)aSpace;

- (void)dealloc;
- (id)copyWithZone:(NSZone*)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (BOOL)isEqual:anObject;
- (unsigned int)hash;

/* special Matrix copying and conversion */
- (id)cloneFromZone:(NSZone*)zone;
- (selfvoid)setToMatrix:aMatrix;
- (selfvoid)setToCopyOfMatrix:aMatrix;
- (selfvoid)setToEmptyCopyOfMatrix:aMatrix;

/* overridden MathMatrix methods */
- (void)insertRow:aRow at:(int)row;
- (BOOL)removeRowAt:(int)row;

/* emancipative Matrix Operation Methods */
- XresultClass;
//- XscaleWith:(double)scalar;
//- XsumWith:aMatrix;
//- XdifferenceTo:aMatrix;
- XproductWith:aMatrix;
- XpowerOfExponent:(int)exp;
- XtaylorOfExponent:(int)exp;

- Xadjoint;
- Xinverse;
- XaffineDifference;
- XquadraticForm;

/* Additional Matrix access */
- (int)rowAt:(int)index;
- (double) doubleValueAtIndex:(int)index;
- (void)setDoubleValue:(double)aValue atIndex:(int)index;

/* satellites access */
- satellites;

/* Special event calculation */
/* destructive calculation methods */
- (selfvoid)shiftBy:anEvent;
- (void)scaleBy:(float)scalar;
- (selfvoid)transformBy:aMatrix;
- (selfvoid)transformBy:aMatrix andShiftBy:anEvent;
- (double)norm;
/* productive calculation methods */
- projectTo:(spaceIndex)aSpace;
- injectInto:(spaceIndex)aSpace;
- parajectTo:(spaceIndex)aSpace;
- alterateAt:(int)basisIndex :(int)pianolaIndex;
- alterate;

/* conversion into pointer for RKF integration */
- (double *)makePointer;

- simplexOfLineIn:aDirection;

/* Ordering protocol methods */
- (BOOL)largerThan:anObject; 
- (BOOL)smallerThan:anObject; 

/*logically redundant but not as methods */
- (BOOL)smallerEqualThan:anObject;
- (BOOL)largerEqualThan:anObject;
@end

@interface MatrixEvent (SpaceProtocolMethods)
/* overridden SpaceProtocolMethods */
- setSpaceAt:(int)index to:(BOOL)flag;
- setSpaceTo:(spaceIndex)aSpace;

@end

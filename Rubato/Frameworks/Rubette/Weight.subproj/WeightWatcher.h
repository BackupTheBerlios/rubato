/* WeightWatcher.h */

#import <Foundation/NSObject.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import "SpaceProtocol.h"

#define MIN_VAL 0.00001

// for LPS
@protocol LPSProtocol
- (int)daughterCount;
- (id)daughterAt:(int)index;
- (id)weightWatcher;
- (void)weightWatcherChanged;
@end

@interface WeightWatcher:JgObject <SpaceProtocol>
{
    id<LPSProtocol> myLPS;
    id myWatchList;
    double *myBaryWeights;
    double *myDeformations;
    double *myLoNorms;
    double *myHiNorms;
    double *myTolerances;
    BOOL   *myInvertFlags;
    BOOL   myProductFlag;
}

/* standard class methods to be overridden */
+ (void)initialize;

/* standard object methods to be overridden */
- init;
- (void)dealloc;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- setOwnerLPS:aLPS;
- ownerLPS;

- addWeightObject:aWeight;
- removeWeightObjectAt:(unsigned int)index;
- weightObjectAt:(int)index;

- (unsigned int)count;

- setLowNorm:(double)aDouble at:(int)index;
- (double) lowNormAt:(int)index;

- setHighNorm:(double)aDouble at:(int)index;
- (double) highNormAt:(int)index;

- setRange:(double)aDouble at:(int)index;
- (double) rangeAt:(int)index;

- setInversion:(BOOL)flag at:(int)index;
- (BOOL) isInvertedAt:(int)index;

- setProduct:(BOOL)flag;
- (BOOL) isProduct;

- setTolerance:(double)aDouble at:(int)index;
- (double) toleranceAt:(int)index;

- (spaceIndex)space;

- (double)baryWeightAt:(unsigned int)index;
- (double)deformationAt:(unsigned int)index;
- setBaryWeight:(double)bary at:(unsigned int)index;
- setDeformation:(double)deform at:(unsigned int)index;

/* spline methods */
- (double)weightSumAt:anEvent;
- (double)weightBDSumIn:(int)index at:anEvent;
- (double)partial:(int)index ofWeightSumAt:anEvent;

/* gradient of a weight function */
- gradientAt:anEvent;


@end

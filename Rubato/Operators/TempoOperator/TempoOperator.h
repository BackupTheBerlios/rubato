/* TempoOperator.h */

#import <PerformanceScore/GenericFieldOperator.h>


#define realIntegration 1
#define realAdaptIntegration 4
#define approxIntegration 2
#define approxAdaptIntegration 3


@interface TempoOperator:GenericFieldOperator
{
    double myAverageTempo; /* tells which tempo should be the average in case of no adaptation */
    //BOOL myAdaptation; /* tells whether we want to adapt to given tempo */
    double myAdaptationFrame[2]; /* tells the time limits to adapt to given tempo */
    int myIntegrationSteps; /* number of subdivisions of the integration interval */
    int myApproximationSteps; /* tells how often the approximation should be tried */
    double myScaleValue; /* gives information about error relative to mother©s duration */
    BOOL isScaleCalculated; /* controls calculation of myScaleValue */
    int	myIntegrationMethod; /* selection of the calculation metod */
    id	myCurrentOrigin; /* is the frame origin per default, and the onsetEvent for successful hit events */
    id	myCurrentOriginSimplex; /* a moving simplex of the last calculated onset for optimization */
    double myCurrentOriginPerformance; /* is the performance onset of myCurrentOriginValue */
}

/* standard class methods to be overridden */
+ (void)initialize;

/* get the operator's nib file */
+ (NSString *)inspectorNibFile;

/*apply operator on a LPS*/
+ apply:applicator to:anLPS;
+ applicatorClass;

- init;
- (void)dealloc;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (double)averageTempo;
- setAverageTempo:(double)tempo;

- (double)adaptationFrameStart;
- (double)adaptationFrameEnd;
- setAdaptationFrameAt:(int)index to:(double)value;

- (int)integrationSteps;
- setIntegrationSteps:(int)steps;

- (int)approximationSteps;
- setApproximationSteps:(int)approx;

- (int)integrationMethod;
- setIntegrationMethod:(int)aMethod;

- calcScale;
- (double)scale;
- (double)error;

- currentOriginSimplex;

- onsetEvent:(double)E;

/* suppose that weightwatcher has weightBDSumIn:(spaceIndex)aSpace At:anEvent (=Boiled Down to aSpace) ! */
- (double)approxIntegralFor:(double)scaling;
/* the following is the successive approximation to a set of boundary values 
from the initial sets on E */ 
- (double)approximationWeightAt:anEvent;

- (double)approxIntegralAt:anEvent;

/* suppose that weightwatcher has weightBDSumIn:(spaceIndex)aSpace At:anEvent (=Boiled Down to aSpace) ! */
- calcPerformanceField:(double *)field at:anEvent;

/*Calculate the performed events of a LPS*/
- (double) calcEventComponent:(int)index at:anEvent;

/* the real component calulation is that inherited from the generic field operator! */
- (double) calcAdaptEventComponent:(int)index at:anEvent;

/* calculus of the E component of an onsEvent (living in E-space) */
- onsetComponentOf:onsEvent;

/* calculus of the E component of an onset */
- onsetComponentOfOnset:(double)onset;

/*overrides the generic method*/
- calcInitPerfOfEvent:anEvent atCustomInitialSet:anInitialSet;

/* combines the initialSetPerformance and the mother©s performance */
- performanceOfEvent:anEvent andInitialSet:anInitialSet;

- doPerform;

/* maintain calc optimization */
- invalidate;

@end
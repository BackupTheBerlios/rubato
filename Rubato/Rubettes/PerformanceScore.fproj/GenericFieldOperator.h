/* GenericFieldOperator.h */

#import "GenericSplitter.h"
#import "Simplex.h"
#import <Rubette/splines.h>
#include <math.h>

// defined on OSX in AppKit.p
//#define INFINITY HUGE_VAL
//old: #define INFINITY	0x7fffffff /*from file bsd/sys/vlimit.h */

# define eventOf(hitObj) 	[hitObj objectAt:0]
# define distanceOf(hitObj)	[[hitObj objectAt:1] doubleValueAt:0]
# define successOf(hitObj) 	[[hitObj objectAt:1] doubleValueAt:1]
# define timeOf(hitObj) 	[[hitObj objectAt:1] doubleValue]

# define eventAt(index) 	[[hitList objectAt:(index)] objectAt:0]
# define distanceAt(index) 	[[[hitList objectAt:(index)] objectAt:1] doubleValueAt:0]
# define successAt(index) 	[[[hitList objectAt:(index)] objectAt:1] doubleValueAt:1]
# define timeAt(index) 		[[[hitList objectAt:(index)] objectAt:1] doubleValue]

#ifdef SETERELEASE
// replaceObjectAtIndex released sowieso schon "ob". Alte Version:
//# define setE(hitObj,event) 	{id ob=[hitList objectAt:0];[hitObj replaceObjectAt:0 with:event]; [ob release]; }
# define setE(hitObj,event) 	{id ob=[hitList objectAt:0];[hitObj replaceObjectAt:0 with:event]; }
#else
# define setE(hitObj,event) 	[hitObj replaceObjectAt:0 with:event]; 
#endif
# define setD(hitObj,distance)	[[hitObj objectAt:1] setDoubleValue:distance at:0]
# define setS(hitObj,success) 	[[hitObj objectAt:1] setDoubleValue:success at:1]
# define setT(hitObj,time) 	[[hitObj objectAt:1] setDoubleValue:time]

# define CALC_SUCCESS		0.0	/* successful integration */
# define CALC_ABORT		1.0	/* aborting before integrating (not used while integrating) */		
# define CALC_HIT_FAILURE	2.0	/* aborting by hit failure	(not used while integrating) */	
# define CALC_OVERFLOW		3.0	/* too many function calls */
# define CALC_TOLERANCE_ERROR	4.0	/* tolerance is too tight */
# define CALC_ACCURACY_ERROR	5.0	/* accuracy is too demanding */
# define MOTHER_SUCCESS_OK    - 2.0	/* Mother's calculation successful */

// for debugging
@interface NSObject (NoRelease)
- (void)norelease;
@end

@interface GenericFieldOperator:GenericSplitter
{
    double myAbsIntegrationError; /*absolute field intgration error tolerance*/ 
    double myRelIntegrationError; /*relative field intgration error tolerance*/
    double myMachineEpsilon; /*the machine epsilon, default = 20.0e-16*/
    unsigned int myCmax; /* max. number of calculation steps default = 1000 */
    unsigned int myLimit; /* calculation limit for nearest point search on integral curve */
    id	myAbortedKernel;/* Kernel events which did not match integration, i.e. success > 0.0 */
    unsigned int myHashHits;
    unsigned int myCalcCount;
    unsigned int myHitPointCalls;
    double myMesh; /* first approximation grid mesh */
    BOOL doBackwardTimeGuess;
    BOOL doForwardTimeGuess;

@private
    id	curInitialSet;
    id	curFlatInitialSet;

}

/* Make sure that the creation of this daughter first of all specifically adjusts its hierarchy !! */

/* standard class methods to be overridden */
+ (void)initialize;

/*apply operator on a LPS*/
+ apply:applicator to:anLPS;

/* standard object methods to be overridden */
- init;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

/* integration errors and calculation constants management */

- setAbsIntegrationError:(double)anAbsError;
- (double)absIntegrationError;

- setRelIntegrationError:(double)aRelError;
- (double) relIntegrationError;

- setMachepsilon:(double)anEpsilon;
- (double) machEpsilon;

- setCmax:(unsigned int)aCmax;
- (unsigned int) Cmax;

- setLimit:(unsigned int)aLimit;
- (unsigned int) limit;

- abortedKernel;
- (int)hashHits;
- (int)calcCount;
- (int)hitPointCalls;

- (double) mesh;
- setMesh:(double)mesh;
- setDoBackwardTimeGuess:(BOOL)flag;
- (BOOL)doBackwardTimeGuess;
- setDoForwardTimeGuess:(BOOL)flag;
- (BOOL)doForwardTimeGuess;
- (double)guessTimeFrom:anEvent to:aSimplex with:(double)aMesh;

/* Spline method giving event on spline curve at time t */

- splineFrom:start :startField :(double)startTime 
	To:end :endField :(double)endTime
	at:(double)time;

/* space of daughter from this operator */
- (spaceIndex) space;


- (double *)performanceFieldPointerAt:(double *)eventPointer on:(spaceIndex)aSpace;


/* stepwise rungeKuttaFehlbergIntegrate, including  
 * integral as first, error as second half 
 * and end time as end entry of the pointer.
 */
- (double *)rKF_IntegrateWithErrorAndTime:(unsigned int)n
					:(double)t0
					:(double)h
					:(double*)x0
					:(spaceIndex)space
					:(double *)dy;

/*	CALC_SUCCESS		0.0	successful integration */
/*	CALC_ABORT		1.0	aborting before integrating (not used while integrating) */		
/*	CALC_HIT_FAILURE	2.0	aborting by hit failure	(not used while integrating) */	
/*	CALC_OVERFLOW		3.0	too many function calls */
/*	CALC_TOLERANCE_ERROR	4.0	tolerance is too tight */
/*	CALC_ACCURACY_ERROR	5.0	accuracy is too demanding */

- (double *)integrateFieldFrom:anEvent at:(double)parameterValue;


- hitPointFromEvent:anEvent onSimplex:aSimplex;
- hitPointFromEvent:anEvent projection:proEvent closure:cloEvent onSimplex:aSimplex atTime:(double)time iterations:(unsigned int)aLimit;
/* a genericFieldOperator method !, 
 * myNeighborhood (double > 0) is an instance variable of Simplex class.
 * Here, anEvent is in  the LPS kernel, but the return hitPoint vector
 * is in the simplex space! This is necessary because the
 * simplex may not be in a factor of the performance field of
 * the LPS. We suppose that anEvent lives in superspace of
 * simplexSpace and of its hierarchy closure.
 * [anEvent projectTo:simplexSpace] is the projection to the simplex
 * space;
 * [anEvent projectTo:[anLPS hierarchyClosureOfSpace:simplexSpace]]
 * is the projection to the closure of the simplex space within 
 * anLPS.
 */

/* The - calcInitPerfOfEvent:atInitialSet: is the standard behaviour 
 * for default initialSet. It first calls the custom method 
 * - calcInitPerfOfEvent:atCustomInitialSet: which is to be 
 * implemented by the concrete operators.
 */
- calcInitPerfOfEvent:anEvent atInitialSet:anInitialSet;
- calcInitPerfOfEvent:anEvent atCustomInitialSet:anInitialSet;

- (double) calcEventComponent:(int)index at:anEvent;

/* success calculation at anEvent, initial set space iSpace, success array  successIndex*/
- (BOOL)successCheckAt:anEvent:(spaceIndex)iSpace:(double *)successIndex;

/* calculate the performed events of a LPS */
/* order is NEW May 20 1996 */
/* to be overridden by subclass operators */
- (int *)orderForInitialSet:anInitialSet andEvent:anEvent;

/* returns a MatrixEvent, success is codified on the event©s doubleValue! */
- initialSetPerformanceOfEvent:anEvent andInitialSet:anInitialSet;

/* combines the initialSetPerformance and the mother©s performance */
- performanceOfEvent:anEvent andInitialSet:anInitialSet;

/* create myPerformanceKernel and abortedKernel, overrides the doPerform method in LPS */
- doPerform;

/* maintain calc optimization */
- (void)invalidate;
- validate;

@end

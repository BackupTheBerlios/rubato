/* TempoOperator.m */

#import "TempoOperator.h"
#import "TempoOperatorApplicator.h"
#import <float.h>
#import <Rubette/splines.h>
#import <Rubette/MatrixEvent.h>
#import <Rubette/WeightWatcher.h>


#define myAdaptation	((myIntegrationMethod==approxAdaptIntegration) || (myIntegrationMethod==realAdaptIntegration))
#define oriE [self adaptationFrameStart]
#define endE [self adaptationFrameEnd]
#define max(A,B) ((A)>(B)?(A):(B))
#define min(A,B) ((A)<(B)?(A):(B))


@implementation TempoOperator

/* standard class methods to be overridden */
+ (void)initialize;
{
    [super initialize];
    if (self == [TempoOperator class]) {
	[TempoOperator setVersion:1];
    }
}


/* get the operator's nib file */
+ (NSString *)inspectorNibFile;
{
    return @"TempoOperatorInspector.nib";
}




/*apply operator on a LPS*/
+ apply:applicator to:anLPS;
{
    int index;
    id daughter, initialSet;
    
    if([anLPS hierarchyAt:E_space] && [anLPS hierarchyAt:ED_space]){
	[super apply:applicator to:anLPS];
    
	/* definition of the InitialSet of for the daughters */
	for (index=0; index<[anLPS daughterCount]; index++) {
	    daughter = [anLPS daughterAt:index];
	    initialSet = [LPSInitialSet newBPSetForLPS:daughter atIndex:indexE];
	    
	    [[initialSet setInitialSet:
		[[[LPSInitialSet alloc]init] setSimplex:
		    [[[Simplex alloc]initWithSpace:E_space andDimension:0] setDoubleValue:
			[daughter frameOriginAt:indexE]ofPointAt:0 atIndex:indexE]] at:2]
			    setInitialSet:[LPSInitialSet newDefaultInitialSetForLPS:daughter] at:3];
	    
	    [daughter extendFrameToInitialSet:initialSet];
	    [daughter setInitialSet:initialSet];
	    [daughter setAdaptationFrameAt:0 to:[daughter frameOriginAt:indexE]];
	    [daughter setAdaptationFrameAt:1 to:[daughter frameEndAt:indexE]];
	    
	    [[[initialSet initialSetAt:0]simplex]setNeighborhood:[applicator simplexNeighborhoodAt:0]];
	    [[[initialSet initialSetAt:1]simplex]setNeighborhood:[applicator simplexNeighborhoodAt:1]];
	    [[daughter currentOriginSimplex] setNeighborhood:[applicator simplexNeighborhoodAt:2]];
	}
    }
    return self;
}


+ applicatorClass;
{
    return [TempoOperatorApplicator class];
}


- init;
{
    [super init];
    
    doForwardTimeGuess = NO;
    //[self setInitialActivationAt:indexE to:YES];
    //[self setFinalActivationAt:indexE to:YES];
    myCalcDirection = ED_space;
    myAverageTempo = 1.0;
    //myAdaptation = YES;
    //myInitialReference = YES;
    //myFinalReference = YES;
    myAdaptationFrame[0] = DBL_MIN;
    myAdaptationFrame[1] = DBL_MAX;
    myIntegrationSteps = 100;
    myApproximationSteps = 20;
    myIntegrationMethod = realIntegration; 
    myScaleValue = 1.0;
    isScaleCalculated = NO;
    myCurrentOrigin = [self onsetEvent:myFrame[indexE].origin];
    myCurrentOriginPerformance = 0.0; 
    myCurrentOriginSimplex = [[Simplex alloc]initWithSpace:E_space andDimension:0]; 
    [myCurrentOriginSimplex replacePointAt:0 with:myCurrentOrigin]; /* insert THIS event */
    [myCurrentOrigin retain]; /* do the referencing now, so we keep an actual pointer to it */
    /* in fact this is DANGEROUS, but we do for the sake of speed */
    
    return self;
}

- (void)dealloc;
{
    /* do NXReference houskeeping */

    /* class-specific initialization goes here */
    [myCurrentOriginSimplex release];
    [myCurrentOrigin release];
    [super dealloc];
}


- (id)initWithCoder:(NSCoder *)aDecoder;
{
    int classVersion = [aDecoder versionForClassName:NSStringFromClass([TempoOperator class])];
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    myCurrentOriginSimplex = [[aDecoder decodeObject] retain];
    myCurrentOrigin = [[[aDecoder decodeObject] retain] ref];
    
    [aDecoder decodeValuesOfObjCTypes:"diidcid", &myAverageTempo,
				&myIntegrationSteps,
				&myApproximationSteps,
				&myScaleValue,
				&isScaleCalculated,
				&myIntegrationMethod,
				&myCurrentOriginPerformance];
				
    if (classVersion)
	[aDecoder decodeValuesOfObjCTypes:"dd", &myAdaptationFrame[0],
				&myAdaptationFrame[1]];
    
    myCalcDirection = ED_space;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myCurrentOriginSimplex];
    [aCoder encodeConditionalObject:myCurrentOrigin];
    
    [aCoder encodeValuesOfObjCTypes:"diidcid", &myAverageTempo,
				&myIntegrationSteps,
				&myApproximationSteps,
				&myScaleValue,
				&isScaleCalculated,
				&myIntegrationMethod,
				&myCurrentOriginPerformance];
    
    [aCoder encodeValuesOfObjCTypes:"dd", &myAdaptationFrame[0],
				&myAdaptationFrame[1]];
}
- (double)averageTempo;
{
    return myAverageTempo;
}


- setAverageTempo:(double)tempo;
{
    if(tempo && myAverageTempo!=tempo) {
	myAverageTempo = fabs(tempo);
	[self invalidate];
    }

    return self;
 }

- (double)adaptationFrameStart;
{
    return myAdaptationFrame[0];
}

- (double)adaptationFrameEnd;
{
    return myAdaptationFrame[1];
}

- setAdaptationFrameAt:(int)index to:(double)value;
{
    if(!index && myAdaptationFrame[1]> value) {
	myAdaptationFrame[0] = value;
	[self invalidate];
    }
    
    if(1 == index && myAdaptationFrame[0]<value) {
	myAdaptationFrame[1] = value;
	[self invalidate];
    }

    return self;
}



- (int)integrationSteps;
{
    return myIntegrationSteps;
}


- setIntegrationSteps:(int)steps;
{
    if(steps && myIntegrationSteps!=steps) {
	myIntegrationSteps = (int)fabs(steps);
	[self invalidate];
    }

    return self; /* does not change the given steps if steps is set to zero */
}


- (int)approximationSteps;
{
    return myApproximationSteps;
}

- setApproximationSteps:(int)approx;
{
    if(approx && myApproximationSteps!=approx) {
	myApproximationSteps = (int)fabs(approx);
	[self invalidate];
    }
    return self; /* does not change the given approx if approx is set to zero */
}


- (int)integrationMethod;
{
    return myIntegrationMethod;
}

- setIntegrationMethod:(int)aMethod;
{
    if (aMethod!=myIntegrationMethod) {
	switch(aMethod) {
	    case realIntegration:
	    case realAdaptIntegration:
	    case approxIntegration:
	    case approxAdaptIntegration:
		myIntegrationMethod = aMethod;
		break;
	    default:
		;
	}
	[self invalidate];
    }
    return self;
}

- calcScale;
{
    if (!isScaleCalculated) {
	id event = nil;
	double  motherDuration, scaling = 1.0;
    
	event = [self onsetEvent:endE]; //autoreleased
	motherDuration = [myMother calcEventComponent:indexE at:event];
        [event setDoubleValue:oriE at:0];
	motherDuration -= [myMother calcEventComponent:indexE at:event];
    
//	[event release];
    
	if(motherDuration){        
	    int i;
	    for(i=0;i<myApproximationSteps; i++){
		double val = [self approxIntegralFor:scaling];
		scaling *= val/motherDuration;
		}
	}
	if(scaling)
	    myScaleValue = scaling; /* Do not allow this instance variable to vanish */
	
	isScaleCalculated = YES;
    }
    
    return self;
}

- (double)scale;
{
    return myScaleValue;
}


- (double)error;/*NEU*/
{
    if (isScaleCalculated) {
	id event = nil;
	double  motherDuration;

        event = [self onsetEvent:endE];//autoreleased
	motherDuration = [myMother calcEventComponent:indexE at:event];
        [event setDoubleValue:oriE at:0];
	motherDuration -= [myMother calcEventComponent:indexE at:event];
//	[event release];
    
	if(motherDuration)
	    return -1.0+([self approxIntegralFor:myScaleValue]/motherDuration);
    }
    return 123.0;
} 

- currentOriginSimplex;
{
    return myCurrentOriginSimplex;
}



- onsetEvent:(double)E;
{
    MatrixEvent *ev=[[[MatrixEvent alloc] init]setSpaceAt:indexE to:YES];
    [ev setDoubleValue:E at:0];
    [ev autorelease];
    return ev;
} 


/* suppose that weightwatcher has weightBDSumIn:(spaceIndex)aSpace At:anEvent (=Boiled Down to aSpace) ! */
- (double)approxIntegralFor:(double)scaling;
{
    double result = 0.0; 
    if(scaling){
	int i;
      id evt1=[self onsetEvent:oriE], evt2=[self onsetEvent:oriE], event;//autoreleased//autoreleased
	double  step = (endE-oriE)/(double)myIntegrationSteps, /* by construction, zero denominator impossible */
		valueStart, valueEnd;

	event = evt1;
	valueEnd = [myMother calcFieldComponent:indexE at:event];
	for(i=0; i<myIntegrationSteps; i++){
	    double  onsiplus = oriE+step*(i+1),
		    vali;
		    event = evt1==event ? evt2: evt1;
		    [event setDoubleValue:onsiplus at:indexE];
		    vali = (i+1<myIntegrationSteps ? scaling*[myWeightWatcher weightBDSumIn:indexE at:
	    			event] : 1.0);
	    valueStart = valueEnd;
	    valueEnd =  [myMother calcFieldComponent:indexE at:event]*vali;
    
	    result += reciproc(onsiplus-step, onsiplus, valueStart, valueEnd);
	}
//	[evt1 release];
//	[evt2 release];
    }
    return result;
}


/* the following is the successive approximation to a set of boundary values 
from the initial sets on E; uses some C code from splines.c */ 
- (double)approximationWeightAt:anEvent;
{
    if(myAdaptation){
	[self calcScale];

    return 	1 + support(oriE, endE, myIntegrationSteps,[anEvent doubleValueAt:0])*
		    (myScaleValue*[myWeightWatcher weightBDSumIn:indexE at:anEvent] - 1);
    }
    else
    return [myWeightWatcher weightBDSumIn:indexE at:anEvent];
}


- (double)approxIntegralAt:anEvent;
{
    int i;
    double  ORIE = [self frameOriginAt:indexE],
	    ENDE = [self frameEndAt:indexE];
    id event = [self onsetEvent:ORIE];//autoreleased
    double  step = (ENDE-ORIE)/(double)myIntegrationSteps, /* by construction, zero denominator impossible */
	    valueStart = [self approximationWeightAt:event], 
	    motherResult = [myMother calcEventComponent:indexE at:event],
	    result = motherResult, 
	    valueEnd = valueStart,
	    onset = [anEvent doubleValueAtIndex:indexE];
    
    for(i=0; i<myIntegrationSteps && ORIE+step*(i+1)<=onset; i++){
	valueStart = valueEnd;
        [event setDoubleValue:ORIE+step*(i+1) atIndex:indexE];
	valueEnd =  [self approximationWeightAt:event];
    
	result += reciproc(ORIE+step*i, ORIE+step*(i+1), valueStart, valueEnd);
	}
    [event setDoubleValue:onset atIndex:indexE];
    result += reciproc(ORIE+step*i, onset, valueEnd, [self approximationWeightAt: event]); 

    if(!myAdaptation && myAverageTempo)
	result = motherResult +(result-motherResult)/myAverageTempo;

//    [event release];
    return result;
}



/* suppose that weightwatcher has weightBDSumIn:(spaceIndex)aSpace At:anEvent (=Boiled Down to aSpace) ! */
- calcPerformanceField:(double *)field at:anEvent;
{
    double approxWeight;
   
    if(
	[self hierarchyAt:E_space] && /* only if tempo field does exist */
	[anEvent spaceAt:indexE] /* event should have onset */ 
	){
	if (!myAdaptation)
	    field[0] *= myAverageTempo;
	
	approxWeight = [self approximationWeightAt:anEvent];
	
	field[0] *= approxWeight;
    
	if([self hierarchyAt:ED_space] &&
	    [anEvent spaceAt:indexD] /*the event has D*/
	    ) {
	    int dDim = [anEvent dimensionOfIndex:indexD]-1;
	    id alterateEvent = [[anEvent alterateAt:indexE:indexD]ref];

	    if (!myAdaptation)
		field[dDim] *= myAverageTempo;

	    field[dDim] = (field[dDim] + field[0]) * [self approximationWeightAt:alterateEvent] 
			    - field[0] * approxWeight;
	    [alterateEvent release];
	}
    }
	
    return self;
} 


/*Calculate the performed events of a LPS*/

- (double) calcEventComponent:(int)index at:anEvent;
{
    switch (myIntegrationMethod) {
	case approxIntegration: case approxAdaptIntegration:
	    return [self calcAdaptEventComponent:index at:anEvent];
    }
    return [super calcEventComponent:index at:anEvent];
}

/* the real component calculation is that inherited from the generic field operator! */
- (double) calcAdaptEventComponent:(int)index at:anEvent;
{
    /* this is a tangent bundle automorphism method avoiding new field integration caluclations*/

    if((index != indexE && index != indexD) || [self operatorIndex] != 1) /* remainderDaughter */

	return [myMother calcEventComponent:index at:anEvent];

    else{/* first transform the event by the tempo simulation under the approximated weight */
	id trafoEvent = [[anEvent clone]ref],
	   alterateEvent = [[anEvent alterateAt:indexE:indexD]ref];

	double  newOnset = [self approxIntegralAt:anEvent],
		newDuration = [self approxIntegralAt:alterateEvent] - newOnset,
		value;
	[alterateEvent release];

	if(myAdaptation){    
	    /* the followig should also yield the correct result in case, no D exists */
            [trafoEvent setDoubleValue:	newOnset atIndex:indexE];
	    [trafoEvent setDoubleValue: newDuration atIndex:indexD];
	    value = [myMother calcEventComponent:index at:trafoEvent];
	}

	else if(index == indexE)
	    value = newOnset;

	else
	    value = newDuration;
	
    	[trafoEvent release];
	return value;
    }
}

/* calculus of the E component of an onsEvent (living in E-space) */
- onsetComponentOf:onsEvent;
{
    id perf = nil;
    if([self hierarchyAt:E_space]){
	perf=[(id)[myPerformanceTable objectForKey:onsEvent]clone];
	if (!perf) {
	    double para, onsVal = [onsEvent doubleValueAtIndex:indexE];
	    id hitObject;
    
	    if (([onsEvent doubleValueAtIndex:indexE]-myFrame[indexE].origin)
		    <([myCurrentOrigin doubleValueAtIndex:indexE]-myFrame[indexE].origin)/2) {
		/* reset the simplex if it is beyond the onsEvent */
		[myCurrentOrigin setDoubleValue:myFrame[indexE].origin atIndex:indexE];
		myCurrentOriginPerformance = [myMother calcEventComponent:indexE at:myCurrentOrigin]; 
	    }
	    hitObject = [[self hitPointFromEvent:onsEvent onSimplex:myCurrentOriginSimplex]ref];
	    if (successOf(hitObject)==CALC_SUCCESS) {
		para = timeOf(hitObject);
		onsVal = myCurrentOriginPerformance - para;
		if((para=[onsEvent doubleValueAtIndex:indexE])>[myCurrentOrigin doubleValueAtIndex:indexE]){
		    [myCurrentOrigin setDoubleValue:para atIndex:indexE];
		    myCurrentOriginPerformance = onsVal;
		}
	    }
	    perf = [self onsetEvent:onsVal];// autoreleased
	    [perf setDoubleValue:successOf(hitObject)];
	    [self insertKeyEvent:onsEvent andPerformance:perf];
	    [hitObject release];
    
	}
	else 
	    myHashHits++;
    }
    return perf;
}

/* calculus of the E component of an onset */
- onsetComponentOfOnset:(double)onset;
{
    id onEvt, val = nil;
    if([self hierarchyAt:E_space]){
      onEvt = [self onsetEvent:onset];//autoreleased
	val = [self onsetComponentOf:onEvt];
//	[onEvt release];
    }
    return val;
}


/*overrides the generic method*/
- calcInitPerfOfEvent:anEvent atCustomInitialSet:anInitialSet;
{ 
    spaceIndex 	evtSpace = [anEvent space],
		simpSpace = [anInitialSet space];
    if(evtSpace == simpSpace){
		id compEvent = nil,
		    perfEvent = nil;

	if(simpSpace == ED_space){/*horizontal simplex or vertical one */
	    perfEvent = [anEvent clone], /* just make a copy! */

	    compEvent = [[self onsetComponentOfOnset:[anEvent doubleValueAtIndex:indexE]]ref];
	    [perfEvent setDoubleValue:[compEvent doubleValueAtIndex:indexE] atIndex:indexE];
	    [perfEvent setDoubleValue:[compEvent doubleValue]];
	    [compEvent release];
	
	if(![perfEvent doubleValue]) { /* only calc second component if success */
	    compEvent = [[self onsetComponentOfOnset:[anEvent doubleValueAtIndex:indexE]+[anEvent doubleValueAtIndex:indexD]]ref];
	    [perfEvent setDoubleValue:[compEvent doubleValueAtIndex:indexE]-[perfEvent doubleValueAtIndex:indexE] atIndex:indexD];
	    [perfEvent setDoubleValue:[compEvent doubleValue]];
	    [compEvent release];
	    }
	}

	if(simpSpace == E_space){/*origin*/ 
	    perfEvent = [anEvent clone], /* just make a copy! */
	    compEvent = [[self onsetComponentOfOnset:[anEvent doubleValueAtIndex:indexE]]ref];
	    [perfEvent setDoubleValue:[compEvent doubleValueAtIndex:indexE] atIndex:indexE];
	    [perfEvent setDoubleValue:[compEvent doubleValue]];
	    [compEvent release];
	    }
    return perfEvent; 
    }
    return nil;
}


/* combines the initialSetPerformance and the mother©s performance */
- performanceOfEvent:anEvent andInitialSet:anInitialSet;
{
    id perf = nil;
    if (myIntegrationMethod == realIntegration|| myIntegrationMethod == realAdaptIntegration) {
	perf = [super performanceOfEvent:anEvent andInitialSet:anInitialSet];
    } else {
	int index;
	perf = [anEvent clone];
	for (index=0; index<MAX_SPACE_DIMENSION; index++) {
	    if ([anEvent spaceAt:index])
		[perf setDoubleValue:[self calcAdaptEventComponent:index at:anEvent] atIndex:index];
	}
    }
    return perf;
}

- doPerform;
{
    if (!isCalculated) {
	[myCurrentOrigin setDoubleValue:myFrame[indexE].origin atIndex:indexE];
	myCurrentOriginPerformance = [myMother calcEventComponent:0 at:myCurrentOrigin];
	
	[self calcScale];
	[super doPerform];
    }
    return self;
}

- invalidate;
{
    [super invalidate];
    isScaleCalculated = NO;
    
    return self;
}
@end

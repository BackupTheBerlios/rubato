/* GenericFieldOperator.m */

#import "GenericFieldOperator.h"
#import <Rubette/space.h>
#import <RubatoDeprecatedCommonKit/ProgressPanel.h>
#import <RubatoDeprecatedCommonKit/JgOwner.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSApplication.h>
#import <float.h>

NSMutableDictionary *noReleaseDictionary;

// for debugging
@implementation NSObject (NoRelease)
- (void)norelease;
{
  NSValue *key;
  NSNumber *value;
  long c;

  if (!noReleaseDictionary)
    noReleaseDictionary=[[NSMutableDictionary alloc] init];
  key=[NSValue valueWithNonretainedObject:self];
  value=[noReleaseDictionary objectForKey:key];
  if (value)
    c=[value longValue];
  else
    c=0;
  c++;
  value=[NSNumber numberWithLong:c];
  [noReleaseDictionary setObject:value forKey:key];
}
@end

@implementation GenericFieldOperator

/* standard class methods to be overridden */
+ (void)initialize;
{
    [super initialize];
    if (self == [GenericFieldOperator class]) {
	[GenericFieldOperator setVersion:3];
    }
}


/*apply operator on a LPS*/
+ apply:applicator to:anLPS;
{
    int index;
    id daughter, initialSet;
    
    [super apply:applicator to:anLPS];

    /* definition of the InitialSet of for the daughters */
    for (index=0; index<[anLPS daughterCount]; index++) {
	daughter = [anLPS daughterAt:index];
	initialSet = [[LPSInitialSet newDefaultInitialSetForLPS:daughter] wrapSelfInList];
	[daughter extendFrameToInitialSet:initialSet];
	[daughter setInitialSet:initialSet];
    }
        
    return self;
}

/* standard object methods to be overridden */
- init;
{
    [super init];
    myAbsIntegrationError = 1.0e-5;
    myRelIntegrationError = 1.0e-9;
    myMachineEpsilon = 20.0e-16;
    myCmax = 1000;
    myLimit = 1000;
    myAbortedKernel = [[RefCountList alloc]init];
    myHashHits = 0;
    myCalcCount = 0;
    myHitPointCalls = 0;
    myMesh = 0.01;
    doBackwardTimeGuess = YES;
    doForwardTimeGuess = YES;
    return self;
} 

- (id)initWithCoder:(NSCoder *)aDecoder;
{
//    NXHashState aState;
    id aKey;
    id aVal;
    int classVersion = [aDecoder versionForClassName:NSStringFromClass([GenericFieldOperator class])];
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    if (classVersion > 1) {
	/* get rid of the myPerformanceTable created by super */
        [myPerformanceTable release]; // jg was: [[myPerformanceTable freeObjects] release]; 
	myPerformanceTable = [[aDecoder decodeObject] retain];
    }
    
    myAbortedKernel = [[aDecoder decodeObject] retain];
    
    if (!classVersion) {
	/* convert the old List objects to
	 * RefCounList or OrderedList objects
	 */
	id abortedKernel = myAbortedKernel;
	myAbortedKernel = [[[[OrderedList alloc]initCount:
	    [abortedKernel count]]appendList:abortedKernel]sort];
	[abortedKernel release];
    }

    [aDecoder decodeValuesOfObjCTypes:"dddd", &myAbsIntegrationError,
				&myRelIntegrationError,
				&myMachineEpsilon,
				&myMesh];
    
    [aDecoder decodeValuesOfObjCTypes:"IIIII",&myCmax,
				&myLimit,
				&myHashHits,
				&myCalcCount,
				&myHitPointCalls];
    
    
    if (classVersion>2) {
	[aDecoder decodeValuesOfObjCTypes:"cc", &doBackwardTimeGuess,
				  &doForwardTimeGuess];
    } else {
	doBackwardTimeGuess = YES;
	doForwardTimeGuess = YES;
    }
    /* set Reference Counting of read or replaced objects */
    [myAbortedKernel ref];
    // jg is this still necessary in the new version???
/*was
    aState = [myPerformanceTable initState];
    while([myPerformanceTable nextState:&aState key:&aKey value:&aVal]) {
	[(id)aKey ref];
	[(id)aVal ref];
    }
*/  { NSEnumerator *enumerator=[myPerformanceTable keyEnumerator];
      while  ((aKey = [enumerator nextObject])) {
        aVal=[myPerformanceTable objectForKey:aKey];
        [(id)aKey ref];
        [(id)aVal ref];
      }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    NSEnumerator *enumerator;//    NXHashState aState;
    id aKey;
    id aVal;
    id performanceTable = myPerformanceTable;
    
    [super encodeWithCoder:aCoder];
    
    /* prepare the performanceTable for archiving */
    if ([myPerformanceTable count]>[myPerformanceKernel count]*3) {
	/* archive kernel table only if size of PerformanceTable 
	 * exceeds 3 times the size of the PerfromanceKernel
	 */
    performanceTable = [[NSMutableDictionary alloc] initWithCapacity:[myPerformanceKernel count]+1];
           // jg was:[[HashTable alloc]initKeyDesc:"@" valueDesc:"@" capacity:[myPerformanceKernel count]+1];
/*	aState = [myPerformanceTable initState];
	while([myPerformanceTable nextState:&aState key:&aKey value:&aVal]) {
	    if ([myKernel indexOfObject:(id)aKey]!=NSNotFound)
		[performanceTable insertKey:aKey value:aVal];
	}
*/
        enumerator=[myPerformanceTable keyEnumerator];
        while((aKey = [enumerator nextObject])) {
          if ([myKernel indexOfObject:(id)aKey]!=NSNotFound) {
            aVal = [myPerformanceTable objectForKey:aKey];
            [performanceTable setObject:aVal forKey:aKey];
          }
       }
    }
    
    [aCoder encodeObject:performanceTable];
    if (performanceTable != myPerformanceTable)
	[performanceTable release];
    
    [aCoder encodeObject:myAbortedKernel];
    
    [aCoder encodeValuesOfObjCTypes:"dddd", &myAbsIntegrationError,
				&myRelIntegrationError,
				&myMachineEpsilon,
				&myMesh];
    
    [aCoder encodeValuesOfObjCTypes:"IIIII", &myCmax,
				&myLimit,
				&myHashHits,
				&myCalcCount,
				&myHitPointCalls];
				
    [aCoder encodeValuesOfObjCTypes:"cc",  &doBackwardTimeGuess,
				&doForwardTimeGuess];
}

/* integration errors and calculation constants management */

- setAbsIntegrationError:(double)anAbsError;
{
    anAbsError = fabs(anAbsError);
    if (myAbsIntegrationError != anAbsError) {
	myAbsIntegrationError = anAbsError;
	[self invalidate];
    }
    return self;
}

- (double)absIntegrationError;
{
    return myAbsIntegrationError;
}

- setRelIntegrationError:(double)aRelError;
{
    aRelError = fabs(aRelError);
    if (myRelIntegrationError != aRelError) {
	myRelIntegrationError = aRelError;
	[self invalidate];
    }
    return self;
}

- (double) relIntegrationError;
{
    return myRelIntegrationError;
}

- setMachepsilon:(double)anEpsilon;
{
    anEpsilon = fabs(anEpsilon);
    if (myMachineEpsilon != anEpsilon) {
	myMachineEpsilon = anEpsilon;
	[self invalidate];
    }
    return self;
}


- (double) machEpsilon;
{
    return myMachineEpsilon;
}


- setCmax:(unsigned int)aCmax;
{
    if (myCmax != aCmax) {
	myCmax = aCmax;
	[self invalidate];
    }
    return self;
}


- (unsigned int) Cmax;
{
    return myCmax;
}


- setLimit:(unsigned int)aLimit;
{
    if (myLimit != aLimit) {
	myLimit = aLimit;
	[self invalidate];
    }
    return self;
}


- (unsigned int) limit;
{
    return myLimit;
}

- abortedKernel;
{
    return myAbortedKernel;
}

- (int)hashHits;
{
    return myHashHits;
}

- (int)calcCount;
{
    return myCalcCount;
}

- (int)hitPointCalls;
{
    return myHitPointCalls;
}


- (double) mesh;
{
    return myMesh;
}

- setMesh:(double)mesh;
{
    if(mesh) {
	mesh = fabs(mesh); 
	if (myMesh != mesh) {
	    myMesh = mesh;
	    [self invalidate];
	}
    }
    return self;
}

- setDoBackwardTimeGuess:(BOOL)flag;
{
    doBackwardTimeGuess = flag;
    return self;
}

- (BOOL)doBackwardTimeGuess;
{
    return doBackwardTimeGuess;
}

- setDoForwardTimeGuess:(BOOL)flag;
{
    doForwardTimeGuess = flag;
    return self;
}

- (BOOL)doForwardTimeGuess;
{
    return doForwardTimeGuess;
}

- (double)guessTimeFrom:anEvent to:aSimplex with:(double)aMesh;
{
    int i, clodim;
    double  bestTime = 0, time = 0, delta = 1, bestDist, dist, maxComp = 0, iComp, *field;
    spaceIndex simplexSpace, cloSpace;
    id  evt = nil;

    simplexSpace = [aSimplex space];
    dist = [[aSimplex minimalSimplexPointTo:[anEvent projectTo:simplexSpace]] doubleValue];
    bestDist = dist;

    cloSpace = [self hierarchyClosureOfSpace:simplexSpace];
    
    if(doBackwardTimeGuess) {
	/* FIRST: back propagation optima bestDist and bestTime */
	evt = [[anEvent projectTo:cloSpace]retain];
	clodim = [evt dimension];
	field = [self performanceFieldPointerAt:evt];
	
	
	do{
	    /* define new evt projection distance from aSimplex */
	    dist = [[aSimplex minimalSimplexPointTo:[evt projectTo:simplexSpace]] doubleValue];
	    
	    if(dist<bestDist){
		bestDist = dist;
		bestTime = time;
	    }
    
	    /* define new field at evt */
	    free(field);
	    field = [self performanceFieldPointerAt:evt];
    
    
	/* calculate maximal field component and value maxComp */
	    maxComp = field[0];
	    for(i = 1; i<clodim; i++){
		iComp = field[i];
	
		if(fabs(iComp) > fabs(maxComp))
		    maxComp = iComp;
	    }
    
	    if(maxComp)
		delta = aMesh/maxComp;
    
	    time -= delta;
	    
	    /* define new evt */
	    for(i=0; i<clodim; i++){
		double evi = [evt doubleValueAt:i];
		[evt setDoubleValue:evi - delta*field[i] at:i];
		}
    
	}while([self frameContains:evt]);
	
	[evt release];
	free(field);
    }
    
    if (doForwardTimeGuess) {
	/* SECOND: forward propagation optima bestDist and bestTime */
    
	/* reset of evt, field and time */
	evt = [[anEvent projectTo:cloSpace]retain];
	clodim = [evt dimension];
	field = [self performanceFieldPointerAt:evt];
	time = 0;
	
	do{
	    /* define new evt projection distance from aSimplex */
	    dist = [[aSimplex minimalSimplexPointTo:[evt projectTo:simplexSpace]] doubleValue];
	    
	    if(dist<bestDist){
		bestDist = dist;
		bestTime = time;
	    }
    
	    /* define new field at evt */
	    free(field);
	    field = [self performanceFieldPointerAt:evt];
    
    
	/* calculate maximal field component and value maxComp */
	    maxComp = field[0];
	    for(i = 1; i<clodim; i++){
		iComp = field[i];
	
		if(fabs(iComp) > fabs(maxComp))
		    maxComp = iComp;
	    }
    
	    if(maxComp)
		delta = aMesh/maxComp;
    
	    time += delta;
	    
	    /* define new evt */
	    for(i=0; i<clodim; i++){
		double evi = [evt doubleValueAt:i];
		[evt setDoubleValue:evi + delta*field[i] at:i];
		}
    
	}while([self frameContains:evt]);
	
	[evt release];
	free(field);
    }
    
     
    return bestTime;  
}


/* Spline method giving event on spline curve at time t, start etc. end are matrix events */

- splineFrom:start :startField :(double)startTime 
	To:end :endField :(double)endTime
	at:(double)time;
{
    int i;
    id result;
    // jg why ref, then release?
    [start ref];
    [startField ref];
    [end ref];
    [endField ref];

    result = [start clone];
    for(i=0; i<[start rows]; i++)
	    [result setDoubleValue:
	    		spline(	[start doubleValueAt:i],[startField doubleValueAt:i],	startTime,
	    			[end doubleValueAt:i],	[endField doubleValueAt:i],	endTime,
				time)
	    at:i];
    /* free objects that were not referenced before */
    [start release];
    [startField release];
    [end release];
    [endField release];
    return result;
}



/* space of daughter from this operator */
- (spaceIndex) space;
{
    return (spaceIndex)[[self adjustHierarchy] hierarchyTop]; 
    /*Possibly the "adjust" part is not necessary if adjustment is guaranteed by the birth of this daughter*/
}



- (double *)performanceFieldPointerAt:(double *)eventPointer on:(spaceIndex)aSpace;
{
    id event = [MatrixEvent newFromPointer:eventPointer withSpace:aSpace];
    double *field = [self performanceFieldPointerAt:event]; /* also frees the event */
    return field;
}


/* stepwise rungeKuttaFehlbergIntegrate, including  
			integral as first,
			error as second half 
			and end time as end enrty of the pointer */
- (double *)rKF_IntegrateWithErrorAndTime:(unsigned int)n
					:(double)t0
					:(double)h
					:(double*)x0
					:(spaceIndex)space
					:(double *)dy;
{

    int         i;
    double      kh,
		*x1,
		*y1,
		*y2,
		*y3,
		*y4,
		*y5;

						/* allocate first work array */
    x1 = calloc(2*n+1, sizeof(double));
    
    kh = 0.25 * h;
    for(i = 0; i < n; ++i) {
	x1[i] = x0[i] + kh * dy[i];
    }

    y1 = [self performanceFieldPointerAt:x1 on:space];

    kh = 9.375e-2 * h;
    for(i = 0; i < n; ++i) {
	x1[i] = x0[i] + kh * (dy[i] + 3.0 * y1[i]);
    }

    y2 = [self performanceFieldPointerAt:x1 on:space];

    kh = h / 2.197;
    for(i = 0; i < n; ++i) {
	x1[i] = x0[i] + kh * (1.932 * dy[i] + (7.296 * y2[i] - 7.2 * y1[i]));
    }

    y3 = [self performanceFieldPointerAt:x1 on:space];

    kh = h / 41.04;
    for(i = 0; i < n; ++i) {
	x1[i] = x0[i] + kh * ((83.41 * dy[i] - 8.45 * y3[i]) + (294.4 * y2[i] - 328.32 * y1[i]));
    }

    y4 = [self performanceFieldPointerAt:x1 on:space];

    kh = h / 20.52;
    for(i = 0; i < n; ++i) {
	x1[i] = x0[i] + kh * ((-6.08 * dy[i] + (9.295 * y3[i] - 5.643 * y4[i])) + (41.04 * y1[i] - 28.352 * y2[i]));
    }
    y5 = [self performanceFieldPointerAt:x1 on:space];
						/* Compute solution: first half of pointer */
    kh = h / 76.1805;
    for(i = 0; i < n; ++i) {
	x1[i] = x0[i] + kh * ((9.0288 * dy[i] + (38.55735 * y3[i] - 13.71249 * y4[i]))
			     + (39.53664 * y2[i] + 2.7702 * y5[i]));
    }
						/* Compute error estimate: second half of pointer  */
    kh = h / 752.4;
    for(i = 0; i < n; ++i) {
	x1[n+i] = kh * ((2.09 * dy[i] + (15.048 * y4[i] - 21.97 * y3[i])) + (27.36 * y5[i] - 22.528 * y2[i]));
    }
    
    x1[2*n] = t0 + h;

    /* free work arrays */
    free(y1);
    free(y2);
    free(y3);
    free(y4);
    free(y5);


    return x1;

}

/* This is a method using instance variables
 * (double)myAbsIntegrationError		(will be positive, possible via fabs())
 * (double)myRelIntegrationError		(will be positive, possible via fabs())
 * (double)myMachineEpsilon 		(U26-machine epsilon, default  = 20.0e-16)
 * (unsigned int)myCmax			(max number of function calls, default = 1000)
 *
 * CALC_SUCCESS		0.0	successful integration
 * CALC_ABORT		1.0	aborting before integrating (not used while integrating)		
 * CALC_HIT_FAILURE	2.0	aborting by hit failure	(not used while integrating)
 * CALC_OVERFLOW		3.0	too many function calls
 * CALC_TOLERANCE_ERROR	4.0	tolerance is too tight
 * CALC_ACCURACY_ERROR	5.0	accuracy is too demanding
 */

- (double *)integrateFieldFrom:anEvent at:(double)parameterValue;
{

    int		i,
		hok,
		dercalls = 0,
		out = 0,
		dim;
    double	step,
		toler,
		minstep,
		dt,
		t,
		tstart = 0,
		error,
		temp,
		normy0;
    double	*eventPointer,
		*dy,
		*z,
		*x, /* result */
    		*rKF_I; /* stepwise result */
    spaceIndex	eventSpace = [anEvent space];
						/* allocate work arrays */
    myCalcCount++;
    eventPointer = [anEvent makePointer];
    dim = [anEvent dimension];
/* dy = calloc(dim, sizeof(double)); is allocated below via performanceFieldPointerAt: */
    z = calloc(dim, sizeof(double));	
    x = calloc(dim+1, sizeof(double)); /*last entry controls the success of integration */
    dt = parameterValue;
    
    /* initialize start x from the event */
    for(i=0;i<dim;i++)
	x[i] = eventPointer[i];
    x[dim] = CALC_SUCCESS; /* successful integration */



    if(!dt){		/* Start equal to end */
	free(eventPointer);
	free(z);

    return x;
    }

    else{

    dy = [self performanceFieldPointerAt:anEvent];

						/* Calculate the initial tolerance and step size */
    toler = myRelIntegrationError * maxNorm(dim, eventPointer) + myAbsIntegrationError; /* maxNorm in splines.c */
    step = fabs(dt);
    normy0 = maxNorm(dim, dy);
    if(toler < normy0 * pow(step, 5.0)) {
	step *= myMachineEpsilon;
	temp = pow((toler / normy0), 0.2);
	step = MAX(step,temp);
    }
						/* Make sure we're stepping in the right direction. */
    if(dt < 0.0) {
	step = -step;
    }
						/* Loop until we integrate from tstart to parameterValue. */

    do {					/* while !out */
	hok = 1;
	minstep = myMachineEpsilon * fabs(tstart);
	dt = parameterValue - tstart;
						/* adjust step size to hit right on end point */
	if(fabs(dt) < 2.0 * fabs(step)) {
	    if(0.9 * fabs(dt) > fabs(step)) {
		step = 0.5 * dt;
	    }
	    else {
		out = 1;
		step = dt;
	    }
	}
						/* integrate over one step */
	do {					/* while error > toler  */

	    if(dercalls > myCmax) {
		x[dim] = CALC_OVERFLOW;
		free(eventPointer);
		free(z);
		free(dy);
	    return x;			/* too many function calls */
	    }

	    rKF_I = [self rKF_IntegrateWithErrorAndTime:dim:tstart:step:eventPointer:eventSpace:dy];
	    t = rKF_I[2*dim];

	    for(i=0; i<dim; i++){
		x[i] = rKF_I[i];
		z[i] = rKF_I[i+dim];
	    }
	    
	    dercalls += 5;
						/* check tolerance */
	    toler = 0.5 * (maxNorm(dim, eventPointer) + maxNorm(dim, x)) *
		    myRelIntegrationError + myAbsIntegrationError;
	    if(toler == 0.0) {
		x[dim] = CALC_TOLERANCE_ERROR;
		free(eventPointer);
		free(z);
		free(dy);
		free(rKF_I);
	    return x;			/* tolerance is too tight */
	    }
						/* If last step was unsuccessful, reduce step size and try again */
	    error = maxNorm(dim, z);
	    if(error >= toler) {
		hok = 0;
		out = 0;
		if(error >= 5.9049e4 * toler) {
		    step *= 0.1;
		}
		else {
		    step = 0.9 * step / pow((error / toler), 0.2);
		}
		if(fabs(step) <= minstep) {
		    x[dim] = CALC_ACCURACY_ERROR;
		    free(eventPointer);
		    free(z);
		    free(dy);
		    free(rKF_I);
		    return x;			/* accuracy is too demanding */
		}
	    }

	} while(error > toler);
			/* Last step was successful; store results and go on to next step */
	tstart = t;
	for(i = 0; i < dim; ++i) {
	    eventPointer[i] = x[i];
	}
	/* recalculate the field at new point */
	free(dy);
	dy = [self performanceFieldPointerAt:eventPointer on:eventSpace];

	++dercalls;
	if(hok) {
	    if(error <= 1.889568e-4 * toler) {
		temp = 5;
	    }
	    else {
		temp = exp(0.2 * log(0.9 * toler / error));
	    }
	    temp *= fabs(step);
	    if(minstep > temp) {
		temp = minstep;
	    }
	    step = (step >= 0 ? temp : -temp);
	}

    } while(!out);

    free(eventPointer);
    free(dy);
    free(z);
    free(rKF_I);
    return x;

    }
}





- hitPointFromEvent:anEvent onSimplex:aSimplex;
{
    id hitObject = nil, proEvent = nil, cloEvent = nil;
    spaceIndex simplexSpace = 0, cloSpace = 0;
    int index;
    double iTime, startTime=0.0, aMesh=DBL_MAX;
    
    [anEvent retain];
    
    simplexSpace = [aSimplex space];
    cloSpace = [self hierarchyClosureOfSpace:simplexSpace];
    
    if (!isSubSubspace(simplexSpace, cloSpace, [anEvent space])) {
	[anEvent release];
	return nil; /* emergency exit if spaces do not match */
    }
    
    if (NO) { static int lauf=0; // jgdebug
      lauf++;
      printf("Lauf %d simplexSpace %d\n",lauf,simplexSpace);
      if((lauf==14)||(lauf==19))
        printf("%d\n",[anEvent retainCount]); // break here
    }
    proEvent = [[anEvent projectTo:simplexSpace]ref];
    cloEvent = [[anEvent projectTo:cloSpace]ref];

    for (index=indexE; index<MAX_SPACE_DIMENSION; index++){
	if ([cloEvent spaceAt:index]) {
	    double val;
	    val = fabs(([cloEvent doubleValueAtIndex:index]-myFrame[index].origin)/2);
	    aMesh = val && val<aMesh ? val : aMesh;
	    val = fabs(([cloEvent doubleValueAtIndex:index]-myFrame[index].end)/2);
	    aMesh = val && val<aMesh ? val : aMesh;
	}
    }
    startTime = [aSimplex minimalSimplexParameterTo:proEvent 
	in:[[self performanceFieldAt:cloEvent] projectTo:simplexSpace]];
    
    hitObject = [self hitPointFromEvent:anEvent projection:proEvent closure:cloEvent
		    onSimplex:aSimplex atTime:startTime iterations:myLimit]; // with retain!
    
    while (successOf(hitObject) && aMesh>=myMesh) {
	iTime = [self guessTimeFrom:anEvent to:aSimplex with:aMesh];
	if (iTime!=startTime) {
	    [hitObject freeObjects];
	    [hitObject release];
	    hitObject = [self hitPointFromEvent:anEvent projection:proEvent closure:cloEvent 
			    onSimplex:aSimplex atTime:iTime iterations:myLimit];
	}
	startTime = iTime;
	aMesh *= 0.5;
    }
    
    [anEvent release];
    [proEvent release];
    [cloEvent release];
    return hitObject;
}


- hitPointFromEvent:anEvent projection:proEvent closure:cloEvent onSimplex:aSimplex atTime:(double)time iterations:(unsigned int)aLimit;
// jg: this hardly is maintanable!
// the returnvalue has a retain count of 1, so the caller should dispose it.
// I see great improvement in code with NEWRETAINSCHEME: arguments need not be released anymore.
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
{
    int i,j, k, clodim, minIndex, maxIndex;
    spaceIndex simplexSpace, cloSpace;
    double distance, iTime, iDistance,  diff, dist;
    double *pointer = (double *)nil;
    id 	zeroHitPoint = nil, zabriskiPoint = nil, oneHitPoint = nil, 
    	hitList = nil, outputMatrix = nil, 
	iEvent = nil, curvePt = nil, fieldAti = nil;

    if (!isSubSubspace([proEvent space], [cloEvent space], [anEvent space]))
	return nil; /* emergency exit if spaces do not match */
	
    [anEvent ref];
    [proEvent ref];
    [cloEvent ref];

    simplexSpace = [aSimplex space];
    cloSpace = [self hierarchyClosureOfSpace:simplexSpace];
    clodim = [cloEvent dimension];
    myHitPointCalls++;

    distance = [[aSimplex minimalSimplexPointTo:proEvent] doubleValue];   

/*
 * first entry		for hit point, a MatrixEvent, 
 * second entry		the 2 x 1 outputMatrix,
 * first coeff.		for distance, 
 * second coeff. 	for success control,
 * value		for curve parameter of hit
 */
			    
	
	/* hitPoint of index 0 on hitList */

	outputMatrix = [[MathMatrix alloc] initRows:1 Cols:2 andValue:0 withCoefficients:YES];
	[outputMatrix setDoubleValue:distance at:0];
	[outputMatrix setDoubleValue:CALC_SUCCESS at:1];/* default is success, what an optimism! */
			
	zeroHitPoint = [[[[RefCountList alloc] initCount:2] 
			insertObject:cloEvent at:0]
			insertObject:outputMatrix at:1];


    /* shorthand for access to the hitpoint list and its entries is in #define of the header of this class */
     
			    
	    
    if([aSimplex isVeryNearTo:proEvent]){
	setE(zeroHitPoint,proEvent);
	[anEvent norelease];
	[proEvent norelease];
	[cloEvent norelease];
    return zeroHitPoint; /* Already the start point successful */
    }
    else{ /*until end of method!*/
	/* this is an escape object called zabriskiPoint */
	setT(
	    [[zabriskiPoint=[[RefCountList alloc] initCount:2] 
	    insertObject:proEvent at:0]
	    insertObject:[outputMatrix clone] at:1],
	HUGE_VAL);

	if(!time) /* Avoid bad start */
	time = -0.1;
	
	/* now, time is non-vanishing, 
	we produce the first, non-trivial point by linear approximation to the simplex */
	
		pointer = [self integrateFieldFrom: /* Check existence of integration */
    				cloEvent at:time];
	    if(pointer[clodim]) {/*failure of integration*/
		setS(zabriskiPoint,pointer[clodim]);
		free(pointer);
		[anEvent norelease];
		[proEvent norelease];
		[cloEvent norelease];
    return zabriskiPoint;
	    }
    
	    /*else: initialization of hitList with start zeroHitPoint; end check */
	    hitList = [[RefCountList alloc] initCount:aLimit];
	    [hitList insertObject: zeroHitPoint at:0];

	    curvePt = [[MatrixEvent newFromPointer:pointer withSpace:cloSpace]ref];
					     
	    /*define oneHitPoint*/
	    oneHitPoint = [[[[RefCountList alloc] initCount:2] 
			    insertObject:curvePt at:0]
			    insertObject:[outputMatrix clone] at:1];

	    /*update oneHitPoint with time and distance control ok = CALC_SUCCESS */
	    		
	    setD(oneHitPoint,[[aSimplex minimalSimplexPointTo:[curvePt projectTo:simplexSpace]] doubleValue]);
	    setT(oneHitPoint, time);

	    /* assure that the list produces decreasing distances */
	    if(distanceOf(zeroHitPoint)>=distanceOf(oneHitPoint)) 
		[hitList insertObject: oneHitPoint at:1]; 
	    else {
		[hitList insertObject: oneHitPoint at:0];
		/* and now we have to replace the curvePt! */
		[curvePt norelease];
		curvePt = [cloEvent ref];
	    }
		
	/* end of defninition of first, non-trivial point */

	
	/* General recursion loop: now, we have at least two parameter values */
	for(i=1; i<aLimit && ![aSimplex isVeryNearTo:eventAt(i)]; i++){
	    iTime = timeAt(i); 
	    minIndex = i;
	    maxIndex = i;
	    for(j=0; j<i; j++){
		if(timeAt(j)<iTime) 
		minIndex = (!j ||timeAt(minIndex)<timeAt(j)) ?j :minIndex;

		else if(timeAt(j)>iTime) 
		maxIndex = (!j || timeAt(maxIndex)>timeAt(j)) ?j :maxIndex;

		else{ /* for security reasons, should not happen except by rounding effects */
		    [[hitList freeObjects] norelease]; 
		    setS(zabriskiPoint, CALC_HIT_FAILURE);
		    [curvePt norelease];
		    [anEvent norelease];
		    [proEvent norelease];
		    [cloEvent norelease];
    return zabriskiPoint;
		}
	    }
		
	    /*after the minIndex and maxIndex calculation, recursion goes on from the ith event of the list */
	    iEvent = eventAt(i);
	    iDistance = distanceAt(i);
	    fieldAti = [[self performanceFieldAt: iEvent]ref];

	    /* First case: the line through the extremal ith point defines the new parameter */
	    if(minIndex == i || maxIndex == i){ 
		diff = [aSimplex minimalSimplexParameterTo:[iEvent projectTo:simplexSpace] in:
							    [fieldAti projectTo:simplexSpace]];
		if (!diff) {
		    for (j=1, diff=fabs(iTime-timeAt(0)); j<i; j++) 
			diff = MIN(diff, fabs(iTime-timeAt(j)));
			
		    if(minIndex == i)
			iTime -=diff;
		    else
			iTime +=diff;
		    
		} 
		
		else {
		    /* ERROR 2 */								
		    for(j=0, k=1; j<i && k<aLimit+1;){
			if(!(timeAt(j)-iTime-diff/k)){
			    k++; j = 0;
			} 
			else 
			    j++;
		    }

		    /* for some k, we got no j time on iTime+diff/k since we have 
		    more than i different times  (i.e. aLimit+1) at disposal*/
		    
			iTime += diff/k;
		}
		/* now we have some new iTime */
		free(pointer);
		pointer = [self integrateFieldFrom:curvePt at:iTime-timeAt(i)];
		if(pointer[clodim]){/* Check existence of integration */
			setS(zabriskiPoint,pointer[clodim]);
			free(pointer);
			[[hitList freeObjects] norelease]; 
			[curvePt norelease];
			[anEvent norelease];
			[proEvent norelease];
			[cloEvent norelease];
	return zabriskiPoint;
		} /* End Check */
    
		dist = [[aSimplex minimalSimplexPointTo:[[MatrixEvent newFromPointer:pointer withSpace:cloSpace]
			projectTo:simplexSpace]] doubleValue];
		
		if(iDistance>=dist) {
		    int zIndex;
		    id zeroClone = [zeroHitPoint mutableCopy];
		    [curvePt norelease];
		    curvePt = [[MatrixEvent newFromPointer:pointer withSpace:cloSpace]ref]; 
		    for (zIndex = 0; zIndex<[zeroClone count]; zIndex++) {
			[[zeroClone replaceObjectAt:zIndex with:[[zeroClone objectAt:zIndex]clone]] norelease];
		    }
		    setE(zeroClone, [curvePt projectTo:simplexSpace]);
		    setD(zeroClone, dist);
		    setT(zeroClone, iTime);
		    [hitList insertObject:zeroClone at:i+1];
		}
		else {
		    free(pointer);
		    pointer = [self integrateFieldFrom:curvePt at:timeAt(i)-iTime];
		    if(pointer[clodim]){/* Check existence of integration */
			    setS(zabriskiPoint,pointer[clodim]);
			    free(pointer);
			    [[hitList freeObjects] norelease]; 
			    [curvePt norelease];
			    [anEvent norelease];
			    [proEvent norelease];
			    [cloEvent norelease];
	    return zabriskiPoint;
		    } /* End Check */
	
		    [curvePt norelease];
		    curvePt = [[MatrixEvent newFromPointer:pointer withSpace:cloSpace]ref]; 
		    dist = [[aSimplex minimalSimplexPointTo:[curvePt projectTo:simplexSpace]] doubleValue];
		    
		    if(iDistance>=dist) {
			int zIndex;
			id zeroClone = [zeroHitPoint mutableCopy];
			[curvePt norelease];
			curvePt = [[MatrixEvent newFromPointer:pointer withSpace:cloSpace]ref]; 
			for (zIndex = 0; zIndex<[zeroClone count]; zIndex++) {
			    [[zeroClone replaceObjectAt:zIndex with:[[zeroClone objectAt:zIndex]clone]] norelease];
			}
			setE(zeroClone, [curvePt projectTo:simplexSpace]);
			setD(zeroClone, dist);
			setT(zeroClone, iTime);
			[hitList insertObject:zeroClone at:i+1];
		    }
		    else{
			setS(zabriskiPoint, CALC_HIT_FAILURE);
			free(pointer);
			[[hitList freeObjects] norelease]; 
			[curvePt norelease];
			[anEvent norelease];
			[proEvent norelease];
			[cloEvent norelease];
	return zabriskiPoint;
			    
		    }
		}
	    }

	    /* Now, iTime is a real intermediate parameter */
	    else{
		id iProjEvt = [[iEvent projectTo:simplexSpace]ref];
		id projFieldAti = [[fieldAti projectTo:simplexSpace]ref];
		id projMaxEvt = [[eventAt(maxIndex) projectTo:simplexSpace]ref];
		id projMinEvt = [[eventAt(minIndex) projectTo:simplexSpace]ref];
		id projMaxFieldAti = [[[self performanceFieldAt:eventAt(maxIndex)] projectTo:simplexSpace]ref];
		id projMinFieldAti = [[[self performanceFieldAt:eventAt(minIndex)] projectTo:simplexSpace]ref];
		
		for (k=2; k<aLimit && [hitList count]<i+1; k++) {
		    double interTime;
		    interTime = iTime + ((timeAt(maxIndex) - iTime)/k);
		    if(iDistance >= [[aSimplex minimalSimplexPointTo:
			    [self splineFrom:iProjEvt:
			    projFieldAti:
			    iTime 
			    To:projMaxEvt:
			    projMaxFieldAti :
			    timeAt(maxIndex)
			    at:interTime]] doubleValue]){
	    
			free(pointer);
			pointer = [self integrateFieldFrom:curvePt at:interTime-iTime];
			
			if(pointer[clodim]){/* Check existence of integration */
			    setS(zabriskiPoint,pointer[clodim]);
			    free(pointer);
			    [[hitList freeObjects] norelease]; 
			    [curvePt norelease];
			    [anEvent norelease];
			    [proEvent norelease];
			    [cloEvent norelease];
		return zabriskiPoint;
		
			} /* End Check*/
		
			[curvePt norelease];
			curvePt = [[MatrixEvent newFromPointer:pointer withSpace:cloSpace]ref]; 
		
			if(iDistance >= (dist = [[aSimplex minimalSimplexPointTo:[curvePt projectTo:simplexSpace]] doubleValue])){
			    int zIndex;
			    id zeroClone = [zeroHitPoint mutableCopy];
			    for (zIndex = 0; zIndex<[zeroClone count]; zIndex++) {
				id tmp1;
                                tmp1=[[zeroClone objectAt:zIndex] clone];
                                [zeroClone replaceObjectAt:zIndex with:tmp1]; // jg hmmm? ...
				[tmp1 norelease];
				//jg [tmp1 norelease];
// jg the above from "{" was:				[[[zeroClone replaceObjectAt:zIndex with:[[zeroClone objectAt:zIndex]clone]] release] release];
			    }
			    setE(zeroClone, [curvePt projectTo:simplexSpace]);
			    setD(zeroClone, dist);
			    setT(zeroClone, interTime);
		
			    [hitList insertObject:zeroClone at:i+1];
			    break; /* approximation successful, skip rest and go to next step */
			}
		    }
	    
		    interTime = iTime + ((timeAt(minIndex) - iTime)/k);
		    
		    if(iDistance >= [[aSimplex minimalSimplexPointTo:
			[self splineFrom:iProjEvt:
			projFieldAti:
			iTime 
			To:projMinEvt:
			projMinFieldAti:
			timeAt(minIndex)
			at:interTime]] doubleValue]){
	    
			free(pointer);
			pointer = [self integrateFieldFrom:curvePt at:interTime-iTime];
			
			if(pointer[clodim]){/* Check existence of integration */
			    setS(zabriskiPoint,pointer[clodim]);
			    free(pointer);
			    [[hitList freeObjects] norelease]; 
			    [curvePt norelease];
			    [anEvent norelease];
			    [proEvent norelease];
			    [cloEvent norelease];
		return zabriskiPoint;
		
			} /* End Check*/
			
			[curvePt norelease];
			curvePt = [[MatrixEvent newFromPointer:pointer withSpace:cloSpace]ref];  
			    
			if(iDistance >= (dist = [[aSimplex minimalSimplexPointTo:[curvePt projectTo:simplexSpace]] doubleValue])) {
			    int zIndex;
			    id zeroClone = [zeroHitPoint mutableCopy];
			    for (zIndex = 0; zIndex<[zeroClone count]; zIndex++) {
				[[zeroClone replaceObjectAt:zIndex with:[[zeroClone objectAt:zIndex]clone]] norelease];
			    }
			    setE(zeroClone, [curvePt projectTo:simplexSpace]);
			    setD(zeroClone, dist);
			    setT(zeroClone, interTime);
		    
			    [hitList insertObject:zeroClone at:i+1];
			    break;  /* approximation successful, skip rest and go to next step */
			    /* this statement has no effect here, since we interate anyway */
			}
		    }
		}
		
		[iProjEvt norelease];
		[projFieldAti norelease];
		[projMaxEvt norelease];
		[projMinEvt norelease];
		[projMaxFieldAti norelease];
		[projMinFieldAti norelease];
		[fieldAti norelease];

		if (k>=aLimit) {
		    setS(zabriskiPoint, CALC_HIT_FAILURE);
		    free(pointer);
		    [[hitList freeObjects] norelease]; 
		    [curvePt norelease];
		    [anEvent norelease];
		    [proEvent norelease];
		    [cloEvent norelease];
	    return zabriskiPoint;
		}
	    }
	}
	
	/* now, the recursive process is done, look at the total number of successes */
    
        // jg zu Debuggingzwecken eingefuegt, weil es vorkam, dass cloEvent ganz verschwand.
        { // jg??? jgdebug
          static int withIncrease=0; // setze mit Debugger um, um anderes Verhalten zu haben.
          static int nrOfIncrease=0;
          printf("  [cloEvents retainCount] is %d",[anEvent retainCount]); 
          if(withIncrease && ([cloEvent retainCount]==1)) {
            [cloEvent retain];    
            nrOfIncrease++;
            printf(" and %d times increased\n",nrOfIncrease);
          } else printf("\n");
        }
	if(i<=aLimit){
	    setE(zabriskiPoint,eventAt(i));
	    setD(zabriskiPoint,distanceAt(i));
	    setS(zabriskiPoint,successAt(i));
	    setT(zabriskiPoint,timeAt(i));
	    free(pointer);
	    [[hitList freeObjects] norelease]; 
	    [curvePt norelease];
	    [anEvent norelease];
	    [proEvent norelease];
	    [cloEvent norelease];
	return zabriskiPoint;
	}
	else{
	    setS(zabriskiPoint, CALC_OVERFLOW);
	    free(pointer);
	    [[hitList freeObjects] norelease]; 
	    [curvePt norelease];
	    [anEvent norelease];
	    [proEvent norelease];
	    [cloEvent norelease];
	return zabriskiPoint;
	}
    }
}



/*Calculate the components of performed events of a LPS*/ 
- (double) calcEventComponent:(int)index at:anEvent;
{
    double retval;
    id perf=(id)[myPerformanceTable objectForKey:anEvent];
    if (perf) {
	retval = [perf doubleValueAtIndex:index];
    }
    else if([myInitialSet spaceAt:index]){
	perf = [[self initialSetPerformanceOfEvent:anEvent andInitialSet:myInitialSet]ref];
	retval = [perf doubleValueAtIndex:index];
	[perf release];
    }
    else 
	retval = [myMother calcEventComponent:index at:anEvent]; 
    return retval;
}

/* calculate the performed events of a LPS */

/* The - calcInitPerfOfEvent:atInitialSet: is the standard behaviour 
 * for default initialSet. It first calls the custom method 
 * - calcInitPerfOfEvent:atCustomInitialSet: which is to be 
 * implemented by the concrete operators.
 */
- calcInitPerfOfEvent:anEvent atInitialSet:anInitialSet;
{
  NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init]; // debug memory
    id result = nil;
    if(![self containsDefaultInitialSet:anInitialSet])
	result = [self calcInitPerfOfEvent:anEvent atCustomInitialSet:anInitialSet];
    else {
	/* the default method for indecomposable default simplex initials */
	spaceIndex initialSpace = [anInitialSet space];
    
	if([anEvent space] == initialSpace){  
	    spaceIndex myInterior = [self hierarchyInteriorOfSpace:initialSpace];
	    result = [[myMother performedEventAt:anEvent]clone];
	    [result setDoubleValue:MOTHER_SUCCESS_OK];
	    /* on fundamentals, take mother©s performance and skip the "if" block */
	    if(myInterior && isStrictSubspace(myInterior, initialSpace)){ 
		int i; 
		id ON_Event, OFF_Event, perf_ON=nil, perf_OFF=nil;
			
		ON_Event = [[anEvent projectTo:myInterior]ref];
		OFF_Event = [[ON_Event clone]ref];
		
		for(i=MAX_BASIS_DIMENSION; i<MAX_SPACE_DIMENSION; i++){
		    if(	spaceOfIndex(i) & initialSpace && 
			!(spaceOfIndex(i) & myInterior) && 
			spaceOfIndex(i-MAX_BASIS_DIMENSION) & myInterior
			)
		    [OFF_Event setDoubleValue:[result doubleValueAtIndex:i]
				+ [ON_Event doubleValueAtIndex:i-MAX_BASIS_DIMENSION]
						atIndex:i-MAX_BASIS_DIMENSION]; 
		}
		
		perf_ON = [[self performanceOfEvent:ON_Event andInitialSet:myInitialSet]ref];
                [result setDoubleValue:[perf_ON doubleValue]];
		if (![result doubleValue]) {
		    if (!(PIANOLA_SPACE  & myInterior))
			perf_OFF = [[self performanceOfEvent:OFF_Event andInitialSet:myInitialSet]ref];
                    [result setDoubleValue:[perf_OFF doubleValue]];
		    if (![result doubleValue]) {
			for(i=0; i<MAX_SPACE_DIMENSION; i++){
			    if(spaceOfIndex(i) & initialSpace){
				if(spaceOfIndex(i) & myInterior)
				    [result setDoubleValue:[perf_ON doubleValueAtIndex:i] atIndex:i];
				else if (i>=MAX_BASIS_DIMENSION)
				    [result setDoubleValue:[perf_OFF doubleValueAtIndex:i-MAX_BASIS_DIMENSION]
					-[perf_ON doubleValueAtIndex:i-MAX_BASIS_DIMENSION] atIndex:i];
			    }
			}
		    }
		}
		[perf_ON release];
		[perf_OFF release];
		[ON_Event release];
		[OFF_Event release];
	    }
	}
    }
    [result retain];
    [pool release];
    [result autorelease];
    return result;
}


- calcInitPerfOfEvent:anEvent atCustomInitialSet:anInitialSet;
{
    return [anEvent projectTo:[anInitialSet space]];
}

/* success calculation at anEvent, initial set space iSpace, direction, success array  successIndex*/
- (BOOL)successCheckAt:anEvent:(spaceIndex)iSpace:(double *)successIndex;
{
    int j, indj, dim = [anEvent dimension];
    for(j=1;j<=dim && 	(!successIndex[(indj = [anEvent indexOfDimension:j])] || 
			!((iSpace & spaceOfIndex(indj)) &&
			 (myCalcDirection & spaceOfIndex(indj)))); j++);
    return j<=dim;
}

/* order is NEW May 20 1996 */
/* to be overridden by subclass operators */
- (int *)orderForInitialSet:anInitialSet andEvent:anEvent;
{
    int i,  c = [anInitialSet listCount];
    int *order;
    order = calloc(c,sizeof(int));
    for(i=0; i<c; i++)
	order[i] = i;
    return order;
}



/* returns a MatrixEvent, success is codified on the event©s doubleValue! */
- initialSetPerformanceOfEvent:anEvent andInitialSet:anInitialSet;
/* new GFO-SONY method, here, we know a priori that there is a mother! 
 * See performanceOf:and: method in this file
 * We need a flattened initialSet for this method to work.
 * By construction, this is a brute list of InitialSimplexes.
 */
{
  NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init]; // debug memory

    int 	i, j, c,
     		dim = [anEvent dimension];
    int *order;
    /* order is NEW May 20 1996 */
		
    spaceIndex  iSpace;

    /* initialize the success index to overall failure */
    double success=0.0, successIndex[MAX_SPACE_DIMENSION] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
 
    id initialSet, bestInitialSet = nil, projEvent = nil, result=nil, iResult=nil, delta;
    
    if (anInitialSet!=curInitialSet) {
	if (curFlatInitialSet!=curInitialSet) {
	    [curFlatInitialSet release];
            curFlatInitialSet = nil;
	}
	
	curInitialSet = anInitialSet;
	if (![curInitialSet isFlat]) {
	    curFlatInitialSet = [curInitialSet flatten];
	} else {
	    curFlatInitialSet = curInitialSet;
	}
    }
    anInitialSet = curFlatInitialSet;

    
    initialSet=anInitialSet;
    c = [anInitialSet listCount];
    anInitialSet = c ? anInitialSet : [anInitialSet wrapSelfInList];
    /* If we get a raw initialSimplex, just wrap it in a list */

    /* The result is obtained from Mother by a separate method (-performedEventAt:), 
     * or retrived from the PerformanceTable. What if Mother's performance is no success? 
     * We should then quit right here.
     */
    
    result = [(id)[myPerformanceTable objectForKey:anEvent]clone];
    
    if(!result) {
	result = [[myMother performedEventAt:anEvent]clone];
	for (i=0; i<MAX_SPACE_DIMENSION; i++) /* unavailable coordinates don't need success */
	    successIndex[i]= [anEvent spaceAt:i] ? (success=[result doubleValue] ? success: MOTHER_SUCCESS_OK) : 0.0;
	
	/* first, check for very near initial simplices and evaluate them */
	for(i=0; i<c; i++){
	    iSpace = [[anInitialSet initialSetAt:i] space]; 
	    /* check success status; do accept as ok if the iSpace does not answer open questions */

	    if([self successCheckAt:anEvent:iSpace:successIndex]){ 
		if(bestInitialSet = [[anInitialSet initialSetAt:i] veryNearInitialSetTo:anEvent]){
		    /* this implies that projection of anEvent to bestInitialSet is possible ! */ 
		    projEvent = [[anEvent projectTo:[bestInitialSet space]]ref];
		    iResult = [(id)[myPerformanceTable objectForKey:projEvent]ref];
		    if (!iResult) {
			iResult = [self calcInitPerfOfEvent:projEvent atInitialSet:bestInitialSet];
			[self insertKeyEvent:projEvent andPerformance:iResult];
			[iResult ref];
		    } else
			myHashHits++;
		    if(iResult){
			/* this success has to be evaluated on the coordinates of this simplex,
			 * except those external to myDirection
			 */
			int dimi = [bestInitialSet dimension];
			for(j=1; j<=dimi; j++){
			    int indexj = [bestInitialSet indexOfDimension:j];
			    successIndex[indexj] = [iResult doubleValue];
			    if(myCalcDirection & spaceOfIndex(indexj) && [iResult doubleValue]<=0)
			    [result setDoubleValue:[iResult doubleValueAtIndex:indexj] atIndex:indexj];
			}
		    }  
		    [iResult release];
		    [projEvent release];
		}
	    }
	}
	/* now, try to hit the initial simplices and not SONY */
	order = [self orderForInitialSet:anInitialSet andEvent:anEvent];
	for(i=0; i<c; i++){
	    iSpace = [[anInitialSet initialSetAt:order[i]] space]; /* order[i] instead of i is NEW May 20 1996 */
	    /* check success status */
    
	    if([self successCheckAt:anEvent:iSpace:successIndex]){ 
	    
		id	iSimplex = [[anInitialSet initialSetAt:order[i]] simplex],
		    ihitObject = [self hitPointFromEvent:anEvent onSimplex:iSimplex];
		int dimi = [iSimplex dimension];
		success = successOf(ihitObject);
	    
		if(success || !ihitObject) {/* success bad! */
		    success = ihitObject ? success : INT_MAX;
	
		    [ihitObject freeObjects];
		    [ihitObject release];	
		}
		else { 
		    /* initial performance of hitPoint */
		    id initPerf = [self calcInitPerfOfEvent:eventOf(ihitObject) atInitialSet:[anInitialSet initialSetAt:order[i]]];
	    
		    /* no success for initial performance of hitPoint */
		    if([initPerf doubleValue]>0){ 
			[ihitObject freeObjects];
			[ihitObject release];	
		    } else { /* now, initial calc success */
			delta = [[MatrixEvent alloc] initWithSpace:iSpace andValue:1.0];
	    
			/* scale delta by hitParameter */
			[delta scaleBy:(float)(-timeOf(ihitObject))]; 
	    
			iResult = initPerf;
                        [iResult shiftBy:delta];
	    
			/* update the new successful coordinates of the performance */
			for(j=1; j<=dimi; j++){
			    int indexj = [iSimplex indexOfDimension:j];
			    if((myCalcDirection & spaceOfIndex(indexj)) && successIndex[indexj])
				[result setDoubleValue:[iResult doubleValueAt:j-1] atIndex:indexj];
			}
			[ihitObject freeObjects];
			[ihitObject release];	
		    }
		}
		/* update the success pointer for the ith step*/
		for(j=1; j<=dimi; j++){
		    int indexj = [iSimplex indexOfDimension:j];
		    if(successIndex[indexj])
			successIndex[indexj] = success;
		}
	    }
	}
	free(order); /* NEW 20 Mai 1996 */
	/* set the finale success to be the maximum of the non-zero sucess indices if any */
	for(j=1, success = 0; j<=dim; j++){
	    double sucj = successIndex[[anEvent indexOfDimension:j]];
	    sucj==MOTHER_SUCCESS_OK ? sucj=0.0 : sucj;
	    if(0<sucj || 0<success) 
		success = MAX(success, sucj);
	    else
		success = MIN(success, sucj);
	    }
	    [result setDoubleValue:success];
	    
	[self insertKeyEvent:anEvent andPerformance:result];
    
    } else {
	myHashHits++;
    }

    if (anInitialSet!=initialSet)
	[anInitialSet release]; /* in case we had to wrap an initialSimplex */

  [result retain];
  [pool release];
  [result autorelease];
    return result;
}
/* combines the initialSetPerformance and the mother©s performance */
- performanceOfEvent:anEvent andInitialSet:anInitialSet;
{
    id perf;
    if (!myMother)
	return [anEvent clone];
	
    perf = [self initialSetPerformanceOfEvent:anEvent andInitialSet:anInitialSet];
    return perf;
}

/* create myPerformanceKernel and abortedKernel, overrides the doPerform method in LPS */
- doPerform;
{
    if (!isCalculated) {
	int i, c;
        id perfEventi;
	id progressPanel;
//        Class theClass;
//        NSBundle *bundle;
        JgOwner *ow=[[JgOwner alloc] init];
	[NSBundle loadNibNamed:@"Progress.nib" owner:ow];
        progressPanel=[ow property];
//        bundle=[NSBundle bundleWithPath:@"Progress.nib"];
//        theClass = [bundle classNamed:@"ProgressPanel"] ; //jg
//        progressPanel = [[theClass alloc] init];
	[self validate];
	
	c = [myKernel count];
	
        [[progressPanel progressView] setDoubleValue:0.0];
	[progressPanel setIncrement:1.0];
	[[progressPanel progressView]setMaxValue:(double)c];
	[progressPanel setTitle:NSStringFromClass([self class])];
	[progressPanel setString:@"Calculation Progress:"];
	[progressPanel makeKeyAndOrderFront:nil];
	[progressPanel display];
	[progressPanel setDelegate:self];
	
	for(i = 0; i < c;i++){
	    NSEvent *theEvent = [[NSApplication sharedApplication] nextEventMatchingMask:(int)NSKeyDownMask untilDate:[NSDate dateWithTimeIntervalSinceNow:0.0] inMode:NSEventTrackingRunLoopMode dequeue:YES];
        if (theEvent && [theEvent modifierFlags] & NSCommandKeyMask && [[theEvent charactersIgnoringModifiers] isEqual:@"."]) //jg
		break;
		
            [progressPanel setString:[NSString stringWithFormat:@"Calculation Progress: %u of %u Events", i+1, c]];
    
	    perfEventi = [self performanceOfEvent:[myKernel objectAt:i] andInitialSet:myInitialSet]; 
	    /* HERE ABOVE, clones are produced by default from initialSetPerformanceOf:: */
	    
	    if(![perfEventi doubleValue]) /* CALC_SUCCESS is 0.0 */
		[myPerformanceKernel addObjectIfAbsent:perfEventi]; 
	    else 
		[myAbortedKernel addObjectIfAbsent:perfEventi];
		
	    [progressPanel increment:self];
    
	}
	[myPerformanceKernel sort];
	[progressPanel close];
	[progressPanel release];
        progressPanel = nil;
        [ow release];
	/*
	NXRunAlertPanel("Calculation Statistics",   "Events: %u\n"
						    "Performed: %u\n"
						    "Errors: %u\n"
						    "Hash Table size: %u\n"
						    "Hash Table hits: %u\n"
						    "Integration Calculations: %u\n"
						    "Hit Point Calls: %u", 
			"Great", NULL, NULL, [myKernel count], [myPerformanceKernel count], 
			[myAbortedKernel count], [myPerformanceTable count], 
			myHashHits, myCalcCount, myHitPointCalls);
	*/
	isCalculated = i==c;
    }
    return self;
}

/* maintain calc optimization */
- (void)invalidate
{
    [super invalidate];
    
    myHashHits = 0;
    myCalcCount = 0;
    myHitPointCalls = 0;
}


- validate;
{
    [super validate];
    
    [self adjustHierarchy];
    
    [myAbortedKernel freeObjects];
    myHashHits = 0;
    myCalcCount = 0;
    myHitPointCalls = 0;
    return self;
}



@end

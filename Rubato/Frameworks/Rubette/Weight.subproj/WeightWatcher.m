/* WeightWatcher.m */

#import "WeightWatcher.h"
#import "Weight.h"
//jg#import "PerformanceScore.h"
#import "space.h"


@implementation WeightWatcher

/* standard class methods to be overridden */
+ (void)initialize;
{
    [super initialize];
    if (self == [WeightWatcher class]) {
	[WeightWatcher setVersion:5];
    }
}


/* standard object methods to be overridden */
- init;
{
    [super init];
    /* class-specific initialization goes here */
    myWatchList = [[[RefCountList alloc]init]ref];
    myBaryWeights = NULL;
    myDeformations = NULL;
    myLoNorms = NULL;
    myHiNorms = NULL;
    myTolerances = NULL;
    myInvertFlags = NULL;
    myProductFlag = NO;
    return self;
}

- (void)dealloc
{
    /* class-specific initialization goes here */
    myLPS = nil;
    [[myWatchList freeObjects] release];
    myWatchList = nil;
    if (myBaryWeights) free(myBaryWeights);
    if (myDeformations) free(myDeformations);
    if (myLoNorms) free(myLoNorms);
    if (myHiNorms) free(myHiNorms);
    if (myInvertFlags) free(myInvertFlags);
    { [super dealloc]; return; };
}

- (id)copyWithZone:(NSZone *)zone;
{
  NSAssert(NO,@"WeightWatcher copyWithZone: not expected/implemented!");
  return JGSHALLOWCOPY;
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    int i, c, classVersion = [aDecoder versionForClassName:NSStringFromClass([WeightWatcher class])];
//    [super initWithCoder:aDecoder];
    /* class-specific code goes here */

    myWatchList = [[aDecoder decodeObject] retain];
    c = [myWatchList count];
    myBaryWeights = realloc(myBaryWeights, c*sizeof(double));
    myDeformations = realloc(myDeformations, c*sizeof(double));
    myLoNorms = realloc(myLoNorms, c*sizeof(double));
    myHiNorms = realloc(myHiNorms, c*sizeof(double));
    myTolerances = realloc(myTolerances, c*sizeof(double));
    myInvertFlags = realloc(myInvertFlags, c*sizeof(double));

    /* now read old stuff of Version 0 */ 
    for (i=0; i<c; i++)
	[aDecoder decodeValueOfObjCType:"d" at:&myBaryWeights[i]];
    /* read for Version 1 and newer */
    if (classVersion > 0) {
	for (i=0; i<c; i++)
	    [aDecoder decodeValueOfObjCType:"d" at:&myDeformations[i]];
    } else
        for (i=0; i<c; i++) 
	    myDeformations[i] = 0.0;

    /* read for Version 3 and newer */
    if (classVersion > 2) {
	for (i=0; i<c; i++) {
	    [aDecoder decodeValueOfObjCType:"d" at:&myLoNorms[i]];
	    [aDecoder decodeValueOfObjCType:"d" at:&myHiNorms[i]];
	    [aDecoder decodeValueOfObjCType:"d" at:&myInvertFlags[i]];
	}
    } else
        for (i=0; i<c; i++) {
	    myLoNorms[i] = 0.0;
	    myHiNorms[i] = 1.0;
	}
	
    /* read for Version 5 and newer */
    if (classVersion > 4) {
	for (i=0; i<c; i++) {
	    [aDecoder decodeValueOfObjCType:"d" at:&myTolerances[i]];
	}
    } else
        for (i=0; i<c; i++) {
	    myTolerances[i] = [[myWatchList objectAtIndex:i]tolerance];
	}
	
    if (classVersion<2) {
	/* convert the old List objects to
	 * RefCounList or OrderedList objects
	 */
	id list = myWatchList;
	myWatchList = [[[RefCountList alloc]initCount:[list count]]appendList:list];
	[list release];
    }

    /* read for Version 4 and newer */
    if (classVersion>3) {
	[aDecoder decodeValueOfObjCType:"c" at:&myProductFlag];
    } else
	myProductFlag = NO;

    if (classVersion>1) 
	myLPS = [[[aDecoder decodeObject] retain] ref];
	
    /* set Reference Counting of read or replaced objects */
    [myWatchList ref];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    int i, c = [myWatchList count];
//    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myWatchList];

    for (i=0; i<c; i++)
	[aCoder encodeValueOfObjCType:"d" at:&myBaryWeights[i]];
    for (i=0; i<c; i++)
	[aCoder encodeValueOfObjCType:"d" at:&myDeformations[i]];
    for (i=0; i<c; i++) {
	[aCoder encodeValueOfObjCType:"d" at:&myLoNorms[i]];
	[aCoder encodeValueOfObjCType:"d" at:&myHiNorms[i]];
	[aCoder encodeValueOfObjCType:"d" at:&myInvertFlags[i]];
    }
    for (i=0; i<c; i++)
	[aCoder encodeValueOfObjCType:"d" at:&myTolerances[i]];
    [aCoder encodeValueOfObjCType:"c" at:&myProductFlag];

    [aCoder encodeConditionalObject:myLPS];
}

// decoupled LocalPerformanceScore and Weight classes
- setOwnerLPS:aLPS;
{
  if (!myLPS && [aLPS isKindOfClass:NSClassFromString(@"LocalPerformanceScore")]) { // jg was:[LocalPerformanceScore class]
	myLPS = aLPS;
	return self;
    }
    return nil;
}

- ownerLPS;
{
    return myLPS;
}


- addWeightObject:aWeight;
{
    if ([aWeight isKindOfClass:[Weight class]] && 
	[myWatchList indexOfObject:aWeight] == NSNotFound) {
	int c;
	[myWatchList addObjectIfAbsent:aWeight];
	c = [myWatchList count];
	myBaryWeights = realloc(myBaryWeights, c*sizeof(double));
	myDeformations = realloc(myDeformations, c*sizeof(double));
	myLoNorms = realloc(myLoNorms, c*sizeof(double));
	myHiNorms = realloc(myHiNorms, c*sizeof(double));
	myTolerances = realloc(myTolerances, c*sizeof(double));
	myInvertFlags = realloc(myInvertFlags, c*sizeof(double));
	myBaryWeights[c-1] = 1.0;
	myDeformations[c-1] = 0.0;
	myLoNorms[c-1] = [aWeight lowNorm];
	myHiNorms[c-1] = [aWeight highNorm];
	myTolerances[c-1] = [aWeight tolerance];
	myInvertFlags[c-1] = [aWeight isInverted];
	[myLPS weightWatcherChanged];
	return self;
    }
    return nil; /* aWatcher was not inserted */
}

- removeWeightObjectAt:(unsigned int)index;
{
    id removed = [myWatchList removeObjectAt:index];
    if(removed){
	int i, c = [myWatchList count];
	for(i=index; i<c; i++) {
	    myBaryWeights[i] = myBaryWeights[i+1];
	    myDeformations[i] = myDeformations[i+1];
	    myLoNorms[i] = myLoNorms[i+1];
	    myHiNorms[i] = myHiNorms[i+1];
	    myTolerances[i] = myTolerances[i+1];
	    myInvertFlags[i] = myInvertFlags[i+1];
	}
	myBaryWeights = realloc(myBaryWeights, c*sizeof(double));
	myDeformations = realloc(myDeformations, c*sizeof(double));
	myLoNorms = realloc(myLoNorms, c*sizeof(double));
	myHiNorms = realloc(myHiNorms, c*sizeof(double));
	myTolerances = realloc(myTolerances, c*sizeof(double));
	myInvertFlags = realloc(myInvertFlags, c*sizeof(double));
	[myLPS weightWatcherChanged];
    }
    return removed;
}

- weightObjectAt:(int)index;
{
    return [myWatchList objectAt:index];
}


- (unsigned int)count;
{
    return [myWatchList count];
}

- setLowNorm:(double)aDouble at:(int)index;
{
    if (index<[myWatchList count]) {
	[[myWatchList objectAt:index]setLowNorm:aDouble];
	myLoNorms[index] = [[myWatchList objectAt:index]lowNorm];
	[myLPS weightWatcherChanged];
    }
    return self;
}

- (double) lowNormAt:(int)index;
{
    if (index<[myWatchList count])
	return myLoNorms[index];
    return 0.0;
}

- setHighNorm:(double)aDouble at:(int)index;
{
    if (index<[myWatchList count]) {
	[[myWatchList objectAt:index]setHighNorm:aDouble];
	myHiNorms[index] = [[myWatchList objectAt:index]highNorm];
	[myLPS weightWatcherChanged];
    }
    return self;
}

- (double) highNormAt:(int)index;
{
    if (index<[myWatchList count])
	return myHiNorms[index];
    return 1.0;
}

- setRange:(double)aDouble at:(int)index;
{
    if (index<[myWatchList count]) {
	[[myWatchList objectAt:index]setRange:aDouble];
	[myLPS weightWatcherChanged];
	myLoNorms[index] = [[myWatchList objectAt:index]lowNorm];
	myHiNorms[index] = [[myWatchList objectAt:index]highNorm];
 	myInvertFlags[index] = [[myWatchList objectAt:index]isInverted];
   }
    return self;
}

- (double) rangeAt:(int)index;
{
    if (index<[myWatchList count])
	return fabs(myHiNorms[index] - myLoNorms[index]);
    return 1.0;
}


- setInversion:(BOOL)flag at:(int)index;
{
    if (index<[myWatchList count]) {
	[[myWatchList objectAt:index]setInversion:flag];
 	myInvertFlags[index] = [[myWatchList objectAt:index]isInverted];
	[myLPS weightWatcherChanged];
    }
    return self;
}

- setProduct:(BOOL)flag;
{
    if (myProductFlag!=flag) {
	myProductFlag = flag;
	[myLPS weightWatcherChanged];
    }
    return self;
}


- (BOOL) isProduct;
{
    return myProductFlag;
}


- (BOOL) isInvertedAt:(int)index;
{
    if (index<[myWatchList count])
	return myInvertFlags[index];
    return NO;
}

- setTolerance:(double)aDouble at:(int)index;
{
    if (index<[myWatchList count]) {
	[[myWatchList objectAt:index]setTolerance:aDouble];
	[myLPS weightWatcherChanged];
	myTolerances[index] = [[myWatchList objectAt:index]tolerance];
    }
    return self;
}

- (double) toleranceAt:(int)index;
{
    if (index<[myWatchList count])
	return myTolerances[index];
    return 1.0;
}

- setSpaceAt:(int)index to:(BOOL)flag;
{
    return self;
}

- (BOOL) spaceAt:(int)index;
{
    if (index<MAX_SPACE_DIMENSION)
	return [self space] & spaceOfIndex(index);
    else
	return NO;
}

- setSpaceTo:(spaceIndex)aSpace;
{
    return self;
}

- (spaceIndex)space;
{
    spaceIndex aSpace = 0;
    int i;
    for(i = 0; i<[myWatchList count]; i++)
	aSpace = aSpace | [[myWatchList objectAt:i] space];
    return aSpace;
}

- (BOOL) directionAt:(int)index;
{
    return [self spaceAt:index];
}

- (spaceIndex) direction;
{
    return [self space];
}

- (int) dimension;
{
    int i;
    unsigned int d=0;
    for(i=0;i<MAX_SPACE_DIMENSION; i++){
	spaceIndex aSpace = [self space];
	if(aSpace & 1<<i)
	    d++;
    }
    return d;
}

- (int) dimensionAtIndex:(int)index;
{/* this gives the dimension until the coordinate given by index */
    int i;
    int d=0;
    index = index<MAX_SPACE_DIMENSION ? index : MAX_SPACE_DIMENSION-1;
    for(i=0;i<=index; i++){
	spaceIndex aSpace = [self space];
	if(aSpace & 1<<i)
	    d++;
    }
    return d;
}

- (int) dimensionOfIndex:(int)index;
{/* this gives the dimension OF the coordinate given by index */
    if ([self spaceAt:index])
	return [self dimensionAtIndex:index];
    return -1;
}

- (int) indexOfDimension:(int)dimension;
{
    int index;
    for (index=0; index<MAX_SPACE_DIMENSION && dimension; index++)
	if ([self spaceAt:index])
	    dimension--;
    return dimension ? -1 : index-1;
}


- (BOOL) isSubspaceFor:(spaceIndex) aSpace;
{
    spaceIndex space = [self space];
    return space == (space & aSpace);
}

- (BOOL) isSuperspaceFor:(spaceIndex) aSpace;
{
    return aSpace == ([self space] & aSpace);
}


- (double)baryWeightAt:(unsigned int)index;
{
    if (index<[myWatchList count])
	return myBaryWeights[index];
    return 0.0;
}

- (double)deformationAt:(unsigned int)index;
{
    if (index<[myWatchList count])
	return myDeformations[index];
    return 0.0;
}

- setBaryWeight:(double)bary at:(unsigned int)index;
{
    if (index<[myWatchList count]) {
	myBaryWeights[index] = bary;
	[myLPS weightWatcherChanged];
    }
    return self;
}

- setDeformation:(double)deform at:(unsigned int)index;
{
    if (index<[myWatchList count]) {
	myDeformations[index] = deform;
	[myLPS weightWatcherChanged];
    }
    return self;
}



/* spline methods */
- (double)weightSumAt:anEvent;
{
    int i, c = [myWatchList count];
    double s = 0;
    [anEvent ref];
    
    if(!myProductFlag){
	for(i = 0; i < c; i++){
	    id obi = [self weightObjectAt:i];
	    if([obi isSubspaceFor:[anEvent space]]) {/* disregard incompatible space combinations */
		id projEvent = [[anEvent projectTo:[obi space]]ref];
		s += myBaryWeights[i]*[obi splineAt:projEvent 
			lowNorm:myLoNorms[i] highNorm:myHiNorms[i] tolerance:myTolerances[i]
			inversion:myInvertFlags[i] deformation:myDeformations[i]];
		[projEvent release];
	    }
	}
    }
    else{
	s=1;
	for(i = 0; i < c; i++){
	    id obi = [self weightObjectAt:i];
	    if([obi isSubspaceFor:[anEvent space]]) {/* disregard incompatible space combinations */
		id projEvent = [[anEvent projectTo:[obi space]]ref];
		s *= myBaryWeights[i]*[obi splineAt:projEvent 
			lowNorm:myLoNorms[i] highNorm:myHiNorms[i] tolerance:myTolerances[i]
			inversion:myInvertFlags[i] deformation:myDeformations[i]];
		[projEvent release];
	    }
	    
	}
    }
    /* free objects that were not referenced before */
    [anEvent release];	
    return s? s: 1.0; /* weights should be 1 in order to be without effect */
}


- (double)weightBDSumIn:(int)index at:anEvent;
{
    int i, c = [myWatchList count];
    double s = 0;
    spaceIndex spInd = spaceOfIndex(index);
    [anEvent ref];
    if([anEvent isSuperspaceFor:spInd]){
	id projEvent = [[anEvent projectTo:spInd]ref];

	if(!myProductFlag){
	    for(i = 0; i < c; i++){
		id obi = [self weightObjectAt:i];
		if([obi isSuperspaceFor:spInd]) {/* should be able to project onto index */
		    s += myBaryWeights[i]*[obi bDSplineAt:projEvent to:index 
			    lowNorm:myLoNorms[i] highNorm:myHiNorms[i] tolerance:myTolerances[i]
			inversion:myInvertFlags[i] deformation:myDeformations[i]];
		}
	    }
	}
	else{
	    s=1;
	    for(i = 0; i < c; i++){
		id obi = [self weightObjectAt:i];
		if([obi isSuperspaceFor:spInd]) {/* should be able to project onto index */
		    s *= myBaryWeights[i]*[obi bDSplineAt:projEvent to:index 
			    lowNorm:myLoNorms[i] highNorm:myHiNorms[i] tolerance:myTolerances[i]
			inversion:myInvertFlags[i] deformation:myDeformations[i]];
		}
	    }
	}
	[projEvent release];

    }
    /* free objects that were not referenced before */
    [anEvent release];	
    return s? s: 1.0; /* weights should be 1 in order to be without effect */
}


- (double)partial:(int)index ofWeightSumAt:anEvent;
{
    int i, c = [myWatchList count];
    double s = 0;
    [anEvent ref];

    if(index){
	double weightCombination = [self weightSumAt:anEvent];
	if(!myProductFlag){
	    for(i = 0; i < c; i++){
		id iWeight = [self weightObjectAt:i];
		if( [iWeight isSubspaceFor:[anEvent space]] && 
		    [iWeight spaceAt:index]){
		    /* disregard incompatible or irrelevant space combinations */
		    id projEvent = [[anEvent projectTo:[iWeight space]]ref];

		    s += myBaryWeights[i]*[iWeight partial:index ofSplineAt:projEvent 
			lowNorm:myLoNorms[i] highNorm:myHiNorms[i] tolerance:myTolerances[i]
			inversion:myInvertFlags[i] deformation:myDeformations[i]];

		    [projEvent release];
		    }
		}
	    }
	else{double iCombi;
	    for(i = 0; i < c; i++){
		id 	iWeight = [self weightObjectAt:i],
		 	projEvent = [[anEvent projectTo:[iWeight space]]ref];
		if( [iWeight isSubspaceFor:[anEvent space]] && 
		    [iWeight spaceAt:index] &&
		    (iCombi = [iWeight splineAt:projEvent 
			    lowNorm:myLoNorms[i] highNorm:myHiNorms[i] tolerance:myTolerances[i]
			    inversion:myInvertFlags[i] deformation:myDeformations[i]])){
		    /* disregard incompatible or irrelevant space combinations and vanishing factors */
		    s += (weightCombination/iCombi)*
			[iWeight partial:index ofSplineAt:projEvent 
			lowNorm:myLoNorms[i] highNorm:myHiNorms[i] tolerance:myTolerances[i]
			inversion:myInvertFlags[i] deformation:myDeformations[i]];
		    
		    }
		[projEvent release];
		}
	    }
	}
    /* free objects that were not referenced before */
    [anEvent release];	
    return s;
}
  
    
/* gradient of a weight function, perhaps better a WeightWatcher method? */
- gradientAt:anEvent;
{
    int i, row;
    id gradient = nil;
    [anEvent ref];
    
    row = [anEvent rows];
    gradient = [[MathMatrix alloc]initRows:row Cols:1 andValue:0.0 withCoefficients:YES];

    for(i = 1; i<=row; i++)
	[gradient setDoubleValue:[self partial:[anEvent dimensionOfIndex:i] ofWeightSumAt:anEvent]
		    at:i-1];
    /* free objects that were not referenced before */
    [anEvent release];	
    return gradient;
}



@end

/* Simplex.m */

#import <MathMatrixKit/MathMatrix.h>

#import "Simplex.h"
#import <Rubette/MatrixEvent.h>
#import <Rubette/space.h>

@implementation Simplex

/* Special Class methods */
+ simplexOfLineIn:aDirection from:anEvent;
{
    id lineSimplex = nil;
    [anEvent ref]; 
    [aDirection ref]; 

    if([aDirection space] == [anEvent space]){
	lineSimplex = [[Simplex alloc] initWithSpace:[anEvent space] andDimension:1];
	[[lineSimplex replacePointAt:0 with:anEvent] replacePointAt:1 with:[anEvent XsumWith: aDirection]];
	[lineSimplex setRegularity:![aDirection isZero]];
    }

    /* free objects that were not referenced before */
    [anEvent release]; 
    [aDirection release];
    return lineSimplex;
}


/* import the standard SpaceProtocol acc to protocol */
#import "SpaceProtocolMethods.m"

/* standard object methods to be overridden */
- init;
{
    [super init];
    /* class-specific initialization goes here */
    mySpace = 0;
    myPoints = [[[MathMatrix alloc] initRows:1 Cols:0 andValue:0.0 withCoefficients:NO]ref];
    [myPoints setCoeffClass:[MatrixEvent class]];
    myNeighborhood = 1.0e-6;
    
    curEvent = nil;
    curOrthoBaryCoord = nil;
    curSimplexComponent = nil;
    curOrthoComponent = nil;
    curMinimalPoint = nil;
    
    return self;
}

- initWithSpace:(spaceIndex)aSpace andDimension:(unsigned int)aDimension;
{
    int i, di;
    [self init];
    mySpace = aSpace;
    [myPoints setColumns:aDimension+1];
    [myPoints setDoubleValue:0.0];
    [myPoints convertToRealMatrix];
    di = [self dimension];
    for(i = 0; i<aDimension+1; i++)
	[[[myPoints matrixAt:i] setSpaceTo:mySpace] setDoubleValue: 1.0 at:(i+1<di ? i+1 : di):1];

    myRegularity = aDimension<=[[myPoints matrixAt:0] dimension];

    return self; 
}

- (void)dealloc;
{
    /* class-specific initialization goes here */
    [myPoints release];
    myPoints = nil;

    [curEvent release];
    [curOrthoBaryCoord release];
    [curSimplexComponent release];
    [curOrthoComponent release];
    [curMinimalPoint release];

    return [super dealloc];
}

- copyWithZone:(NSZone*)zone;
{
    Simplex *myCopy = JGSHALLOWCOPY;
    myCopy->myPoints = [[myPoints cloneFromZone:zone]ref];
    /* we always want to have indipendent simplex poits so
     * so we use the clone method of the MathMatrix class
     */
    myCopy->myRegularity = myRegularity;
    myCopy->myNeighborhood = myNeighborhood;
    
    myCopy->curEvent = [curEvent ref];
    myCopy->curOrthoBaryCoord = [curOrthoBaryCoord ref];
    myCopy->curSimplexComponent = [curSimplexComponent ref];
    myCopy->curOrthoComponent = [curOrthoComponent ref];
    myCopy->curMinimalPoint = [curMinimalPoint ref];
     
    return myCopy;
}


- (id)initWithCoder:(NSCoder *)aDecoder;
{
//    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    myPoints = [[[aDecoder decodeObject] retain] ref];
    [aDecoder decodeValuesOfObjCTypes:"ccd", &mySpace,
				&myRegularity,
				&myNeighborhood];
    
    curEvent = [[[aDecoder decodeObject] retain] ref];
    curOrthoBaryCoord = [[[aDecoder decodeObject] retain] ref];
    curSimplexComponent = [[[aDecoder decodeObject] retain] ref];
    curOrthoComponent = [[[aDecoder decodeObject] retain] ref];
    curMinimalPoint = [[[aDecoder decodeObject] retain] ref];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
//    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myPoints];
    [aCoder encodeValuesOfObjCTypes:"ccd", &mySpace,
				&myRegularity,
				&myNeighborhood];
   
    /* now, write those instance variables for 
     * optimated calculation via NXWriteObjectReference,
     * i.e. only if they're used elsewhere.
     */
    [aCoder encodeConditionalObject:curEvent];
    [aCoder encodeConditionalObject:curOrthoBaryCoord];
    [aCoder encodeConditionalObject:curSimplexComponent];
    [aCoder encodeConditionalObject:curOrthoComponent];
    [aCoder encodeConditionalObject:curMinimalPoint];
}


- (id) curMinimalPoint
{
	return curMinimalPoint;
}

- (void) setCurMinimalPoint:(id)newCurMinimalPoint
{
	[newCurMinimalPoint retain];
	[curMinimalPoint release];
	curMinimalPoint = newCurMinimalPoint;
}




/* space control */
- (int)simplexDimension;
{
    return [myPoints columns]-1;
}

- (int)rank;
{
    int rank = 0;
    
    if([myPoints columns]>1) {
	id matrix = [myPoints affineDifference];
	rank = [matrix rank];
	if (!NEWRETAINSCHEME) [matrix release];
    }
    return rank;
}


- (BOOL)regularity;
{
    return myRegularity;
}

- setRegularity:(BOOL)flag;
{
    myRegularity = flag;
    return self;
}


- (double)neighborhood;
{
    return myNeighborhood;
}

- setNeighborhood:(double)aNeighborhood;
{
    if(aNeighborhood) 
	myNeighborhood = fabs(aNeighborhood);
    return self; /* hence, myNeighborhood is always positive */
}

/* Simplex point access */
- insertPoint:aPoint at:(int)index;
{
    if(	[aPoint isKindOfClass:[MatrixEvent class]] && 
	[aPoint space] == mySpace && 
	0<=index && index<=[myPoints columns]){
	if ([aPoint retainCount]>1)
	    aPoint = [aPoint clone]; /* insert only independent exact copies */
        else
          [aPoint retain];
	index++; /* simplices count from 0, matrices columns from 1 */
	[myPoints insertCol:aPoint at:index];
        [aPoint release];
	myRegularity = ([self simplexDimension]==[self rank]);
	[self calculateForEvent:nil]; /* reset calculation variables */
    }
    return self;
}

- replacePointAt:(int)index with:aPoint;
{
    if(	[aPoint isKindOfClass:[MatrixEvent class]] && 
	[aPoint space] == mySpace && 
	0<=index && index<[myPoints columns]){
	if ([aPoint retainCount]>1)
	    aPoint = [aPoint clone]; /* insert only independent exact copies */
        else
          [aPoint retain];
	[myPoints replaceMatrixAt:index with:aPoint];
        [aPoint release];
	myRegularity = ([self simplexDimension]==[self rank]);
	[self calculateForEvent:nil]; /* reset calculation variables */
    }
    return self;
}

- removePointAt:(int)index;
{
    index++; /* simplices count from 0, matrices columns from 1 */
    if(2<=[myPoints columns] && 1<=index && index<=[myPoints columns]){
	[myPoints removeColAt:index];
	myRegularity = ([self simplexDimension]==[self rank]);
	[self calculateForEvent:nil]; /* reset calculation variables */
    }
    return self;
}

- addPoint:aPoint;
{
    return [self insertPoint:aPoint at:[myPoints columns]];
}

- pointAt:(int)index;
{
    return [[myPoints matrixAt:(unsigned int)index] clone];
}

- face:(unsigned int)index;
{
    id face;
    if(2<=[myPoints columns] && index<[myPoints columns]){
	face = [self copy];

	[face removePointAt:index];
        if (NEWRETAINSCHEME) [face autorelease];
	return face;
    }
    return nil;
}


- setDoubleValue:(double)aValue ofPointAt:(int)pointIndex atIndex:(int)index;
{
    [[myPoints matrixAt:(unsigned int)pointIndex] setDoubleValue:aValue atIndex:index];
    return self;
}

- (double) doubleValueOfPointAt:(int)pointIndex atIndex:(int)index;
{
    return [[myPoints matrixAt:(unsigned int)pointIndex] doubleValueAtIndex:index];
}


/* maintain calc optimization */
- (BOOL) calculateForEvent:anEvent;
{
    if (curEvent!=anEvent || !curEvent) {
	[curEvent release]; 
	[curOrthoBaryCoord release];
	[curSimplexComponent release];
	[curOrthoComponent release];
	[curMinimalPoint release];
	
	curEvent = [anEvent ref];
	curOrthoBaryCoord = nil;
	curSimplexComponent = nil;
	curOrthoComponent = nil;
	curMinimalPoint = nil;
	
	return YES;
    }
    
    return NO;
}


/* the following methods are introduced from HitPointMethoden.m */
/* returns the column matrix with the coefficients ot the simplex points yielding the
event©s orthogonal decomposition component coefficients of the simplex points */
- orthoBaryCoordinatesOf:anEvent;
{
    if ([self calculateForEvent:anEvent] || !curOrthoBaryCoord) {
	id pointClone, colMatrix, coeffMatrix, diffEvent;
        double valSum; //jg tmp
	if([anEvent space] == mySpace && myRegularity){
	    pointClone = [myPoints Xstrip];
	    diffEvent = [anEvent XdifferenceTo:[pointClone colMatrixAt:1 asCopy:NO]];
	    colMatrix = [pointClone affineDifference];
	    coeffMatrix = [colMatrix clone];
            [coeffMatrix transpose];
            do {
              id prod;
              id inv;
              id qF;
              prod=[coeffMatrix productWith:diffEvent];
              qF=[colMatrix quadraticForm];
              inv=[qF inverse];
              if (!NEWRETAINSCHEME) [qF release];
              [coeffMatrix release];
              if (!NEWRETAINSCHEME) [colMatrix release];
  	      coeffMatrix = [inv productWith:prod]; /* one column of coefficients */
              if (!NEWRETAINSCHEME) [inv release];
              if (!NEWRETAINSCHEME) [prod release];
              } while (0);
            valSum=[coeffMatrix valueSum];
	    [coeffMatrix insertRow:1];
	    [coeffMatrix setDoubleValue:1 -valSum at:0];
            // [curOrthoBaryCoord release]; maybe this should be here!
	    curOrthoBaryCoord = [coeffMatrix emancipate]; /*this frees any unneccessary operand objects*/
	    [curOrthoBaryCoord ref]; /* we keep a reference to it, so we have to increment the refCount */
            // ref commented in at 29.12.00 jg 
            // the reference is inside coeffMatrix, which is not used anymore.
	} else {
            [curOrthoBaryCoord release];
	    curOrthoBaryCoord = nil;
	}
    }
    return curOrthoBaryCoord;
} 
	

/* returns the simplex MatrixEvent for the orthoBaryCoordinates */
- simplexComponentOf:anEvent;
{
    if ([self calculateForEvent:anEvent] || !curSimplexComponent) {
	int i;
	[self orthoBaryCoordinatesOf:anEvent];
        curSimplexComponent = [self pointAt:0]; // jg original with next line /* gives a clone */ 
        [curSimplexComponent scaleBy:(float)[curOrthoBaryCoord doubleValueAt:0]]; 
	for(i=1; i<[myPoints columns]; i++) {
	    id scalePoint = [self pointAt:i];
            [scalePoint scaleBy:(float)[curOrthoBaryCoord doubleValueAt:i]];
	    [curSimplexComponent shiftBy:scalePoint];
	    //scalePoint = [scalePoint free]; /* shiftBy frees not referenced operands */
	}
	[curSimplexComponent ref]; /* we keep a reference to it, so we have to increment the refCount */
    }
    return curSimplexComponent;
}


- orthogonalComponentOf:anEvent;
{
    if ([self calculateForEvent:anEvent] || !curOrthoComponent) {
	id simplexCompEvent;
	
	curOrthoComponent = [anEvent clone];
	simplexCompEvent = [[self simplexComponentOf:anEvent] clone];
        [simplexCompEvent scaleBy:-1.0];
	[curOrthoComponent shiftBy:simplexCompEvent];
	
	//[simplexCompEvent free];/* shiftBy frees not referenced operands */
	
	[curOrthoComponent ref]; /* we keep a reference to it, so we have to increment the refCount */
    }
    return curOrthoComponent; /* no change of the anEvent */
}		


- (BOOL)contains:anEvent; /* Simplex method to decide whether a simplex contains an event */
{
    return ![self orthogonalComponentOf:anEvent] && [[self orthoBaryCoordinatesOf:anEvent] isPositive];
}




/* advanced methods */

- minimalSimplexPointTo:anEvent; /* 	gives a point within the (here possibly degenerate!) 
					simplex with minimal distance to anEvent, as being 
					*expressed* as a matrix of barycentric coordinates, 
					together with the square euclidean distance 
					to anEvent fixed on the doubleValue! */
{	
 
    if ([self calculateForEvent:anEvent] || !curMinimalPoint) {
      int i;
	id simplexComponent, tmp;
	[self setCurMinimalPoint:nil];
	if([anEvent space] == mySpace){
	
	    /* zero-dimensional simplex */
	    if(![self simplexDimension]) {
		[anEvent ref];
		tmp = [[myPoints matrixAt:0] differenceTo:anEvent];
		curMinimalPoint = [[MathMatrix alloc]initIdentityMatrixOfWidth:1];
		[curMinimalPoint setDoubleValue:[tmp euclideanValue]]; /* square distance */
		if (!NEWRETAINSCHEME) [tmp release];
		[anEvent deRef];
	    }
	
	    /* nondegenerate simplex */
	    else if(myRegularity){	
	    
		    /* simplex component in the simplex */
		if([[self orthoBaryCoordinatesOf:anEvent] isPositive]){ 
		    curMinimalPoint = [curOrthoBaryCoord clone]; /* by now these are the current ones */
		    if([self simplexDimension] == [self dimension])
			[curMinimalPoint setDoubleValue:0];
		    else{
			[curMinimalPoint setDoubleValue:[[self orthogonalComponentOf:anEvent] euclideanValue]];
		    }
		}
    
		    /* the simplex component is not contained in the simplex */
		else{ 
		    id aFace = [self face:0];
		    simplexComponent = [self simplexComponentOf:anEvent];
		    curMinimalPoint = [[aFace minimalSimplexPointTo:simplexComponent]retain];
                    if (!NEWRETAINSCHEME) [aFace release];
    
		    for(i=1;i<=[self simplexDimension]; i++){
			aFace = [self face:i];
			tmp = [aFace minimalSimplexPointTo:simplexComponent];
    
			if([curMinimalPoint doubleValue]>[tmp doubleValue]){
			    [self setCurMinimalPoint:tmp];
			} 
			
                        if (!NEWRETAINSCHEME) [aFace release];
		    }
    
		    [curMinimalPoint setDoubleValue:[curMinimalPoint doubleValue]
			    +[[self orthogonalComponentOf:anEvent]euclideanValue]]; /* this is pythagoras ! */
		}
	    }
			
	    /* degenerate simplex */ 
	    else{
		id aFace = [self face:0];
		curMinimalPoint = [[aFace minimalSimplexPointTo:anEvent]retain];
                if (!NEWRETAINSCHEME) [aFace release];
   
		for(i=1;i<[myPoints columns]; i++){
		    aFace = [self face:i];
		    tmp = [aFace minimalSimplexPointTo:anEvent];
		    
		    if([curMinimalPoint doubleValue]>[tmp doubleValue]){
			[self setCurMinimalPoint:tmp];
		    } 
		
                    if (!NEWRETAINSCHEME) [aFace release];
		}
	    }
// jg: curMinimalPoint got a retainCount of 1.
//	    if (![curMinimalPoint references]) /* might be already referenced from code above */
//		[curMinimalPoint ref]; /* we keep a reference to it, so we have to increment the refCount */
	}
    }
    return curMinimalPoint; // retain autorelease?
}


- (BOOL) isVeryNearTo:anEvent;
{
    if([anEvent space] == mySpace) {
	return [[self minimalSimplexPointTo:anEvent] doubleValue] < myNeighborhood;
    }
    return NO;
}

- (double)cosineFactorOf:anEvent in:aDirection;
{
    int i;
    double dVal = 0.0;
    [anEvent ref];
    [aDirection ref];
    
    if(![aDirection isZero] && [anEvent space] == [aDirection space]){

	for (i=0; i<[anEvent rows]; i++)
	    dVal += [aDirection doubleValueAt:i]*[anEvent doubleValueAt:i];

	dVal = dVal/[aDirection euclideanValue];

    }
    /* free objects that were not referenced before */
    [anEvent release]; 
    [aDirection release];
    return dVal;
}

- minimalSimplexPointTo:anEvent in:aDirection;
{
    int i;
    id flatCopy, basePoint, lineSimplex, miniPoint = nil;
    
    [anEvent ref]; 
    [aDirection ref]; 
    
    if([anEvent space] == mySpace && [aDirection space] == mySpace){
      id scaleMatrix;
	flatCopy = [self copy];
	lineSimplex = [[self class] simplexOfLineIn:aDirection from:anEvent];
	
        scaleMatrix=[aDirection scaleWith:[self cosineFactorOf:anEvent in:aDirection]];
	basePoint = [[anEvent XdifferenceTo: scaleMatrix]ref];
        if (!NEWRETAINSCHEME) [scaleMatrix release];
    
	for(i = 0; i<=[self simplexDimension]; i++) {
	    id flatPoint, sumMatrix;
	    flatPoint = [[flatCopy pointAt:i]ref];
	    sumMatrix = [[lineSimplex orthogonalComponentOf:flatPoint] XsumWith: basePoint];
	    [flatCopy replacePointAt:i with:sumMatrix];
	    [flatPoint release];
	    //[sumMatrix free];
	}
	
	miniPoint = [[flatCopy minimalSimplexPointTo:basePoint]ref]; // jg?? add autorelease here?
    
	[flatCopy release];
	[basePoint release];
        if (!NEWRETAINSCHEME) [lineSimplex release]; // dont know, if simplexOfLineIn retains...
    }

    /* free objects that were not referenced before */
    [anEvent release]; 
    [aDirection release];
    return miniPoint;
}

- (double)minimalSimplexParameterTo:anEvent in:aDirection;
{
    id miniPoint;
    int i;
    double para = 0.0, cosEvtDir;

    [anEvent ref]; 
    [aDirection ref]; 

    if (mySpace == [aDirection space] && mySpace == [anEvent space]) {
	miniPoint = [self minimalSimplexPointTo:anEvent in:aDirection];
	cosEvtDir = [self cosineFactorOf:anEvent in:aDirection];
    
	for(i=0; i<=[self simplexDimension]; i++){
	    para += ([self cosineFactorOf:[myPoints matrixAt:i] in:aDirection]-cosEvtDir)*[miniPoint doubleValueAt:i];
	}
	
	[miniPoint release];
    }
    /* free objects that were not referenced before */
    [anEvent release]; 
    [aDirection release];
    return para;
}



@end

@implementation Simplex (SpaceProtocolMethods)

/* overridden SpaceProtocolMethods */
- (spaceIndex)space;
{
    return mySpace;
}


- setSpaceAt:(int)index to:(BOOL)flag;
{
    if (index<MAX_SPACE_DIMENSION) {
	int i;
	if (flag) {
	    mySpace = mySpace | 1 << index;
	} else {
	    mySpace = mySpace & ~(1 << index);
	}
	for (i=0; i<[myPoints columns]; i++)
	    [[myPoints matrixAt:i]setSpaceAt:index to:flag];
    }
    [self calculateForEvent:nil]; /* reset calculation variables */
    return self;
}

- setSpaceTo:(spaceIndex)aSpace;
{
    if (aSpace!=mySpace) {
	int i;
	mySpace = aSpace;
	for (i=0; i<[myPoints columns]; i++)
	    [[myPoints matrixAt:i]setSpaceTo:aSpace];
    }
    [self calculateForEvent:nil]; /* reset calculation variables */
    return self;
}

@end

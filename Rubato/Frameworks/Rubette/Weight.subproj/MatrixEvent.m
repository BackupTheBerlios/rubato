/* MatrixEvent.m */

#import "MatrixEvent.h"
#import "space.h"

@implementation MatrixEvent

/* special class methods */
+ newFromPointer:(double *)eventPointer withSpace:(spaceIndex)aSpace;
{
    return [[self alloc]initFromPointer:eventPointer withSpace:aSpace];
}


/* Import the standard SpaceProtocolMethods */
#import "SpaceProtocolMethods.m"

/* standard object methods to be overridden */
- init;
{
//    int index;
    [super init];
//    myRows = MAX_SPACE_DIMENSION;
//    myCols = 1;
    myValue = 0.0;
    [self convertToRealMatrix];
    mySpace = 1;
    mySatellites=nil;
//    for (index=0; index<MAX_SPACE_DIMENSION; index++)
//	mySpace = mySpace | 1 << index;
    return self;
}

- initRows:(int)rowCount Cols:(int)colCount andValue:(double)value withCoefficients:(BOOL)cFlag;
{
    [self init];
    myValue = value; 
    return self;
}

- initIdentityMatrixOfWidth:(int)width;
{
    [self init];
    return self;
}

- initElementaryMatrixWithRows:(int)rowCount Cols:(int)colCount andValue:(double)value at:(int)row:(int)col 
{
    [self init];
    return self;
}

- initWithSpace:(spaceIndex)aSpace;
{
    [self init];
    [self setSpaceTo:aSpace];
    return self;
}


- initWithSpace:(spaceIndex)aSpace andValue:(double)value;
{
    int i, count;
    [self initWithSpace:aSpace];
    
    count = [myCoefficients count];
    for(i=0; i<count;i++)
	[self setDoubleValue:value at:i];
    return self;
}


/* Transform a pointer into a MatrixEvent, the converse is makePointer method */
- initFromPointer:(double *)eventPointer withSpace:(spaceIndex)aSpace;
{
    int i, di;
    [self initWithSpace:aSpace];

    di = [self dimension];
    for(i=0; i<di;i++)
	[self setDoubleValue:eventPointer[i] at:i];
    return self; 
}

- (void)dealloc;
{
    /* do NXReference houskeeping */
    
    [mySatellites release];
    mySatellites = nil;
    [super dealloc];
}

- copyWithZone:(NSZone*)zone;
{
    MatrixEvent *myCopy = [super copyWithZone:zone];
    myCopy->mySpace = mySpace;
    myCopy->mySatellites = [mySatellites mutableCopyWithZone:zone]; //jgrelease ohne ref?
    return myCopy;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    [aDecoder decodeValueOfObjCType:"c" at:&mySpace];
    mySatellites = [[aDecoder decodeObject] retain]; // jgrelease
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeValueOfObjCType:"c" at:&mySpace];
    [aCoder encodeObject:mySatellites];
}

- (BOOL)isEqual:anObject;
{
    if (anObject!=self) {
	if ([anObject isKindOfClass:[self class]]) {
	    int i, c=[mySatellites count];
	    id satellites = [anObject satellites];
	    
	    if ([anObject space]==mySpace && [super isEqual:anObject] && c==[satellites count]) {
		for (i=0; i<c && [[mySatellites objectAt:i]isEqual:[satellites objectAt:i]]; i++);
		
		return i==c;
	    }
	}
	return NO;
    }
    return YES;
}

- (unsigned int)hash;
{
    return [super hash] ^ (unsigned int)mySpace;
}


/* special Matrix copying and conversion */
- cloneFromZone:(NSZone*)zone;  
{
    unsigned int index;
    // achtung: MathMatrix (super) ruft self (MatrixEvent) copyFromZone auf.
    MatrixEvent *myCopy = [super cloneFromZone:zone];
    
    if (mySatellites) {
	id satCopy = [[myCopy satellites]freeObjects];  
	for (index=0; index<[mySatellites count]; index++) {
	    [satCopy addObject:[[mySatellites objectAt:index]cloneFromZone:zone]];
	}
    }
    return myCopy;
}

- (void)setSatellites:(NSMutableArray *)satellites;
{
  [satellites retain];
  [mySatellites release];
  mySatellites=satellites;
}
- (selfvoid)setToMatrix:aMatrix;
{
    if ([aMatrix isKindOfClass:[MatrixEvent class]]) {
	[super setToMatrix:aMatrix];
	[self setSatellites:[[aMatrix satellites] mutableCopyWithZone:[self zone]]]; // jgrelease
    }
    else if ([aMatrix isKindOfClass:[MathMatrix class]]
		&& [aMatrix columns]==1 && [aMatrix rows]) {
	int i;
	[myCoefficients freeObjects];
	myValue = [aMatrix doubleValue];
	for (i=0; i<[self dimension]; i++) {
	    if ([aMatrix matrixAt:i])
		[myCoefficients addObject:[aMatrix matrixAt:i]];
	    else
		[self setSpaceAt:[self indexOfDimension:i] to:NO];
	}
    }
}

- (selfvoid)setToCopyOfMatrix:aMatrix;
{
    if ([aMatrix isKindOfClass:[MatrixEvent class]]) {
	int index, satCount = [[aMatrix satellites] count]; 
	[super setToCopyOfMatrix:aMatrix];
	[self setSatellites:[[RefCountList alloc]initCount:satCount]]; // jgrelease
	for (index=0; index<satCount; index++) {
          id clone=[[[aMatrix satellites]
                    objectAt:index]cloneFromZone:[self zone]];
	    [mySatellites addObject:clone];
          [clone release];
	}
    }
    else if ([aMatrix isKindOfClass:[MathMatrix class]]
	    && [aMatrix columns]==1) {
	int i;
	[myCoefficients freeObjects];
	myValue = [aMatrix doubleValue];
	for (i=0; i<[self dimension]; i++) {
          if ([aMatrix matrixAt:i]) {
            id clone=[[aMatrix matrixAt:i]clone];
		[myCoefficients addObject:clone];
                [clone release];
          }
	    else
		[self setSpaceAt:[self indexOfDimension:i] to:NO];
	}
    }
}

- (selfvoid)setToEmptyCopyOfMatrix:aMatrix;
{
    if ([aMatrix isKindOfClass:[MatrixEvent class]]) {
	[super setToEmptyCopyOfMatrix:aMatrix];
	mySpace = [aMatrix space];
	[mySatellites freeObjects];
    }
    else if ([aMatrix isKindOfClass:[MathMatrix class]]
	    && [aMatrix columns]==1) {
	[myCoefficients freeObjects];
	myValue = [aMatrix doubleValue];
    }
}


/* overridden MathMatrix methods */
- (void)insertRow:aRow at:(int)row;
{
    /* nothing may be changed here without accessing the space */
    //return self;
}

- (BOOL)removeRowAt:(int)row;
{
    /* nothing may be changed here without accessing the space */
    return YES;
}


/* emancipative Matrix Operation Methods */
- XresultClass;
{
    return [MatrixEvent class];
}

//- XscaleWith:(double)scalar;	-- this works anyway
//- XsumWith:aMatrix;		-- this works only with selected matrices as usual
//- XdifferenceTo:aMatrix;	-- this works only with selected matrices as usual


- XproductWith:aMatrix;
{
    id new = nil, result = nil;

    //[self ref]; /* Just in case...*/
    result = [[aMatrix productWith:self]emancipate]; /* reverse the operand order */
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];

    return new;
}

- XpowerOfExponent:(int)exp;
{
  if (exp==1) {
    id cp=[self copy];
    id ret=[cp emancipate];
    [cp release];
    return ret;
  }
    return nil;
}

- XtaylorOfExponent:(int)exp;
{
    return nil;
}


- Xadjoint;
{
    return nil;
}

- Xinverse;
{
    return nil;
}

- XaffineDifference;
{
    return nil;
}

- XquadraticForm;
{
    return nil;
}


/* Additional Matrix access */
- (int)rowAt:(int)index;
{
    return [self dimensionOfIndex:index];
}

- (double) doubleValueAtIndex:(int)index;
{
    return [self doubleValueAt:[self dimensionOfIndex:index]-1];
}

- (void)setDoubleValue:(double)aValue atIndex:(int)index;
{
    [self setDoubleValue:aValue at:[self dimensionOfIndex:index]-1];
}

/* satellites access */
- satellites;
{
    return mySatellites;
}

/* Special event calculation */
/* destructive calculation methods */
- (selfvoid)shiftBy:anEvent;
{
    if ([anEvent isKindOfClass:[MatrixEvent class]] && [anEvent space] == mySpace) {
      id sumMatrix=[anEvent sumWith:self];
	anEvent = [sumMatrix emancipate];
	[self setToMatrix:anEvent];
        if (!NEWRETAINSCHEME) [sumMatrix release];
    }
}

- (void)scaleBy:(float)scalar; 
{
    id anEvent;
    anEvent = [[self scaleWith:scalar]emancipate]; 
    [self setToMatrix:anEvent];
    if (!NEWRETAINSCHEME) [anEvent release];
}


- (selfvoid)transformBy:aMatrix;
{
    if ([aMatrix isKindOfClass:[MathMatrix class]]) {
	aMatrix = [[aMatrix productWith:self]emancipate];
	[self setToMatrix:aMatrix];
        if (!NEWRETAINSCHEME) [aMatrix release];
    }
}

- (selfvoid)transformBy:aMatrix andShiftBy:anEvent;
{
   [self transformBy:aMatrix];
   [self shiftBy:anEvent];
}

#if 0
/* this mehtod is already implemented in the MathMatrix */
- (double)euclideanValue; /* Euclidean length of anEvent, a method of symbolicEvent class */
{
    id temp;
    double eucl;
    id cp=[self copy];
    temp = [[cp transpose]productWith: self];
    [cp release];
    eucl = [temp doubleValue];
    if (!NEWRETAINSCHEME) [temp release];
    return eucl;
}

#endif

- (double)norm;
{
#if 0
    int i;
    double s = 0.0;
    id stripMatrix = [self strip];
    
    for(i=0; i<[stripMatrix rows];i++)
	s += pow([stripMatrix doubleValueAt:i],2);

    if (!NEWRETAINSCHEME) [stripMatrix release];
    return s;
#endif
    return [self stripEuclideanValue];
}

/* productive calculation methods */
- projectTo:(spaceIndex)aSpace;
{
    if ([self isSuperspaceFor:aSpace]) {
	id projEvent = [self clone];
	[projEvent setSpaceTo:aSpace];
        if (NEWRETAINSCHEME) [projEvent autorelease];
        //else [self release];
	return projEvent;
    }
    return nil;
}

- injectInto:(spaceIndex)aSpace;
{
    if ([self isSubspaceFor:aSpace]) {
	id projEvent = [self clone];
	[projEvent setSpaceTo:aSpace];
        if (NEWRETAINSCHEME) [projEvent autorelease];
        //else [self release];
	return projEvent;
    }
    return nil;
} 

- parajectTo:(spaceIndex)aSpace;
{
    id projEvent = [self clone];
    [projEvent setSpaceTo:aSpace];
    if (NEWRETAINSCHEME) [projEvent autorelease];
    //else [self release];
    return projEvent;
}


/* Alteration "from basisIndex to pianolaIndex" */
- alterateAt:(int)basisIndex :(int)pianolaIndex;
{
    id	alterateEvent;
    
    if([self spaceAt:basisIndex] && [self spaceAt:pianolaIndex]){
	
	alterateEvent = [self clone];
        [alterateEvent setDoubleValue:[self doubleValueAtIndex:basisIndex] +[self doubleValueAtIndex:pianolaIndex] atIndex:basisIndex];
        if (NEWRETAINSCHEME) [alterateEvent autorelease];
	//else   [self release];
	return alterateEvent;
    }
    return nil;
} 

- alterate;
{
    int i;
    id alterateEvent = [self clone];
    for(i=MAX_BASIS_DIMENSION; i<MAX_SPACE_DIMENSION; i++){
	if([self spaceAt:i-MAX_BASIS_DIMENSION] && [self spaceAt:i])
	    [alterateEvent setDoubleValue:
		    [self doubleValueAtIndex:i-MAX_BASIS_DIMENSION]
		    +[self doubleValueAtIndex:i] atIndex:i-MAX_BASIS_DIMENSION];
	}
    if (NEWRETAINSCHEME) [alterateEvent autorelease];
    //else [self release];
    return alterateEvent;
}


/* conversion into pointer for RKF integration */
- (double *)makePointer; 
{
    int i, di;
    double *pointer;
    di = [self dimension];
    pointer = calloc(di, sizeof(double));
    for(i=0; i<di; i++)
	pointer[i] = [self doubleValueAt:i];

    return pointer;
}



- simplexOfLineIn:aDirection; /* a method for symEvents */
{
    id lineMatrix;
    int i;
    lineMatrix = [self clone];
    [lineMatrix addColumn];

    for(i=1; i<=[self rows]; i++)
	[lineMatrix replaceMatrixAt:i:2 with:[[lineMatrix matrixAt:i:1] sumWith:[aDirection matrixAt:i]]];

    if (NEWRETAINSCHEME) [lineMatrix autorelease];
    return lineMatrix;
}

// jg compareTo wird von MathMatrix geerbt.

/* Implementation of Ordering protocol */
- (BOOL)largerThan:anObject; 
{
    if ([anObject isKindOfClass:[self class]]) {
	if ([self space]==[anObject space]) {
	    int i, d =[self dimension];
	    for (i=0; i<d && ([self doubleValueAt:i] == [anObject doubleValueAt:i]); i++);	
	    return (i<d && ([self doubleValueAt:i] > [anObject doubleValueAt:i]));
	
	} else {/* unequal spaces */
	    
	    return [self space] > [anObject space];
	
	}
    }
    return [super largerThan:anObject];
}


- (BOOL)smallerThan:anObject; 
{
    return ![self largerEqualThan:anObject];
}


- (BOOL)smallerEqualThan:anObject;
{
    return ![self largerThan:anObject];
}


- (BOOL)largerEqualThan:anObject;
{
    if ([anObject isKindOfClass:[self class]]) {
	if ([self space]==[anObject space]) {
	    int i, d =[self dimension];
	    for (i=0; i<d && ([self doubleValueAt:i] == [anObject doubleValueAt:i]); i++);	
	    return (i==d || [self doubleValueAt:i] > [anObject doubleValueAt:i]);
	
	} else {/* unequal spaces */
	    
	    return [self space] >= [anObject space];
	
	}
    }
    return [super largerEqualThan:anObject];
}



@end



@implementation MatrixEvent (SpaceProtocolMethods)

/* overridden SpaceProtocolMethods */
- setSpaceAt:(int)index to:(BOOL)flag;
{
    if (index<MAX_SPACE_DIMENSION) {
	if (flag) {
	    if (![self spaceAt:index] && mySpace) {
	    /* if space was set to 0, the last row wasn©t removed. In this case
	     * we don©t have to insert a new row, just use the old one.
	     */ 
		id aRow = [[MathMatrix alloc]initRows:1 Cols:1 andValue:0.0 withCoefficients:YES];
		[super insertRow: aRow at:[self dimensionAtIndex:index]+1];
		[aRow release];
                aRow = nil;
	    }
	    mySpace = mySpace | 1 << index;
	} else {
	    if ([self spaceAt:index])
		[super removeRowAt:[self dimensionAtIndex:index]];
		/* this will NOT remove the last row */
	    mySpace = mySpace & ~(1 << index);
	}
    }
    return self;
}

- setSpaceTo:(spaceIndex)aSpace;
{
    if (aSpace && aSpace!=mySpace) {
	int index;
	for (index=0; index<MAX_SPACE_DIMENSION; index++){
	    [self setSpaceAt:index to:(aSpace & spaceOfIndex(index))];
	}
    }
    return self;
}

@end

/* LocalPerformanceScore.m */

#import <AppKit/NSApplication.h>
#import "LocalPerformanceScore.h"
#import "PerformanceOperator.h"
#import <Rubette/WeightWatcher.h>
#import <Rubette/space.h>

@implementation LocalPerformanceScore

/* standard class methods to be overridden */
+ (void)initialize;
{
    [super initialize];
    if (self == [LocalPerformanceScore class]) {
	[LocalPerformanceScore setVersion:3];
    }
}



/* standard object methods to be overridden */
- init;
{
    int i;
    BOOL test = YES;
    NSZone *zone;
    [super init];
    zone = [self zone];
    /* class-specific initialization goes here */
    myName = [[StringConverter allocWithZone:zone]init];
    /* class-specific initialization goes here */
    [myName setStringValue:@"Mother LPS"];
    myMother = nil;
    myDaughters = [[[RefCountList alloc]init]ref];
    myInstrument = nil;
    myInitialSet = nil;
    myKernel = [[[OrderedList alloc]init]ref];
    myPerformanceKernel = [[[OrderedList alloc]init]ref];
    myPerformanceTable = [[NSMutableDictionary alloc]init];  // jg was:[[HashTable alloc]initKeyDesc:"@" valueDesc:"@"];
    for(i=0;i<MAX_SPACE_DIMENSION; i++)
	curField[i] = 1.0; /* The generic field*/
    myPerformanceDepth = 0;
    isCalculated = NO;
    
    for (i=0; i<Hierarchy_Size;i++) {
	test = YES;
	test = (i & spaceOfIndex(indexD)) ? test && (i & spaceOfIndex(indexE)) : test;
	test = (i & spaceOfIndex(indexG)) ? test && (i & spaceOfIndex(indexH)) : test;
	test = (i & spaceOfIndex(indexC)) ? test && (i & spaceOfIndex(indexL)) : test;
	myHierarchy[i] = test;
    }
    return self;
}


- initWithLPSFrame:(LPS_Frame *)aFrame;
{
    int index;
    [self init];
    for (index=0; index<MAX_SPACE_DIMENSION; index++) {
	[self setFrame:aFrame+index at:index];
    }
    return self;
}


- initWithLPSFrame:(LPS_Frame *)aFrame andBPInitialSetWithBasisSpace:(spaceIndex)basisSpace;
{
    id bpInitialSet = nil;
    [self initWithLPSFrame:aFrame];
    bpInitialSet = [LPSInitialSet newBPListForLPS:self withSpace:basisSpace];
    [self extendFrameTo:bpInitialSet];
    [self setInitialSet:bpInitialSet];
    return self;
}

- copyWithZone:(NSZone*)zone;
{
    int index;
//    NXHashState aState;
    id aKey, aVal;    
    LocalPerformanceScore *myCopy = JGSHALLOWCOPY; // [super copyWithZone:zone];

    myCopy->myName = [myName copyWithZone:zone];
    myCopy->myMother = [myMother ref];
    myCopy->myDaughters = [myDaughters mutableCopyWithZone:zone];
    myCopy->myInstrument = myInstrument;

    myCopy->myInitialSet = [myInitialSet copyWithZone:zone];
    for (index=0; index<Hierarchy_Size; index++)
	myCopy->myHierarchy[index] = myHierarchy[index];

    for (index = 0; index<MAX_SPACE_DIMENSION; index++)
	myCopy->myFrame[index] = myFrame[index];

    myCopy->myKernel = [myKernel mutableCopyWithZone:zone];

    myCopy->myPerformanceKernel = [myPerformanceKernel mutableCopyWithZone:zone];
    myCopy->myPerformanceTable = [myPerformanceTable copyWithZone:zone];
// jg ist dies in der neuen Version noch noetig???
/*war
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
    
    myCopy->isCalculated = isCalculated;
    myCopy->curEvent = nil;
    for (index = 0; index<MAX_SPACE_DIMENSION; index++)
	myCopy->curField[index] = 1.0;
    myCopy->myPerformanceDepth = myPerformanceDepth;
    return myCopy;
}


- (void)dealloc
{
    /* do NXReference houskeeping */

    /* class-specific initialization goes here */
    [myName release];
    myMother = nil;
    [myDaughters release];
    [myInstrument release];
    [[myKernel freeObjects] release];
    [[myPerformanceKernel freeObjects] release];
    [myPerformanceTable removeAllObjects]; [myPerformanceTable release]; // jg was: [[myPerformanceTable freeObjects] release];
    [myInitialSet release];
    { [super dealloc]; return; };
}


- (id)initWithCoder:(NSCoder *)aDecoder;
{
int i, classVersion = [aDecoder versionForClassName:NSStringFromClass([LocalPerformanceScore class])];
//    [super initWithCoder:aDecoder];
    /* class-specific code goes here */

    myName = [[aDecoder decodeObject] retain];
    myMother = [[[aDecoder decodeObject] retain] ref];
    myDaughters = [[aDecoder decodeObject] retain];
    
    myInstrument = [[aDecoder decodeObject] retain];
    myInitialSet = [[aDecoder decodeObject] retain];
    myKernel = [[aDecoder decodeObject] retain];
    
    myPerformanceKernel = [[aDecoder decodeObject] retain];
    
    if (!classVersion)
	[[aDecoder decodeObject] retain];
    myPerformanceTable = [[NSMutableDictionary alloc]init];  // jg was:[[HashTable alloc]initKeyDesc:"@" valueDesc:"@"];
    
    [aDecoder decodeArrayOfObjCType:"c" count:Hierarchy_Size at:&myHierarchy];
    [aDecoder decodeArrayOfObjCType:"{dd}" count:MAX_SPACE_DIMENSION at:&myFrame];
    
    if (classVersion>2)
	[aDecoder decodeValueOfObjCType:"c" at:&isCalculated];
    else
	isCalculated = NO;
    
    myPerformanceDepth = 0;
    
    curEvent = nil;
    for(i=0;i<MAX_SPACE_DIMENSION; i++)
	curField[i] = 1.0; /* The generic field */
    
    if (classVersion<2) {
	/* convert the old List objects to
	 * RefCounList or OrderedList objects
	 */
	id list = myDaughters;
	myDaughters = [[[RefCountList alloc]initCount:[list count]]appendList:list];
	[list release];
	list = myKernel;
	myKernel = [[[[OrderedList alloc]initCount:[list count]]appendList:list]sort];
	[list release];
	list = myPerformanceKernel;
	myPerformanceKernel = [[[[OrderedList alloc]initCount:[list count]]appendList:list]sort];
	[list release];
    } 
    /* set Reference Counting of read or replaced objects */
    [myDaughters ref];
    [myKernel ref];
    [myPerformanceKernel ref];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
//    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myName];
    [aCoder encodeObject:myMother];
    [aCoder encodeObject:myDaughters];
    [aCoder encodeObject:myInstrument];
    [aCoder encodeObject:myInitialSet];
    [aCoder encodeObject:myKernel];
    
    if (!isCalculated) 
	[myPerformanceKernel freeObjects];
    [aCoder encodeObject:myPerformanceKernel];
    
    [aCoder encodeArrayOfObjCType:"c" count:Hierarchy_Size at:&myHierarchy];
    [aCoder encodeArrayOfObjCType:"{dd}" count:MAX_SPACE_DIMENSION at:&myFrame];

    [aCoder encodeValueOfObjCType:"c" at:&isCalculated];
}

/* get the operator's nib file */
+ (NSString *)inspectorNibFile;
{
    return @"LPSInspector.nib";
}

- setNameString: (const char *)aName;
{
    [myName setStringValue:[NSString jgStringWithCString:aName]];
    return self;
}

- (const char *)nameString;
{
    return [[myName stringValue] cString];
}
- (NSString *)name; // jg added
{
    return [NSString jgStringWithCString:[self nameString]];
}

- getNameString;
{
    return myName;
}

/* get the operator's nib file */
- (NSString *)inspectorNibFile;
{
    return [[self class]inspectorNibFile];
}


- setMother:aMother;/*can only be done once*/
{
    if (!myMother && [aMother isKindOfClass:[LocalPerformanceScore class]])
	myMother = aMother;
    return self;
}

- mother;
{
    return myMother;
}

- operator;
{
    return nil;
}


- setOperatorIndex:(int)index;
{
    return self;
}

- (int)operatorIndex;
{
    return 0;
}

- setInstrument:anInstrument;
{
    myInstrument = anInstrument;
    return self;
}

- instrument;
{
    return myInstrument;
}


- setKernel:aKernel;
{
    if ([aKernel isKindOfClass:[JgList class]] || [aKernel isKindOfClass:[OrderedList class]]) {
	int i, index, c=[aKernel count];
	id anEvent = nil;
	[self invalidate];
	[myKernel freeObjects];
	for (index=0; index<MAX_SPACE_DIMENSION; index++){ /* reset myFrame */
	    for (i=0; i<c && !([anEvent=[aKernel objectAt:i] isKindOfClass:[MatrixEvent class]]
		    && [anEvent spaceAt:index]); i++);
		    		    
	    myFrame[index].origin = i<c ? [anEvent doubleValueAtIndex:index] : 0.0;
	    myFrame[index].end = myFrame[index].origin;
	}
	for (i=0; i<c; i++) {
	    anEvent = [aKernel objectAt:i];
	    if([anEvent isKindOfClass:[MatrixEvent class]]) {
		[myKernel addObjectIfAbsent:anEvent];
		[self extendFrameToEvent:anEvent];
	    }
	}
	[myKernel sort];
	//for (i=0; i<c; i++) /* update the performance table */
	//	[self insertKeyEvent:[myKernel objectAt:i] andPerformance:nil];
        [myDaughters makeObjectsPerformSelector:@selector(setKernel:) withObject:myKernel];
    }
    return self;
}

- kernel;
{
    return myKernel;
}


- setFrame:(LPS_Frame *)aFrame at:(int)index;
{
    if (index<MAX_SPACE_DIMENSION) {
	myFrame[index] = *aFrame;
	[self invalidate];
    }
    return self;
}

- (LPS_Frame *)frameAt:(int)index;
{
    if (index<MAX_SPACE_DIMENSION)
	return &myFrame[index];
    else
	return (LPS_Frame *)NULL;
}

- (LPS_Frame *)frame;
{
    return myFrame;
}

- setFrameOrigin:(double)aDouble at:(int)index;
{
    if (index<MAX_SPACE_DIMENSION && myFrame[index].origin!=aDouble) {
	myFrame[index].origin = aDouble;
	[self invalidate];
    }
    return self;
}

- setFrameEnd:(double)aDouble at:(int)index;
{
    if (index<MAX_SPACE_DIMENSION && myFrame[index].end!=aDouble) {
	myFrame[index].end = aDouble;
	[self invalidate];
    }
    return self;
}

- (double)frameOriginAt:(int)index;
{
    if (index<MAX_SPACE_DIMENSION) 
	return myFrame[index].origin;
    return 0.0;
    
}

- (double)frameEndAt:(int)index;
{
    if (index<MAX_SPACE_DIMENSION) 
	return myFrame[index].end;
    return 0.0;
    
}

- setEdge:(int)edge ofFrameAt:(int)index to:(double)aDouble;
{
    if (index<MAX_SPACE_DIMENSION) {
	if(edge==FRAME_ORIGIN)
	    myFrame[index].origin = aDouble;
	if(edge==FRAME_END)
	    myFrame[index].end = aDouble;
	[self invalidate];
    }
    return self;
}

- (double)edge:(int)edge ofFrameAt:(int)index;
{
    if (index<MAX_SPACE_DIMENSION) {
	if(edge==FRAME_ORIGIN)
	    return myFrame[index].origin;
	if(edge==FRAME_END)
	    return myFrame[index].end;
    }
    return 0.0;
    
}

- (BOOL)frameContains:anEvent;
{
    int i;
    double evi = 0.0, evipia = 0.0; /*evi resp. evipia is the basis resp. the pianola coordinate of index i */
    
    [anEvent ref];
    if(![anEvent dimension])
	return NO; /* don't accept 0 dimensional Events */

    for(i=0; i<MAX_SPACE_DIMENSION; i++){
	if([anEvent spaceAt:i]){
	    evi = [anEvent doubleValueAtIndex:i];
	    evipia = (i+MAX_BASIS_DIMENSION < MAX_SPACE_DIMENSION) ? [anEvent doubleValueAtIndex:i+MAX_BASIS_DIMENSION] : 0.0;
	    if(!(myFrame[i].origin <= evi && 
		    evi < myFrame[i].end))
		return NO;
	}
    }
    [anEvent release];
    return YES;
}

/* this is the designated extension method. It©s the only one that -invalidate the LPS */
- extendFrameTo:anObject;
{
    if ([anObject isKindOfClass:[InitialSet class]])
	[self extendFrameToInitialSet:anObject];
    
    if ([anObject isKindOfClass:[Simplex class]])
	[self extendFrameToSimplex:anObject];
    
    if ([anObject isKindOfClass:[RefCountList class]])
	[self extendFrameToKernel:anObject];
    
    if ([anObject isKindOfClass:[MatrixEvent class]])
	[self extendFrameToEvent:anObject];
    
    [self invalidate];
    return self;
}

- extendFrameToInitialSet:anInitialSet;
{
    int i, c = [anInitialSet listCount];
    for (i=0; i<c; i++) {
	id initialSetAtI = [anInitialSet initialSetAt:i];
	if ([initialSetAtI isInitialSimplex])
	    [self extendFrameToSimplex:[initialSetAtI simplex]];
	else 
	    [self extendFrameToInitialSet:initialSetAtI];
    }
    return self;
}

- extendFrameToSimplex:aSimplex;
{
    int i, c = [aSimplex simplexDimension]+1;
    for (i=0; i<c; i++) {
	id aPoint = [aSimplex pointAt:i];
	[self extendFrameToEvent:aPoint];
        if (!NEWRETAINSCHEME) [aPoint release];
    }
    return self;
}

- extendFrameToKernel: aKernel;
{
    int i, c;
    c = [aKernel count];
    
    for (i=0; i<c; i++)
	[self extendFrameToEvent:[aKernel objectAt:i]];
    
    return self;
}

- extendFrameToEvent:anEvent;
{
    int i;
    double evi = 0.0;
    
    for(i=0; i<MAX_SPACE_DIMENSION; i++){
	evi = [anEvent doubleValueAtIndex:i];

	if ([anEvent spaceAt:i]) {
	    myFrame[i].origin =
	    myFrame[i].origin < evi ? myFrame[i].origin : evi;

	    myFrame[i].end =
	    myFrame[i].end > evi ? myFrame[i].end : evi + 1e-6;
	}    

    }
    return self;
}


- resetFrameToKernel:aKernel;
{
    int index,i, c=[aKernel count];
    id anEvent=nil;
    for (index=0; index<MAX_SPACE_DIMENSION; index++){ /* reset myFrame */
	for (i=0; i<c && !([anEvent=[aKernel objectAt:i] isKindOfClass:[MatrixEvent class]]
		&& [anEvent spaceAt:index]); i++);
				
	myFrame[index].origin = i<c ? [anEvent doubleValueAtIndex:index] : 0.0;
	myFrame[index].end = myFrame[index].origin;
    }
    [self extendFrameToKernel:aKernel];
    return self;
}

/* InitialSet and Hierarchy access and maintenance */
#if 0

- adapt:initialSet;/* adaptation resp. restriction to a frame */
{
    int i, c = [initialSet listCount];
    
    if([initialSet isInitialList]){
	for(i = c-1; 0<=i; i--){
	    id list = [initialSet list];  
	    id adapi = [self adapt:[initialSet initialSetAt:i]];

	    if(adapi == nil)
		[list removeObjectAt:i];
	    else
		[list replaceObjectAt:i with:adapi];
	}
    }
    else{
	id simplex = [initialSet simplex];
	int dimSimplex = [simplex dimension];  
	for(i=0; i<=dimSimplex && [self frameContains:[simplex pointAt:i]]; i++);
	if(i<= dimSimplex)
	    return nil;
    }
    return initialSet;
}
#endif


- setInitialSet:anInitialSet;
{
    if (anInitialSet!=myInitialSet
	&& (!anInitialSet || [anInitialSet isKindOfClass:[LPSInitialSet class]])) {
	if ([anInitialSet ownerLPS]) 
	    anInitialSet = [anInitialSet copy]; // not jgCopy, because it is no List.
	[myInitialSet release];	
	if ([anInitialSet setOwnerLPS:self])
	    myInitialSet = [anInitialSet restrictTo:self];
	[self invalidate];
    }
    return self;
}

- initialSet;
{
    return myInitialSet;
}


- (BOOL)containsDefaultInitialSet:anInitialSet;
{
    if([anInitialSet isInitialSimplex])
	return [[myInitialSet lastInitialSet] contains:anInitialSet];
    else
	return NO;
} 

- setHierarchy:(BOOL *)aHierarchy;
{
    int i;
    for (i=0; i<Hierarchy_Size;i++)
	myHierarchy[i] = aHierarchy[i];
    [self invalidate];
    return self;
}

- (BOOL *) hierarchy;
{
    return myHierarchy;
}

- setHierarchyAt:(int)index to:(BOOL)flag;
{
    if (index<Hierarchy_Size && myHierarchy[index]!=flag) {
	myHierarchy[index] = flag;
	[self invalidate];
    }
    return self;
}

- (BOOL)hierarchyAt:(int)index;
{
    if (index<Hierarchy_Size)
	return myHierarchy[index];
    else
	return NO;
}

/* A LPS method to get the highest hierarchy space index where hierarchy does exist. */
- (spaceIndex)hierarchyTop;
{
    int i;
    for(i = 63; i>=0 && !myHierarchy[i]; i--);
    return (spaceIndex) i; 
}


- (BOOL)hierarchyTopAt:(int)index;
{
    return [self hierarchyTop] & (1 << index);
}

/* get the smallest hierarchy index containing the index aSpace */
- (spaceIndex)hierarchyClosureOfSpace:(spaceIndex)aSpace;
{
    int i = 0;
    spaceIndex clo = 0,
    top = [self hierarchyTop];
    if(!(aSpace & ~top)){
	for(i = top, clo = top; i>=0; i--){
	    if(!(aSpace & ~i) && myHierarchy[i])
	    clo = i & clo;
	}
    }
    return clo;
}

- (spaceIndex)hierarchyInteriorOfSpace:(spaceIndex)aSpace;
{
    int i;
    spaceIndex interior = 0;
    
    for(i=0; i<Hierarchy_Size; i++){
	if(myHierarchy[i] && isStrictSubspace(i,aSpace))
	interior = interior | i;
	}
	
    return interior;
}

- (spaceIndex)fundamentOfSpace:(spaceIndex)aSpace;
{
    int i;
    spaceIndex fundament = [self hierarchyInteriorOfSpace:aSpace];

    for(i=1; i<Hierarchy_Size; i++){ /* i > 0 */
	if(myHierarchy[i] && isStrictSubspace(i,aSpace))
	fundament = fundament & i;
	}
    return fundament;
} 


/* takes place only for non-zero hierarchy spaces */
- (BOOL)hasReducibleSpace:(spaceIndex)aSpace;
{
    return aSpace && myHierarchy[aSpace] && !isStrictSubspace([self hierarchyInteriorOfSpace:aSpace], aSpace);
}


/* takes place only for non-zero hierarchy spaces */
- (BOOL)isFundamentalSpace:(spaceIndex)aSpace;
{
    return aSpace && myHierarchy[aSpace] && ![self hierarchyInteriorOfSpace:aSpace];
}

	
/* takes place only for non-zero hierarchy spaces */
- (BOOL)isDecomposableSpace:(spaceIndex)aSpace;
{
    return myHierarchy[aSpace] && [self fundamentOfSpace:aSpace] && !(aSpace==[self hierarchyInteriorOfSpace:aSpace]);
}


- performanceKernel;
{
    return myPerformanceKernel;
}

- setPerformanceDepth:(int)depth;
{
    myPerformanceDepth = depth;
    return self;
}

- (int)performanceDepth;
{
    return myPerformanceDepth;
}

/*access & creation of daughters*/
- (int)daughterCount;
{
    return [myDaughters count];
}

- daughterAt:(int)index;
{
    return [myDaughters objectAt:index];
}

- makeDaughterWithOperator:anOperator;
{
    id newDaughter = [[anOperator alloc]initWithLPSFrame:myFrame];
    [newDaughter setMother:self];

    [newDaughter setInstrument:myInstrument];
    //[newDaughter setInitialSet:myInitialSet];
    //[newDaughter setHierarchy:myHierarchy];

    [newDaughter setKernel:[self kernel]];

    [myDaughters addObjectIfAbsent:newDaughter];
    
    return newDaughter;
}

- mutateWithOperator:anOperator;
{
    LocalPerformanceScore *myCopy = [self copyWithZone:[self zone]];
    myCopy->myMother = self;
    
    [[myDaughters empty]addObject:myCopy];
    return myCopy;
}

- abandonDaughter:aDaughter;
{
    int index= [myDaughters indexOfObject:aDaughter];
    if (index != NSNotFound) {
        [myDaughters removeObjectAtIndex:index];
	[aDaughter deRef];
    }
    else
	aDaughter = nil;
    return aDaughter;
}

- killDaughter:aDaughter;
{
    int index= [myDaughters indexOfObject:aDaughter];
    if (index != NSNotFound) {
        [myDaughters removeObjectAtIndex:index];
//      [aDaughter release]; // guess thats included in removeObjectAtIndex
	return self;
    }
    return self;
}


/*get the string representation of the operator*/
- (const char*)operatorString;
{
    return "Generic LPS";
}

/* Calculate the performance field components of this operator, 
 * to be implemented specifically, including events not in the total space!
 * For events not in the hierarchy spaces, the values go back to the mother©s values,
 * for the hierarchic ones, the component has to be implemented specifically.
 */
/* maintain calc optimization */
- (BOOL) calculateForEvent:anEvent;
{
    if (curEvent!=anEvent || !curEvent) {
	int i, di;
	[curEvent release]; 
	
	curEvent = [anEvent ref];
	di = [anEvent dimension];
	for(i=0;i<di; i++)
	    curField[i] = 1.0; /* The generic field*/
	
	return YES;
    }
    
    return NO;
}

- (int)hashTableSize;
{
    return [myPerformanceTable count];
}

// version 2
// changed semantic to version 1: also setObject, if keyEvent is in table. (else case was empty because of #ifdefs) 
- insertKeyEvent:keyEvent andPerformance:perfEvent;
{
    if (![myPerformanceTable objectForKey:keyEvent]) {
        if ([myKernel indexOfObject:keyEvent]==NSNotFound) {
            /* it's not our's, make an independent copy */
            keyEvent = [[keyEvent clone] autorelease];
            perfEvent = [[perfEvent clone] autorelease];
        }
    }
    [myPerformanceTable setObject:perfEvent forKey:keyEvent];
    return self;
}

#if 0
// Original
- insertKeyEvent:keyEvent andPerformance:perfEvent;
{
    if (![myPerformanceTable isKey:keyEvent]) {
        if ([myKernel indexOf:keyEvent]==NX_NOT_IN_LIST) {
            /* it's not our's, make an independent copy */
            keyEvent = [keyEvent clone];
            perfEvent = [perfEvent clone];
        }

        [(id)[myPerformanceTable insertKey:[keyEvent ref] value:[perfEvent ref]]free];
    } else {
        NXHashState aState = [myPerformanceTable initState];
        const void *oldKey;
              void *oldVal;

        while([myPerformanceTable nextState:&aState key:&oldKey value:&oldVal] && ![(id)oldKey isEqual:keyEvent]);

        if (oldKey!=keyEvent) {
            [(id)[myPerformanceTable insertKey:[keyEvent ref] value:[perfEvent ref]]free];
            /* since the HashTable replaces the id's when equal-inserting, we have to take care of this effect */
            [(id)oldKey free];
        } else {
            [(id)[myPerformanceTable insertKey:keyEvent value:[perfEvent ref]]free];
            /* else the keyEvent is already in there, i.e. dont need to clone or ref */
        }
    }


    return self;
}
#endif

#if 0
// Version 1 (with #if 0 #else #endif)
// jg: did I create that much code here? see Original
- insertKeyEvent:keyEvent andPerformance:perfEvent;
{
    if (![myPerformanceTable objectForKey:keyEvent]) {
	if ([myKernel indexOfObject:keyEvent]==NSNotFound) {
	    /* it's not our's, make an independent copy */
	    keyEvent = [[keyEvent clone] autorelease];
	    perfEvent = [[perfEvent clone] autorelease];
	}

//#if 0
      // jg the retains are performed by NSMutableDictionary anyway. This is to be reviewed!
#warning see comments in source LocalPerformanceScore.m
        { id oldVal=[myPerformanceTable objectForKey:keyEvent];
          int cnt=[oldVal retainCount]-1;
  	  [myPerformanceTable setObject:[perfEvent ref] forKey:[keyEvent ref]];
	  if (oldVal && cnt) [oldVal release];
        }
    } else {
//	NXHashState aState = [myPerformanceTable initState];
        NSEnumerator *enumerator=[myPerformanceTable keyEnumerator];
	id oldKey;
	id oldVal;
	
//	while([myPerformanceTable nextState:&aState key:&oldKey value:&oldVal] && ![(id)oldKey isEqual:keyEvent]);
        while  ((oldKey = [enumerator nextObject])) {
                oldVal=[myPerformanceTable objectForKey:oldKey];
                if ([(id)oldKey isEqual:keyEvent]) break;
        }

        if (oldKey!=keyEvent) { // jg die Referenzierungen werden sowieso von NSMutableDictionary gemacht. Das hier noch ueberarbeiten!
          { id oldVal=[myPerformanceTable objectForKey:keyEvent];
            int cnt=[oldVal retainCount]-1;
            [myPerformanceTable setObject:[perfEvent ref] forKey:[keyEvent ref]];
            if (oldVal && cnt) [oldVal release];
          }
          /* since the HashTable replaces the id's when equal-inserting, we have to take care of this effect */
            [(id)oldKey release];
	} else {
          { id oldVal=[myPerformanceTable objectForKey:keyEvent];
            int cnt=[oldVal retainCount]-1;
            [myPerformanceTable setObject:[perfEvent ref] forKey:keyEvent];
            if (oldVal && cnt) [oldVal release];
          }
	    /* else the keyEvent is already in there, i.e. dont need to clone or ref */
        }
//#else
          [myPerformanceTable setObject:perfEvent forKey:keyEvent];
//#endif
    }
    
    
    return self;
}
#endif

- (void) invalidate;
{
    isCalculated = NO;
    [myPerformanceTable removeAllObjects];
    [myDaughters makeObjectsPerformSelector:@selector(invalidate)];
}

- validate;
{
    [myPerformanceKernel freeObjects];
    [myKernel sort];
    return self;
}

- (BOOL)isCalculated;
{
    return isCalculated;
}


/*Calculate the Field of a LPS*/
- (double *) performanceFieldPointerAt:anEvent;
{
    double *field;
    int i, di = [anEvent dimension];
   
    if ([self calculateForEvent:anEvent]) {
	if (myMother) {
	    field = [myMother performanceFieldPointerAt:anEvent];
	} else {
	    field = calloc(di, sizeof(double));
	    for(i=0;i<di; i++)
		field[i] = 1.0;
	}
	[self calcPerformanceField:field at:anEvent];
	for(i=0;i<di; i++)
	    curField[i] = field[i];
    } else {
	field = calloc(di, sizeof(double));
	for(i=0;i<di; i++)
	    field[i] = curField[i];
    }
    return field;
}

- calcPerformanceField:(double *)field at:anEvent;
{
    /* this is the field calculation method to be overridden by subclasses */
    return self;
}

- performanceFieldAt:anEvent;
{
    double *field;
    id	fieldMatrix;
    [anEvent ref];
    
    field = [self performanceFieldPointerAt:anEvent];
    fieldMatrix = [MatrixEvent newFromPointer:field withSpace:[anEvent space]];
    free(field);
    
    /* free objects that were not referenced before */
    if (!NEWRETAINSCHEME) [anEvent release];	
    return fieldMatrix;
}

- (double) calcFieldComponent:(int)index at:anEvent;
{
    if ([anEvent spaceAt:index]) {
	free([self performanceFieldPointerAt:anEvent]);
	return curField[[anEvent dimensionOfIndex:index]-1];
    }
    else
	return 1.0; /* The generic field*/
}

/*Calculate the performed events of a LPS*/
- performedEventAt:anEvent;
{
    id perfEvent = [myPerformanceTable objectForKey:anEvent];
    if (!perfEvent)
	perfEvent = [self initialSetPerformanceOfEvent:anEvent
			andInitialSet:myInitialSet];
    return perfEvent;
}

- (double) calcEventComponent:(int)index at:anEvent;
{
    if (myMother)
	return [myMother calcEventComponent:index at:anEvent];
    else
	return [anEvent doubleValueAtIndex:index];
}

/* calculate the performed events of a LPS */
- initialSetPerformanceOfEvent:anEvent andInitialSet:anInitialSet;
{
    int d;
    id perf = [anEvent clone];
    for(d = 0; d < [anEvent dimension]; d++)
	[perf setDoubleValue: [self calcEventComponent:
		[anEvent indexOfDimension:d+1] at:anEvent] at:d];
    [self insertKeyEvent:anEvent andPerformance:perf];
    return perf;
}

/* The entire collector©s work for the performance of the leaves of myPerformanceDepth */

/* Finds all leaves of the subtree defined by myRootLPS and searchDepth */
- collectLeavesAt:(int)depth;
// return value must be released by the caller
{
    int i, dc;
    id theList;
    dc = [self daughterCount]; 
    theList = [[RefCountList alloc]initCount:1];
    
    if(!depth || !dc)
    return [theList insertObject:self  at:0]; 

    else{

    for(i=0; i<dc; i++) {
	id iLeaves = [[self daughterAt:i] collectLeavesAt:depth-1];
	[theList appendList:iLeaves];
	//[iLeaves release];
    }

    return [theList autorelease];
    }
}

- collectLeaves;
{
    return [self collectLeavesAt:myPerformanceDepth];
}

- makePerformedLPSList;
{
    int i, c;
    id performList;
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init]; // debug memory

    performList = [self collectLeaves];
    c = [performList count];

    for(i = 0; i < c; i++){
	[[performList objectAt:i] doPerform];
	}

    [performList retain];
    [pool release];
    [performList autorelease];
    return performList;
}


/*The heavy work: create myPerformanceKernel*/
- doPerform;
{
    if (!isCalculated) {	
	int i, c = [myKernel count];
	//char text[256];
	id eventi, perfEventi;
	//id progressPanel = [NXApp loadNibSection:"Progress.nib" owner:self];
	
	[self validate];
	
	/*
	[[progressPanel progressView]setStepSize:1];
	[[progressPanel progressView]setTotal:c];
	[progressPanel setTitle:[self name]];
	[progressPanel setText:"Calculation Progress:"];
	[[progressPanel makeKeyAndOrderFront:self]display];
	[progressPanel setDelegate:self];
	*/
	
	for(i = 0; i < c;i++){
	    /*
	    NXEvent *theEvent = [NXApp getNextEvent:(int)NX_KEYDOWNMASK
					waitFor:0.0
					threshold:NX_MODALRESPTHRESHOLD];
	    if (theEvent && theEvent->flags & NX_COMMANDMASK && theEvent->data.key.charCode=='.')
		break;
		
	    */
	    //sprintf(text, "Calculation Progress: %u of %u Events", i+1, c);
	    //[progressPanel setText:text];
	    
	    eventi = [myKernel objectAt:i];
	    perfEventi = [self performedEventAt:eventi];
		    
	    [myPerformanceKernel addObjectIfAbsent:perfEventi]; 
	    [self insertKeyEvent:eventi andPerformance:perfEventi]; 

	    //[progressPanel increment:self];
	}
	[myPerformanceKernel sort]; 
	//progressPanel = [[progressPanel close]free];
	isCalculated = i==c;
    }
    return self;
}


@end

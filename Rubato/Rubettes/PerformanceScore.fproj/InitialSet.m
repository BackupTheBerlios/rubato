/* InitialSet.m */

#import "InitialSet.h"
#import "Simplex.h"
#import "LocalPerformanceScore.h"

@implementation InitialSet

/* standard class methods to be overridden */
+ (void)initialize;
{
    [super initialize];
    if (self == [InitialSet class]) {
	[InitialSet setVersion:1];
    }
}



/* standard object methods to be overridden */
- init;
{
    [super init];
    /* class-specific initialization goes here */
    myList = [[[RefCountList alloc]init]ref];
    mySimplex = [[Simplex alloc]init];
    isList = NO;
    return self;
}

- (void)dealloc
{
    /* class-specific initialization goes here */
    [myList release];
    myList = nil;
    [mySimplex release];
    mySimplex = nil;
    { [super dealloc]; return; };
}

- copyWithZone:(NSZone*)zone;
{
    unsigned int index;
    InitialSet *myCopy = JGSHALLOWCOPY;
    myCopy->myList = [myList mutableCopyWithZone:zone];//ref];
    myCopy->mySimplex = [mySimplex copyWithZone:zone];
    myCopy->isList = isList;

    if (myList) {
	id listCopy = myCopy->myList;
	[listCopy empty];
	for (index=0; index<[myList count]; index++) {
	    [listCopy addObject:[[myList objectAt:index] mutableCopyWithZone:zone]];
	}
    }
    return myCopy;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    int classVersion = [aDecoder versionForClassName:NSStringFromClass([InitialSet class])];
//    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    myList = [[aDecoder decodeObject] retain];
    if (!classVersion) {
	/* convert the old List objects to
	 * RefCounList or OrderedList objects
	 */

	id list = myList;
	myList = [[[RefCountList alloc]initCount:[list count]]appendList:list];
	[list release];
    }
    mySimplex = [[aDecoder decodeObject] retain];
    
    [aDecoder decodeValueOfObjCType:"c" at:&isList];
    
    /* set Reference Counting of read or replaced objects */
    [myList ref];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
//    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myList];
    [aCoder encodeObject:mySimplex];
    
    [aCoder encodeValueOfObjCType:"c" at:&isList];
}


- simplex;
{
    if ([self isInitialSimplex])
	return mySimplex;
    else
	return nil;
}

- setSimplex:aSimplex;
{
    if([self isInitialSimplex]) {
      [aSimplex retain];
	[mySimplex release];
	mySimplex = aSimplex;
	return self;
    }

    return nil;
}




- (BOOL) isInitialSimplex;
{
    return mySimplex && ![myList count] && !isList;
}

- (BOOL) isInitialList;
{
    return isList;
}


- (BOOL) isFlat;
{ 
    int i, c = [myList count];
    for(i=0; i<c && [[self initialSetAt:i] isInitialSimplex]; i++);
    return isList && i == c; 
}


- veryNearInitialSetTo:anEvent;
{    
    id intialSet;
    [anEvent ref]; 

    if ([self space] & [anEvent space]) {
	if ([self isInitialList]) {
	    int i, c = [myList count];
	    for (i=0; i<c && ![[myList objectAt:i]veryNearInitialSetTo:anEvent]; i++);
    
	    intialSet = i<c ? [myList objectAt:i] : nil;
	    [anEvent release];    
	    return intialSet;
	}

	if ([self isInitialSimplex]){
	    intialSet = [mySimplex isVeryNearTo:[anEvent projectTo:[mySimplex space]]] ? self : nil;
	    [anEvent release];    
	    return intialSet;
	}
    }
    [anEvent release];
    return nil;
}

/* make a singleton-list-initial set of list or product type */
- convertToInitialList;
{
    int i, c = [myList count];
    spaceIndex listSpace = 0;
    for(i = 0; i<c; i++)
	listSpace = listSpace | [[myList objectAt:i] space];

    [self setSpaceTo: listSpace];
    isList = YES;
    
    return self;
}


/* convert self to a single-list-initial list */
- realizeAsList;
{
    id myCopy = [self copyWithZone:[self zone]];

    myList = [myList empty];
    [self setInitialSet:myCopy at:0];

    [self convertToInitialList];

    return self;
}

/* insert self into a single-list-initial list */
- wrapSelfInList;
{
    id wrapList = [[[self class] alloc]init];
    [wrapList setInitialSet:self at:0];

    [wrapList convertToInitialList];

    return wrapList;
}


- makeListWith:anInitialSet;
{
    int i, c, d;
    id firstList = self, secondList = anInitialSet;

    if(![self isInitialList])
	firstList = [self  wrapSelfInList]; 

    if(![anInitialSet isInitialList])
	secondList = [anInitialSet wrapSelfInList];

    c = [secondList listCount];
    d = [firstList listCount];
    //d = d ? d-1 : d;

    for(i=0; i<c; i++){
	[firstList setInitialSet:[secondList initialSetAt:i] at:d+i];
	[firstList setSpaceTo: [[secondList initialSetAt:i] space] | [firstList space]];
    }
    if (secondList!=anInitialSet) {
	[secondList release];
        secondList = nil;
    }
    return firstList; /* this is only self if self was a list from beginning */
}


/* The "flattening" method builds an initial set which is
 * the list of all simplices of the receiver.
 * Maybe this method should not make an new InitialSet
 * instance, but actually flatten the receiver instance.
 */
- flatten;
{
    int i, c;
    id result = nil;
    
    if([self isInitialSimplex])
	result = [self  wrapSelfInList]; /* we just wrap the initial simplex */ 
    
    if([self isInitialList]){
	c = [self listCount];
	result = [[self initialSetAt:0] flatten]; 
	for(i = 1; i<c; i++)
	    result = [result makeListWith:[[self initialSetAt:i] flatten]];
	}
    return result;
}


/* restriction to resp. exclusion from a frame */
- restrictTo:aFrameObject;
{
    if ([aFrameObject respondsToSelector:@selector(frameContains:)]) {
	int i, c = [self listCount];
	
	if([self isInitialList])
	    for(i = c-1; 0<=i; i--){
		id adapi = [[myList objectAt:i] restrictTo:aFrameObject];
    
		if(![adapi simplex] && ![adapi listCount])
		    [myList removeObjectAt:i]; // jg: dont know, if restrictTo adds a retaincount, so removed relese here
	    }
    
	else{
	    int dimSimplex = [mySimplex simplexDimension];  
	    for(i=0; i<=dimSimplex; i++) {
		if (![aFrameObject frameContains:[mySimplex pointAt:i]]) 
		    break;
	    };
	    if(i<= dimSimplex) {
		[mySimplex release];
                mySimplex = nil;
	    }	
	}
    }
    return self;
}

- excludeFrom:aFrameObject;
{
    if ([aFrameObject respondsToSelector:@selector(frameContains:)]) {
	
	/* to be implemented, is the complementary action to the restriction */
    
	
	/* to be implemented, is the complementary action to the restriction */
    }
    return self;
}

- initialSetAt:(int)index;
{
    return [myList objectAt:index];
}

- setInitialSet:initialSet at:(int)index;
{
    [myList insertObject:initialSet at:index];
    return self;
}


/* superfluous */
/*- addInitialSet:initialSet;
{
    [myList addObject:initialSet];
    [self convertToInitialList];
    return self;
}
*/
- lastInitialSet;
{
    return [myList lastObject];
}


- (unsigned int)indexOfObject:anInitialSet;
{
    return [myList indexOfObject:anInitialSet];
}

- (BOOL) contains:anInitialSet;
{
    return [self indexOfObject:anInitialSet] != NSNotFound;
}


- (int) listCount;
{
    return [myList count];
}

/* implemented methods of SpaceProtocol */
- setSpaceAt:(int)index to:(BOOL)flag;
{
    [mySimplex setSpaceAt:index to:flag];
    return self;
}

- (BOOL) spaceAt:(int)index;
{
    return [mySimplex spaceAt:index];
}


- setSpaceTo:(spaceIndex)aSpace;
{
    [mySimplex setSpaceTo:aSpace];
    return self;
}

- (spaceIndex) space;
{
    return [mySimplex space];
}

/* synonyms for space access */
- (BOOL) directionAt:(int)index;
{
    return [mySimplex directionAt:index];
}

- (spaceIndex) direction;
{
    return [mySimplex direction];
}


/* Dimension and inclusion calculation */
- (int) dimension;
{
    return [mySimplex dimension];
}

- (int) dimensionAtIndex:(int)index;
{
    return [mySimplex dimensionAtIndex:index];
}

- (int) dimensionOfIndex:(int)index;
{
    return [mySimplex dimensionOfIndex:index];
}

- (int) indexOfDimension:(int)dimension;
{
    return [mySimplex indexOfDimension:dimension];
}


- (BOOL) isSubspaceFor:(spaceIndex) aSpace;
{
    return [mySimplex isSubspaceFor:aSpace];
}

- (BOOL) isSuperspaceFor:(spaceIndex) aSpace;
{
    return [mySimplex isSuperspaceFor:aSpace];
}


@end
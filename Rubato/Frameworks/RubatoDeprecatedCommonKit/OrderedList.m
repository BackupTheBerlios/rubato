/* OrderedList.m */ 

#import "OrderedList.h"
#import "Ordering.h"
#include <stdio.h>
#import "JGNXCompatibleUnarchiver.h"

@implementation OrderedList
+(void)initialize;
{
  [OrderedList setVersion:2];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector; 
{
  id superSignature=[super methodSignatureForSelector:selector];
  if (superSignature)
    return superSignature;
  else
    return [mysuper methodSignatureForSelector:selector];
}
- (void)forwardInvocation:(NSInvocation *)invocation;
{ // jg eventually remove if-Test for performance reasons.
//   if ([mysuper respondsToSelector:[invocation selector]]) {
      isSorted=NO;
      [invocation invokeWithTarget:mysuper];
//   } else
//     [self doesNotRecognizeSelector:[invocation selector]];
}
- (BOOL)respondsToSelector:(SEL)aSelector;
{
  if ([mysuper respondsToSelector:aSelector])
    return YES;
//  sortedCopyWithZone, sort, sortAndClean, isSorted, sortDone, lessThan,
    return ((aSelector==@selector(sortedCopyWithZone:)) || (aSelector==@selector(sort)) 
        || (aSelector==@selector(sortAndClean)) || (aSelector==@selector(isSorted)) 
        || (aSelector==@selector(sortDone)) || (aSelector==@selector(lessThan::)));
}

// Creation:
+ (id) arrayWithCapacity:(unsigned int)numItems;
{
  return [[OrderedList alloc] initWithCapacity:numItems];
}
- initWithCapacity:(unsigned int)numItems;
{
  [super init];
  mysuper=[[RefCountList alloc] initWithCapacity:numItems];
  isSorted = NO; // jg?
  return self;
}
- initCount:(unsigned int)numItems; 
{
  return [self initWithCapacity:numItems];
}
- init;
{
    [super init];
    mysuper=[[RefCountList alloc] init];    
    isSorted = NO;
    return self;
}
- (void)dealloc;
{ 
  [mysuper release];
  [super dealloc];
}
- mutableCopyWithZone:(NSZone *)zone; // ==copyWithZone. But important, because sometimes not clear, if it is a OrderedList or a RefCountList.
{
  return [self sortedCopyWithZone:zone];
}
- copyWithZone:(NSZone *)zone;
{
  return [self sortedCopyWithZone:zone];
}
- sortedCopyWithZone:(NSZone *)zone;
{
    OrderedList *myCopy = [[[self class] alloc] init]; //(OrderedList *) NSCopyObject(self,0,[self zone]);
    [myCopy setMySuper:[mysuper mutableCopyWithZone:zone]];
    if (isSorted)
        [myCopy sort]; // jg?
    return myCopy;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
  unsigned oldVersion=[aDecoder versionForClassName:@"OrderedList"];
  char boolChar;
  if (oldVersion<2) { // List is the super class.
    [super init];
    mysuper=[[ListReader alloc] initWithCoder:aDecoder]; // will be an NSMutableArray
    isSorted=NO;
    [self sort];
  } else {
//    [super initWithCoder:aDecoder]; // is abstract Class.
    mysuper=[[aDecoder decodeObject] retain];
    [aDecoder decodeValueOfObjCType:"c" at:&boolChar];
    isSorted=(BOOL)boolChar;
  }
  return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    char boolChar;
//    [super encodeWithCoder:aCoder];
    /* class-specific code goes here */
    [aCoder encodeObject:mysuper];
    boolChar=isSorted ? 1 : 0;
    [aCoder encodeValueOfObjCType:"c" at:&boolChar];
}

// some "add.." and "replace.."-Methods:
// from NSMutableArray:
- (void)addObject:anObject;
{ [self nx_addObject:anObject];
}
/* forward
- (void)insertObject:(id)anObject atIndex:(unsigned)index; {[mysuper insertObject:anObject atIndex:index];isSorted=NO;} // geht sicher schneller.
etc.
*/
/* overrides of inherited List methods */
/* Manipulating objects by index */
- nx_addObject:anObject;
{
//    printf("add %s\n",[[anObject description] cString]);
    if ([anObject conformsToProtocol:@protocol(Ordering)]) {
        if (isSorted) { /* we're sorted, insert anObject at the right point */
            unsigned int index;
            unsigned int numElements=[mysuper count];
            for (index=0; index<numElements && [[mysuper objectAtIndex:index] smallerThan:anObject]; index++);
            if([mysuper insertObject:anObject at:index]) {;
                isSorted = YES; // not necessary.
                return self;
            }
        } else
            return [mysuper nx_addObject:anObject]; /* doesn't matter where it's inserted */
    }
    return nil;
}

- insertObject:anObject at:(unsigned)index;
{
    printf("insert %s\n",[[anObject description] cString]);
    if ([anObject conformsToProtocol:@protocol(Ordering)]) {
        if ([mysuper insertObject:anObject at:index]) {
            isSorted = NO;
            return self;
        }
    }
    return nil;
}

/* object removal doesn't change sorting order */
//- removeObjectAt:(unsigned)index;
//- removeLastObject;

- replaceObjectAt:(unsigned)index with:newObject;
{
printf("replaceAt %s\n",[[newObject description] cString]);
    if ([newObject conformsToProtocol:@protocol(Ordering)]) {
        id obj = [mysuper replaceObjectAt:index with:newObject];
        if (obj) {
            isSorted = NO;
            return obj;
        }
    }
    return nil;
}

- appendList: (NSArray *)otherList;
{
    int c, i;
    id obj;
    for (c = [otherList count], i = 0; i<c; i++) {
        if ([obj=[otherList objectAtIndex:i] conformsToProtocol:@protocol(Ordering)])
            [self nx_addObject:obj]; // makes the isSorted-relation secure.
    }
    return self;
}


/* Manipulating objects by id */
//- addObjectIfAbsent:anObject; /* List uses -addObject:*/

/* object removal doesn't change sorting order */
//- removeObject:anObject;
- replaceObject:anObject with:newObject;
{
printf("replaceWith %s\n",[[anObject description] cString]);
    if ([newObject conformsToProtocol:@protocol(Ordering)]) {
        if ([mysuper replaceObject:anObject with:newObject]) {
            isSorted = NO;
            return anObject;
        }
    }
    return nil;
}


// primitive methods for NSMutableArray-Subclasses, which do not change the Sorted-state:
- (unsigned)count; {return [mysuper count];}
- (id)objectAtIndex:(unsigned)index; {return [mysuper objectAtIndex:index];}
- (void)removeLastObject; {[mysuper removeLastObject];}
- (void)removeObjectAtIndex:(unsigned)index; {[mysuper removeObjectAtIndex:index];}
- (void)setMySuper:(id)ms; {mysuper=ms;}
- (NSMutableArray *)myArray;{return mysuper;}
- (id)objectAt:(unsigned)index; // quicker than forward invocation.
{
  if (index>=[mysuper count]) return nil;
  else return [mysuper objectAtIndex:index];
}


- sort;
{
/* This shell sort is taken from the NextDeveloper Example SortingInAction
 *
 * COPYRIGHT NOTE
 * Author: Julie Zelenski, NeXT Developer Support
 * You may freely copy, distribute and reuse the code in this example.  
 * NeXT disclaims any warranty of any kind, expressed or implied, as to 
 * its fitness for any particular use.
 */

/* Because Shellsort is a variation on Insertion Sort, it has the same 
 * inconsistency that I noted in the InsertionSort class.  Notice where I 
 * subtract a move to compensate for calling a swap for visual purposes.
 */

/*
#define STRIDE_FACTOR 3 	
                                // good value for stride factor is not well-understood
				// 3 is a fairly good choice (Sedgewick)
    if (!isSorted) {
	unsigned int c, stride;
	unsigned int numElements=[mysuper count];
	long long int d;
	BOOL found;
    
	stride = 1;
	while (stride <= numElements)
	    stride = stride*STRIDE_FACTOR +1;
	
	while (stride>(STRIDE_FACTOR-1)) { // loop to sort for each value of stride
	    stride = stride / STRIDE_FACTOR;
	    for (c = stride; c < numElements; c++){
		found = NO;
		d = c-stride;
		while ((d >= 0) && !found) { // move to left until correct place
		    if ([self lessThan:d+stride :d]) {
			[mysuper swapObjectAt:d+stride with:d];//swap each time(visual effect)
			d -= stride;		// jump by stride factor
		    } else
			found = YES;
		}
	    }
	}
	[self sortDone];
    }
    return self;
*/
#ifdef ORDERED_LIST_SHOW
   printf("sortiere Liste %d:%s\n\n", (int)mysuper,[[mysuper description] cString]);
#endif
  if (!isSorted) {
    [mysuper sortUsingSelector:@selector(compareTo:)];  // jg simpler.
    [self sortDone];
  }
#ifdef ORDERED_LIST_SHOW
   printf("Sortierung beendet.\n");
#endif
   return self;
}

- sortAndClean;
{
    int i;
    [self sort];
    for (i=0; i<[mysuper count]-1; i++) {
	if ([[mysuper objectAt:(i+1)] equalTo:[mysuper objectAt:i]])
	    [mysuper removeObjectAt:i+1];
    }
    return self;
}


- (BOOL)isSorted;
{
    return isSorted;
}

- sortDone;
{
    isSorted = YES;
    return self;
}


- (BOOL)lessThan:(int)index1 :(int)index2;
{
    unsigned int numElements=[mysuper count];
    if (index1<numElements && index2<numElements) {
	return [[mysuper objectAtIndex:index1] smallerThan:[mysuper objectAtIndex:index2]];
    }
    return NO;
}




@end
/* OrderedList.h */
#import <Foundation/NSArchiver.h>
#import <Foundation/NSInvocation.h>
#import "JGList.h"
#import "JgRefCountObject.h"

// OrderedList becomse Subclass of RefCountList by embedding. See also
// /Documentation/Developer/YellowBox/TasksAndConcepts/ProgrammingTopics/ClassClusters.pdf 
// With a direct Subclass of NSMutableArray it did not work. see _OrderedList.h.error
@interface OrderedList:JgRefCountObject // =MutableArray
{
    RefCountList *mysuper;
    BOOL isSorted;
}
// The Methods are usually forwarded to mysuper. This does not work for creation and 
// some "add.." and "replace.."-Methods, which change the isSorted status.
// Methods, which are called often, should be listed explicitly, because 
// forwardInvocation sets isSorted=NO, to be sure. That makes everything more clear.

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector; //necessary for forwardInvocation
- (void)forwardInvocation:(NSInvocation *)invocation;
- (BOOL)respondsToSelector:(SEL)aSelector;


// Creation:
+ (id) arrayWithCapacity:(unsigned int)numItems;
- initWithCapacity:(unsigned int)numItems;
- initCount:(unsigned int)numItems; // backwards compatibility
- init;
- copyWithZone:(NSZone *)zone;
- mutableCopyWithZone:(NSZone *)zone;
- sortedCopyWithZone:(NSZone *)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder; // jg

// som "add.." and "replace.."-Methoden:
// from NSMutableArray: 
//         addObject:, insertObject:atIndex: , replaceObjectAtIndex:withObject
//         addObjectsFromArray:, replaceObjectInRange:withObjectsFromArray:[range:]
//         setArray:
- (void)addObject:(id)anObject;
/* forward
- (void)insertObject:(id)anObject atIndex:(unsigned)index;
- (void)replaceObjectAtIndex:(unsigned)index withObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray;
- (void)setArray:(NSArray *)otherArray;
*/

// From the List- culture:

/* Overrides of inherited List methods. Only the
 * insertion methods need overriding, since
 * object removal doesn't change the sorting order.
 */

/* Manipulating objects by index */
// see above. - (void)addObject:anObject;// for compatibility with NSMutableArray
- nx_addObject:anObject;
- insertObject:anObject at:(unsigned)index;
- replaceObjectAt:(unsigned)index with:newObject;
- appendList: (NSArray *)otherList;

/* Manipulating objects by id */
//- addObjectIfAbsent:anObject; /* List uses -addObject:*/
- replaceObject:anObject with:newObject;



// OrderedList specific Methods:
- sort;
- sortAndClean;
- (BOOL)isSorted;

/* private sorting methods */
- sortDone;
- (BOOL)lessThan:(int)index1 :(int)index2;


// necessary?: more efficient than forward (incl. isSorted=NO)
// primitive Methods for NSMutableArray-Subclassen
- (unsigned)count;
- (id)objectAtIndex:(unsigned)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(unsigned)index;
- (void)setMySuper:(id)ms;
- (NSMutableArray *)myArray;

@end
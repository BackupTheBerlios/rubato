#import <Foundation/NSArray.h>
#import "RefCounting.h"
#define JgList NSMutableArray
#define RefCountList NSMutableArray


//@interface NSArray (JGList) <RefCounting>
//@end

// jg: must be NSArray, because NSConcreteArray (without documentation)
//  has as a superclass not NSMutableArray hat, but NSArray.
@interface NSMutableArray (JGList) <RefCounting>
//RefCounting begin
- (void)nxrelease;  //== release
#if 0
- (unsigned int)references;
#endif
- (id)ref;
- (oneway void)deRef;
// RefCounting end
- (unsigned)capacity; // legacy, do not use any more!


- initCount:(unsigned)cnt; // ==initWithCapacity
//- jgCopyWithZone:(NSZone *)zone;
//- jgCopy;


// Methodes for Conversion.
// List-Methoden can be recognized at the At suffix instead of AtIndex resp. -with instead of -withObject.
// returns self or nil, if anObject==nil
- (id)objectAt:(unsigned)index;
- (unsigned)indexOf:(id)object;

// returns self or nil, if anObject==nil
- (id)nx_addObject:(id)anObject;
- appendList:(NSArray *)list;
- insertObject:anObject at:(unsigned)index;
- removeObjectAt:(unsigned)index;

// Warning: the ReturnObject is only valid, if it had a previous retain.
- replaceObjectAt:(unsigned)index with:newObject;
- replaceObject:anObject with:newObject;
- (id)nx_removeObject:anObject;

- empty;
- freeObjects;

- swapObjectAt:(unsigned)index1 with:(unsigned)index2;
- (JgList *)addObjectIfAbsent:(id)obj;
- (JgList *)makeObjectsPerform:(SEL)sel;
- (JgList *)makeObjectsPerform:(SEL)sel with:(id)sender;

// Creating, freeing 

/*
- freeObjects;

// Initializing 

- init;
- initCount:(unsigned)numSlots;

// Comparing two lists 

- (BOOL)isEqual: anObject;

// Managing the storage capacity 

- (unsigned)capacity;
- setAvailableCapacity:(unsigned)numSlots;

// Manipulating objects by index 

- (unsigned)count;
- objectAt:(unsigned)index;
- lastObject;
- addObject:anObject;
- insertObject:anObject at:(unsigned)index;
- removeObjectAt:(unsigned)index;
- removeLastObject;
- replaceObjectAt:(unsigned)index with:newObject;

- appendList: (SuperJGListPointer)otherList;

// Manipulating objects by id 

// NSArray: indexOfObject
- (unsigned)indexOf:anObject;
// jg NSArray not 
- addObjectIfAbsent:anObject;
// jg: NSArray: all isEqual objects are removed.
- removeObject:anObject;
// jg: NSArray: replaceObjectAtIndex withObject
- replaceObject:anObject with:newObject;

// Emptying the list 

// jg: not in NSArray
- empty;

// Sending messages to elements of the list 
// jg: List returns id, NSArray returns void
- makeObjectsPerform:(SEL)aSelector;
- makeObjectsPerform:(SEL)aSelector with:anObject;

*/

@end

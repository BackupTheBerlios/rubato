#import "JGList.h"
#import <AppKit/AppKit.h>

#define REPLACE(aDecoder,old,new) \
    if (doReplaceFlag && [aDecoder respondsToSelector:@selector(replaceObject:withObject:)]) \
      [(NSArchiver *)aDecoder replaceObject:old withObject:new];

#define SELFRELEASE ;


//@implementation NSArray(JGList)
@implementation NSMutableArray (JGList)

// does not make sense any more
// is also only used in the sense that memory is going to be saved
// see the release of  myCoefficients in MathMatrix-Classes.
- (unsigned)capacity;
{
 return [self count];
}

// autorelease is not possible, because some Methods, e.g. in MathMatrix refCount are based on -refCount.
- (void)nxrelease;
{ 
//#ifdef SUPERFREE
//#warning Compiler option SUPERFREE defined.
//if([self retainCount]!=2)
//  [self release];
//else {
//  [self release]; // myRefCount
//  [self release]; // [super free]
//}
//#else
//#warning Compiler option SUPERFREE not defined.
[self release];
//#endif
}

/* NXReference methods */
- (id)ref;
{
   return [self retain];
}
- (oneway void)deRef;
{
   [self release];// autorelease is not possible, because some Methods, e.g. in MathMatrix refCount are based on -refCount.
}
#if 0
- (unsigned int)references;
{
#ifdef RETAINCOUNTMINUS1
#warning Compiler option RETAINCOUNTMINUS1 defined.
   return [self retainCount]-1;
#else
#warning Compiler option RETAINCOUNTMINUS1 not defined.
   return [self retainCount];
#endif
}
#endif
// normally not defined for NSArray, but are used in the old Rubato version...where?
// they do nothing here in contrary to NSMutableArray.
//- empty;
//{ return self;}
//- freeObjects;
//{ return self;}


// is in NSArray not any more included, but is still used
- initCount:(unsigned)cnt;
{
  return [self initWithCapacity:cnt];
}

/*
// not clean, but this way Lists are used!
- jgCopyWithZone:(NSZone *)zone;
{
   return [self mutableCopyWithZone:zone];
}

// not clean, but this way Lists are used!
- jgCopy;
{
  return [self mutableCopyWithZone:[self zone]];
}
*/

- (id)objectAt:(unsigned)index;
{
  if (index>=[self count]) return nil;
  else return [self objectAtIndex:index];
}

- (unsigned)indexOf:(id)object;
{
  return [self indexOfObject:object];
}

// Methodes for Conversion.
- (id)nx_addObject:(id)anObject;
{
  if (anObject) {
    [self addObject:anObject];
    return self;
  } else return nil;
}

- appendList:(NSArray *)list;
{
  [self addObjectsFromArray:list];
  return self;
}

/* Manipulating objects by index */
- insertObject:anObject at:(unsigned)index;
{
  if (anObject) {
    [self insertObject:anObject atIndex:index];
    return self;
  } else return nil;
}

- removeObjectAt:(unsigned)index;
{
   id obj;
   if (index>=[self count]) return nil;
   obj=[self objectAtIndex:index];
   [[obj retain] autorelease];
   [self removeObjectAtIndex:index];
   return obj;
}

// Warning: the ReturnObject is only valid, if it had a previous retain.
// it is released in replaceObjectAtIndex
- replaceObjectAt:(unsigned)index with:newObject;
{
    id anObject;
    if (!newObject || (index>=[self count])) return nil;
    anObject = [self objectAtIndex:index];
    [[anObject retain] autorelease];
    [self replaceObjectAtIndex:index withObject:newObject];
    return anObject;
}


// Warning: the ReturnObject is only valid, if it had a previous retain.
- replaceObject:anObject with:newObject;
{
    unsigned index;
    if (!anObject || !newObject) return nil;
    index=[self indexOfObject:anObject]; // Problem, if NSNotFound is the return. 
    if (index==NSNotFound) return nil;
    [[anObject retain] autorelease];
    [self replaceObjectAtIndex:index withObject:newObject];
    return anObject;
}

// Warning: the ReturnObject is only valid, if it had a previous retain.
- (id)nx_removeObject:anObject;
{
  if ([self containsObject:anObject]) {
    [[anObject retain] autorelease]; 
     [self removeObject:anObject];
     return anObject;
  } else return nil;
}


/* Emptying the list */
- empty;
{
//    NSRunAlertPanel(@"empty",@"stopped because of debugging",@"continue",nil,nil);
    [self removeAllObjects];
    return self;
}

// see empty. 
// In the description of List it is mentioned, that contrary to -empty the objects are send a free message.
// This is now covered by the refcount mechanism.
- freeObjects;
{
    [self removeAllObjects];
    return self;
}


// was in ordered List.
// jg should I customize it with List semantic?
- swapObjectAt:(unsigned)index1 with:(unsigned)index2;
{
    unsigned int numElements=[self count];
    if (index1<numElements && index2<numElements) {
        id tmp = [self objectAtIndex:index2]; [tmp retain];
        [self replaceObjectAtIndex:index2 withObject:[self objectAtIndex:index1]];
        [self replaceObjectAtIndex:index1 withObject:tmp];
	[tmp release];
    }
    return self;
}

- (JgList *)addObjectIfAbsent:(id)obj;
{
  if (![self containsObject:obj]) [self addObject:obj];
  return self;
}

- (JgList *)makeObjectsPerform:(SEL)sel;
{
  [self makeObjectsPerformSelector:sel];
  return self;
}
- (JgList *)makeObjectsPerform:(SEL)sel with:(id)sender;
{
  [self makeObjectsPerformSelector:sel withObject:sender];
  return self;
}

@end

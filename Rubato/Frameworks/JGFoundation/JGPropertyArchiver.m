/* DTXDenotatorArchiver.m created by jg on Wed 16-Aug-2000 */

#import "JGPropertyArchiver.h"

/*
 Achtung: das Ergebnis ist nicht eindeutig, da 347 sowohl als Attribut, als auch als Referenz aufgefasst werden kann. Es braucht also Kontextinformation z.B. EOClassDefinition dafuer. */

@implementation JGPropertyArchiver
- (id)init;
{
  [super init];
  addressAsString=YES;
  addReferencedObjects=YES;
  reallyCreateRepresentation=YES;
  returnReferences=YES;
  maxArchivationDepth=0;
  maxRepresentationDepth=0;
  
  archivedObjects=[[NSMutableDictionary alloc]init];
  referencedObjects=[[NSMutableDictionary alloc]init];
  topObjects=[[NSMutableArray alloc]init];
  maxArchivedDepth=0;

  representationReplacement=nil;
  lastNumber=[[NSNumber valueWithPointer:NULL] retain];
  lastId=nil;
  return self;
}
- (void)dealloc;
{
  [archivedObjects release];
  [referencedObjects release];
  [topObjects release];
  [lastNumber release];
  [super dealloc];
}

// Access to Flags 

- (BOOL) addressAsString
{
	return addressAsString;
}

- (void) setAddressAsString:(BOOL)newAddressAsString
{
	addressAsString = newAddressAsString;
}

- (BOOL) addReferencedObjects
{
	return addReferencedObjects;
}

- (void) setAddReferencedObjects:(BOOL)newAddReferencedObjects
{
	addReferencedObjects = newAddReferencedObjects;
}

- (BOOL) reallyCreateRepresentation
{
	return reallyCreateRepresentation;
}

- (void) setReallyCreateRepresentation:(BOOL)newReallyCreateRepresentation
{
	reallyCreateRepresentation = newReallyCreateRepresentation;
}

- (BOOL) returnReferences
{
	return returnReferences;
}

- (void) setReturnReferences:(BOOL)newReturnReferences
{
	returnReferences = newReturnReferences;
}

- (int) maxArchivationDepth
{
	return maxArchivationDepth;
}

- (void) setMaxArchivationDepth:(int)newMaxArchivationDepth
{
	maxArchivationDepth = newMaxArchivationDepth;
}

- (int) maxRepresentationDepth
{
	return maxRepresentationDepth;
}

- (void) setMaxRepresentationDepth:(int)newMaxRepresentationDepth
{
	maxRepresentationDepth = newMaxRepresentationDepth;
}


// Access to Results

- (NSMutableDictionary*) archivedObjects
{
	return archivedObjects;
}

- (NSMutableDictionary*) referencedObjects
{
	return referencedObjects;
}

- (NSMutableArray*) topObjects
{
	return topObjects;
}

- (int) maxArchivedDepth
{
	return maxArchivedDepth;
}

- (BOOL)containsObject:(id)obj;
  /*" convenience Method for checking archivedObjects "*/
{
  id address=[self idForObject:obj];
  return ([archivedObjects objectForKey:address]!=nil);
}

- (id)nameForObject:(id)obj;
{
  if (addressAsString)
    return [self stringForObject:obj];
  else
    return [self idForObject:obj];
}
- (NSString *)stringForObject:(id)obj;
{
  return [NSString stringWithFormat:@"0x%xd",(int)obj];
}
- (id)idForObject:(id)obj;
{
  if (obj!=lastId) {
    [lastNumber release];
    lastId=obj;
    lastNumber=[[NSValue valueWithPointer:(void *)obj] retain];
  }
  return lastNumber;
}
- (id)objectForId:(id)identification;
{
  return (id)[identification pointerValue];
}
- (NSString *)classKey;
{
  return @"class";
}
- (NSString *)idKey;
{
  return @"id";
}
- (id)classInfoForObject:(id)obj;
{
  return NSStringFromClass([obj class]);
}

- (id)representationForObject:(id)obj forceReference:(BOOL)forceReference;
  /*" Called by addObject/addRootObject. (Do not call directly). If obj allready archived or becomes a new topObject due to limited maxArchivationDepth, returns a [self nameForObject:obj], otherwise returns a property list"*/
{
  id address=[self idForObject:obj];
  NSMutableDictionary *dict=[archivedObjects objectForKey:address];
  BOOL wasArchived=(dict!=nil);
  BOOL becameTop=NO;
  if (!wasArchived) {
    if (representationReplacement) { // if used with a previously declared root.
      dict=representationReplacement;
      representationReplacement=nil;
    } else 
      dict=[NSMutableDictionary dictionary];
    [archivedObjects setObject:dict forKey:address];
    archivationDepth++;
    if (archivationDepth!=maxArchivationDepth)
      [self addToDictionary:dict representationForObject:obj];
    else if (archivationDepth>maxArchivedDepth) maxArchivedDepth=archivationDepth;
    archivationDepth--;
    if ((maxRepresentationDepth && (archivationDepth % maxRepresentationDepth==0) && archivationDepth)
        ||  forceReference ) {
      becameTop=YES; // becameTop for maxRepresentationDepth==3: 3,6,9 so we get 012,345,678,...
      [topObjects addObject:dict];
    }
  }
  if ((returnReferences && (wasArchived || becameTop))
       ||  forceReference ) {
    id name=[referencedObjects objectForKey:address];
    if (!name) {
      name=[self nameForObject:obj];
      if (addReferencedObjects)
        [referencedObjects setObject:name forKey:address];
    }
    return name;
  } else {
    return dict;
  }
}

- (id)representationForObject:(id)obj;
{
  return [self representationForObject:obj forceReference:NO];
}

- (void)addObject:(id)obj duplicates:(BOOL)duplicates;
/*" Add a representation of obj to the top level of dictionary, if not already containd somewhere within dictionary "*/
{
  id address=[self idForObject:obj];
  if (duplicates || ![archivedObjects objectForKey:address]) {
    id result;
    archivationDepth=0;
    result=[self representationForObject:obj];
    [topObjects addObject:result];
  }
}

- (void)declareRootObject:(id)obj;
  /*" Call this, if in successive calls to [self addObject:someOtherObject] you want to store references of obj instead of properties of obj "*/
{
  id address=[self idForObject:obj];
  NSMutableDictionary *dict=[NSMutableDictionary dictionary];
  [archivedObjects setObject:dict forKey:address];
}
- (void)addRootObject:(id)obj;
/*" Call this instead of addObject:, if you already have called declareRootObject:obj. "*/
{
  id address=[self idForObject:obj];
  NSMutableDictionary *dict=[[archivedObjects objectForKey:address] retain];
  [archivedObjects removeObjectForKey:address];
  representationReplacement=dict;
  [self addObject:obj duplicates:YES];
  [dict release];
}
  
- (void)addNamesForReferencedObjects;
  /*" for each name stored for address referencedObjects sets name in the represetation of address "*/
{
  NSEnumerator *e=[referencedObjects keyEnumerator];
  id address;
  while (address=[e nextObject]) {
    id name=[referencedObjects objectForKey:address];
    NSMutableDictionary *dict=[archivedObjects objectForKey:address];
    [dict setObject:name forKey:[self idKey]];
  }
}

- (void)addToDictionary:(NSMutableDictionary *)dict representationForObject:(id)obj;
{
  [dict setObject:@"Error: JGPropertyArchiver -addToDictionary:representationForObject: not implemented by subclass!" forKey:@"Error"];
}

- (void)declareRootObjects:(NSArray *)objects;
{
  NSEnumerator *e=[objects objectEnumerator];
  id obj;
  while (obj=[e nextObject])
    [self declareRootObject:obj];
}
- (void)addRootObjects:(NSArray *)objects;
{
  NSEnumerator *e=[objects objectEnumerator];
  id obj;
  while (obj=[e nextObject])
    [self addRootObject:obj];
}

@end



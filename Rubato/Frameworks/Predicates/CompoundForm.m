/* CompoundForm.m */

#import "CompoundForm.h"
#import "CompoundPredicate.h"

#define inspectorNibName @"CompoundFormInspector.nib"

@implementation CompoundForm

+ (CompoundForm *)listForm;
{
  static id listForm;
  if (listForm)
    return listForm;
  listForm = [[CompoundForm alloc] init];
  [listForm setTypeString:type_List];
  [listForm setNameString:"ListForm"];
  [listForm setLocked:YES];
  [listForm setAllowsToChangeType:NO];
  return listForm;
}


- init
{
    [super init];
    /* class-specific initialization goes here */
    [self setTypeString:type_List];
    myList = [[JgList allocWithZone:[self zone]]init];
    roles = [[NSMutableDictionary alloc] init];
    return self;
}


- (void)dealloc;
{
#if PKRefCountImplemented
    /* do NXReference houskeeping */
#endif

    if (([myList count]>0) && ([[myList objectAt:0] parent]==self))
      [myList makeObjectsPerformSelector:@selector(setParent:)withObject:nil];
    [myList release];
    myList = nil;
    [roles release];
    [super dealloc];
}


- copyWithZone:(NSZone *)zone;
{
    CompoundForm *myCopy = [super copyWithZone:zone];
    myCopy->myList = [myList mutableCopyWithZone:zone];
    myCopy->roles = [roles mutableCopyWithZone:zone];
    return myCopy;
}

+(void)initialize;
{
  [CompoundForm setVersion:2];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  unsigned oldVersion=[aDecoder versionForClassName:@"CompoundForm"];
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    myList = [[aDecoder decodeObject] retain];
    if (oldVersion>=2)
      roles = [[aDecoder decodeObject] retain];
      
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myList];
    [aCoder encodeObject:roles];
}

/*Form specific methods*/
- makePredicate;
{
    return [self makePredicateFromZone:[self zone]];
}

- makePredicateFromZone:(NSZone *)zone;
{
    const char* theType = [myType cString];
    isLocked = YES;
    if (strcmp(theType, type_Predicate)==0) {
	id aPredicate = [[CompoundPredicate allocWithZone:zone]init];
	[aPredicate setNameString:[self nameString]];
	[aPredicate setForm:self];
        if ([myList count]>0)
  	  [aPredicate setValue:[[myList objectAt:0] makePredicate]];
	else
	  [aPredicate setValue:nil];  // nothing happens with SimplePredicate instance, because only defined in GenericPredicate and in ListForm.
	return aPredicate;
    }
    if (strcmp(theType, type_List)== 0) {
	int i, count = [myList count];
	id aList, aPredicate = [[CompoundPredicate allocWithZone:zone]init];
	[aPredicate setNameString:[self nameString]];
	[aPredicate setForm:self];
	aList = [myList mutableCopyWithZone:zone];  // copy only because of zone?
	[aList empty];	// hmm, and here everything is thrown away?
	for (i=0;i<count;i++) {
	    [aList addObject:[[myList objectAt:i] makePredicate]];
	}
	[aPredicate setValue:aList];
	return aPredicate;
    }
    if (strcmp(theType, type_Product)== 0) {
	int i, count = [myList count];
	id aList, aPredicate = [[CompoundPredicate allocWithZone:zone]init];
	[aPredicate setNameString:[self nameString]];
	[aPredicate setForm:self];
	aList = [myList mutableCopyWithZone:zone];
	[aList empty];
	for (i=0;i<count;i++) {
	    [aList addObject:[[myList objectAt:i] makePredicate]];
	}
	[aPredicate setValue:aList];
	return aPredicate;
    }
    if (strcmp(theType, type_Coproduct)== 0) {
	id aPredicate = [[CompoundPredicate allocWithZone:zone]init];
	[aPredicate setNameString:[self nameString]];
	[aPredicate setForm:self];
        if ([myList count]>0)
          [aPredicate setValue:[[myList objectAt:0] makePredicate]];
        else
          [aPredicate setValue:nil];   // nothing happens with SimplePredicate instance, because only defined in GenericPredicate and in ListForm.
	return aPredicate;
    }
    if (strcmp(theType, type_Subset)== 0) {
	int i, count = [myList count];
	id aList, aPredicate = [[CompoundPredicate allocWithZone:zone]init];
	[aPredicate setNameString:[self nameString]];
	[aPredicate setForm:self];
	aList = [myList mutableCopyWithZone:zone];
	[aList empty];
	for (i=0;i<count;i++) {
	    [aList addObject:[[myList objectAt:i] makePredicate]];
	}
	[aPredicate setValue:aList];
	return aPredicate;
    }
    else
	return nil;
}


/* special object methods to be overridden */
- (NSString *) inspectorNibFile;
{
    return inspectorNibName;
}

#include "CompoundMathStream.m"

/*access methods to all predicates names*/
//- setName: sender;
//- setNameString: (const char *)aName;
//- getName;
//- getNameString;/* returns a StringConverter object */
//- (const char *)nameString;

/*access methods to the predicates type */
- (BOOL) canChangeTypeString: (const char *)toType
{
    if (isLocked) 
	return NO;
    if (![[self type]isEqualToString:[NSString stringWithCString:toType]]) {
	if (strcmp(toType, type_Generic)== 0) 
		/* never convert to a GENERIC predicate.
		    *This is only an abstract superclass.
		    */
	    return NO;
	if (strcmp(toType, type_Empty)== 0)
	    return YES;
	if (strcmp(toType, type_Predicate)== 0)
	    return YES;
	if (strcmp(toType, type_Int)== 0)
	    return YES;
	if (strcmp(toType, type_Float)== 0)
	    return YES;
	if (strcmp(toType, type_Bool)== 0)
	    return YES;
	if (strcmp(toType, type_String)== 0)
	    return YES;
	if (strcmp(toType, type_Musical)== 0)
	    return YES;
	if (strcmp(toType, type_List)== 0)
	    return YES;
	if (strcmp(toType, type_Product)== 0)
	    return YES;
	if (strcmp(toType, type_Coproduct)== 0)
	    return YES;
	if (strcmp(toType, type_Subset)== 0)
	    return NO;
	else
	    return NO;
	}
    else
	return YES;
}

- changeTypeString: (const char *)toType;
{
    if (isLocked)
	return nil;
    if (![[self type]isEqualToString:[NSString stringWithCString:toType]]) {
	if (strcmp(toType, type_Generic)== 0)
	    /* never convert to a GENERIC predicate.
		*This is only an abstract superclass.
		*/
	    return self;
	if (strcmp(toType, type_Empty)== 0) {
	    return [super changeTypeString: toType];
	}
	if (strcmp(toType, type_Predicate)== 0) {
	    return [super changeTypeString: toType];
	}
	if (strcmp(toType, type_Int)== 0||strcmp(toType, type_Float)== 0||
	    strcmp(toType, type_Bool)== 0||strcmp(toType, type_String)== 0){
	    return [super changeTypeString: toType];
	}
	if (strcmp(toType, type_Musical)== 0)
	    return [super changeTypeString: toType];
	if (strcmp(toType, type_Product)== 0) {
	    [self setType0:[NSString jgStringWithCString:toType]];
	    return self;
	}
	if (strcmp(toType, type_List)== 0) {
	    [self setType0:[NSString jgStringWithCString:toType]];
	    return self;
	}
	if (strcmp(toType, type_Product)== 0) {
	    [self setType0:[NSString jgStringWithCString:toType]];
	    return self;
	}
	if (strcmp(toType, type_Coproduct)== 0) {
	    [self setType0:[NSString jgStringWithCString:toType]];
	    return self;
	}
	if (strcmp(toType, type_Subset)== 0) {
	    [self setType0:[NSString jgStringWithCString:toType]];
	    return self;
	}
	else
	    return nil;
    }
    else
	return self;
}


/*access methods to the predicates form */

/*access methods to all predicates values*/
#include "CompoundValueAccess.m"

- (void)setRoleOfIndex:(int)index to:(NSString *)roleName;
{
  [roles setObject:roleName forKey:[NSNumber numberWithInt:index]];
}

- (NSString *)roleAtIndex:(int)index;
{
  NSString *n=[roles objectForKey:[NSNumber numberWithInt:index]];
  if (n)
   return n;
  else
   return [NSString stringWithFormat:@"%d",index+1];
}

+ (NSString *)roleWithoutFather;
{
  return @"";
}

#include "Compound.m"

@end
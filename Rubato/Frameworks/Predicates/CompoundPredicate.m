/* CompoundPredicate.m */

#import "CompoundPredicate.h"
#import "CompoundForm.h"

#define inspectorNibName @"ListInspector.nib"

@implementation CompoundPredicate

- (NSMutableArray *)values;
{
    return myList;
}

- (NSArray *)toManyRelationshipKeys;
{
    static NSArray *keys=nil;
    if (!keys)
        keys=[[NSArray alloc] initWithObjects:@"values",nil]; // [self valueForKey:@"myList"] gives sigbus error 
    return keys;
}

- init
{
    [super init];
    /* class-specific initialization goes here */
    [self setNameString:type_Empty];
    [self setTypeString:type_List];
    myList = [[JgList allocWithZone:[self zone]]init];
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
    [super dealloc];
}


- copyWithZone:(NSZone *)zone;
{
    CompoundPredicate *myCopy = [super copyWithZone:zone];
    myCopy->myList = [myList mutableCopyWithZone:zone];
    return myCopy;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    myList = [[aDecoder decodeObject] retain];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myList];
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
//- setType: sender;
//- setTypeString: (const char *)aType;
//- getTypeString;
//- (const char *)typeString;
- (BOOL) canChangeTypeString: (const char *)toType
{
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
	if (strcmp(toType, type_Product)== 0)
	    return [super changeTypeString: toType];
	if (strcmp(toType, type_Coproduct)== 0)
	    return [super changeTypeString: toType];
	if (strcmp(toType, type_Subset)== 0)
	    return [super changeTypeString: toType];
	else
	    return nil;
    }
    else
	return self;
}


/*access methods to the predicates form */


/*access methods to all predicates values*/
#include "CompoundValueAccess.m"

#include "Compound.m"

@end
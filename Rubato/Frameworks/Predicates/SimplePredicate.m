/* SimplePredicate.m */

#import "SimplePredicate.h"
#import "GenericForm.h"

#define inspectorNibName @"ValueInspector.nib"

@implementation SimplePredicate
- (NSArray *)attributeKeys;
{
    static NSArray *keys=nil;
    if (!keys)
        keys=[[NSArray alloc] initWithObjects:@"name",@"type",@"myValue",nil];
    return keys;
}

- init
{
    [super init];
    /* class-specific initialization goes here */
    [self setNameString:type_Empty];
    [self setTypeString:type_String];
    myValue = @"";
    [myValue retain];
    return self;
}


- (void)dealloc;
{
#if PKRefCountImplemented
    /* do NXReference houskeeping */
#endif

    if (myValue) // jg: sollte immer Wahr sein!
	[myValue release];
    return [super dealloc];
}


- copyWithZone:(NSZone*)zone;
{
    SimplePredicate *myCopy = [super copyWithZone:zone];
    myCopy->myValue = [myValue copyWithZone:zone];
    return myCopy;
}

+(void)initialize;
{
  [SimplePredicate setVersion:2];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  unsigned oldVersion=[aDecoder versionForClassName:@"SimplePredicate"];
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    if (oldVersion < 2) {
      myValue=[StringConverter readNSStringWithCoder:aDecoder];
    } else {
      myValue =[aDecoder decodeObject];
    }
    [myValue retain];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myValue];
}

- (id)value;
{
  return myValue;
}

/* special object methods to be overridden */
- (NSString *) inspectorNibFile;
{
    return inspectorNibName;
}

#include "SimpleMathStream.m"

/*access methods to all predicates names*/
//- setName: sender;
//- setNameString: (const char *)aName;
//- getName;
//- getNameString;/* returns a StringConverter object */
//- (const char *)nameString;

/*access methods to the predicates type */
//- setType: sender;
//- c: (const char *)aType;
//- getTypeString;
//- (const char *)typeString;
- (BOOL) canChangeTypeString: (const char *)toType
{
    if (![[self typeName]isEqualToString:[NSString stringWithCString:toType]]) {
	if (strcmp(toType, type_Generic)== 0) 
		/* never convert to a GENERIC predicate.
		    *This is only an abstract superclass.
		    */
	    return NO;
	if (strcmp(toType, type_Empty)== 0)
	    return NO;
	if (strcmp(toType, type_Predicate)== 0)
	    return NO;
	if (strcmp(toType, type_Int)== 0)
	    return YES;
	if (strcmp(toType, type_Float)== 0)
	    return YES;
	if (strcmp(toType, type_Bool)== 0)
	    return YES;
	if (strcmp(toType, type_String)== 0)
	    return YES;
	if (strcmp(toType, type_Product)== 0)
	    return NO;
	if (strcmp(toType, type_Coproduct)== 0)
	    return NO;
	if (strcmp(toType, type_Subset)== 0)
	    return NO;
	else
	    return NO;
	}
    else
	return YES;

}

- (NSString *)typeName;
{
  if ([myValue isKindOfClass:[NSString class]])
    return ns_type_String;
  if ([myValue isKindOfClass:[NSNumber class]]) 
    return ns_type_Float;  // not already clean, is it?
    //    return [(NSNumber *)myValue typeName]; // jg: already defined?
  if ([myValue isKindOfClass:[JgFract class]])
    return ns_type_Fract;
  // watch for ModuleElements
  return @"error";
}

- changeTypeString: (const char *)toType;
{
  if (![[self typeName]isEqualToString:[NSString stringWithCString:toType]]) {
    if (strcmp(toType, type_Empty)== 0)  // ??
        [super changeTypeString:toType];
    if (strcmp(toType, type_Predicate)== 0)  // ??
        [super changeTypeString:toType];
    if (strcmp(toType, type_Int)== 0)
        [self setIntValue:[self intValue]];
    if (strcmp(toType, type_Float)== 0)
        [self setFloatValue:[self floatValue]];
    if (strcmp(toType, type_Bool)== 0)
        [self setBoolValue:[self boolValue]];
    if (strcmp(toType, type_String)== 0)
        [self setStringValue:[self stringValue]];
    if (strcmp(toType, type_Product)== 0)
        [super changeTypeString:toType];
    if (strcmp(toType, type_Coproduct)== 0)
        [super changeTypeString:toType];
    if (strcmp(toType, type_Subset)== 0)
        [super changeTypeString:toType];
  }
  return self;
}


/*access methods to all predicates values*/
#include "SimpleValueAccess.m"

#include "Simple.m"

@end
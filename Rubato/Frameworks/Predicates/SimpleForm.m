/* SimpleForm.m */

#import "SimpleForm.h"
#import "SimplePredicate.h"

#define inspectorNibName @"SimpleFormInspector.nib"

@implementation SimpleForm

+ (SimpleForm *)valueForm;
{
  static id valueForm;
  if (valueForm)
    return valueForm;
  valueForm = [[SimpleForm alloc] init];
  [valueForm setTypeString:type_String];
  [valueForm setNameString:"ValueForm"];
  [valueForm setLocked:YES];
  [valueForm setAllowsToChangeType:YES];
  return valueForm;
}


- init
{
    [super init];
    /* class-specific initialization goes here */
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

    [myValue release];
    return [super dealloc];
}


- copyWithZone:(NSZone*)zone;
{
    SimpleForm *myCopy = [super copyWithZone:zone];
    myCopy->myValue = [myValue copyWithZone:zone];
    return myCopy;
}

+(void)initialize;
{
  [SimpleForm setVersion:2];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  unsigned oldVersion=[aDecoder versionForClassName:@"SimpleForm"];
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    if (oldVersion < 2) {
      myValue=nil; // myValue was not encoded in SimpleForm
    } else {
      myValue =[aDecoder decodeObject];
    }
    [myValue retain];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:myValue];  // jg
}



/*Form specific methods*/
- makePredicate;
{
    return [self makePredicateFromZone:[self zone]];
}

- makePredicateFromZone:(NSZone *)zone;
{
    id aPredicate = [[SimplePredicate allocWithZone:zone]init];
    [aPredicate setNameString:[self nameString]];
    [aPredicate setForm:self];
    [aPredicate setStringValue:[self stringValue]];
    return aPredicate;
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

- (BOOL) canChangeTypeString: (const char *)toType
{
    if (isLocked) 
	return NO;
    if (![[self typeName]isEqualToString:[NSString stringWithCString:toType]]) {
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
	if (strcmp(toType, type_Product)== 0)
	    return YES;
	if (strcmp(toType, type_Coproduct)== 0)
	    return YES;
	if (strcmp(toType, type_Subset)== 0)
	    return YES;
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
    if (![[self typeName]isEqualToString:[NSString stringWithCString:toType]]) {
	if (strcmp(toType, type_Generic)== 0) 
		/* never convert to a GENERIC predicate.
		    *This is only an abstract superclass.
		    */
	    return nil;
	if (strcmp(toType, type_Empty)== 0) {
	    [self setType0:[NSString jgStringWithCString:toType]];
	    return self;
	}
	if (strcmp(toType, type_Predicate)== 0)
	    return nil;
	if (strcmp(toType, type_Int)== 0) {
	    [self setType0:[NSString jgStringWithCString:toType]];
	    return self;
	}
	if (strcmp(toType, type_Float)== 0) {
	    [self setType0:[NSString jgStringWithCString:toType]];
	    return self;
	}
	if (strcmp(toType, type_Bool)== 0) {
	    [self setType0:[NSString jgStringWithCString:toType]];
	    return self;
	}
	if (strcmp(toType, type_String)== 0) {
	    [self setType0:[NSString jgStringWithCString:toType]];
	    return self;
	}
	if (strcmp(toType, type_Product)== 0) {
	    return nil;
	}
	if (strcmp(toType, type_Coproduct)== 0) {
	    return nil;
	}
	if (strcmp(toType, type_Subset)== 0) {
	    return nil;
	}
	else
	    return nil;
	}
    else
	return self;
}


/*access methods to the predicates form */

/*access methods to all predicates values*/
#include "SimpleValueAccess.m"

#include "Simple.m"

@end
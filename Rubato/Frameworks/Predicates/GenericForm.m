/* GenericForm.m */

#import "GenericForm.h"

@implementation GenericForm

- init
{
    [super init];
    /* class-specific initialization goes here */
    [self setNameString:nilStr];
    myType = [[NSString alloc] initWithCString:type_String];
    myForm = self;
    needsUniqueName = NO;
    isLocked = NO;
    allowsTo.changeName = YES;
    allowsTo.changeType = YES;
    allowsTo.setValue = YES;
    return self;
}


- (void)dealloc;
{
#if PKRefCountImplemented
    /* do NXReference houskeeping */
#endif

    [myType release];
    myType = nil;
    [super dealloc];
}


- copyWithZone:(NSZone*)zone;
{
    GenericForm *myCopy = [super copyWithZone:zone];
    myCopy->myType = [myType copyWithZone:zone];
    if (needsUniqueName) {
      [myCopy setName0:[[myCopy name] stringByAppendingString:@" copy"]];
    }
    return myCopy;
}

+(void)initialize;
{
  [GenericForm setVersion:2];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  unsigned oldVersion=[aDecoder versionForClassName:@"GenericForm"];
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
   if (oldVersion < 2) {
       myType=[StringConverter readNSStringWithCoder:aDecoder];
    } else {
     myType =  [aDecoder decodeObject];
   } 
   [myType retain];
    [aDecoder decodeValueOfObjCType:"{ccc}" at:&allowsTo];
    [aDecoder decodeValueOfObjCType:"c" at:&needsUniqueName];
    [aDecoder decodeValueOfObjCType:"c" at:&isLocked];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myType];
    [aCoder encodeValueOfObjCType:"{ccc}" at:&allowsTo];
    [aCoder encodeValueOfObjCType:"c" at:&needsUniqueName];
    [aCoder encodeValueOfObjCType:"c" at:&isLocked];
}



/*Form specific methods*/
- setAllowsToChangeName:(BOOL)nameFlag 
		Type:(BOOL)typeFlag 
		Value:(BOOL)valueFlag;
{
    if (!isLocked) {
	allowsTo.changeName = nameFlag;
	allowsTo.changeType = typeFlag;
	allowsTo.setValue = valueFlag;
    }
    return self;
}

- setAllowsToChangeName:(BOOL)nameFlag ;
{
    if (!isLocked) allowsTo.changeName = nameFlag;
    return self;
}

- setAllowsToChangeType:(BOOL)typeFlag ;
{
    if (!isLocked) allowsTo.changeType = typeFlag;
    return self;
}

- setAllowsToChangeValue:(BOOL)valueFlag;
{
    if (!isLocked) allowsTo.setValue = valueFlag;
    return self;
}

- setNeedsUniqueName:(BOOL)flag;
{
    if (!isLocked) needsUniqueName = flag;
    return self;
}

- setLocked:(BOOL)flag;
{
    isLocked = flag;
    return self;
}

- (BOOL)allowsToChangeName;
{
    return allowsTo.changeName;
}

- (BOOL)allowsToChangeType;
{
    return allowsTo.changeType;
}

- (BOOL)allowsToChangeValue;
{
    return allowsTo.setValue;
}

- (BOOL)needsUniqueName;
{
    return needsUniqueName;
}

- (BOOL)isLocked;
{
    return isLocked;
}


- (BOOL)allowsTo:(SEL)aSelector;
{
    if (aSelector==@selector(changeType:))
	return allowsTo.changeType;
    else return YES;
}

- makePredicate;
{
    return nil;
}

- makePredicateFromZone:(NSZone *)zone;
{
    return nil;
}


/* special object methods to be overridden */
- (const char*) fileTypeString;
{
    return FormFileType;
}


/*access methods to all predicates names*/
- setName:(id)sender;
{
    if ( sender!=nil && [myForm allowsToChangeName] && !isLocked) {
    	if ([sender respondsToSelector:@selector(name)]) {
	    if (![myName isEqualToString:[sender name]]) {
		[self setName0:[sender name]];
	    }
	}
    	else if ([sender respondsToSelector:@selector(stringValue)]) {
	    if (![myName isEqualToString:[sender stringValue]]) {
                [self setName0:[sender stringValue]];
	    }
	}
    }
    return self;
}


- setNameString: (const char *)aName;
{
    if ([myForm allowsToChangeName] && !isLocked)
      [self setName0:[NSString jgStringWithCString:aName]];
    return self;
}

//- getName;
//- getNameString;/* returns a StringConverter object */
//- (const char *)nameString;

/*access methods to the predicates type */
- (void)setType:sender;
{
    if (sender!=nil && allowsTo.changeType && !isLocked) {
    	if ([sender respondsToSelector:@selector(typeName)]) 
	    [self setType0:[(GenericPredicate *)sender typeName]];
    	else if ([sender respondsToSelector:@selector(stringValue)]) 
	    [self setType0:[sender stringValue]];
    }
}

- (void)setType0:(NSString *)value;
{
  [myType release];
  myType = [value copy];
}

- setTypeString: (const char *)aType;
{
    if ([self canChangeTypeString:aType])
	[self changeTypeString:aType];
    return self;
}

- (NSString *)type;
{
  return myType;
}

- (NSString *)typeName; // jg new.
{
    return myType;
}

- (const char *) typeString;
{
    return [myType cString];
}

- (BOOL) canChangeTypeString: (const char *)toType
{
    return NO;
}

- changeTypeString: (const char *)toType;
{
    return self;
}


/*access methods to the predicates form */
- setForm: aPredicateForm;
{
    /* does nothing. Form has no form */
    return self;
}


@end
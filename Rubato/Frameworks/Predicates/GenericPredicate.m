/* GenericPredicate.m */

#import "GenericPredicate.h"

#import "GenericForm.h"
//12.11.01 #import "MKScoreReader.h"
//frmwrk #import "FormManager.h"
#import <Rubato/FormListProtocol.h>

#define inspectorNibName @"ValueInspector.nib"

id currentFormManager;


@implementation GenericPredicate
- (NSArray *)attributeKeys;
{
    static NSArray *keys=nil;
    if (!keys)
        keys=[[NSArray alloc] initWithObjects:@"name",@"type",nil];
    return keys;
}
- (NSArray *)toOneRelationshipKeys;
{
    static NSArray *keys=nil;
    if (!keys)
        keys=[[NSArray alloc] initWithObjects:@"form",nil];
    return keys;
}


- init
{
    [super init];
    /* class-specific initialization goes here */
    myName = [[NSString alloc] initWithCString:predibaseDefaultName];
    myForm = nil;
    myTag = 0;
    return self;
}


- (void)dealloc;
{
#if PKRefCountImplemented
    /* do NXReference houskeeping */
#endif
    
    [myName release];
    myName = nil;
    [super dealloc];
}


- copyWithZone:(NSZone*)zone;
{
    GenericPredicate *myCopy = JGSHALLOWCOPY;
    myCopy->myName = [myName copyWithZone:zone];

#if PKRefCountImplemented
    [myForm ref];
#endif

    return myCopy;
}
+(void)initialize;
{
  [GenericPredicate setVersion:2];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  unsigned oldVersion=[aDecoder versionForClassName:@"GenericPredicate"];
//    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    if (oldVersion < 2) {
      myName=[StringConverter readNSStringWithCoder:aDecoder];
    } else {
      myName =[aDecoder decodeObject];
    }
    [myName retain];
    myForm =  [[aDecoder decodeObject] retain];

#if PKRefCountImplemented
    [myForm ref];
#endif

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
//    [super encodeWithCoder:aCoder];
    
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myName];
    [aCoder encodeObject:myForm];
}


/* special object methods to be overridden */
- (NSString *) inspectorNibFile;
{
    return inspectorNibName;
}

- (const char*) fileTypeString;
{
    return PredFileType;
}

- (int)tag;
{
    return myTag;
}

- (void)setTag:(int)anInt;
{
    myTag = anInt;
}


- appendToMathString:(NSMutableString *)mutableString;
{
    return [self appendToMathString:mutableString andTabs:NO_TABS];
}

- appendToMathString:(NSMutableString *)mutableString andTabs:(int)tabCount;
{
    id delimiter = [[PredicateDelimiter alloc]init];
    if (!mutableString) //jg!! in this case mutableString is not retured!
	mutableString = [NSMutableString new];
    
    [delimiter withType:YES];
    [delimiter withName:YES];
    [delimiter withValue:YES];
    [delimiter setNew:"\n"];
    [delimiter setIndent:"\t"];
    [delimiter setStart:"["];
    [delimiter setEnd:"]"];
    [delimiter setFieldStart:"\""];
    [delimiter setFieldEnd:"\""];
    [delimiter setFieldDelimiter:","];
    
    [self appendToString:mutableString withDelimiters:delimiter andIndent:tabCount];
    
    [delimiter release];
    return self;
}

- appendToString:(NSMutableString *)mutableString withDelimiters:delimiters andIndent:(int)indentCount;
{
    int countIndents;
    if (mutableString) {
    
	if (!delimiters) {
	    delimiters = [[PredicateDelimiter alloc]init];
	}
	
	if (indentCount!=NO_TABS) {
	    [mutableString appendFormat:@"%s", [delimiters new]];
	    for (countIndents=0; countIndents<indentCount; countIndents++) {
		[mutableString appendFormat:@"%s", [delimiters indent]];
	    }
	}
	if ([delimiters hasType]) {
	    [mutableString appendFormat:@"%s", [self fileTypeString]];
	    [mutableString appendFormat:@"%s", [self typeString]];
	}
	[mutableString appendFormat:@"%s", [delimiters start]];

	if ([delimiters hasName]){
	    [mutableString appendFormat:@"%s", [delimiters fieldStart]];
	    [mutableString appendFormat:@"%@",[self name]];
	    [mutableString appendFormat:@"%s", [delimiters fieldEnd]];
	    if ([delimiters hasForm])
		[mutableString appendFormat:@"%s", [delimiters fieldDelimiter]];
	}
	
	if ([delimiters hasForm]){
	    [mutableString appendFormat:@"%s", [delimiters fieldStart]];
            [mutableString appendFormat:@"%@", [myForm name]];
	    [mutableString appendFormat:@"%s", [delimiters fieldEnd]];
	    if ([delimiters hasValue])
		[mutableString appendFormat:@"%s", [delimiters fieldDelimiter]];
	}
	
	if ([delimiters hasValue]) {
	    [[self getValue] appendToString:mutableString withDelimiters:delimiters andIndent:indentCount+1];
	}
	[mutableString appendFormat:@"%s", [delimiters end]];
    }
    return self;
}

/*access methods to all predicates names*/
- setName:(id)sender;
{
    if ( sender!=nil && [myForm allowsToChangeName]) {
    	if ([sender respondsToSelector:@selector(name)]) {
	    if (![myName isEqualToString:[sender name]]) { //jg Change war: sender nameString 
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

- (void)setName0:(NSString *)value;
{
  [myName release];
  myName = [value copy];
}

- setNameString: (const char *)aName;
{
    if ([myForm allowsToChangeName]) {
      [myName release];
      myName=[NSString jgStringWithCString:aName];
      [myName retain];
    }
    return self;
}

/*
- getName; // jg not used and bad method name.
{
    id aPredicate;
    
    aPredicate = [[GenericPredicate alloc] init];
    [aPredicate setNameString:[self nameString]];
    return aPredicate;
}
*/

/* replaced by -name
- getNameString;
{
    return myName;
}
*/
- (NSString *)name; // jg added
{
    return myName;
}

- (const char *)nameString;
{
    return [myName cString];
}


/*access methods to the predicates type */
- (void)setType:sender;
{
}


- setTypeString: (const char *)aType;
{
    return self;
}

/* jg Change
- getTypeString;
{
    return [myForm getTypeString];
}
*/
- (NSString *)type; //jg Change see above  - getTypeString;
{
    return [myForm type];
}
- (NSString *)typeName; //jg Change see above  - getTypeString;
{
   return [myForm type];
}

- (const char *) typeString;
{
    return [myForm typeString];
}


- (BOOL) canChangeTypeString: (const char *)toType
{
    return [myForm canChangeTypeString:toType];
}

- changeTypeString: (const char *)toType;
{
    return self;
}


/*access methods to the predicates form */
- setForm: aPredicateForm;
{
    if (!myForm && [aPredicateForm isKindOfClass:[GenericForm class]])
	myForm = aPredicateForm;
    return self;
}
- (void)jgSetForm:(id)Form; // jg hack
{
  myForm=Form;
}

- form;
{
    return myForm;
}



/*access methods to the predicates parent (its super-predicate)*/
- setParent: aPredicate;
{
    return self;
}

- parent;
{
    return nil;
}

/*access methods to all predicates values*/
- (unsigned int)count;
{
    return 0;
}

- (unsigned int)indexOfValue: aValue;
{
    return NSNotFound;
}

- setValue: aValue;
{
    /* Predicate specific code goes here */
    return self;
}

- removeValue: aValue;
{
    id aParent = self;
    while (!([aParent getValue] == aValue) && aParent)
	   aParent = [aParent getValue];
    if (aParent) {/* parent of aValue found in our tree*/
	[aParent setValue:nil];
	[aValue setParent:nil];
	return aValue;
    } else
	return nil;
}

- deleteValue: aValue;
{
    id removed = [self removeValue:aValue];
    if (removed) {
	[removed release];
	return self;
    }else
	return nil;
}

- replaceValue: aValue with: bValue;
{
    id aParent = self;
    while (!([aParent getValue] == aValue) && aParent)
	    aParent = [aParent getValue];
    if (aParent) {/* parent of aValue found in our tree*/
	[bValue setValue:[aValue getValue]];
	[aParent setValue:bValue];
	[aValue setValue:nil];
	return aValue;
    } else
	return nil;
}


- (void)setStringValue:(NSString *)aString;
{
    [self setStringValueAt:0 to:[aString cString]];
}


- (void)setIntValue:(int)aInt;
{
    [self setIntValueAt:0 to:aInt];
}

- (void)setFloatValue:(float)aFloat;
{
    [self setFloatValueAt:0 to:aFloat];
}

- (void)setDoubleValue:(double)aDouble;
{
    [self setDoubleValueAt:0 to:aDouble];
}

- (selfvoid)setFractValue: (RubatoFract)aFract;
{
    [self setFractValueAt:0 to:aFract];
}

- (selfvoid)setBoolValue: (BOOL)aBool;
{
    [self setBoolValueAt:0 to:aBool];
}




- setValueOf: (const char *)aPredicateName to: aValue;
{
    if ([myForm allowsToChangeValue])
	[[self getFirstPredicateOfNameString:aPredicateName]setValue:aValue];
    return self;
}

- setStringValueOf: (const char *)aPredicateName to: (const char *)aString;
{
    if ([myForm allowsToChangeValue])
	[[self getFirstPredicateOfNameString:aPredicateName] setStringValue:[NSString jgStringWithCString:aString]];
    return self;
}

- setIntValueOf: (const char *)aPredicateName to: (int)aInt;
{
    if ([myForm allowsToChangeValue])
	[[self getFirstPredicateOfNameString:aPredicateName] setIntValue:aInt];
    return self;
}

- setFloatValueOf: (const char *)aPredicateName to: (float)aFloat;
{
    if ([myForm allowsToChangeValue])
	[[self getFirstPredicateOfNameString:aPredicateName] setFloatValue:aFloat];
    return self;
}

- setDoubleValueOf: (const char *)aPredicateName to: (double)aDouble;
{
    if ([myForm allowsToChangeValue])
	[[self getFirstPredicateOfNameString:aPredicateName] setDoubleValue:aDouble];
    return self;
}

- setFractValueOf: (const char *)aPredicateName to: (RubatoFract)aFract;
{
    if ([myForm allowsToChangeValue])
	[[self getFirstPredicateOfNameString:aPredicateName]setFractValue:aFract];
    return self;
}

- setBoolValueOf: (const char *)aPredicateName to: (BOOL)aBool;
{
    if ([myForm allowsToChangeValue])
	[[self getFirstPredicateOfNameString:aPredicateName]setBoolValue:aBool];
    return self;
}



- setValueAt: (unsigned int)index to: aValue;
{
    return self; /* must be overriden in subclasses */
}

- setStringValueAt: (unsigned int)index to: (const char *)aString;
{
    return self; /* must be overriden in subclasses */
}

- setIntValueAt: (unsigned int)index to: (int)aInt;
{
    return self; /* must be overriden in subclasses */
}

- setFloatValueAt: (unsigned int)index to: (float)aFloat;
{
    return self; /* must be overriden in subclasses */
}

- setDoubleValueAt: (unsigned int)index to: (double)aDouble;
{
    return self; /* must be overriden in subclasses */
}

- setFractValueAt: (unsigned int)index to: (RubatoFract)aFract;
{
    return self; /* must be overriden in subclasses */
}

- setBoolValueAt: (unsigned int)index to: (BOOL)aBool;
{
    return self; /* must be overriden in subclasses */
}



- getValue;
{
    return nil;/* must be overriden in subclasses */
}

- getStringValue;
{
    return [self getStringValueAt:0];
}

- (NSString *)stringValue;
{
    return [NSString jgStringWithCString:[self stringValueAt:0]];
}

- (int)	intValue;
{
    return [self intValueAt:0];
}

- (float)floatValue;
{
    return [self floatValueAt:0];
}

- (double)doubleValue;
{
    return [self doubleValueAt:0];
}

- (RubatoFract)fractValue;
{
    return [self fractValueAt:0];
}

- (BOOL)boolValue;
{
    return [self boolValueAt:0];
}


- getValueOf: (const char *)aPredicateName;
{
    return [self getFirstPredicateOfNameString:aPredicateName];
}

- getStringValueOf: (const char *)aPredicateName;
{
    return [[self getFirstPredicateOfNameString:aPredicateName]getStringValue];
}

- (NSString *)stringValueOfPredicateWithName:(NSString *)predName;
{
  id aPredicate = [self getFirstPredicateOfName:predName];
  if (aPredicate)
    return [aPredicate stringValue];
  else
    return nil;
}
- (const char *)stringValueOf: (const char *)aPredicateName;
{
    id aPredicate = [self getFirstPredicateOfNameString:aPredicateName];
    if (aPredicate)
	return [[aPredicate stringValue] cString];
    else
	return nilStr;
}

- (int)	intValueOf: (const char *)aPredicateName;
{
    id aPredicate = [self getFirstPredicateOfNameString:aPredicateName];
    if (aPredicate)
	return [aPredicate intValue];
    else
	return nilVal;
}

- (float)floatValueOf: (const char *)aPredicateName;
{
    id aPredicate = [self getFirstPredicateOfNameString:aPredicateName];
    if (aPredicate)
	return [aPredicate floatValue];
    else
	return nilVal;
}

- (double)doubleValueOf: (const char *)aPredicateName;
{
    id aPredicate = [self getFirstPredicateOfNameString:aPredicateName];
    if (aPredicate)
	return [aPredicate doubleValue];
    else
	return nilVal;
}

- (RubatoFract)fractValueOf: (const char *)aPredicateName;
{
    id aPredicate = [self getFirstPredicateOfNameString:aPredicateName];
    if (aPredicate)
	return [aPredicate fractValue];
    else
	return (RubatoFract){0, 0, 0};
}

- (BOOL)boolValueOf: (const char *)aPredicateName;
{
    id aPredicate = [self getFirstPredicateOfNameString:aPredicateName];
    if (aPredicate)
	return [aPredicate boolValue];
    else
	return NO;
}


- getValueAt: (unsigned int)index;
{
    return nil;/* must be overriden in subclasses */
}

- getStringValueAt: (unsigned int)index;
{
    return nil;/* must be overriden in subclasses */
}

- (const char *)stringValueAt: (unsigned int)index;
{
    return nilStr;/* must be overriden in subclasses */
}

- (int)	intValueAt: (unsigned int)index;
{
    return nilVal;/* must be overriden in subclasses */
}

- (float)floatValueAt: (unsigned int)index;
{
    return nilVal;/* must be overriden in subclasses */
}

- (double)doubleValueAt: (unsigned int)index;
{
    return nilVal;/* must be overriden in subclasses */
}

- (RubatoFract)fractValueAt: (unsigned int)index;
{
    return nilFract;/* must be overriden in subclasses */
}

- (BOOL)boolValueAt: (unsigned int)index;
{
    return NO;/* must be overriden in subclasses */
}


/*check methods for all predicates*/
- (BOOL) hasPredicate:aPredicate;
{
    return [self hasPredicate:aPredicate inLevels:ALL_LEVELS];
}

- (BOOL) hasPredicate:aPredicate inLevels:(int)levels;
{
    return [self getFirstPredicateOf:@selector(isEqual:) with:aPredicate inLevels:levels]!=nil;
}


- (BOOL) isPredicateOfNameString: (const char *)aPredicateName;
{
    return [myName isEqualToString:[NSString jgStringWithCString:aPredicateName]];
}

- (BOOL) hasPredicateOfNameString: (const char *)aPredicateName;
{
    return [self hasPredicateOfNameString:aPredicateName inLevels:ALL_LEVELS];
}

- (BOOL) hasPredicateOfNameString: (const char *)aPredicateName inLevels:(int)levels;
{
    BOOL retVal;
    id aName = [[NSString alloc]initWithCString:aPredicateName];
    retVal = [self getFirstPredicateOf:@selector(isPredicateOfName:) with:aName inLevels:levels]!=nil;
    [aName release];
    aName = nil;
    return retVal;
}

- (id<PredicateProtocol>)getFirstPredicateOfNameString: (const char *)aPredicateName;
{
    return [self getFirstPredicateOfNameString:aPredicateName inLevels:ALL_LEVELS];
}

- (id<PredicateProtocol>)getFirstPredicateOfNameString: (const char *)aPredicateName inLevels:(int)levels;
{
    id retVal;
    id aName = [[NSString alloc]initWithCString:aPredicateName];
    retVal = [self getFirstPredicateOf:@selector(isPredicateOfName:) with:aName inLevels:levels];
    [aName release];
    aName = nil;
    return retVal;
}

- (JgList *)getAllPredicatesOfNameString: (const char *)aPredicateName;
{
    return [self getAllPredicatesOfNameString:aPredicateName inLevels:ALL_LEVELS];
}

- (JgList *)getAllPredicatesOfNameString: (const char *)aPredicateName inLevels:(int)levels;
{
    id retVal;
    id aName = [[NSString alloc]initWithCString:aPredicateName];
    retVal = [self getAllPredicatesOf:@selector(isPredicateOfName:) with:aName inLevels:levels];
    [aName release];
    aName = nil;
    return retVal;
}


- (BOOL) isPredicateOfName:aPredicateName;
{
    return [myName isEqualToString:aPredicateName];
}

- (BOOL) hasPredicateOfName: aPredicateName;
{
    return [self hasPredicateOfName:aPredicateName inLevels:ALL_LEVELS];
}

- (BOOL) hasPredicateOfName: aPredicateName inLevels:(int)levels;
{
    return [self getFirstPredicateOf:@selector(isPredicateOfName:) with:aPredicateName inLevels:levels]!=nil;
}


- (id<PredicateProtocol>)getFirstPredicateOfName:aPredicateName;
{
    return [self getFirstPredicateOf:@selector(isPredicateOfName:) with:aPredicateName inLevels:ALL_LEVELS];
}

- (id<PredicateProtocol>)getFirstPredicateOfName:aPredicateName inLevels:(int)levels;
{
    return [self getFirstPredicateOf:@selector(isPredicateOfName:) with:aPredicateName inLevels:levels];
}

- (JgList *)getAllPredicatesOfName:aPredicateName;
{
    return [self getAllPredicatesOf:@selector(isPredicateOfName:) with:aPredicateName inLevels:ALL_LEVELS];
}

- (JgList *)getAllPredicatesOfName:aPredicateName inLevels:(int)levels;
{
    return [self getAllPredicatesOf:@selector(isPredicateOfName:) with:aPredicateName inLevels:levels];
}



- (BOOL)hasPredicateAt:(unsigned int)index;
{
    if (!index)
	return [self getValue]!=nil;
    else
	return NO;
}

/*check methods for all predicates TYPES*/
- (BOOL) isPredicateOfType:(NSString *)aPredicateType;
{
    return [[self type] isEqualToString:aPredicateType];
}

- (BOOL) hasPredicateOfType:(NSString *)aPredicateType;
{
    return [self hasPredicateOfType:aPredicateType inLevels:ALL_LEVELS];
}

- (BOOL) hasPredicateOfType:(NSString *)aPredicateType inLevels:(int)levels;
{
    return !([self getFirstPredicateOf:@selector(isPredicateOfType:) with:aPredicateType inLevels:levels] == nil);
}

- (id<PredicateProtocol>)getFirstPredicateOfType:(NSString *)aPredicateType;
{
    return [self getFirstPredicateOf:@selector(isPredicateOfType:) with:aPredicateType inLevels:ALL_LEVELS];
}

- (id<PredicateProtocol>)getFirstPredicateOfType:(NSString *)aPredicateType inLevels:(int)levels;
{
    return [self getFirstPredicateOf:@selector(isPredicateOfType:) with: aPredicateType inLevels:levels];
}

- (JgList *)getAllPredicatesOfType:(NSString *)aPredicateType;
{
    return [self getAllPredicatesOf:@selector(isPredicateOfType:) with: aPredicateType inLevels:ALL_LEVELS];
}
- (JgList *)getAllPredicatesOfType:(NSString *)aPredicateType inLevels:(int)levels;
{
    return [self getAllPredicatesOf:@selector(isPredicateOfType:) with:aPredicateType inLevels:levels];
}



/*check methods for all predicates FORMS by form id*/
- (BOOL) isPredicateOfForm: (id)aPredicateForm;
{
    return (myForm==aPredicateForm);
}

- (BOOL) hasPredicateOfForm: (id)aPredicateForm;
{
    return [self hasPredicateOfForm:aPredicateForm inLevels:ALL_LEVELS];
}

- (BOOL) hasPredicateOfForm: (id)aPredicateForm inLevels:(int)levels;
{
    return [self getFirstPredicateOf:@selector(isPredicateOfForm:) with: aPredicateForm inLevels:levels]!=nil;
}

- (id<PredicateProtocol>)getFirstPredicateOfForm: (id)aPredicateForm;
{
    return [self getFirstPredicateOf:@selector(isPredicateOfForm:) with: aPredicateForm inLevels:ALL_LEVELS];
}

- (id<PredicateProtocol>)getFirstPredicateOfForm: (id)aPredicateForm inLevels:(int)levels;
{
    return [self getFirstPredicateOf:@selector(isPredicateOfForm:) with: aPredicateForm inLevels:levels];
}

- (JgList *)getAllPredicatesOfForm: (id)aPredicateForm;
{
    return [self getAllPredicatesOf:@selector(isPredicateOfForm:) with: aPredicateForm inLevels:ALL_LEVELS];
}

- (JgList *)getAllPredicatesOfForm: (id)aPredicateForm inLevels:(int)levels;
{
    return [self getAllPredicatesOf:@selector(isPredicateOfForm:) with: aPredicateForm inLevels:levels];
}


/*check methods for all predicates FORMS by name*/
- (BOOL) isPredicateOfFormName: (NSString *)aFormName;
{
    return [[myForm name]isEqualToString:aFormName];
}

- (BOOL) hasPredicateOfFormName: (NSString *)aFormName;
{
    return [self hasPredicateOfFormName:aFormName inLevels:ALL_LEVELS];
}

- (BOOL) hasPredicateOfFormName: (NSString *)aFormName inLevels:(int)levels;
{
    return [self getFirstPredicateOf:@selector(isPredicateOfFormName:) with:aFormName inLevels:levels]!=nil;
}

- (id<PredicateProtocol>)getFirstPredicateOfFormName: (NSString *)aFormName;
{
    return [self getFirstPredicateOf:@selector(isPredicateOfFormName:) with: aFormName inLevels:ALL_LEVELS];
}

- (id<PredicateProtocol>)getFirstPredicateOfFormName: (NSString *)aFormName inLevels:(int)levels;
{
    return [self getFirstPredicateOf:@selector(isPredicateOfFormName:) with: aFormName inLevels:levels];
}

- (JgList *)getAllPredicatesOfFormName: (NSString *)aFormName;
{
    return [self getAllPredicatesOf:@selector(isPredicateOfFormName:) with: aFormName inLevels:ALL_LEVELS];
}

- (JgList *)getAllPredicatesOfFormName: (NSString *)aFormName inLevels:(int)levels;
{
    return [self getAllPredicatesOf:@selector(isPredicateOfFormName:) with: aFormName inLevels:levels];
}

/* get methods according to any specification */
- (id<PredicateProtocol>)getFirstPredicateOf:(SEL)aTest with:(id)anObject;
{
    return [self getFirstPredicateOf:aTest with:anObject inLevels:ALL_LEVELS];
}

- (id<PredicateProtocol>)getFirstPredicateOf:(SEL)aTest with:(id)anObject inLevels:(int)levels;
{
    if (levels) {
	if (levels!=ALL_LEVELS) levels--;
	if (anObject) {
	    if ( [[self getValue] respondsToSelector:aTest]) {
		if ([[self getValue] performSelector:aTest withObject:anObject])
		    return [self getValue];
		else {
		    /* count down the levels to search */
		    if (levels!=ALL_LEVELS) levels--;
		    /* pass search message to next level */
		    return [[self getValue] getFirstPredicateOf:aTest with:anObject inLevels:levels];
		}
	    }
	    else
		return nil;
	} else
	    return [self getValue];/* return any predicate if nil specified as name*/
    }
    return nil; /* if 0 levels specified return nil */
}

- (JgList *)getAllPredicatesOf:(SEL)aTest with:(id)anObject;
{
    return [self getAllPredicatesOf:aTest with:anObject inLevels:ALL_LEVELS];
}

// this returns a retained List. In the future it should return a autoreleased retained object.
// but before: check with places, where this is used (a lot of them!)
- (JgList *)getAllPredicatesOf:(SEL)aTest with:(id)anObject inLevels:(int)levels;
{
    id returnList = nil;
    if (levels && anObject) {
	if (anObject) {
	    if ( [[self getValue] respondsToSelector:aTest]) {
		if ([[self getValue] performSelector:aTest withObject:anObject])
		    returnList = [[[JgList alloc]init] addObjectIfAbsent: [self getValue]];
		else {
		    /* count down the levels to search */
		    if (levels!=ALL_LEVELS) levels--;
		    /* pass search message to next level */
		    returnList=[[self getValue]getAllPredicatesOf:aTest with:anObject inLevels:levels];
		}
	    }
	} else
	    returnList=[[[JgList alloc]init]addObjectIfAbsent:[self getValue]];
	    /* return any predicate if nil specified as name*/
    }
    return returnList; /* if 0 levels specified return nil */
}

//jg: the following is added.

- (NSMutableDictionary *) jgToPropertyListWithDicts:(dictstruct *)dicts;
{
  NSMutableDictionary *d,*f; // a:Adressen, d:returnvalue f:forms
  JGAddressDictionary *a;

  a=dicts->addresses;
  f=dicts->forms;
  d=[NSMutableDictionary new];
  if ([a containsAddress:self]) {
    ; // do nothing 
  } else {
    printf("%s\n",[myName cString]);
    [d setObject:[self name] forKey:AttKey];
    [d setObject:[myForm name] forKey:FormKey];

    [a insertAddress:self withName:[self name]];
    if (    (![self isKindOfClass:[GenericForm class]])  // do not hold forms of forms!
         && (![f objectForKey:[myForm name]])  ) {
//      jgdebug();
      [f setObject:[myForm jgToPropertyListWithDicts:dicts] forKey:[myForm name]];
    }
    [self jgInfoToPropertyList:d withDicts:dicts]; // calls the Subclass-Method
  }
  [d setObject:[a getNameForAddress:self] forKey:@"ref"]; // here the name can be changed later through side effects.
  return d;
}

- (void) jgInfoToPropertyList:(NSMutableDictionary *)d withDicts:(dictstruct *)dicts;
{
}

- (NSMutableDictionary *) jgToPropertyList;
{
  NSMutableDictionary *d=[NSMutableDictionary new];
  [d setObject:[self name] forKey:AttKey];
  [d setObject:[myForm name] forKey:FormKey];
  return d;
}

- (void)jgInitFromPropertyList:(id) pl;
{
// next line already happens in jgNewFromPropertyList.
//  id form=[forms objectForKey:[pl objectForKey:FormKey]];
  NSString *att=[pl objectForKey:AttKey];
  [self setName0:att];
//  myForm=form;
}

+ (void)setFormManager:aManager;
{
  static int mkIsInited=0;
  currentFormManager=aManager;
  if (!mkIsInited) {
    id sr=[[NSClassFromString(@"MKScoreReader") alloc] init]; //12.11.01 removed class reference
    [sr setFormManager:aManager];
    [sr release];   // Seiteneffekte: MKValueListForm, MKValueForm.
    mkIsInited=1;
  }
}

// here in the real Code
// simply the Method makePredicateFromZone of CompoundForm should be used!
+ (GenericPredicate *) jgNewFromPropertyList:(NSDictionary *)d;
{
  NSString *formString;
  id form;
  GenericPredicate *pred;
  if (!d) return nil;

  formString=[d objectForKey:FormKey];
  form=[[currentFormManager formList] getFirstPredicateOfNameString:[formString cString]]; // formList does not work anymore
  if (!form) {
//   NSRunAlertPanel(@"Make Predicate from PLIST", @"Cannont find Form %@", @"Sorry", nil, nil, formString)
    NSLog(@"Make Predicate from PLIST: Cannont find Form %@", formString);
    return nil;
  }
  pred=[form makePredicate];
  [pred jgInitFromPropertyList:d];
  return pred;
}

@end

/* CompoundValueAccess.m */



/*access methods to all predicates values*/
- (unsigned int) count;
{
    return [myList count];
}

- (unsigned int) indexOfValue: aValue;
{
    return [myList indexOf: aValue];
}

- (void)setValue:(id)aValue;
{
    if ([aValue conformsToProtocol:@protocol(PredicateProtocol)])
	if ([myList addObjectIfAbsent:aValue])
	    [aValue setParent:self];
    if ([aValue isKindOfClass:[JgList class]]) {
	id aPredicate;
	unsigned int i=0;
	/* if we got a list, merge the new with our old list */
	do {
	    aPredicate = [aValue objectAt:i];
	    if ([aPredicate conformsToProtocol:@protocol(PredicateProtocol)])
		[myList addObjectIfAbsent:aPredicate];
	    i++;
	} while(i<[aValue count]);
	
	[myList makeObjectsPerform:@selector(setParent:)with:self];
    }
}

- removeValue: aValue;
{
    [[aValue retain] autorelease];
    [myList removeObject:aValue];
    [aValue setParent:nil];
    return aValue;
}

- deleteValue: aValue;
{
    id removed = [myList nx_removeObject:aValue];
    if (removed) {
//	[removed release];
	return self;
    } else
	return nil;
}

- replaceValue: aValue with: bValue;
{
    id removed = [myList replaceObject: aValue with: bValue];
    if (removed) {
	[aValue setParent:nil];
	[bValue setParent:self];
    }
    return removed;
}

//- setStringValue: (const char *)aString;
//- setIntValue: (int)aInt;
//- setFloatValue: (float)aFloat;
//- setBoolValue: (BOOL)aBool;

- (void)addValue:(id)aValue;
{
  [myList addObject:aValue];
  [aValue setParent:self];
}

- setValueAt: (unsigned int)index to: aValue;
{
    if ([myList indexOf:aValue]==NSNotFound) {  // jg?: still valid for DenotatorenForms? No!
	int count = [myList count];
	index = index<=count ? index : count;
	if ([myList insertObject:aValue at:index]) {
	    [aValue setParent:self];
	    return self;
	}
	return nil;
    } else
	return nil;
}

- setStringValueAt: (unsigned int)index to: (const char *)aString;
{
    [[myList objectAt:index] setStringValue:[NSString jgStringWithCString:aString]];
    return self;
}

- setIntValueAt: (unsigned int)index to: (int)aInt;
{
    [[myList objectAt:index] setIntValue:aInt];
    return self;
}

- setFloatValueAt: (unsigned int)index to: (float)aFloat;
{
    [[myList objectAt:index] setFloatValue:aFloat];
    return self;
}

- setDoubleValueAt: (unsigned int)index to: (double)aDouble;
{
    [[myList objectAt:index] setDoubleValue:aDouble];
    return self;
}

- setFractValueAt: (unsigned int)index to: (RubatoFract)aFract;
{
    [[myList objectAt:index] setFractValue:aFract];
    return self;
}

- setBoolValueAt: (unsigned int)index to: (BOOL)aBool;
{
    [[myList objectAt:index] setBoolValue:aBool];
    return self;
}


- getValue;
{
    return [myList objectAt:0];
    /* just returns first object in list. maybe stupid!!! */
}

//- getStringValue;
//- (const char *)	stringValue;
//- (int) 		intValue;
//- (float)		floatValue;
//- (BOOL)		boolValue;



- getValueAt: (unsigned int)index;
{
    return [myList objectAt:index];
}

- getStringValueAt: (unsigned int)index;
{
    id aPredicate = [myList objectAt:index];
    if (aPredicate)
	return [aPredicate getStringValue];
    else
	return nil;
}

- (const char *)	stringValueAt: (unsigned int)index;
{
    id aPredicate = [myList objectAt:index];
    if (aPredicate)
	return [[aPredicate stringValue] cString];
    else
	return nilStr;
}

- (int)			intValueAt: (unsigned int)index;
{
    id aPredicate = [myList objectAt:index];
    if (aPredicate)
	return [aPredicate intValue];
    else
	return nilVal;
}

- (float)		floatValueAt: (unsigned int)index;
{
    id aPredicate = [myList objectAt:index];
    if (aPredicate)
	return [aPredicate floatValue];
    else
	return nilVal;
}

- (double)		doubleValueAt: (unsigned int)index;
{
    id aPredicate = [myList objectAt:index];
    if (aPredicate)
	return [aPredicate doubleValue];
    else
	return nilVal;
}

- (RubatoFract)		fractValueAt: (unsigned int)index;
{
    id aPredicate = [myList objectAt:index];
    if (aPredicate)
	return [aPredicate fractValue];
    else
	return nilFract;
}

- (BOOL)		boolValueAt: (unsigned int)index;
{
    id aPredicate = [myList objectAt:index];
    if (aPredicate)
	return [aPredicate boolValue];
    else
	return NO;
}


/*check methods for all predicates*/
//- (BOOL) isPredicateOfName:aPredicateName;

#if 0
- (BOOL) hasPredicateOfName:aPredicateName inLevels:(int)levels;
{
    int i=0;
    id	aPredicate;
    
    if (levels) {
	do {
	    aPredicate = [myList objectAt:i];
	    if ([aPredicate isPredicateOfName: aPredicateName]) 
		return YES;
	    i++;
	} while (i<[myList count]);
    
	/* not found in the first level, search the next levels */
	i=0;
	if(levels!=ALL_LEVELS) levels--;
	do {
	    aPredicate = [myList objectAt:i];
	    aPredicate = [aPredicate getFirstPredicateOfName:aPredicateName inLevels:levels];
	    if (aPredicate) 
		return YES;
	    i++;
	} while (i<[myList count]);
    }	
    return NO;
}
#endif


- (BOOL)hasPredicateAt:(unsigned int)index;
{
    return [myList objectAt:index]!=nil;
}

/*check methods for all predicates TYPES*/
/*check methods for all predicates FORMS*/
//- (BOOL) isPredicateOfForm: aPredicateForm;
//- (BOOL) hasPredicateOfForm: aPredicateForm;
//- getFirstPredicateOfForm: aPredicateForm;
//- getAllPredicatesOfForm: aPredicateForm;

/* get methods according to any specification */
- getFirstPredicateOf:(SEL)aTest with:anObject inLevels:(int)levels;
{
    int i=0;
    id	aPredicate;
    
    if (levels && anObject) {
	do {
	    if ([self hasPredicateAt:i]) {
		aPredicate = [myList objectAt:i];
		if ([aPredicate respondsToSelector:aTest]) 
		    if ([aPredicate performSelector:aTest withObject:anObject]) 
			return aPredicate;
	    }
	    i++;
	} while (i<[myList count]);
    
	/* not found in the first level, search the next levels */
	i=0;
	if(levels!=ALL_LEVELS) levels--;
	do {
	    if ([self hasPredicateAt:i]) {
		aPredicate = [myList objectAt:i];
		aPredicate = [aPredicate getFirstPredicateOf:aTest with:anObject inLevels:levels];
		if (aPredicate) 
		    return aPredicate;
	    }
	    i++;
	} while (i<[myList count]);
    }	
    return nil;
}

- getAllPredicatesOf:(SEL)aTest with:anObject inLevels:(int)levels;
{
    if (levels && anObject) {
	int i=0, j=0;
	id aPredicate;
	id returnList, aSet;
	if (anObject) {
	    returnList = [[JgList allocWithZone:[self zone]]init];
	    do {
		if ([self hasPredicateAt:i]) {
		    aPredicate = [myList objectAt:i];
		    if ([aPredicate respondsToSelector:aTest]) 
			if ([aPredicate performSelector:aTest withObject:anObject]) 
			    [returnList addObjectIfAbsent: aPredicate];
		}
		i++;
	    } while (i<[myList count]);
	    
	    i=0;
	    if(levels!=ALL_LEVELS) levels--;
	    do {
		if ([self hasPredicateAt:i]) {
		    aPredicate = [myList objectAt:i];
		    aSet = [aPredicate getAllPredicatesOf:aTest with:anObject inLevels:levels];
		    for(j=0; j<[aSet count]; j++) { /*add all returned predicates to returnList*/
			[returnList addObjectIfAbsent: [aSet objectAt:j]];
		    }
		    [aSet release]; /*now free the returned list*/ // should be removed in future.
		}
		i++;
	    } while (i<[myList count]);
	    
	} else
	    returnList = [myList copy]; /* if nil specified as name, return whole list*/
	if ([returnList count])
	    return returnList;
	else {
	    [returnList release];
	    return nil;
	}
    }
    return nil;
}


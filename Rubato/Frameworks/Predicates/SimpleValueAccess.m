/* SimpleValueAccess.m */

/*access methods to all predicates values*/
- (unsigned int)count;
{
    return (myValue!=nil);
}

- (unsigned int)indexOfValue: aValue;
{
    if (myValue==aValue) 
	return 0;
    else
	return NSNotFound;
}

- setValueAt: (unsigned int)index to: aValue;  // aValue is a GenericPredicate
{
    if (!index && [myForm allowsToChangeValue]) {
        myValue=[aValue copy]; // jg
/*	if (aValue!=nil && [aValue respondsToSelector:@selector(stringValue)])
	    [self setStringValue:[aValue stringValue]];
	else
	    [self setStringValue:[NSString stringWithCString:nilStr]];
*/
    }
    return self;
}


- setStringValueAt: (unsigned int)index to: (const char *)aString;
{
    if (!index && [myForm allowsToChangeValue]) {
        [myValue release];
	myValue=[[NSString alloc] initWithCString:aString];
	[self setTypeString: type_String];
    }
    return self;
}


- setIntValueAt: (unsigned int)index to: (int)aInt;
{
    if (!index && [myForm allowsToChangeValue]) {
        [myValue release];
	myValue=[[NSNumber alloc] initWithInt:aInt];
	[self setTypeString: type_Int];
    }
    return self;
}


- setFloatValueAt: (unsigned int)index to: (float)aFloat;
{
    if (!index && [myForm allowsToChangeValue]) {
       [myValue release];
       myValue=[[NSNumber alloc] initWithFloat:aFloat];
       [self setTypeString: type_Float];
    }
    return self;
}


- setDoubleValueAt: (unsigned int)index to: (double)aDouble;
{
    if (!index && [myForm allowsToChangeValue]) {
      [myValue release];
      myValue=[[NSNumber alloc] initWithDouble:aDouble];
      [self setTypeString: type_Float];
    }
    return self;
}

- setBoolValueAt: (unsigned int)index to: (BOOL)aBool;
{
    if (!index && [myForm allowsToChangeValue]) {
      [myValue release];
      myValue=[[NSNumber alloc] initWithBool:aBool];
      [self setTypeString: type_Bool];
    }
    return self;
}

- setFractValueAt: (unsigned int)index to: (RubatoFract)aFract;
{
    if (!index && [myForm allowsToChangeValue]) {
      [myValue release];
      myValue=[[JgFract alloc] initWithFract:aFract];
      [self setTypeString: type_Fract];
    }
    return self;
}





//- setValueOf: (const char *)aPredicateName to: aValue;
//- setStringValueOf: (const char *)aPredicateName to: (const char *)aString;
//- setIntValueOf: (const char *)aPredicateName to: (int)aInt;
//- setFloatValueOf: (const char *)aPredicateName to: (float)aFloat;
//- setBoolValueOf: (const char *)aPredicateName to: (BOOL)aBool;

- getValueAt: (unsigned int)index;
{
    return nil;
}

- getStringValueAt: (unsigned int)index;
{
    if ([self hasPredicateAt:index])
	return myValue;
    else
	return nil;
}

- (const char *) stringValueAt: (unsigned int)index;
{
    if ([self hasPredicateAt:index])
        if ([myValue respondsToSelector:@selector(stringValue)])
  	  return [[myValue stringValue] cString];
        else // jg: NSString   Watch for ModuleElements
          return [myValue cString]; 
    else
	return nilStr;
}

- (int) intValueAt: (unsigned int)index;
{
    if ([self hasPredicateAt:index])
	return [myValue intValue];
    else
	return nilVal;
}

- (float) floatValueAt: (unsigned int)index;
{
    if ([self hasPredicateAt:index])
	return [myValue floatValue];
    else
	return nilVal;
}

- (double) doubleValueAt: (unsigned int)index;
{
    if ([self hasPredicateAt:index])
	return [myValue doubleValue];
    else
	return nilVal;
}

- (RubatoFract) fractValueAt: (unsigned int)index;
{
    if ([self hasPredicateAt:index]) {
	return [myValue fractValue];
    }
    else
	return nilFract;
}

- (BOOL) boolValueAt: (unsigned int)index;
{
    if ([self hasPredicateAt:index])
	return [myValue boolValue];
    else
	return FALSE;
}


//- getValueOf: (const char *)aPredicateName;
//- getStringValueOf: (const char *)aPredicateName;
//- (const char *)	stringValueOf: (const char *)aPredicateName;
//- (int)			intValueOf: (const char *)aPredicateName;
//- (float)		floatValueOf: (const char *)aPredicateName;
//- (BOOL)		boolValueOf: (const char *)aPredicateName;

/*check methods for all predicates*/
//- (BOOL) isPredicateOfName:aPredicateName;
//- (BOOL) hasPredicateOfName:aPredicateName;
//- getFirstPredicateOfName: (const char *)aPredicateName;
//- getAllPredicatesOfName: (const char *)aPredicateName;

- (BOOL)hasPredicateAt:(unsigned int)index;
{
    if ([[self type] isEqualToString:ns_type_Empty])
	return FALSE;
    else
	return (!index && myValue);
}


/*check methods for all predicates TYPES*/
//- (BOOL) isPredicateOfType: (const char *)aPredicateType;
//- (BOOL) hasPredicateOfType: (const char *)aPredicateType;
//- getFirstPredicateOfType: (const char *)aPredicateType;
//- getAllPredicatesOfType: (const char *)aPredicateType;


/*check methods for all predicates FORMS*/
//- (BOOL) isPredicateOfForm: aPredicateForm;
//- (BOOL) hasPredicateOfForm: aPredicateForm;
//- getFirstPredicateOfForm: aPredicateForm;
//- getAllPredicatesOfForm: aPredicateForm;

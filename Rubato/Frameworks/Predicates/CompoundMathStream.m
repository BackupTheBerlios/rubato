/* CompoundValueAccess.m */


- makeString:aString withDelimiters:delimiters andIndent:(int)indentCount;
{
    int countIndents;
    unsigned int count, countComma, index=0;
    count=[myList count];
    
    if (!aString) {
	aString = [[StringConverter alloc]init];
    }
    
    if (!delimiters) {
	delimiters = [[PredicateDelimiter alloc]init];
    }
    
    if (indentCount!=NO_TABS) {
	[aString concat:[delimiters new]];
	for (countIndents=0; countIndents<indentCount; countIndents++) {
	    [aString concat:[delimiters indent]];
	}
    }
    [aString concat:[self fileTypeString]];
    [aString concat:[self typeString]];
    [aString concat:[delimiters start]];
    [aString concat:[delimiters fieldStart]];
    [aString concat:[self nameString]];
    [aString concat:[delimiters fieldEnd]];
    [aString concat:[delimiters fieldDelimiter]];
    
    /* class specific aString behaviour */
    indentCount = indentCount==NO_TABS ? NO_TABS : indentCount+1;
    countComma = [self count]-1;
    do{
	if ([self hasPredicateAt:index]) {
	    [[myList objectAt:index] makeString:aString withDelimiters:delimiters andIndent:indentCount];
	    if (countComma>0) { /* while countComma>0 concat one */
		[aString concat:[delimiters fieldDelimiter]];
		countComma--;
	    }
	}
	index++;
    }while(index<count);
    
    [aString concat:[delimiters end]];
    return aString;
}


- appendToString:(NSMutableString *)mutableString withDelimiters:delimiters andIndent:(int)indentCount;
{
    int countIndents;
    unsigned int count, countComma, index=0;
    count=[myList count];
    
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

	if ([delimiters hasName]) {
	    [mutableString appendFormat:@"%s", [delimiters fieldStart]];
            [mutableString appendFormat:@"%@",myName];
	    [mutableString appendFormat:@"%s", [delimiters fieldEnd]];
	    [mutableString appendFormat:@"%s", [delimiters fieldDelimiter]];
	}
	
	if ([delimiters hasForm]){
	    [mutableString appendFormat:@"%s", [delimiters fieldStart]];
            [mutableString appendFormat:@"%@", [myForm name]];
	    [mutableString appendFormat:@"%s", [delimiters fieldEnd]];
	    [mutableString appendFormat:@"%s", [delimiters fieldDelimiter]];
	}
	/* class specific write to mutableString behaviour */
	indentCount = indentCount==NO_TABS ? NO_TABS : indentCount+1;
	countComma = [self count]-1;
	do{
	    if ([self hasPredicateAt:index]) {
		[[myList objectAt:index] appendToString:mutableString withDelimiters:delimiters andIndent:indentCount];
		if (countComma>0) { /* while countComma>0 concat one */
		    [mutableString appendFormat:@"%s", [delimiters fieldDelimiter]];
		    countComma--;
		}
	    }
	    index++;
	}while(index<count);
	
	[mutableString appendFormat:@"%s", [delimiters end]];
    }
    return self;
}



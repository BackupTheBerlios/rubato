/* SimpleMathStream.m */

- makeString:aString withDelimiters:delimiters andIndent:(int)indentCount;
{
    int countIndents;
    
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
    
    [aString concat:[delimiters fieldStart]];
    [aString concat:[[self stringValue] cString]];
    [aString concat:[delimiters fieldEnd]];
    
    [aString concat:[delimiters end]];
    return aString;
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
	if ([delimiters hasName]) {
	    [mutableString appendFormat:@"%s", [delimiters fieldStart]];
            [mutableString appendFormat:@"%@",[self name]];
	    [mutableString appendFormat:@"%s", [delimiters fieldEnd]];
	    if ([delimiters hasForm])
		[mutableString appendFormat:@"%s", [delimiters fieldDelimiter]];
	}
	
	if ([delimiters hasForm]){
	    [mutableString appendFormat:@"%s", [delimiters fieldStart]];
            [mutableString appendFormat:@"%@",[myForm name]];
	    [mutableString appendFormat:@"%s", [delimiters fieldEnd]];
	    if ([delimiters hasValue])
		[mutableString appendFormat:@"%s", [delimiters fieldDelimiter]];
	}
	
	if ([delimiters hasValue]) {
	    [mutableString appendFormat:@"%s", [delimiters fieldStart]];
	    [mutableString appendFormat:@"%s", [[self stringValue] cString]];
	    [mutableString appendFormat:@"%s", [delimiters fieldEnd]];
	}
	
	[mutableString appendFormat:@"%s", [delimiters end]];
    }
    return self;
}




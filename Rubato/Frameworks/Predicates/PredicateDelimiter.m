/* PredicateDelimiter.h */

#import "PredicateDelimiter.h"

@implementation PredicateDelimiter;

- init;
{
    [super init];
    start = malloc(strlen("")+1);
    end = malloc(strlen("")+1);
    new = malloc(strlen("")+1);
    fieldDel = malloc(strlen("")+1);
    indent = malloc(strlen("")+1);
    startField = malloc(strlen("")+1);
    endField = malloc(strlen("")+1);
    strcpy(start, "");
    strcpy(end, "");
    strcpy(new, "");
    strcpy(fieldDel, "");
    strcpy(indent, "");
    strcpy(startField, "");
    strcpy(endField, "");
    hasType = YES;
    hasName = YES;
    hasForm = YES;
    hasValue = YES;
    return self;
}

- (void)dealloc;
{
    if (start) free(start);
    if (end) free(end);
    if (new) free(new);
    if (fieldDel) free(fieldDel);
    if (indent) free(indent);
    if (startField) free(startField);
    if (endField) free(endField);
    return [super dealloc];
}

- (BOOL) hasType;
{
    return hasType;
}

- (BOOL) hasName;
{
    return hasName;
}

- (BOOL) hasForm;
{
    return hasForm;
}

- (BOOL) hasValue;
{
    return hasValue;
}

- withType:(BOOL)flag;
{
    hasType = flag;
    return self;
}

- withName:(BOOL)flag;
{
    hasName = flag;
    return self;
}

- withForm:(BOOL)flag;
{
    hasForm = flag;
    return self;
}

- withValue:(BOOL)flag;
{
    hasValue = flag;
    return self;
}



- setDelimiter:(char **)aDelimiter to:(const char *)str;
{
    if (*aDelimiter)
	free(*aDelimiter);
    if (str) {
	*aDelimiter = malloc(strlen(str)+1);
	strcpy(*aDelimiter, str);
    } else {
	*aDelimiter = malloc(strlen("")+1);
	strcpy(*aDelimiter, "");
    }
    return self;
}

- setStart:(const char *)str;
{
    return [self setDelimiter:&start to:str];
}

- (const char *)start;
{
    if(start)
	return (const char *)start;
    return "";
}

- setEnd:(const char *)str;
{
    return [self setDelimiter:&end to:str];
}

- (const char *)end;
{
    if(end)
	return (const char *)end;
    return "";
}


- setNew:(const char *)str;
{
    return [self setDelimiter:&new to:str];
}

- (const char *)new;
{
    if(new)
	return (const char *)new;
    return "";
}


- setFieldDelimiter:(const char *)str;
{
    return [self setDelimiter:&fieldDel to:str];
}

- (const char *)fieldDelimiter;
{
    if(fieldDel)
	return (const char *)fieldDel;
    return "";
}


- setIndent:(const char *)str;
{
    return [self setDelimiter:&indent to:str];
}

- (const char*)indent;
{
    if(indent)
	return (const char *)indent;
    return "";
}


- setFieldStart:(const char *)str;
{
    return [self setDelimiter:&startField to:str];
}

- (const char*)fieldStart;
{
    if(startField)
	return (const char *)startField;
    return "";
}


- setFieldEnd:(const char *)str;
{
    return [self setDelimiter:&endField to:str];
}

- (const char*)fieldEnd;
{
    if(endField)
	return (const char *)endField;
    return "";
}


@end;
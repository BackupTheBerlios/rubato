/* PredicateDelimiter.h */

#import <AppKit/AppKit.h>

@interface PredicateDelimiter:NSObject
{
    char *start;
    char *end;
    char *new;
    char *fieldDel;
    char *indent;
    char *startField;
    char *endField;
    BOOL hasType;
    BOOL hasName;
    BOOL hasForm;
    BOOL hasValue;

}

- init;
- (void)dealloc;

- (BOOL)hasType;
- (BOOL)hasName;
- (BOOL)hasForm;
- (BOOL)hasValue;

- withType:(BOOL)flag;
- withName:(BOOL)flag;
- withForm:(BOOL)flag;
- withValue:(BOOL)flag;

- setStart:(const char *)str;
- (const char *)start;

- setEnd:(const char *)str;
- (const char *)end;

- setNew:(const char *)str;
- (const char *)new;

- setFieldDelimiter:(const char *)str;
- (const char *)fieldDelimiter;

- setIndent:(const char *)str;
- (const char*)indent;

- setFieldStart:(const char *)str;
- (const char*)fieldStart;

- setFieldEnd:(const char *)str;
- (const char*)fieldEnd;

@end;
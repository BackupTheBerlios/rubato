
#import "FindRubetteDriver.h"
#import "prediKit/PredicateProtocol.h"

#define SHOW_TYPE "ShowTypePref"
#define SHOW_NAME "ShowNamePref"
#define SHOW_FORM "ShowFormPref"
#define SHOW_VALUE "ShowValuePref"
#define DEL_NEW "DelimiterNewString"
#define DEL_INDENT "DelimiterIndentString"
#define DEL_START "DelimiterStartString"
#define DEL_END "DelimiterEndString"
#define DEL_FIELD_START "DelimiterFieldStartString"
#define DEL_FIELD_END "DelimiterFieldEndString"
#define DEL_FIELD_DEL "DelimiterFieldDelimiterString"

@class PredicateDelimiter;

@implementation FindRubetteDriver

- (void)dealloc;
{
    [myPreferencesPanel performClose:self];
    [myPreferencesPanel release]; myPreferencesPanel = nil;
    return [super release];
}

- customAwakeFromNib;
{
    [myPreferencesPanel setFrameUsingName:[myPreferencesPanel title]];
    
    return self;
}
- readCustomData;
{
    if (rubetteData) {
	[showType setIntValue:[rubetteData boolValueOf:SHOW_TYPE]];
	[showName setIntValue:[rubetteData boolValueOf:SHOW_NAME]];
	[showForm setIntValue:[rubetteData boolValueOf:SHOW_FORM]];
	[showValue setIntValue:[rubetteData boolValueOf:SHOW_VALUE]];
	[new setStringValue:[NSString stringWithCString:[rubetteData stringValueOf:DEL_NEW]]];
	[indent setStringValue:[NSString stringWithCString:[rubetteData stringValueOf:DEL_INDENT]]];
	[start setStringValue:[NSString stringWithCString:[rubetteData stringValueOf:DEL_START]]];
	[end setStringValue:[NSString stringWithCString:[rubetteData stringValueOf:DEL_END]]];
	[fieldStart setStringValue:[NSString stringWithCString:[rubetteData stringValueOf:DEL_FIELD_START]]];
	[fieldEnd setStringValue:[NSString stringWithCString:[rubetteData stringValueOf:DEL_FIELD_END]]];
	[fieldDelimiter setStringValue:[NSString stringWithCString:[rubetteData stringValueOf:DEL_FIELD_DEL]]];
    }
    return self;
}

- writeCustomData;
{
    if (![rubetteData hasPredicateOfNameString:SHOW_TYPE]) {
	id <PredicateProtocol> aPredicate = [[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:SHOW_TYPE];
	[rubetteData setValueOf:PREF_NAME To:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:SHOW_NAME]) {
	id <PredicateProtocol> aPredicate = [[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:SHOW_NAME];
	[rubetteData setValueOf:PREF_NAME To:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:SHOW_FORM]) {
	id <PredicateProtocol> aPredicate = [[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:SHOW_FORM];
	[rubetteData setValueOf:PREF_NAME To:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:SHOW_VALUE]) {
	id <PredicateProtocol> aPredicate = [[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:SHOW_VALUE];
	[rubetteData setValueOf:PREF_NAME To:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:DEL_NEW]) {
	id <PredicateProtocol> aPredicate = [[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:DEL_NEW];
	[rubetteData setValueOf:PREF_NAME To:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:DEL_INDENT]) {
	id <PredicateProtocol> aPredicate = [[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:DEL_INDENT];
	[rubetteData setValueOf:PREF_NAME To:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:DEL_START]) {
	id <PredicateProtocol> aPredicate = [[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:DEL_START];
	[rubetteData setValueOf:PREF_NAME To:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:DEL_END]) {
	id <PredicateProtocol> aPredicate = [[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:DEL_END];
	[rubetteData setValueOf:PREF_NAME To:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:DEL_FIELD_START]) {
	id <PredicateProtocol> aPredicate = [[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:DEL_FIELD_START];
	[rubetteData setValueOf:PREF_NAME To:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:DEL_FIELD_END]) {
	id <PredicateProtocol> aPredicate = [[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:DEL_FIELD_END];
	[rubetteData setValueOf:PREF_NAME To:aPredicate];
    }
    
    if (![rubetteData hasPredicateOfNameString:DEL_FIELD_DEL]) {
	id <PredicateProtocol> aPredicate = [[myValueForm makePredicateFromZone:[self zone]]
			    setNameString:DEL_FIELD_DEL];
	[rubetteData setValueOf:PREF_NAME To:aPredicate];
    }
    
    [rubetteData setBoolValueOf:SHOW_TYPE To:[showType intValue]];
    [rubetteData setBoolValueOf:SHOW_NAME To:[showName intValue]];
    [rubetteData setBoolValueOf:SHOW_FORM To:[showForm intValue]];
    [rubetteData setBoolValueOf:SHOW_VALUE To:[showValue intValue]];
    [rubetteData setStringValueOf:DEL_NEW To:[[new stringValue] cString]];
    [rubetteData setStringValueOf:DEL_INDENT To:[[indent stringValue] cString]];
    [rubetteData setStringValueOf:DEL_START To:[[start stringValue] cString]];
    [rubetteData setStringValueOf:DEL_END To:[[end stringValue] cString]];
    [rubetteData setStringValueOf:DEL_FIELD_START To:[[fieldStart stringValue] cString]];
    [rubetteData setStringValueOf:DEL_FIELD_END To:[[fieldEnd stringValue] cString]];
    [rubetteData setStringValueOf:DEL_FIELD_DEL To:[[fieldDelimiter stringValue] cString]];

    return self;
}


/* finding predicates */
- doSearch:sender;/* action method for find buttons */
{
    [super doSearch:sender];
    [self getStringOfFound:myText];
    return self;
}

- initSearch:sender;
{
    [super initSearch:sender];
    [self getStringOfFound:myText];
    return self;
}


- getStringOfFound:sender;
{
#error TextConversion: readText: is obsolete
   if ([sender respondsToSelector:@selector(readText:)] ||
	[sender respondsToSelector:@selector(setStringValue:)]) {
	NXStream *stream = NXOpenMemory(NULL,0,NX_READWRITE);
	[self writeCustomStream:stream];
	NXFlush(stream);
	NXSeek(stream, 0L, NX_FROMSTART);
#error TextConversion: readText: is obsolete
	if ([sender respondsToSelector:@selector(readText:)])
#error TextConversion: 'setString:' used to be 'readText' takes an NSString instance (used to take NXStream) ; stream must be converted to NSString
	    [sender setString:stream];
	else {
	    char * data;
	    int length, maxlen;
	    NXGetMemoryBuffer(stream, &data, &length, &maxlen);
	    [sender setStringValue:[NSString stringWithCString:data]];
	}
	    
	NXCloseMemory(stream, NX_FREEBUFFER);
    }
    return self;
}

- writeCustomStream:(NXStream *)stream;
{
    int i, count;
    id delimiter= [[PredicateDelimiter alloc]init];
    
    [delimiter withType:[showType intValue]];
    [delimiter withName:[showName intValue]];
    [delimiter withForm:[showForm intValue]];
    [delimiter withValue:[showValue intValue]];
    [delimiter setNew:[[new stringValue] cString]];
    [delimiter setIndent:[[indent stringValue] cString]];
    [delimiter setStart:[[start stringValue] cString]];
    [delimiter setEnd:[[end stringValue] cString]];
    [delimiter setFieldStart:[[fieldStart stringValue] cString]];
    [delimiter setFieldEnd:[[fieldEnd stringValue] cString]];
    [delimiter setFieldDelimiter:[[fieldDelimiter stringValue] cString]];

    if (count=[foundPredicates count])
    for (i=0; i<count; i++)
    	[[foundPredicates getValueAt:i]writeToStream:stream withDelimiters:delimiter andIndent:0];
    NXFlush(stream);
    return self;
}


- insertCustomMenuCells;
{
#error StringConversion: key equivalents are now instances of NSString. Change your C string variable to an NSString.
    [[myMenu addItemWithTitle:@"Preferences¼" action:@selector(makeKeyAndOrderFront:) keyEquivalent:0] setTarget:myPreferencesPanel];
    return self;
}

    
    
/* class methods to be overriden */
+ (const char*)nibFileName;
{
    return "FindRubette.nib";
}

+ (const char *)rubetteName;
{
    return "Find";
}

+ (const char *)rubetteVersion;
{
    return "1.0";
}

@end

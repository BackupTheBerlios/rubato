/* StringConverter.m */
/* This is a general purpose StringConverter class
*  (c) by Oliver Zahorka
*  date: 16.2.94
*  changes
*  30.3.94	NXZone memory allocation, uses own zone
*  29.7.94	Added typed comparison functions
*  30.12.94	Added methods for Fraction handling
*  5.1.95	Refined Fraction handling
*  2.2.95	Debugged insert: at: method
*  3.2.95	Added number concatenation methods
*/

#import "StringConverter.h"
//#import <objc/Storage.h>
#import "JGList.h"
#import <AppKit/NSText.h>

#import <stdlib.h>                
#import <stdio.h>                
#import <string.h>                
#import <limits.h>                

@implementation StringConverter:JgObject

#define REPLACE(aDecoder,old,new) \
    if (doReplaceFlag && [aDecoder respondsToSelector:@selector(replaceObject:withObject:)]) \
      [(NSArchiver *)aDecoder replaceObject:old withObject:new];

+ (NSString *)readNSStringWithCoder:(NSCoder *)aDecoder;
{
  id conv;
  NSString *str;
  conv=[aDecoder decodeObject];
  if ([conv isKindOfClass:[StringConverter class]]) {
    static BOOL doReplaceFlag=NO;
    str=[conv stringValue];
    REPLACE(aDecoder,conv,str)
  } else {
    return conv;
  }
  return str;
}

/* standard object methods to be overridden */
- init
{
    [super init];
    /* class-specific initialization goes here */
    //[self setCStringValue:"init"];
    /* allocate space for the string in objects own zone */
    myString = NSZoneMalloc([self zone], strlen("")+1);
    strcpy(myString, "");
    freeString=YES;
    noCopy=NO;
    return self;
}


- (void)dealloc {
    /* class-specific initialization goes here */
    if (myString&&freeString)
	free(myString);
    { [super dealloc]; return; };
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
//jg NSObject    [super initWithCoder:aDecoder];
    [aDecoder decodeValuesOfObjCTypes:"*cc", &myString, &freeString, &noCopy];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
//jg NSObject    [super encodeWithCoder:aCoder];
    [aCoder encodeValuesOfObjCTypes:"*cc", &myString, &freeString, &noCopy];
}


- (id)copyWithZone:(NSZone *)zone
{
    StringConverter* myCopy = [[[self class] allocWithZone:zone] init];
    if (!noCopy) {
	myCopy->myString = NSZoneMalloc(zone,(strlen(myString)+1));
	strcpy(myCopy->myString, myString);
    }
    return myCopy;
}

/*access methods to string*/
- (StringConverter *)setCStringValue:(const char *)aString;
{
    size_t length;
    length = aString ? (strlen(aString)+1) : 1;
    if (freeString) {
//	myString = NSZoneRealloc([self zone], myString, length);
// jg there were problems with NSZoneRealloc. thats why:
        free(myString);	
        myString = NSZoneMalloc([self zone], length);
    } else
	myString = NSZoneMalloc([self zone], length);
    freeString = YES;
    noCopy=NO;
    if (aString) {
	strcpy(myString, aString);
    } else {
	strcpy(myString, "");
    }
    return self;
}

// jg added.
- (void)setStringValue:(NSString *)aString;
{
    [self setCStringValue:[aString cString]];
}

- (void)setStringValueNoCopy:(const char *)aString;
{
    [self setStringValueNoCopy:(char *)aString shouldFree:NO];
}

- (void)setStringValueNoCopy:(char *)aString shouldFree:(BOOL)flag;
{
    if (aString!=myString) {
	if (myString&&freeString) 
	    free(myString);
	freeString=flag;
	noCopy=YES;
	myString = aString;
    } else
	freeString = !(!freeString || !flag);
	/* same behaviour as Cell:
	* you can't set a string as non-freeable and later change it to be
	* freeable by reinvoking this method with that same string; 
	* you can, however, change it from freeable to nonfreeable.
	*/
}

- (void)setIntValue:(int)aInt;
{
    char floatStr[256]="";
    [self double:aInt ToString:floatStr];
    [self setCStringValue:floatStr];
}

- (void)setFloatValue:(float)aFloat;
{
    char floatStr[256]="";
    [self double:aFloat ToString:floatStr];
    [self setCStringValue:floatStr];
}

- (void)setDoubleValue:(double)aDouble;
{
    char floatStr[256]="";
    [self double:aDouble ToString:floatStr];
    [self setCStringValue:floatStr];
}

- (selfvoid)setBoolValue: (BOOL)aBool;
{
    [self setCStringValue:(aBool ? trueStr : falseStr)];
}

- (selfvoid)setFractValue: (RubatoFract)aFract;
{
    [self setDoubleValue:aFract.numerator];
    if (aFract.isFraction) {
	char strBuf[20];
	sprintf(strBuf, "%lu", aFract.denominator);
	[self concat:"/"];
	[self concat:strBuf];
    }
}

- (NSString *)stringValue;
{
   return [NSString jgStringWithCString:[self cString]];
}

- (const char *) cString;
{
    if (myString)
	return myString;
    else
	return nilStr;
}

- (int) 	intValue;
{
    return (int)[self doubleValue];
}

- (float)	floatValue;
{
    return (float)[self doubleValue];
}

- (double)	doubleValue;
{
    RubatoFract theVal = [self fractValue];
    return (!theVal.isFraction ? theVal.numerator : 
    		(theVal.denominator ? theVal.numerator/theVal.denominator : 0));
}

- (BOOL)	boolValue;
{
    if (strlen(myString))
	return (strcmp(myString, falseStr)); /* strcmp returns 0 if true */
    else
	return 0;
}

- (RubatoFract)	fractValue;
{
    RubatoFract retVal = nilFract;
    if (strlen(myString)) {
	const char *postfix, *denom, *slash, *str;
	char **endp = &postfix;
	double signedDenom=0;
	double num2=0;
	str = myString;
	postfix = str;
	slash = strchr(str, '/');

	str = strpbrk(str, "-0123456789I"); /* I is included for Infinity */
	if(str && (!slash || (slash - str)>0)) {
	    retVal.numerator = strtod(str, endp);
	}

	if (slash) {
	    denom = strpbrk(slash, "-0123456789I");
	    retVal.isFraction = YES;
	    if (denom)
		signedDenom = strtod(denom, (char**)NULL);

	    str = strpbrk(*endp, "-0123456789");
	    if(str && (slash - str)>0) {
		num2 = strtod(str, endp);
	    }
	    
	    if (signedDenom <0) {
		if (num2) 
		    num2 = -num2;
		else
		    retVal.numerator = -retVal.numerator;
		
		signedDenom = -signedDenom;
	    }
	    
	    retVal.denominator = (int)signedDenom;
	    if (num2) 
		if (retVal.numerator<0 && num2>0)
		    retVal.numerator = retVal.numerator * signedDenom - num2;
		else
		    retVal.numerator = retVal.numerator * signedDenom + num2;

	}
    }
    return retVal;
}

/* Utility methods */
- (size_t)length;
{
    return strlen(myString);
}

- (int)compareTo:anObject;
{
    if ([anObject respondsToSelector:@selector(stringValue)])
	return [self compareToString:[[anObject stringValue] cString]];
    return INT_MAX; /* anObject = nil or uncomparable so we are much bigger */
}

- (int)compareToObject:anObject;
{
    return [self compareToObject:anObject as:type_string];
}

- (int)compareToObject:anObject as:(int)comparisonType;
{
    switch(comparisonType) {
	case type_double:
	if ([anObject respondsToSelector:@selector(doubleValue)])
	    return [self compareToDouble:[anObject doubleValue]];
	
	case type_float:
	if ([anObject respondsToSelector:@selector(floatValue)])
	    return [self compareToFloat:[anObject floatValue]];
	
	case type_int:
	if ([anObject respondsToSelector:@selector(intValue)])
	    return [self compareToInt:[anObject intValue]];
	
	case type_bool:
	if ([anObject respondsToSelector:@selector(boolValue)])
	    return [self compareToBool:[anObject boolValue]];
	
	case type_string:
	default:
	if ([anObject respondsToSelector:@selector(stringValue)])
	    return [self compareToString:[[anObject stringValue] cString]];
    }
    return INT_MAX; /* anObject = nil or uncomparable so we are much bigger */
}

- (int)compareToDouble:(double)aDouble;
{
    double myDouble = [self doubleValue];
    if (myDouble<aDouble)
	return -1;
    else 
	return (int)(myDouble>aDouble);
}

- (int)compareToFloat:(float)aFloat;
{
    float myFloat = [self floatValue];
    if (myFloat<aFloat)
	return -1;
    else 
	return (int)(myFloat>aFloat);
}

- (int)compareToInt:(int)anInt;
{
    return [self intValue] - anInt;
}

- (int)compareToBool:(BOOL)aBool;
{
    BOOL myBool = [self boolValue];
    if (myBool<aBool)
	return -1;
    else 
	return (int)(myBool>aBool);
}

- (int)compareToString:(const char *)aString;
{
    if (aString) {
	return strcmp(myString,aString);
//jg caseSensitive==YES, length==-1, StringOrderTable==NULL
//jg was	return NSOrderStrings(myString, aString, YES, -1, NULL);
    }
    return INT_MAX; /* aString = nil so we are much bigger */
}


- (BOOL)isEqual:anObject;
{
    if (anObject==self)
	return YES;
    return ([self compareTo:anObject] == 0);
}


- (BOOL)isEqualTo:(const char*)aString;
{
    return ([self compareToString:aString] == 0);
}


- (BOOL)isEqualToObject:anObject;
{
    return ([self compareToObject:anObject as:type_string] == 0);
}

- (BOOL)isEqualToObject:anObject as:(int)comparisonType;
{
    return ([self compareToObject:anObject as:comparisonType] == 0);
}


- (BOOL)equalTo:anObject;
{
    return [self isEqual:anObject];
}

- (BOOL)largerThan:anObject; 
{
    if ([anObject respondsToSelector:@selector(stringValue)])
	return [self compareToString:[[anObject stringValue] cString]]>0;
    return [NSStringFromClass([self class]) compare:NSStringFromClass([anObject class])] >0;
// jg was return NSOrderStrings(NSStringFromClass([self class]), NSStringFromClass([anObject class]), YES, -1, NULL)>0;
}

- (BOOL)smallerThan:anObject; 
{
    if ([anObject respondsToSelector:@selector(stringValue)])
	return [self compareToString:[[anObject stringValue] cString]]<0;
    return [NSStringFromClass([self class]) compare:NSStringFromClass([anObject class])]<0;
}


/*logically redundant but not as methods */
- (BOOL)largerEqualThan:anObject;
{
    return ![self smallerThan:anObject];
}

- (BOOL)smallerEqualThan:anObject;
{
    return ![self largerThan:anObject];
}


- double:(double) aDbl ToString:(char *) floatStr;
{ 
    sprintf(floatStr, "%.15g", aDbl);
    return self;
}

- (selfvoid)concat:(const char*)aString;
{
    if (!noCopy && aString) {
	if (strlen(aString)) { /* only work if not nilStr */
// jg: there was a crash at MeloRubette at the position NSZoneRealloc.
// Thats why i reformulated it.
//	    myString = NSZoneRealloc([self zone], myString, 
//				([self length]+1)+strlen(aString));
//          strcat(myString, aString);
            char *newString=NSZoneMalloc([self zone], strlen("")+1+[self length]+strlen(aString));
            strcpy(newString,myString);
	    strcat(newString, aString);
	    free(myString);
 	    myString=newString;
	}
    }
}

- (selfvoid)concatInt:(int)anInt;
{
    char floatStr[80]="";
    [self double:anInt ToString:floatStr];
    [self concat:floatStr];
}

- (selfvoid)concatFloat:(float)aFloat;
{
    char floatStr[80]="";
    [self double:aFloat ToString:floatStr];
    [self concat:floatStr];
}

- (selfvoid)concatDouble:(double)aDouble;
{
    char floatStr[80]="";
    [self double:aDouble ToString:floatStr];
    [self concat:floatStr];
}

- (selfvoid)concatBool:(BOOL)aBool;
{
    [self concat:(aBool ? trueStr : falseStr)];
}


- (selfvoid)concatWith:anObject;
{
    if ([anObject respondsToSelector:@selector(stringValue)])
	[self concat:[[anObject stringValue] cString]];
}

- (selfvoid)insert:(const char*)aString at:(unsigned int)index;
{
    if (aString&&!noCopy) { /* if nil or noCopy don't do anything */
	int length = [self length];
	char *strBuf;

	index = index<length ? index : length;
	/* only insertable if index<length */
	strBuf = NSZoneMalloc([self zone],(strlen(aString)+length));
	strcpy(strBuf, "");

	strncpy(strBuf, [self cString], index);
	strcat(strBuf, aString);
	strcat(strBuf, [self cString]+index);
	[self setCStringValue:strBuf];
	NSZoneFree([self zone], strBuf);
    }
}

/*
- (Storage *)tokenizeWith:(const char*)delimiters;
{
    Storage *tokens = nil;
    if ([self length] && delimiters) {
	char *token, *strBuf = NSZoneMalloc([self zone], strlen(myString));
	tokens = [[Storage alloc]initCount:1 elementSize:sizeof(char *) description:"*"];
	strcpy(strBuf, myString);
	token=strtok(strBuf, delimiters);
	token = strcpy(NSZoneMalloc([self zone], strlen(token)), token);
	[tokens addElement:&token];
	while (token=strtok(NULL, delimiters)) {
	    token = strcpy(NSZoneMalloc([self zone], strlen(token)), token);
	    [tokens addElement:&token];
	}
	free(strBuf);
    }
    return tokens;
}
*/

- (JgList *)tokenizeToStringsWith:(const char*)delimiters;
{
    JgList *tokens = nil;
    if ([self length] && delimiters) {
	char *token, *strBuf = NSZoneMalloc([self zone], strlen(myString));
	tokens = [[JgList alloc]initCount:1];
	strcpy(strBuf, myString);
	token=strtok(strBuf, delimiters);
	[tokens addObject:[[[StringConverter alloc]init]setCStringValue:token]];
	while (token=strtok(NULL, delimiters)) 
	    [tokens addObject:[[[StringConverter alloc]init]setCStringValue:token]];
	free(strBuf);
    }
    return [tokens autorelease];
}


/*
// not used
- readFromStream:(NSMutableString *)stream;
{
    char * data;
    int length, maxlen;
    if (stream) {
	if (myString)
	    NSZoneFree([self zone], myString);
	JGGetMemoryBuffer(stream, &data, &length, &maxlen);
	myString = NSZoneMalloc([self zone], length+1);
	strcpy(myString, data);
    }
    return self;
}
*/

// Because of NSMutableString==NSMutableString, it should be simple!
- appendToString:(NSMutableString *)mutableString;
{
    if (mutableString) {
	if (myString) {
//	    NXWrite(mutableString, myString, strlen(myString));
        [mutableString appendString:[self stringValue]]; // jg: why did I have here [[self stringValue] description]]; ?
	}
    }
    return self;
}

/* Action methods for IB Objects */
- (void)takeDoubleValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(doubleValue)])
	[self setDoubleValue:[sender doubleValue]];
}

- (void)takeFloatValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(floatValue)])
	[self setFloatValue:[sender floatValue]];
}

- (void)takeIntValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(intValue)])
	[self setIntValue:[sender intValue]];
}

- (void)takeBoolValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(boolValue)])
	[self setBoolValue:[sender boolValue]];
}

- (void)takeStringValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(stringValue)])
	[self setStringValue:[sender stringValue]];
}


@end

/* Weight.m */

#import "Weight.h"
#import "splines.h"
#import "space.h"

//#import <objc/NXStringTable.h>
#import <Foundation/NSBundle.h>
#import <objc/objc-runtime.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSButtonCell.h>
#import <JgKit/MyUnArchiver.h>

@implementation Weight

#define INIT_REFCOUNT 0

#define CREATOR "Creator"
#define NAME "Name"
#define USED_BUNDLE "Module"

#define BEGIN_MATRIX "{"
#define END_MATRIX "}"
#define COEFF_DELIM ", "
#define ROW_DELIM ", "

/* standard class methods to be overridden */
+ (void)initialize 
{
    [super initialize];
    if (self == [Weight class]) {
	[Weight setVersion:5];
    }
    return;
}

/* get the operator's nib file */
+ (const char*) inspectorNibFile;
{
    return "WeightInspector.nib";
}

/* import the standard SpaceProtocol acc to protocol */
#import "SpaceProtocolMethods.m"


/* standard object methods to be overridden */
- init;
{
    [super init];
    /* class-specific initialization goes here */

    myWeightEvents = [[[OrderedList alloc]init]ref];
    mySpace = 0;
    
    myBDWeight = nil;

    myMinWeight = 0.0;
    myMaxWeight = 0.0;
    myMeanWeight = 0.0;
    myStartNorm = 0.8;
    myRange = 0.4;
    myTolerance = MIN_VAL;

    myParameterTable = [[NSMutableDictionary alloc]init];
    myParameterObject = nil;
    myConverter = [[String alloc]init];
    return self;
}

- (void)dealloc
{
    /* do NXReference houskeeping */
    
    /* class-specific initialization goes here */
    [myWeightEvents release];
    [myBDWeight release];
    [myParameterTable release];
    if ([myParameterObject conformsToProtocol:@protocol(RefCounting)])
	[myParameterObject release];
    [myConverter release];
    { [super dealloc]; return; };
}

- copyWithZone:(NSZone*)zone;
{
//    NXHashState aState;
//    const void *aKey, *aVal;    
    NSEnumerator *enumerator;
    id key;

    Weight *myCopy = [super copyWithZone:zone];
    myCopy->myWeightEvents = [[myWeightEvents jgCopyWithZone:zone]ref];
    myCopy->myBDWeight = nil;
    
    myCopy->myMinWeight = myMinWeight;
    myCopy->myMaxWeight = myMaxWeight;
    myCopy->myMeanWeight = myMeanWeight;
    myCopy->myStartNorm = myStartNorm;
    myCopy->myRange = myRange;
    myCopy->myTolerance = myTolerance;
    
    myCopy->myParameterTable = [[NSMutableDictionary alloc]init];
    myCopy->myParameterObject = nil;
    myCopy->myParameterObjectBundles = nil;
//    aState = [myParameterTable initState];
//    while([myParameterTable nextState:&aState key:&aKey value:&aVal]) {
//	[myCopy setParameter:aKey toStringValue:aVal];
//    }
    enumerator = [myParameterTable keyEnumerator];  // NSDictionary
    while  ((key = [enumerator nextObject])) {
      [myCopy setParameter:[key cString] toStringValue:[[myParameterTable objectForKey:key] cString]];
    }

    myCopy->myConverter = [[String alloc]init];

    [myCopy setParameterObject:myParameterObject requiredBundles:[myParameterObjectBundles jgCopyWithZone:zone]];
    return myCopy;
}

// jg new
- (id)initWithCoder:(NSCoder *)aDecoder;
{
//    int classVersion = [aDecoder versionForClassName:NSStringFromClass([Weight class])];
    [super initWithCoder:aDecoder];
    // class-specific code goes here 
    myParameterTable = [[aDecoder decodeObject] retain];   
    myWeightEvents = [[aDecoder decodeObject] retain];
    
    [aDecoder decodeValuesOfObjCTypes:"cdddddd", &mySpace, 
				    &myMinWeight, 
				    &myMaxWeight, 
				    &myMeanWeight, 
				    &myStartNorm,
				    &myRange, 
				    &myTolerance];
    
    [self readParameterObject:aDecoder];
    
    // set Reference Counting of read or replaced objects 
    [myWeightEvents ref];
    
    if (!myStartNorm)
	myStartNorm = 0.8;
    if (!myRange)
	myRange = 0.4;
    if (!myTolerance)
	myTolerance = MIN_VAL;
    myBDWeight = nil;
//    myRefCount = INIT_REFCOUNT;
    if (!myConverter) myConverter = [[String alloc]init];
    [self makeParametersUnique];
    return self;
}

/* alter code mit Fallunterscheidungen fuer die Zeit vor Rubato 1.0 auf Next. Die machen auf Mac eh keinen Sinn mehr
 - (id)initWithCoder:(NSCoder *)aDecoder;
 {
     id oldRubetteName, oldCustomName;
     int classVersion = [aDecoder versionForClassName:NSStringFromClass([Weight class])];
     char bundles[MAXPATHLEN+1] = "";	
     [super initWithCoder:aDecoder];
     // class-specific code goes here 
     if (classVersion>2)
         myParameterTable = [[aDecoder decodeObject] retain];
     else {
         myParameterTable = [[NSMutableDictionary alloc]init];

         oldRubetteName = [[aDecoder decodeObject] retain]; // read old Rubette Name 
         oldCustomName = [[aDecoder decodeObject] retain]; // read old Custom Name 
         [self setRubetteName:[[oldRubetteName stringValue] cString]];
         [self setNameString:[[oldCustomName stringValue] cString]];
         [oldRubetteName release]; oldRubetteName = nil;
         [oldCustomName release]; oldCustomName = nil;
     }

     if (classVersion==4) {
         [self needsBundles:bundles];
         NS_DURING
         myParameterObject = [[aDecoder decodeObject] retain];
         NS_HANDLER
 //jg	if (NXLocalHandler.code==NSArchiverClassError && strlen(bundles)) {
             NSRunAlertPanel(@"Read Weight", @"The following Modules must be loaded in order to read this weight: %s", @"", nil, nil, bundles);
             NS_VALUERETURN(nil, typeof(nil));
 //jg	} else
 //jg	    [localException raise];
         NS_ENDHANDLER // end of handler 

         if ([myParameterObject conformsToProtocol:@protocol(RefCounting)])
             [myParameterObject ref];
     }

     myWeightEvents = [[aDecoder decodeObject] retain];

     if (!classVersion) {
     // the old fashioned version 0 reading 
         [aDecoder decodeValuesOfObjCTypes:"c", &mySpace];
         [aDecoder decodeValuesOfObjCTypes:"d", &myMinWeight];
         [aDecoder decodeValuesOfObjCTypes:"d", &myMaxWeight];
         [aDecoder decodeValuesOfObjCTypes:"d", &myMeanWeight];
         [aDecoder decodeValuesOfObjCTypes:"d", &myStartNorm];
         [aDecoder decodeValuesOfObjCTypes:"d", &myRange];
         [aDecoder decodeValuesOfObjCTypes:"d", &myTolerance];
     } else {
         [aDecoder decodeValuesOfObjCTypes:"cdddddd", &mySpace,
                                     &myMinWeight,
                                     &myMaxWeight,
                                     &myMeanWeight,
                                     &myStartNorm,
                                     &myRange,
                                     &myTolerance];
     }


     if (classVersion<2) {
         // convert the old List objects to
         // RefCounList or OrderedList objects
         //
         id list = myWeightEvents;
         myWeightEvents = [[[[OrderedList alloc]initCount:
                 [list count]]appendList:list]sort];
         [list release];
     } else

     if (classVersion>4) {
         [self readParameterObject:aDecoder];
     }

     // set Reference Counting of read or replaced objects 
     [myWeightEvents ref];

     if (!myStartNorm)
         myStartNorm = 0.8;
     if (!myRange)
         myRange = 0.4;
     if (!myTolerance)
         myTolerance = MIN_VAL;
     myBDWeight = nil;
 //    myRefCount = INIT_REFCOUNT;
     if (!myConverter) myConverter = [[String alloc]init];
     [self makeParametersUnique];
     return self;
 }
*/
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myParameterTable];
    [aCoder encodeObject:myWeightEvents];
    
    [aCoder encodeValuesOfObjCTypes:"cdddddd", &mySpace, 
				&myMinWeight, 
				&myMaxWeight, 
				&myMeanWeight, 
				&myStartNorm, 
				&myRange, 
				&myTolerance];
    
    [self writeParameterObject:aCoder];
}

/* get the operator's nib file */
- (const char*) inspectorNibFile;
{
    return [[self class]inspectorNibFile];
}


/* Access to instance variables */
- setNameString: (const char *)aName;
{
    [self setParameter:NAME toStringValue:aName];
    return self;
}

- (const char *)nameString;
{
    return [self stringValueOfParameter:NAME];
}
- (NSString *)name; // jg added
{
    return [NSString jgStringWithCString:[self nameString]];
}

- setRubetteName: (const char *)aName;
{
    [self setParameter:CREATOR toStringValue:aName];
    return self;
}

- (const char *)rubetteName;
{
    return [self stringValueOfParameter:CREATOR];
}

- setLowNorm:(double)aDouble;
{
    if (aDouble!=[self lowNorm]) {
	if (!aDouble)
	    aDouble  = MIN_VAL;
	else
	    aDouble = fabs(aDouble);
	
	if (myRange>=0) {
	    if (aDouble < myStartNorm + myRange) {
		myRange += (myStartNorm-aDouble);
		myStartNorm = aDouble;
	    } else {
		myStartNorm = myStartNorm+myRange-MIN_VAL;
		myRange = MIN_VAL;
	    }
	}else {
	    if (aDouble < myStartNorm)
		myRange = aDouble - myStartNorm;
	    else 
		myRange = -MIN_VAL;
	}
	[myBDWeight setLowNorm:aDouble];
    }
    return self;
}

- (double) lowNorm;
{
    if ([self isInverted])
	return myStartNorm + myRange;
    return myStartNorm;
}

- setHighNorm:(double)aDouble;
{
    if (aDouble != [self highNorm]) {
	if (!aDouble)
	    aDouble  = MIN_VAL;
	else
	    aDouble = fabs(aDouble);
    
	if (myRange>=0) {
	    if (aDouble > myStartNorm)
		myRange = aDouble - myStartNorm;
	    else
		myRange = MIN_VAL;
	} else {
	    if (aDouble > myStartNorm + myRange) {
		myRange = (myStartNorm + myRange) - aDouble;
		myStartNorm = aDouble;
	    } else {
		myStartNorm += (myRange + MIN_VAL);
		myRange = -MIN_VAL;
	    }
	}
	[myBDWeight setHighNorm:aDouble];
    }
    return self;
}

- (double) highNorm;
{
    if ([self isInverted])
	return myStartNorm;
    return myStartNorm + myRange;
}


- setStartNorm:(double)aDouble;
{
    if (aDouble)
	myStartNorm = fabs(aDouble);
    else
	myStartNorm = MIN_VAL;
    [myBDWeight setStartNorm:aDouble];
    return self;
}

- (double) startNorm;
{
    return myStartNorm;
}

- setRange:(double)aDouble;
{
    if(!aDouble)
	aDouble = MIN_VAL;

    if(aDouble + myStartNorm > 0)
	myRange = aDouble;
    else 	
	myRange = fabs(aDouble);

    [myBDWeight setRange:aDouble];
    return self;
}

- (double) range;
{
    return myRange;
}


- (void)invert;
{
    myStartNorm += myRange;
    myRange = -myRange;	
    [myBDWeight invert];
}

- setInversion:(BOOL)flag;
{
  if (flag!=[self isInverted])
    [self invert]; 
  return self;
}

- (BOOL)isInverted;
{
    return myRange < 0;
}



- setTolerance:(double)aDouble;
{
    if (aDouble)
	myTolerance = fabs(aDouble);
    else
	myTolerance = MIN_VAL;
    
    [myBDWeight setTolerance:aDouble];
    return self;
}

- (double) tolerance;
{
    return myTolerance;
}

- (double)originAt:(int)index;
{
    return [self minCoordinate:index];
}

- (double)endAt:(int)index;
{
    return [self maxCoordinate:index];
}

/* Access to ParameterTable which lead to the weight */
- setParameter:(const char*)paraName toStringValue:(const char*)paraVal;
{
    if (paraName && paraVal) {
//	char *oldVal;
//	paraVal = NXCopyStringBufferFromZone(paraVal, (NXZone *)[self zone]);
//	paraName = NXUniqueString(paraName);
//	
//	oldVal = [myParameterTable insertKey:paraName value:(char*)paraVal];
//	if(oldVal) free(oldVal);
// new:
	id oldVal, key, val;
	key= [NSString jgStringWithCString:paraName];// autorelease]; (is included in constructor).
        val= [NSString jgStringWithCString:paraVal];// autorelease]; 
	oldVal= [myParameterTable objectForKey:key];
	[myParameterTable setObject:val forKey:key];  // makes copy of key
    }
    return self;
}

- setParameter:(const char*)paraName toIntValue:(int)paraVal;
{
    [myConverter setIntValue:paraVal];
    [self setParameter:paraName toStringValue:[[myConverter stringValue] cString]];
    return self;
}

- setParameter:(const char*)paraName toDoubleValue:(double)paraVal;
{
    [myConverter setDoubleValue:paraVal];
    [self setParameter:paraName toStringValue:[[myConverter stringValue] cString]];
    return self;
}

- setParameter:(const char*)paraName toBoolValue:(BOOL)paraVal;
{
    [myConverter setBoolValue:paraVal];
    [self setParameter:paraName toStringValue:[[myConverter stringValue] cString]];
    return self;
}

- setParameter:(const char*)paraName toMatrix:aMatrix;
{
    int rows, cols, r, c;
    id cell;
    BOOL isMath = [aMatrix isKindOfClass:[MathMatrix class]];
    [aMatrix getNumberOfRows:&rows columns:&cols];
    [myConverter setStringValue:[NSString jgStringWithCString:BEGIN_MATRIX]];
    for (r=0; r<rows; r++) {
	for (c=0; c<cols; c++) {
	    if (isMath)
		[myConverter concatDouble:[aMatrix doubleValueAt:r:c]];
	    else {
		cell = [aMatrix cellAtRow:r column:c];
		if ([cell isKindOfClass:[NSButtonCell class]])
		    [myConverter concatBool:[cell intValue]];
		else
		    [myConverter concat:[[cell stringValue] cString]];
	    }
	    if (c<cols-1) [myConverter concat:COEFF_DELIM];
	}
	[myConverter concat:ROW_DELIM];
    }
    [myConverter concat:END_MATRIX];
    [self setParameter:paraName toStringValue:[[myConverter stringValue] cString]];
    return self;
}

- setParameterObject:anObject requiredBundles:bundles;
{
    int i, c;
    NSString *className;
    if (anObject!=myParameterObject) {
	[self removeParameterObject];
	
	myParameterObject = anObject;
	if ([myParameterObject conformsToProtocol:@protocol(RefCounting)])
	    [myParameterObject ref];
	
        if ([bundles isKindOfClass:[JgList class]] || [bundles isKindOfClass:[OrderedList class]]) {
	    [myParameterObjectBundles release];
	    myParameterObjectBundles = [bundles retain];
	}
	else if([bundles isKindOfClass:[NSBundle class]])
	    myParameterObjectBundles = [[[JgList alloc]init]nx_addObject:bundles];
	c = [myParameterObjectBundles count];
	for (i=0; i<c; i++) {
            className=NSStringFromClass([[myParameterObjectBundles objectAt:i]principalClass]);
	    [self setParameter:[className cString] toStringValue:USED_BUNDLE];
	}
    }
    return self;
}

- (int)needsBundles:(char *)bundles;
{
    int bundleDiff = 0;
    const   void  *key; 
//	    void  *value;
//    NXHashState  state = [myParameterTable initState]; 
    NSString *nskey;
    NSString *nsvalue;
    NSEnumerator *en=[myParameterTable keyEnumerator];
//    while ([myParameterTable nextState: &state key: &key value: &value]) {
    while ((nskey=[en nextObject])) {	//new
	key=[nskey cString];		//new
	nsvalue=[myParameterTable objectForKey:nskey];	//new
//        value=[nsvalue cString];
        if (!strcmp([nsvalue cString], USED_BUNDLE)) {
	    bundleDiff++;
//#warning NSNameConversion:  Class names have changed. Check that the class name passed in is real.
//	    if ([[NSBundle bundleForClass:objc_lookUpClass(key)]principalClass])
            if ([[NSBundle bundleForClass:NSClassFromString(nskey)]principalClass])
		bundleDiff--;
	    else if(bundles){
		if(bundleDiff>1)
		    strcat(bundles, ", ");
		strcat(bundles, key);
	    }
	}
    }
    return bundleDiff;
}

- makeParametersUnique;
{
/* jg is glaub ich ueberfluessig, weil ja NSDictionary sowieso keine doppelten Eintraege hat. siehe auch Preferences.m
    id newTable = [[NXStringTable alloc]init];
    const void  *key; 
	  void  *value; 
    NXHashState  state = [myParameterTable initState]; 
    while ([myParameterTable nextState: &state key: &key value: &value]) {
	[newTable insertKey:NXUniqueString(key) value:NXCopyStringBufferFromZone(value, (NXZone *)[self zone])];
    }
    
    [[myParameterTable freeObjects] release];
    myParameterTable = newTable;
*/
    return self;
}
- removeParameter:(const char*)paraName;
{
    [myParameterTable removeObjectForKey:[NSString jgStringWithCString:paraName]];
    return self;
}

- removeParameterObject;
{
    NSString *className;
    int i, c = [myParameterObjectBundles count];
    if ([myParameterObject conformsToProtocol:@protocol(RefCounting)])
	[myParameterObject release];
    myParameterObject = nil;
    
    for (i=0; i<c; i++) {
        className=NSStringFromClass([[myParameterObjectBundles objectAt:i]principalClass]);
	[self removeParameter:[className cString]];
    }
    [myParameterObjectBundles release];
    myParameterObjectBundles = nil;
    return self;
}

- (const char*)stringValueOfParameter:(const char*)paraName;
{
//    return [myParameterTable valueForStringKey:paraName];
    return [[myParameterTable objectForKey:[NSString jgStringWithCString:paraName]] cString];
}

- (int)intValueOfParameter:(const char*)paraName;
{
   // jg here and further below, in Rubato 1 the return strangely was before the first command!
    [myConverter setStringValue:[myParameterTable objectForKey:[NSString jgStringWithCString:paraName]]];
    return [myConverter intValue];
}

- (double)doubleValueOfParameter:(const char*)paraName;
{
    [myConverter setStringValue:[myParameterTable objectForKey:[NSString jgStringWithCString:paraName]]];
   return [myConverter doubleValue];
}

- (BOOL)boolValueOfParameter:(const char*)paraName;
{
    [myConverter setStringValue:[myParameterTable objectForKey:[NSString jgStringWithCString:paraName]]];
   return [myConverter boolValue];
}

- getParameter:(const char*)paraName forMatrix:aMatrix;
{
    int rows, cols, r, c;
    id tokens, cell;
    BOOL isMath = [aMatrix isKindOfClass:NSClassFromString(@"MathMatrix")];
    [aMatrix getNumberOfRows:&rows columns:&cols];
    [myConverter setStringValue:[myParameterTable objectForKey:[NSString jgStringWithCString:paraName]]];
    tokens = [myConverter tokenizeToStringsWith:BEGIN_MATRIX END_MATRIX ROW_DELIM COEFF_DELIM];
    for (r=0; r<rows; r++) {
	for (c=0; c<cols; c++) {
	    if (isMath)
		[aMatrix setDoubleValue:[[tokens objectAt:(r*cols)+c]doubleValue] at:r:c];
	    else {
		cell = [aMatrix cellAtRow:r column:c];
		if ([cell isKindOfClass:[NSButtonCell class]])
		    [cell setIntValue:[[tokens objectAt:(r*cols)+c]boolValue]];
		else
		    [cell setStringValue:[[tokens objectAt:(r*cols)+c] stringValue]];
	    }
	}
    }
    return self;
}

- parameterObject;
{
    return myParameterObject;
}

// used to write the weight to text.
// new: the text is not initialized by stream, but by string
- writeParametersToString:(NSMutableString *)toString;
{
    id aString = [[String alloc]init], stringList, sortList;
    char *data;
    int i, c, len, maxlen;
    JGStream *privateStream = JGOpenMemory(NULL,0,NX_READWRITE);
    
    JGSeek(privateStream, 0L, NX_FROMSTART);
// was:    [myParameterTable writeToStream:privateStream]; // jg: Dictionary description method
    [privateStream appendString:[myParameterTable description]]; // jg is

    JGSeek(privateStream, 0L, NX_FROMSTART);
    JGGetMemoryBuffer(privateStream, &data, &len, &maxlen);
    
    [aString setStringValue:privateStream];
    
    stringList = [aString tokenizeToStringsWith:"\n"];
    sortList = [[[OrderedList alloc]init]appendList:stringList];
    [sortList sort];
    [aString release];
    
    for (i=0, c=[sortList count]; i<c; i++) {
	aString = [sortList objectAt:i];
//	NXWrite(aCoder, [[aString stringValue] cString], [aString length]);
//	if (i<c-1) NXPutc(aCoder, '\n');
	[toString appendString:[aString stringValue]];
        if (i<c-1) [toString appendString:@"\n"];
    }
    
    [sortList release];
//    JGCloseMemory(privateStream, NX_FREEBUFFER);
    return self;
}

// special treatment, because during read it is not clear, if the necessary classes exist in the runtime.
// That is the reason for the Wrapper for myParameterObject.
- writeParameterObject:(NSCoder *)aCoder;
{
//    int i, length;
//    char *buffer;
    NSMutableData *buffer;
    NSArchiver *localArchiver;
    buffer=[NSMutableData new];
    localArchiver=[[NSArchiver alloc] initForWritingWithMutableData:buffer];

//    buffer = NXWriteRootObjectToBuffer(myParameterObject, &length);
    [localArchiver encodeRootObject:myParameterObject];
    
//    [aCoder encodeValueOfObjCType:"i" at:&length];
//    for (i=0; i<length; i++)
//	[aCoder encodeValueOfObjCType:"c" at:&buffer[i]];
    [aCoder encodeObject:[localArchiver archiverData]];
    //NXWriteObject(aCoder, myParameterObject);
    
//    NXFreeObjectBuffer(buffer, length);
    return self;
}

- readParameterObject:(NSCoder *)aDecoder;
{
//    id returnValue;
    char bundles[1025];
//    char *buffer;
    NSMutableData *buffer;
//    int i, length;

    bundles[0]=0; // jg new. obviously lokal c-Strings are not in initialised (any more). 

//    [aDecoder decodeValueOfObjCType:"i" at:&length];
//    buffer = malloc(length);
//    for (i=0; i<length; i++)
//	[aDecoder decodeValueOfObjCType:"c" at:&buffer[i]];
    buffer=[[aDecoder decodeObject] retain];

    [self needsBundles:bundles];
	
    NS_DURING
//    myParameterObject = NXReadObjectFromBufferWithZone(buffer, length, [self zone]);
    myParameterObject=[[MyUnArchiver unarchiveObjectWithData:buffer parent:aDecoder] retain]; // localArchiver
    NS_HANDLER
//jg    if (NXLocalHandler.code==NSArchiverClassError && strlen(bundles)) {
	NSRunAlertPanel(@"Read Weight", @"The following Modules must be loaded in order to read all weight parameters: %s", @"", nil, nil, bundles);
	NS_VALUERETURN(nil, id); // was statt id: typeof(nil));
//jg    } else
//jg	LOAD_HANDLER  /* a load handler macro in macros.h */
    NS_ENDHANDLER /* end of handler */
    if ([myParameterObject conformsToProtocol:@protocol(RefCounting)])
	[myParameterObject ref];
	
    [buffer release];
    return self;
}

/* Access to myWeightEvents */
-(unsigned int)count;
{
    return [myWeightEvents count];
}

- eventAt:(unsigned int)index; /* This should be a symbolic event from myWeightEvents© list */
{
    return [myWeightEvents objectAt:index];
}

- (double)weightAt:(unsigned int)index;
{
    return [[myWeightEvents objectAt:index]doubleValue];
}

- addWeight:(double)aWeightValue at:(double)E:(double)H:(double)L:(double)D:(double)G:(double)C;
{
    int index;
    id anEvent = [[MatrixEvent alloc]init];
    [anEvent setSpaceTo:mySpace];
    [anEvent setDoubleValue:aWeightValue];
    for (index=0; index<MAX_SPACE_DIMENSION; index++)
	if ([anEvent spaceAt:index])
	 switch (index) {
	    case indexE: [anEvent setDoubleValue:E atIndex:index];
			 break;
	    case indexH: [anEvent setDoubleValue:H atIndex:index];
			 break;
	    case indexL: [anEvent setDoubleValue:L atIndex:index];
			 break;
	    case indexD: [anEvent setDoubleValue:D atIndex:index];
			 break;
	    case indexG: [anEvent setDoubleValue:G atIndex:index];
			 break;
	    case indexC: [anEvent setDoubleValue:C atIndex:index];
			 break;
	 }
    if ([self addEvent:anEvent]) /* frees the event if not inserted */
	return self;
    else 
	return nil;
}


- addWeight:(double)aWeightValue atEvent:anEvent;
{
    if ([anEvent isSuperspaceFor:mySpace]) {
	if ([anEvent retainCount]>1)
	    anEvent = [anEvent clone]; /* insert only independent exact copies */
	[anEvent setSpaceTo:mySpace];
	[anEvent setDoubleValue:aWeightValue];
	if ([self addEvent:anEvent]) /* frees the event if not inserted */
	    return self;
	else {
	    return nil;
	}
    }
    return nil;
}

- addEvent:anEvent;
{
    if ([anEvent isKindOfClass:[MatrixEvent class]] && [anEvent space]==mySpace 
		&& [myWeightEvents indexOfObject:anEvent]==NSNotFound) {
	id evt;
	int i, c = [myWeightEvents count];
        if ([anEvent retainCount]>1)
	    anEvent = [[anEvent clone] autorelease]; /* insert only independent exact copies */
	
	for (i=0; i<c; i++) {
	    evt = [myWeightEvents objectAt:i];
	    if ([evt isEqual:anEvent]) {
	    /* all coordinates are equal, replace the weight's value */
		double w = [anEvent doubleValue];
		[evt setDoubleValue:w];
		myMinWeight = myMinWeight < w ? myMinWeight : w;
		myMaxWeight = myMaxWeight > w ? myMaxWeight : w;
		[self calcMeanWeight];
		//[anEvent release]; /* this event object isn't needed anymore */
		[myBDWeight release]; /* is not valid anymore */
		myBDWeight = nil;
		
		return self;
	    }
	}
	/* exited or none was bigger until end of list */
	if ([myWeightEvents nx_addObject:anEvent]) {
	    double w = [anEvent doubleValue];
	    /* if first event to be inserted, c = 0, then min = max = w */
	    myMinWeight = c ? (myMinWeight < w ? myMinWeight : w) : w;
	    myMaxWeight = c ? (myMaxWeight > w ? myMaxWeight : w) : w;
	    [self calcMeanWeight];
	    [myBDWeight release]; /* is not valid anymore */
	    myBDWeight = nil;
	    
	    return self;
	}
    }
//    if ([anEvent retainCount]<=1) /* it's an independent copy */
//	[anEvent release];
    return nil;
}

- removeEvent:anEvent;
{
    if([myWeightEvents containsObject:anEvent]) {
        [myWeightEvents removeObject:anEvent];
	[self calcMinWeight];
	[self calcMaxWeight];
	[self calcMeanWeight];
	
	//[anEvent release];

	[myBDWeight release]; /* is not valid anymore */
	myBDWeight = nil;
    }
    return self;
}


/* weight maintenance methods */
- (double)maxWeight;
{
    return myMaxWeight;
}

- (double)minWeight;
{
    return myMinWeight;
}

- (double)meanWeight;
{
    return myMeanWeight;
}

- (double)calcMaxWeight;
{
    int i, c = [self count];
    double w;
    myMaxWeight = [self weightAt:0];
    for(i=1; i<c;i++) {
	w = [self weightAt:i];
	myMaxWeight = myMaxWeight > w ? myMaxWeight : w;
    }
    return myMaxWeight;
}

- (double)calcMinWeight;
{
    int i, c = [self count];
    double w;
    myMinWeight = [self weightAt:0];
    for(i=1; i<c;i++) {
	w = [self weightAt:i];
	myMinWeight = myMinWeight < w ? myMinWeight : w;
    }
    return myMinWeight;
}

- (double) calcMeanWeight;
{
    int i, c = [self count];
    myMeanWeight = 0.0;
    for(i=0; i<c;i++) {
	myMeanWeight += [self weightAt:i]/c;
    }
    return myMeanWeight;
}

- sort;
{
    [myWeightEvents sort];
    return self;
}


/* Get normalized weights */
- (double)normWeightAt:(unsigned int)index;
{
    double d = myMaxWeight - myMinWeight;
    if (d)
	return myStartNorm + (([self weightAt:index] - myMinWeight)*myRange)/d;
    else
	return myStartNorm;
}

- (double)meanNormalizedWeight;
{
    double d = myMaxWeight - myMinWeight;
    if (d)
	return myStartNorm + ((myMeanWeight - myMinWeight)*myRange)/d;
    else
	return myStartNorm;
}



/* One and two dim. splines */
- (double)splineAt:anEvent; /* Suppose anEvent is a numeric column matrix with coefficients! */
{
    if([self dimension] == 1)
	return [self cubeSplineAt:anEvent];

    else if([self dimension] == 2)
	return [self twoDSplineAt:anEvent];

    else
	return 1.0;
}


/* boiled down weight */
- bDWeightTo:(int)index;
{
    id bdWeight = nil;
    spaceIndex spInd=spaceOfIndex(index);
    [self sort];

    if([self dimension] == 1 && (spInd & mySpace))
	bdWeight = [self copyWithZone:[self zone]];
    
    if([self dimension] == 2 && (spInd & mySpace)){
	int i, c = [self count];
	id bdEvent, bdEventAti, bdWeightEvents;
	bdWeight = [[Weight alloc]init];

	[bdWeight setRubetteName:[self rubetteName]];
	[bdWeight setNameString:[self nameString]];
	[bdWeight setSpaceAt:index to:YES];
	[bdWeight setStartNorm:[self startNorm]];
	[bdWeight setRange:[self range]];
	[bdWeight setTolerance:[self tolerance]];

	bdWeightEvents = [[OrderedList alloc]initCount:c];
	for(i=0; i<c; i++) /* define the boiled down weight events */
	    [bdWeightEvents addObject:[[myWeightEvents objectAt:i]projectTo:spInd]];
	
	[bdWeightEvents sort];
	/* now we have a list of sorted events in spInd space */
	while([bdWeightEvents count]) {
            bdEvent = [bdWeightEvents objectAt:0];
            [bdWeightEvents removeObjectAt:0];
	
            bdEventAti=[bdWeightEvents objectAt:0];
	    while(bdEventAti && ([bdEventAti doubleValueAt:0] == [bdEvent doubleValueAt:0])) {
		/* just add up the existing weights */
		[bdEvent setDoubleValue:[bdEvent doubleValue]+[bdEventAti doubleValue]];
                bdEventAti =[bdWeightEvents objectAt:0];
                [bdWeightEvents removeObjectAt:0];
                //[bdEventAti release];
                bdEventAti=[bdWeightEvents objectAt:0];
	    }
	    /* now, insert a new weight event */
            [bdWeight addEvent:bdEvent]; 
            [bdEvent deRef];  
	}
	[bdWeightEvents release];
	[bdWeight sort];
	[bdWeight calcMaxWeight];
	[bdWeight calcMinWeight];
	[bdWeight calcMeanWeight];
    }
    if (NEWRETAINSCHEME) [bdWeight autorelease];
    return bdWeight;
}


/* boiled down splines */
- (double)bDSplineTo:(int)index at:anEvent;
{
    double result = 1.0;
	if (![myBDWeight isSuperspaceFor:spaceOfIndex(index)]) {
            [myBDWeight release]; /* not valid anymore */
	    myBDWeight = [self bDWeightTo:index];
	}

    if([self dimension] == 1 && spaceOfIndex(index)==mySpace)
	result = [self cubeSplineAt:anEvent];

    else if([self dimension] == 2 && [self spaceAt:index])
	result = [myBDWeight cubeSplineAt:anEvent];

    return result;
}



/* partial derivatives of one or two dim. splines */
- (double)partial:(unsigned int)index ofSplineAt:anEvent;
{
    if([self dimension] == 1)
	return [self dCubeSplineAt:anEvent];

    else if([self dimension] == 2 && index <=2)
	return [self partial:index twoDSplineAt:anEvent];
    else
	return 0.0;
}

/* One dim. cubic spline */
- (double)cubeSplineAt:anEvent;
{
    int i;
    double  first, last, x,
	    low, high;
    first = [[myWeightEvents objectAt:0] doubleValueAt:0];
    last = [[myWeightEvents lastObject] doubleValueAt:0];
    x = [anEvent doubleValueAt:0];
    low = first - myTolerance;
    high = last + myTolerance; 

    if((x <= low) || (x >= high))
	return 1.0;
	    
    else if(x <= first)
	return cube(low, 1.0,
		    first,[self normWeightAt:0],x);

    else if(x >= last)
	return cube(last,[self normWeightAt:[myWeightEvents count]-1],
		    high, 1.0, x);

    else
	{
	for(i = 0; (i < [myWeightEvents count]) && x > [[self eventAt:i] doubleValueAt:0]; i++);

	return cube([[self eventAt:i-1] doubleValueAt:0],[self normWeightAt:i-1],
		    [[self eventAt:i] doubleValueAt:0],[self normWeightAt:i],x);
	}
    return 1.0;
}


/* partial derivatives techniques in dim one */
/*Derivation of cubic spline with tol etc. on the boundary*/
- (double)dCubeSplineAt:anEvent;
{
    int i;
    double  first, last, x,
	    low, high;
    first = [[self eventAt:0] doubleValueAt:0];
    last = [[myWeightEvents lastObject] doubleValueAt:0];
    x = [anEvent doubleValueAt:0];
    low = first - myTolerance;
    high = last + myTolerance; 

    if((x <= low) || (x >= high))
	return 0.0;
	    
    else if(x <= first)
	return Dcube(low, 1.0,
		    first,[self normWeightAt:0],x);

    else if(x >= last)
	return Dcube(last,[self normWeightAt:[myWeightEvents count]-1],
		    high, 1.0, x);

    else
	{
	for(i = 0; (i < [myWeightEvents count]) && x > [[self eventAt:i] doubleValueAt:0]; i++);

	return Dcube([[self eventAt:i-1] doubleValueAt:0],[self normWeightAt:i-1],
		    [[self eventAt:i] doubleValueAt:0],[self normWeightAt:i],x);
	}
}

/* A better 2-dimensional technique for interpolations of degree 3 and extendable to any dimenson */

/* calculation of maximal an minimal second coordinates in a 2-dim weight */
- (double)maxCoordinate:(int)aCoordinate;
{
    int i;
    double w, coordi;
    w = [[self eventAt:0] doubleValueAt:aCoordinate]; 
    
    for(i=1; i<[myWeightEvents count];i++)
	w = (coordi = [[self eventAt:i] doubleValueAt:aCoordinate]) > w ? coordi : w;
    return w;
}

- (double)minCoordinate:(int)aCoordinate;
{
    int i;
    double w, coordi;
    w = [[self eventAt:0] doubleValueAt:aCoordinate]; 
    
    for(i=1; i<[myWeightEvents count];i++)
	w = (coordi = [[self eventAt:i] doubleValueAt:aCoordinate]) < w ? coordi : w;
    return w;
}


/* Here, anEvent is an object of the weight, i.e. a matrix of a priori dimension 2 */
- (double)twoDSplineAt:anEvent;
{
    id 		firstEvent, lastEvent,
    		eventi, eventimin, 
		eventj;
		
    double 	x, y, val, meanval, 
    		lowval, highval, 
		minFirstCoord, maxFirstCoord, 
		minSecondCoord, maxSecondCoord;
    int c, i, j;
    
    meanval = 1.0; /* formerly set to [self meanNormalizedWeight] */
    x = [anEvent doubleValueAt:0];
    y = [anEvent doubleValueAt:1];
    c = (int)[myWeightEvents count];
    firstEvent = [self eventAt:0];
    lastEvent = [self eventAt:c-1];
    minFirstCoord = [firstEvent doubleValueAt:0];
    maxFirstCoord = [lastEvent doubleValueAt:0];
    minSecondCoord = [self minCoordinate:1];
    maxSecondCoord = [self maxCoordinate:1];
    
    if(!(	x<=minFirstCoord-myTolerance || /*outside the tolerance frame */
    		x>=maxFirstCoord+myTolerance ||
		y<=minSecondCoord-myTolerance ||
    		y>=maxSecondCoord+myTolerance)) {
    for(i = c-1; i>=0 && [[self eventAt:i] doubleValueAt:0] > x; i--);
    /*The result is the first index (from above) with x coordinate <= x */
    
    if(i < 0) /* x to the left (before) of all weight events */
	{
	for(j = 0;	[(eventj=[self eventAt:j]) doubleValueAt:0] == [firstEvent doubleValueAt:0] &&
		    [eventj doubleValueAt:1] <= y &&
		    j < c; j++);
	    if(!j )
		val = [self normWeightAt:0];
	    else if(j == c)
		val = [self normWeightAt:c-1];
	    
	    else if([eventj doubleValueAt:0] != [firstEvent doubleValueAt:0])
		val = [self normWeightAt:j-1];
	    
	    else{
		val = cube(	[[self eventAt:j-1] doubleValueAt:1], [self normWeightAt:j-1],
				[eventj doubleValueAt:1], [self normWeightAt:j],
				    y);
		}
	}

    else if(i == c-1) /* x to the right (after) of all weight events */
	{
	for(j=c-1;	[(eventj=[self eventAt:j]) doubleValueAt:0] == [lastEvent doubleValueAt:0] &&
			[eventj doubleValueAt:1] > y &&
		    j >=0; j--);
	    if(j == c-1)
		val = [self normWeightAt:c-1];
	    else if(j == -1)
		val = [self normWeightAt:0];
    
	    else if([eventj doubleValueAt:0] != [lastEvent doubleValueAt:0])
		val = [self normWeightAt:j+1];
	    else{
		val = cube(	[eventj doubleValueAt:1], [self normWeightAt:j],
				[[self eventAt:j+1] doubleValueAt:1], [self normWeightAt:j+1],
				    y);
	    }
	}
   
   else /* now, 0<=i<c-1, and we have (x,y) between two indices */
	{
	    eventi = [self eventAt:i];
	    eventimin = [self eventAt:i+1];
	for(j=i;	[(eventj=[self eventAt:j]) doubleValueAt:0] == [eventi doubleValueAt:0] &&
		    [eventj doubleValueAt:1] > y &&
		    j >=0; j--);
	    if(j == i)
		lowval = [self normWeightAt:i];
    
	    else if(j == -1)
		lowval = [self normWeightAt:0];
    
	    else if([eventj doubleValueAt:0] != [eventi doubleValueAt:0])
		lowval = [self normWeightAt:j+1];
    
	    else{
		lowval = cube(	[eventj doubleValueAt:1], [self normWeightAt:j],
				[[self eventAt:j+1] doubleValueAt:1], [self normWeightAt:j+1],
				    y);
		}
    
	for(j=i+1;	[(eventj=[self eventAt:j]) doubleValueAt:0] == [eventimin doubleValueAt:0] &&
		    [eventj doubleValueAt:1] <= y &&
		    j < c; j++);
	    if(j == i+1)
		highval = [self normWeightAt:i+1];
    
	    else if(j == c)
		highval = [self normWeightAt:c-1];
		
	    else if([eventj doubleValueAt:0] != [eventimin doubleValueAt:0])
		highval = [self normWeightAt:j-1];
	    
	    else{
		highval = cube(	[[self eventAt:j-1] doubleValueAt:1], [self normWeightAt:j-1],
				[eventj doubleValueAt:1], [self normWeightAt:j],
				    y);
		}
	    
	    val = cube(	[eventi doubleValueAt:0], lowval,
			[eventimin doubleValueAt:0], highval,
			    x);
	}
    
	if(		x>=minFirstCoord && /* everything within the weight frame */
			x<=maxFirstCoord &&
			y>=minSecondCoord &&
			y<=maxSecondCoord)
	return val;
	
	else if(	x>=minFirstCoord && /* above the weight frame */
			x<=maxFirstCoord &&
			y>maxSecondCoord)

	return 		meanval+(val-meanval)*cube(	maxSecondCoord,1, 
					maxSecondCoord+myTolerance,0,
					y); 

	else if(	x>=minFirstCoord && /* below the weight frame */
			x<=maxFirstCoord &&
			y<minSecondCoord)
			
	return 		meanval+(val-meanval)*cube(	minSecondCoord-myTolerance,0,
					minSecondCoord,1, 
					y); 

	else if(	x<minFirstCoord && /* to the left of the weight frame */
			y>=minSecondCoord &&
			y<=maxSecondCoord)
			
	return 		meanval+(val-meanval)*cube(	minFirstCoord-myTolerance,0,
					minFirstCoord,1, 
					x); 

	else if(	x>maxFirstCoord && /* to the right of the weight frame */
			y>=minSecondCoord &&
			y<=maxSecondCoord)
			
	return 		meanval+(val-meanval)*cube(	maxFirstCoord,1,
					maxFirstCoord+myTolerance,0,
					x); 

	else if(	x<minFirstCoord && /* left upper corner */
			y>maxSecondCoord)

	return 		meanval+(val-meanval)*cube(	maxSecondCoord,1, 
					maxSecondCoord+myTolerance,0,
					y)*
				cube(	minFirstCoord-myTolerance,0,
					minFirstCoord,1, 
					x); 

	else if(	x<minFirstCoord && /* left lower corner */
			y<minSecondCoord)

	return 		meanval+(val-meanval)*cube(	minSecondCoord-myTolerance,0,
					minSecondCoord,1, 
					y)*
				cube(	minFirstCoord-myTolerance,0,
					minFirstCoord,1, 
					x); 

	else if(	x>maxFirstCoord && /* right upper corner */
			y>maxSecondCoord)

	return 		meanval+(val-meanval)*cube(	maxSecondCoord,1, 
					maxSecondCoord+myTolerance,0,
					y)*
				cube(	maxFirstCoord,1,
					maxFirstCoord+myTolerance,0,
					x); 

	else if(	x>maxFirstCoord && /* right lower corner */
			y<minSecondCoord)

	return 		meanval+(val-meanval)*cube(	minSecondCoord-myTolerance,0,
					minSecondCoord,1, 
					y)*
				cube(	maxFirstCoord,1,
					maxFirstCoord+myTolerance,0,
					x);
	
	}
	return meanval;
}

/* Partial derivatives of 2D splines.*/
- (double)partial:(unsigned int)index twoDSplineAt:anEvent;
{
    id 		firstEvent, lastEvent,
    		eventi, eventimin, 
		eventj;
		
    double 	x, y, val, Dval, 
    		lowval, highval, 
    		Dlowval, Dhighval, 
		minFirstCoord, maxFirstCoord, 
		minSecondCoord, maxSecondCoord;
    int c, i, j;
    
    x = [anEvent doubleValueAt:0];
    y = [anEvent doubleValueAt:1];
    c = (int)[myWeightEvents count];
    firstEvent = [self eventAt:0];
    lastEvent = [self eventAt:c-1];

    minFirstCoord = [firstEvent doubleValueAt:0];
    maxFirstCoord = [lastEvent doubleValueAt:0];
    minSecondCoord = [self minCoordinate:1];
    maxSecondCoord = [self maxCoordinate:1];
    
    if(		x<=minFirstCoord-myTolerance || /*outside the tolerance frame */
    		x>=maxFirstCoord+myTolerance ||
		y<=minSecondCoord-myTolerance ||
    		y>=maxSecondCoord+myTolerance)
    return 0.0;

    else
    {
    val = [self twoDSplineAt:anEvent]; /* from now on, val is needed, but not yet Dval */

    	if(		x<minFirstCoord && /* left upper corner */
			y>maxSecondCoord)
		{
		if(index == 1)
		
	return	(val-1)*cube(	maxSecondCoord,1, 
				maxSecondCoord+myTolerance,0,
				y)*
			Dcube(	minFirstCoord-myTolerance,0,
				minFirstCoord,1, 
				x);	

		if(index == 2)

	return	(val-1)*Dcube(	maxSecondCoord,1, 
				maxSecondCoord+myTolerance,0,
				y)*
			cube(	minFirstCoord-myTolerance,0,
				minFirstCoord,1, 
				x);	
		}	


	else if(	x<minFirstCoord && /* left lower corner */
			y<minSecondCoord)
		{
		if(index == 1)
		
	return	(val-1)*cube(	minSecondCoord-myTolerance,0,
				minSecondCoord,1,
				y)*
			Dcube(	minFirstCoord-myTolerance,0,
				minFirstCoord,1, 
				x);	

		if(index == 2)

	return	(val-1)*Dcube(	minSecondCoord-myTolerance,0,
				minSecondCoord,1,
				y)*
			cube(	minFirstCoord-myTolerance,0,
				minFirstCoord,1, 
				x);	
		}	

	else if(	x>maxFirstCoord && /* right upper corner */
			y>maxSecondCoord)
		{
		if(index == 1)
		
	return	(val-1)*cube(	maxSecondCoord,1, 
				maxSecondCoord+myTolerance,0,
				y)*
			Dcube(	maxFirstCoord,1,
				maxFirstCoord+myTolerance,0, 
				x);	

		if(index == 2)

	return	(val-1)*Dcube(	maxSecondCoord,1, 
				maxSecondCoord+myTolerance,0,
				y)*
			cube(	maxFirstCoord,1,
				maxFirstCoord+myTolerance,0, 
				x);	
		}	

	else if(	x>maxFirstCoord && /* right lower corner */
			y<minSecondCoord)
		{
		if(index == 1)
		
	return	(val-1)*cube(	minSecondCoord-myTolerance,0,
				minSecondCoord,1,
				y)*
			Dcube(	maxFirstCoord,1,
				maxFirstCoord+myTolerance,0, 
				x);	

		if(index == 2)

	return	(val-1)*Dcube(	minSecondCoord-myTolerance,0,
				minSecondCoord,1,
				y)*
			cube(	maxFirstCoord,1,
				maxFirstCoord+myTolerance,0, 
				x);	
		}


	else if(	x>=minFirstCoord && /* above the weight frame */
			x<=maxFirstCoord &&
			y>maxSecondCoord &&
			index == 2)

	return	(val-1)*Dcube(	maxSecondCoord,1, 
				maxSecondCoord+myTolerance,0,
				y);
		
	else if(	x>=minFirstCoord && /* below the weight frame */
			x<=maxFirstCoord &&
			y<minSecondCoord &&
			index == 2)

	return	(val-1)*Dcube(	minSecondCoord-myTolerance,0,
				minSecondCoord,1,
				y);
		
 	else if(	x<minFirstCoord && /* to the left of the weight frame */
			y>=minSecondCoord &&
			y<=maxSecondCoord &&
			index == 1)

	return	(val-1)*Dcube(	minFirstCoord-myTolerance,0,
				minFirstCoord,1, 
				x);
   
	else if(	x>maxFirstCoord && /* to the right of the weight frame */
			y>=minSecondCoord &&
			y<=maxSecondCoord &&
			index == 1)
			
	return	(val-1)*Dcube(	maxFirstCoord,1,
				maxFirstCoord+myTolerance,0, 
				x);
    
    
    
    
    
	else{
    /* NOW, we have to calculate Dval! */

    for(i = c-1; i>=0 && [[self eventAt:i] doubleValueAt:0] > x; i--);
    /*The result is the first index (from above) with x coordinate <= x */
    
    if(i < 0) /* x to the left (before) of all weight events */
	{if(index == 1)
	Dval = 0.0;

	else{
	for(j = 0;	[(eventj=[self eventAt:j]) doubleValueAt:0] == [firstEvent doubleValueAt:0] &&
			[eventj doubleValueAt:1] <= y &&
			j < c; j++);
	    if(!j || j == c || [eventj doubleValueAt:0] != [firstEvent doubleValueAt:0] )
	Dval = 0.0;
	    
	    else{
	Dval = Dcube(	[[self eventAt:j-1] doubleValueAt:1], [self normWeightAt:j-1],
			[eventj doubleValueAt:1], [self normWeightAt:j],
			y);
		}
	    }
	}

    else if(i == c-1) /* x to the right (after) of all weight events */
	{if(index == 1)
	Dval = 0.0;

	else{
	for(j=c-1;	[(eventj=[self eventAt:j]) doubleValueAt:0] == [lastEvent doubleValueAt:0] &&
			[eventj doubleValueAt:1] > y &&
			j >=0; j--);
	    if(j == c-1 || j == -1 || [eventj doubleValueAt:0] != [lastEvent doubleValueAt:0])
	Dval = 0.0;

	    else{
	Dval = Dcube(	[eventj doubleValueAt:1], [self normWeightAt:j],
			[[self eventAt:j+1] doubleValueAt:1], [self normWeightAt:j+1],
			y);
		}
	    }
	}
   
    else /* now, 0<=i<c-1, and we have (x,y) between two indices */
	{
	    eventi = [self eventAt:i];
	    eventimin = [self eventAt:i+1];
	if(index == 1)
	{
	for(j=i;[(eventj=[self eventAt:j]) doubleValueAt:0] == [eventi doubleValueAt:0] &&
		[eventj doubleValueAt:1] > y &&
		j >=0; j--);
	    if(j == i)
		lowval = [self normWeightAt:i];
    
	    else if(j == -1)
		lowval = [self normWeightAt:0];
    
	    else if([eventj doubleValueAt:0] != [eventi doubleValueAt:0])
		lowval = [self normWeightAt:j+1];
    
	    else{
		lowval = cube(	[eventj doubleValueAt:1], [self normWeightAt:j],
				[[self eventAt:j+1] doubleValueAt:1], [self normWeightAt:j+1],
				y);
		}
    
	for(j=i+1;  [(eventj=[self eventAt:j]) doubleValueAt:0] == [eventimin doubleValueAt:0] &&
		    [eventj doubleValueAt:1] <= y &&
		    j < c; j++);
	    if(j == i+1)
		highval = [self normWeightAt:i+1];
    
	    else if(j == c)
		highval = [self normWeightAt:c-1];
		
	    else if([eventj doubleValueAt:0] != [eventimin doubleValueAt:0])
		highval = [self normWeightAt:j-1];
	    
	    else{
		highval = cube(	[[self eventAt:j-1] doubleValueAt:1], [self normWeightAt:j-1],
				[eventj doubleValueAt:1], [self normWeightAt:j],
				
				y);
		}

	Dval = Dcube(	[eventi doubleValueAt:0], lowval,
			[eventimin doubleValueAt:0], highval,
			x);
	}
	else{ /*index = 2 */
	
	for(j=i;[(eventj=[self eventAt:j]) doubleValueAt:0] == [eventi doubleValueAt:0] &&
		[eventj doubleValueAt:1] > y &&
		j >=0; j--);
	    if(j == i || j == -1 || [[self eventAt:j] doubleValueAt:0] != [eventi doubleValueAt:0])
		Dlowval = 0.0;
    
	    else{
		Dlowval = Dcube([eventj doubleValueAt:1], [self normWeightAt:j],
				[[self eventAt:j+1] doubleValueAt:1], [self normWeightAt:j+1],
				y);
		}
    
	for(j=i+1;  [(eventj=[self eventAt:j]) doubleValueAt:0] == [eventimin doubleValueAt:0] &&
		    [eventj doubleValueAt:1] <= y &&
		    j < c; j++);
	    if(j == i+1 || j == c || [eventj doubleValueAt:0] != [eventimin doubleValueAt:0])
		Dhighval = 0.0;
    
	    else{
		Dhighval = Dcube(	[[self eventAt:j-1] doubleValueAt:1], [self normWeightAt:j-1],
					[eventj doubleValueAt:1], [self normWeightAt:j],
					y);
		}

	Dval = cube([eventi doubleValueAt:0], Dlowval,
		    [eventimin doubleValueAt:0], Dhighval,
		    x);
	    }
	}
    
	if(		x>=minFirstCoord && /* everything within the weight frame */
			x<=maxFirstCoord &&
			y>=minSecondCoord &&
			y<=maxSecondCoord)
	return Dval;
	
	else if(	x>=minFirstCoord && /* above the weight frame */
			x<=maxFirstCoord &&
			y>maxSecondCoord /*&&
			index == 1*/)

	return	Dval*cube(	maxSecondCoord,1, 
				maxSecondCoord+myTolerance,0,
				y);

	else if(	x>=minFirstCoord && /* below the weight frame */
			x<=maxFirstCoord &&
			y<minSecondCoord /*&&
			index == 1*/)

	return	Dval*cube(	minSecondCoord-myTolerance,0,
				minSecondCoord,1,
				y);

	else if(	x<minFirstCoord && /* to the left of the weight frame */
			y>=minSecondCoord &&
			y<=maxSecondCoord /*&&
			index == 2*/)

	return	Dval*cube(	minFirstCoord-myTolerance,0,
				minFirstCoord,1, 
				x); 

			
	else if(	x>maxFirstCoord && /* to the right of the weight frame */
			y>=minSecondCoord &&
			y<=maxSecondCoord /*&&
			index == 2*/)
			
	return	Dval*cube(	maxFirstCoord,1,
				maxFirstCoord+myTolerance,0, 
				x);
	}
    } 
	return 0.0;
	
}

/* deformation sensitive splines and their derivatives; deformation = 0 is the default (linear) setting */
/* deformation of splineAt:anEvent */
- (double)splineAt:anEvent deformation:(double)deformation;
{
    if(!deformation)
	return [self splineAt:anEvent];
    if([self dimension] == 1) {
	if (myRange>0)
/*	    
	    return myStartNorm + deform(([self cubeSplineAt:anEvent]-myStartNorm)/myRange, deformation)*myRange;
*/

	    return myStartNorm + supported1DDeform(([self cubeSplineAt:anEvent]-myStartNorm)/myRange,
						deformation,
						[self minCoordinate:0],
						[self maxCoordinate:0],
						myTolerance,
						[anEvent doubleValueAtIndex:[self indexOfDimension:1]])*myRange;

	else
	    return (myStartNorm+myRange) + supported1DDeform(([self cubeSplineAt:anEvent]-(myStartNorm+myRange))/fabs(myRange),
						deformation,
						[self minCoordinate:0],
						[self maxCoordinate:0],
						myTolerance,
						[anEvent doubleValueAtIndex:[self indexOfDimension:1]])*fabs(myRange);

     } else if([self dimension] == 2) {
	if (myRange>0)
	    return myStartNorm + supported2DDeform(([self twoDSplineAt:anEvent]-myStartNorm)/myRange,
						deformation,
						[self minCoordinate:0], [self maxCoordinate:0],
						[self minCoordinate:1], [self maxCoordinate:1],
						myTolerance,
						[anEvent doubleValueAtIndex:[self indexOfDimension:1]],
						[anEvent doubleValueAtIndex:[self indexOfDimension:2]])*myRange;
	else
	    return (myStartNorm+myRange) + supported2DDeform(([self twoDSplineAt:anEvent]-(myStartNorm+myRange))/fabs(myRange),
						deformation,
						[self minCoordinate:0], [self maxCoordinate:0],
						[self minCoordinate:1], [self maxCoordinate:1],
						myTolerance,
						[anEvent doubleValueAtIndex:[self indexOfDimension:1]],
						[anEvent doubleValueAtIndex:[self indexOfDimension:2]])*fabs(myRange);

    } else
	return 1.0;
} 

- (double)splineAt:anEvent lowNorm:(double)loNorm highNorm:(double)hiNorm tolerance:(double)tolerance inversion:(BOOL)flag deformation:(double)deformation;
{
    double spline, saveHi, saveLo, saveTol;
    BOOL saveInv = [self isInverted];
    saveHi = [self highNorm];
    saveLo = [self lowNorm];
    saveTol = [self tolerance];
    [self setLowNorm:loNorm];
    [self setHighNorm:hiNorm];
    [self setTolerance:tolerance];
    [self setInversion:flag];
    spline = [self splineAt:anEvent deformation:deformation];
    [self setLowNorm:saveLo];
    [self setHighNorm:saveHi];
    [self setTolerance:saveTol];
    [self setInversion:saveInv];
   return spline;
}

/* deformation of bdSplineTo:anEvent */
- (double)bDSplineAt:anEvent to:(int)index deformation:(double)deformation;
{
    double stN, rg, spl = [self bDSplineTo:index at:anEvent];
    if(deformation) {
	    stN = [myBDWeight startNorm];
	    rg = [myBDWeight range];
    
	    if (rg>0)
		return stN + supported1DDeform((spl-stN)/rg,  deformation,
						[myBDWeight minCoordinate:0],
						[myBDWeight maxCoordinate:0],
						[myBDWeight tolerance],
						[anEvent doubleValueAtIndex:[myBDWeight indexOfDimension:1]])*rg;
	    else
		return (stN+rg) + supported1DDeform((spl-(stN+rg))/fabs(rg),deformation,
						[myBDWeight minCoordinate:0],
						[myBDWeight maxCoordinate:0],
						[myBDWeight tolerance],
						[anEvent doubleValueAtIndex:[myBDWeight indexOfDimension:1]])*fabs(rg);
    }
    else
	return spl;
} 

- (double)bDSplineAt:anEvent to:(int)index lowNorm:(double)loNorm highNorm:(double)hiNorm tolerance:(double)tolerance inversion:(BOOL)flag deformation:(double)deformation;
{
    double spline, saveHi, saveLo, saveTol;
    BOOL saveInv = [self isInverted];
    saveHi = [self highNorm];
    saveLo = [self lowNorm];
    saveTol = [self tolerance];
    [self setLowNorm:loNorm];
    [self setHighNorm:hiNorm];
    [self setTolerance:tolerance];
    [self setInversion:flag];
    spline = [self bDSplineAt:anEvent to:index deformation:deformation];
    [self setLowNorm:saveLo];
    [self setHighNorm:saveHi];
    [self setTolerance:saveTol];
    [self setInversion:saveInv];
    return spline;
}

/* partial of deformation of splineAt:anEvent */
- (double)partial:(unsigned int)index ofSplineDeformationAt:anEvent:(double)deformation;
{
    return derDeform([self splineAt:anEvent deformation:deformation], 
	tol1Dsupport(deformation, [self minCoordinate:0], [self maxCoordinate:0], myTolerance,
	    [anEvent doubleValueAtIndex:[self indexOfDimension:1]]))*[self partial:index ofSplineAt:anEvent];
}

- (double)partial:(unsigned int)index ofSplineAt:anEvent lowNorm:(double)loNorm highNorm:(double)hiNorm tolerance:(double)tolerance inversion:(BOOL)flag deformation:(double)deformation;
{
    return derDeform([self splineAt:anEvent lowNorm:loNorm highNorm:hiNorm tolerance:tolerance inversion:flag deformation:deformation], 
	tol1Dsupport(deformation, [self minCoordinate:0], [self maxCoordinate:0], myTolerance,
	    [anEvent doubleValueAtIndex:[self indexOfDimension:1]]))*[self partial:index ofSplineAt:anEvent];
}
/* RefCounting & NXReference methods */
- ref;
{
    [self retain];
    return self;
}

- deRef;
{
    [self release]; 
    return self;
}
#if 0
- (unsigned int)references;
{
#ifdef RETAINCOUNTMINUS1
#warning Compile option RETAINCOUNTMINUS1 defined.
   return [self retainCount]-1;
#else
#warning Compile option RETAINCOUNTMINUS1 not defined.
   return [self retainCount];
#endif
}
#endif
- (void)nxrelease;
{
//#ifdef SUPERFREE
//#warning Compile option SUPERFREE defined.
//  if([self retainCount]!=2)
//    [self release];
//  else {
//    [self release]; // myRefCount
//    [self release]; // [super free]
//  }
//#else
//#warning Compile option SUPERFREE not defined.
  [self release];
//#endif
}
@end


/* SymbolicOperator */

#import "SymbolicOperator.h"
#import <AppKit/NSApplication.h>
#import <Rubette/WeightWatcher.h>
#import <Rubette/MatrixEvent.h>

@implementation SymbolicOperator

/* get the operator's nib file */
+ (NSString *)inspectorNibFile;
{
    return @"SymbolicOperatorInspector.nib";
}

- init;
{
    [super init];
    
    myInheritedKernel = [[[OrderedList alloc]init]ref];
    isKernelCalculated = NO;
    return self;
}

- (void)dealloc;
{
    /* do NXReference houskeeping */

    [myInheritedKernel release]; myInheritedKernel = nil;
    /* class-specific initialization goes here */
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    [super initWithCoder:aDecoder];
    
    if (myInheritedKernel) {
      [myInheritedKernel release]; myInheritedKernel = nil;
    }
    myInheritedKernel = [[[myMother kernel]copy]ref];
    return self;
}

- setKernel:aKernel;
{
   if ([aKernel isKindOfClass:[JgList class]] || [aKernel isKindOfClass:[OrderedList class]]) {
	int i, c=[aKernel count];
	id anEvent = nil;
	[self invalidate];
	isKernelCalculated = NO;
	[myKernel freeObjects];
	[myInheritedKernel freeObjects];
	
	for (i=0; i<c; i++) {
	    anEvent = [aKernel objectAt:i];
	    if([anEvent isKindOfClass:[MatrixEvent class]]) {
		[myInheritedKernel addObjectIfAbsent:anEvent];
		[myKernel addObjectIfAbsent:[anEvent clone]];
	    }
	}
	[self calcAlterateKernel];
    }
    return self;
}

- setFieldDilatationAt:(int)index to:(double)aDouble;
{
    if (index<MAX_SPACE_DIMENSION) {
	if ((aDouble || fieldTranslation[index]) && fieldDilatation[index] != aDouble) {
	    fieldDilatation[index] = aDouble;
	    [self invalidate];
	    if ([self spaceAt:index]) {
		isKernelCalculated = NO;
		[self calcAlterateKernel];
	    }
	}
    }
    return self;
}

- setFieldTranslationAt:(int)index to:(double)aDouble;
{
    if (index<MAX_SPACE_DIMENSION) {
	if ((aDouble || fieldDilatation[index]) && fieldTranslation[index] != aDouble) {
	    fieldTranslation[index] = aDouble;
	    [self invalidate];
	    if ([self spaceAt:index]) {
		isKernelCalculated = NO;
		[self calcAlterateKernel];
	    }
	}
    }
    return self;
}

/* maintain calc optimization */
- weightWatcherChanged;
{
    [super weightWatcherChanged];
    isKernelCalculated = NO;
    [self calcAlterateKernel];
    return self;
}

- validate;
{
    [myPerformanceKernel freeObjects];
    
    [self calcAlterateKernel];
    return self;
}

/* calculation of new symbolic events, also extends the LPS frame */
- calcAlterateKernel;
{
    if (!isKernelCalculated) {
	int i, index, c = [myKernel count];
	
	[myInheritedKernel sort];
	
	for (i=0; i<c; i++) 
	    [self brutalizeEventAt:i];
	[myKernel sort];
	for (index=0; index<MAX_SPACE_DIMENSION; index++){ /* reset myFrame */
	    for (i=0; i<c && !([[myKernel objectAt:i] spaceAt:index]); i++);
		    		    
	    myFrame[index].origin = i<c ? [[myKernel objectAt:i] doubleValueAtIndex:index] : 0.0;
	    myFrame[index].end = myFrame[index].origin;
	}
    
	[self extendFrameToKernel:myKernel];
	[myDaughters makeObjectsPerform:@selector(setKernel:) with:myKernel];
	isKernelCalculated = YES;
    }
    return self;
}

- brutalizeEventAt:(int)index;
{
    int i;
    double curBruteValue;
    id symbEvent = [myInheritedKernel objectAt:index];
    id perfEvent = [myKernel objectAt:index];
    for(i = 0; i<MAX_SPACE_DIMENSION; i++){
	if([self hierarchyTopAt:i] && [symbEvent spaceAt:i] && [self directionAt:i]) {
	    curBruteValue = [myWeightWatcher weightSumAt:symbEvent];
	    curBruteValue *= fieldDilatation[i];
	    curBruteValue *= [symbEvent doubleValueAtIndex:i];
	    curBruteValue += fieldTranslation[i];
	} else
	    curBruteValue = [symbEvent doubleValueAtIndex:i];
	[perfEvent setDoubleValue:curBruteValue atIndex:i];

    }
    return self;
} 




/*get the string representation of the operator*/
- (NSString *)stringValue;
{
    return @"(ax + b)";
}

- (const char*)operatorString;
{
    [myConverter setStringValue:@"SymbolicBruteForce(a * "];
    [myConverter concat:[myMother operatorString]];
    [myConverter concat:"+ b)"];
    
    return [[myConverter stringValue] cString];
}


/* Calculate the Field of an Operator */
- calcPerformanceField:(double *)field at:anEvent;
{
    /* The SymbolicBruteForce Operator doesn't alter the field at all */
    return self;
}

@end

@implementation SymbolicOperator (SpaceProtocolMethods)
- setSpaceAt:(int)index to:(BOOL)flag;
{
    if ([self spaceAt:index]!=flag && index<MAX_SPACE_DIMENSION) {
	if (flag)
	    mySpace = mySpace | 1 << index;
	else
	    mySpace = mySpace & ~(1 << index);
	[self invalidate];
	isKernelCalculated = NO;
	[self calcAlterateKernel];
    }
    return self;
}
- setSpaceTo:(spaceIndex)aSpace;
{
    if (mySpace!=aSpace) {
	mySpace = aSpace;
	[self invalidate];
	isKernelCalculated = NO;
	[self calcAlterateKernel];
    }
    return self;
}

@end
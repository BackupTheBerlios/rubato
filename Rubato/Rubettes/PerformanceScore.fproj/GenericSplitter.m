/* GenericSplitter.m */

#import "GenericSplitter.h"
#import "GenericSplitterApplicator.h"

@implementation GenericSplitter

/* get the operator's nib files */
+ (NSString *)inspectorNibFile;
{
    return @"PerformanceOperatorInspector.nib";
}


/*apply operator on a LPS*/
+ apply:applicator to:anLPS;
{
    int index, c;
    id string, event, theLPSkernel, theChangeDaughter, theRemainderDaughter, remainderKernel, changeKernel;
        
    theLPSkernel = [anLPS kernel];
    theChangeDaughter = [anLPS makeDaughterWithOperator:self];
    theRemainderDaughter = [anLPS makeDaughterWithOperator:self];

    remainderKernel = [theRemainderDaughter kernel];
    changeKernel = [theChangeDaughter kernel];
    
    string = [theChangeDaughter getNameString];
    if (applicator && strlen([applicator nameString]) )
	[string setStringValue:[NSString jgStringWithCString:[applicator nameString]]];
    [string concat:" "];
    [string concatInt:CHANGE_DAUGHTER_INDEX];
    
    string = [theRemainderDaughter getNameString];
    if (applicator && strlen([applicator nameString]))
	[string setStringValue:[NSString jgStringWithCString:[applicator nameString]]];
    [string concat:" "];
    [string concatInt:REMAINDER_DAUGHTER_INDEX];
    
    for (index=0; index<MAX_SPACE_DIMENSION; index++){/* define the frame of theChangeDaughter */
	    LPS_Frame *indexFrame = [theChangeDaughter frameAt:index];

	    if([applicator initialActivationAt:index])
		indexFrame->origin = [applicator splitOriginAt:index]; 

	    if([applicator finalActivationAt:index])
		indexFrame->end = [applicator splitEndAt:index]; 
	    
    }

    /* theRemainderDaughter just looses some kernel events, the rest remains as it is */  
    c = [theLPSkernel count];
    for(index=c-1; 0<=index; index--){
	event = [theLPSkernel objectAt:index];
	if([theChangeDaughter frameContains:event]) {
//	    [[remainderKernel removeObject:event] release];
	    [remainderKernel removeObject:event];
	    //[event release];
        } else {
	    [changeKernel removeObject:event];
	    //[event release];
	}
    }
    if (![remainderKernel count]) {
	[anLPS killDaughter:theRemainderDaughter];
	theRemainderDaughter = nil;
    }
    if (![changeKernel count]) {
	[anLPS killDaughter:theChangeDaughter];
	theChangeDaughter = nil;
    }
    [theChangeDaughter invalidate]; /* update performanceTable & stuff */
    [theRemainderDaughter invalidate];
    [theChangeDaughter setOperatorIndex:CHANGE_DAUGHTER_INDEX];
    [theRemainderDaughter setOperatorIndex:REMAINDER_DAUGHTER_INDEX];

    return self;
}

+ applicatorClass;
{
    return [GenericSplitterApplicator class];
}


- init;
{
    [super init];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    [aDecoder decodeValuesOfObjCTypes:"cc",  &myInitialActivation,  &myFinalActivation];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeValuesOfObjCTypes:"cc",  &myInitialActivation,  &myFinalActivation];
}

/* operator sets kernel under restriction of frame */
- setKernel:aKernel;
{
    if ([aKernel isKindOfClass:[RefCountList class]] || [aKernel isKindOfClass:[OrderedList class]]) {
	int i, c =[aKernel count];
	id anEvent;
	[self invalidate];
	[myKernel freeObjects];
	for(i=0; i<c; i++) {
	    anEvent = [aKernel objectAt:i];
	    if([self frameContains:anEvent])
		[myKernel addObjectIfAbsent:anEvent];
		//[self insertKeyEvent:anEvent andPerformance:nil];
	}
	[myKernel sort];
	[myDaughters makeObjectsPerformSelector:@selector(setKernel:) withObject:myKernel];
    }
    return self;
}


- setFrame:(LPS_Frame *)aFrame at:(int)index;
{
/* Forget all the mustard below!
    if (index<MAX_SPACE_DIMENSION) {
	int i, c=[aKernel count];
    
	myFrame[index] = *aFrame;
    
	for (i=0; i<c; i++){
	    if (![self frameContains:[myKernel objectAt:i]])
		[[myKernel removeObjectAt:i] free];
	}
    }
*/
    return [super setFrame:aFrame at:index];
}

#if 0
- (double)splitOriginAt:(int) index;
{
    return mySplitFrame[index].origin;
}


- (double)splitEndAt:(int)index;
{
    return mySplitFrame[index].end;
}


- setSplitOriginAt:(int)index to:(double)initial;
{
    if((initial >= myFrame[index].origin) && (initial < myFrame[index].end))
	mySplitFrame[index].origin = initial;
 
    [self invalidate];
    return self;
}


- setSplitEndAt:(int)index to:(double)final;
{
    if((final > myFrame[index].origin) && (final <= myFrame[index].end))
	mySplitFrame[index].end = final;

    [self invalidate];
    return self;
}


- (BOOL)initialActivationAt:(int)index;
{
    return myInitialActivation & (1<<index);
}


- (BOOL)finalActivationAt:(int)index;
{
    return myFinalActivation & (1<<index);
}


- setInitialActivationAt:(int)index to:(BOOL)flag;
{
    if (flag)
	myInitialActivation =  myInitialActivation |  1<<index;
    else
	myInitialActivation =  myInitialActivation & ~(1<<index);
    [self invalidate];
    return self;
}


- setFinalActivationAt:(int)index to:(BOOL)flag;
{
    if (flag)
	myFinalActivation =  myFinalActivation |  1<<index;
    else
	myFinalActivation =  myFinalActivation & ~(1<<index);
    [self invalidate];
    return self;
}

#endif



@end
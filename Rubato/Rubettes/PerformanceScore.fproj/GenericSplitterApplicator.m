/* GenericSplitterApplicator.m */

#import "GenericSplitterApplicator.h"
#import "GenericSplitter.h"

@implementation GenericSplitterApplicator


- init;
{
    [super init];
    return self;
}


- initFromLPS:anLPS;
{
    [super initFromLPS:anLPS];
    [self setFrameToLPS:anLPS];
    return self;
}


- takeSplitFrameFrom:sender;
{
    int i;
    if (sender==mySplitFrameMatrix) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    [self setSplitOriginAt:i to:[[sender cellWithTag:i] doubleValue]];
	    [myOperator setSplitOriginAt:i to:[self splitOriginAt:i]];
	    [self setSplitEndAt:i to:[[sender cellWithTag:i+MAX_SPACE_DIMENSION] doubleValue]];
	    [myOperator setSplitEndAt:i to:[self splitOriginAt:i]];
	}
    if (sender==myInitialActivMatrix) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    [self setInitialActivationAt:i to:[[sender cellWithTag:i] intValue]];
	    [myOperator setInitialActivationAt:i to:[self initialActivationAt:i]];
	    [[mySplitFrameMatrix cellWithTag:i] setEnabled:[self initialActivationAt:i]];
	}
    if (sender==myFinalActivMatrix) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    [self setFinalActivationAt:i to:[[sender cellWithTag:i] intValue]];
	    [myOperator setFinalActivationAt:i to:[self finalActivationAt:i]];
	    [[mySplitFrameMatrix cellWithTag:+MAX_SPACE_DIMENSION] setEnabled:[self finalActivationAt:i]]; // jg findCell... -> cell
	}
    [self displayValues:self];
    return self;
}


- collectValues:sender;
{
    int i;
    if ([mySplitFrameMatrix respondsToSelector:@selector(cellWithTag:)]) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    [self setSplitOriginAt:i to:[[mySplitFrameMatrix cellWithTag:i] doubleValue]];
	    [myOperator setSplitOriginAt:i to:[self splitOriginAt:i]];
	    
	    [self setSplitEndAt:i to:[[mySplitFrameMatrix cellWithTag:i+MAX_SPACE_DIMENSION] doubleValue]];
	    [myOperator setSplitEndAt:i to:[self splitEndAt:i]];
	}
    if ([myInitialActivMatrix respondsToSelector:@selector(cellWithTag:)]) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    [self setInitialActivationAt:i to:[[myInitialActivMatrix cellWithTag:i] intValue]];
	    [myOperator setInitialActivationAt:i to:[self initialActivationAt:i]];
	}
    if ([myFinalActivMatrix respondsToSelector:@selector(cellWithTag:)]) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    [self setFinalActivationAt:i to:[[myFinalActivMatrix cellWithTag:i] intValue]];
	    [myOperator setFinalActivationAt:i to:[self finalActivationAt:i]];
	}
    return [super collectValues:sender];
}


- displayValues:sender;
{
    int i;
    if ([mySplitFrameMatrix respondsToSelector:@selector(cellWithTag:)]) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    [[mySplitFrameMatrix cellWithTag:i] setDoubleValue:[self splitOriginAt:i]];
	    [[mySplitFrameMatrix cellWithTag:i+MAX_SPACE_DIMENSION] setDoubleValue:[self splitEndAt:i]];
	}
    if ([myInitialActivMatrix respondsToSelector:@selector(cellWithTag:)]) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    [[myInitialActivMatrix cellWithTag:i] setIntValue:[self initialActivationAt:i]];
	    [[mySplitFrameMatrix cellWithTag:i] setEnabled:[self initialActivationAt:i]];
	}
    if ([myFinalActivMatrix respondsToSelector:@selector(cellWithTag:)]) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    [[myFinalActivMatrix cellWithTag:i] setIntValue:[self finalActivationAt:i]];
	    [[mySplitFrameMatrix cellWithTag:i+MAX_SPACE_DIMENSION] setEnabled:[self finalActivationAt:i]];
	}
    return [super displayValues:sender];
}

- setFrameToLPS:anLPS;
{
    if (anLPS) {
	int index;
	for (index=0; index<MAX_SPACE_DIMENSION; index++) {
	    myFrame[index] = *[anLPS frameAt:index];
	    mySplitFrame[index] = *[anLPS frameAt:index];
	}
	[self displayValues:self];
    }
    return self;
}


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
 
    return self;
}


- setSplitEndAt:(int)index to:(double)final;
{
    if((final > myFrame[index].origin) && (final <= myFrame[index].end))
	mySplitFrame[index].end = final;

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
    return self;
}


- setFinalActivationAt:(int)index to:(BOOL)flag;
{
    if (flag)
	myFinalActivation =  myFinalActivation |  1<<index;
    else
	myFinalActivation =  myFinalActivation & ~(1<<index);
    return self;
}

- operatorClass;
{
    return [GenericSplitter class];
}


@end
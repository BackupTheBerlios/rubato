/*ScalarOperator.m*/

#import "ScalarOperator.h"
#import <Rubette/WeightWatcher.h>
#import <Rubette/space.h>

@implementation ScalarOperator

/* get the operator's nib files */
+ (NSString *)inspectorNibFile;
{
    return @"ScalarOperatorInspector.nib";
}



- init;
{
    [super init];
    [self adjustHierarchy];
    return self;
} 


- setCalcDirectionAt:(int)index to:(BOOL)flag;
{
    if (index<MAX_SPACE_DIMENSION) {
	if (flag)
	    myCalcDirection = myCalcDirection | 1 << index;
	else
	    myCalcDirection = myCalcDirection & ~(1 << index);
    }
    [self invalidate];
    return self;
}


/* specific adjustment */
- adjustHierarchy;
{
    int i;
    BOOL test;
    spaceIndex weightspace = [myWeightWatcher space];
    /* initialize myHierarchy to default values */
    if (myMother) {
	for (i=0; i<Hierarchy_Size;i++) {
	    myHierarchy[i] = [myMother hierarchyAt:i];
	}
    } else {
	for (i=0; i<Hierarchy_Size;i++) {
	    test = YES;
	    test = (i & spaceOfIndex(indexD)) ? test && (i & spaceOfIndex(indexE)) : test;
	    test = (i & spaceOfIndex(indexG)) ? test && (i & spaceOfIndex(indexH)) : test;
	    test = (i & spaceOfIndex(indexC)) ? test && (i & spaceOfIndex(indexL)) : test;
	    myHierarchy[i] = test;
	}
    }
    
    for(i = 0; i<Hierarchy_Size; i++){
	if(
	    (i & mySpace) &&
	    (i != (weightspace | i)) 
	    /* for all i intersecting with mySpace, 
	     * the i must contain the weightspace 
	     */
	    )
	myHierarchy[i] = NO;
	}
    return self;
} 



- validate;
{
    id initialSet;
    [super validate];
    
    //myCalcDirection = mySpace;
    
    initialSet = [[LPSInitialSet newDefaultInitialSetForLPS:self] wrapSelfInList];
    [self extendFrameToInitialSet:initialSet];
    [self setInitialSet:initialSet];
    /* we have to do this since the default set depends on the hierarchy */
    return self;
}

/*get the string representation of the operator*/
- (NSString *)stringValue;
{
    return @"(x)";
}

- (const char*)operatorString;
{
    [myConverter setStringValue:@"Scalar("];
    [myConverter concat:[myMother operatorString]];
    [myConverter concat:")"];
    
    return [[myConverter stringValue] cString];
}



@end
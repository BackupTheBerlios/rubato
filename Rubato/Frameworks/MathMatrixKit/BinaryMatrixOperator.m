/* BinaryMatrixOperator.m */

#import "BinaryMatrixOperator.h"

@implementation BinaryMatrixOperator

- init;
{
    [super init];
    /* class-specific initialization goes here */
    myRightOperand = nil;
    myLeftOperand = nil;
    isCalculated = NO;
    return self;
}

- initWithOperands:leftOperand :rightOperand
{
    [self init];
    [self setLeftOperand:leftOperand];
    [self setRightOperand:rightOperand];
    return self;
}

- (void)dealloc;
{
    /* do NXReference houskeeping */
 
    [myLeftOperand nxrelease];    myLeftOperand = nil;    
    [myRightOperand nxrelease];   myRightOperand = nil;
    [super dealloc];
}


- copyWithZone:(NSZone*)zone;
{
    BinaryMatrixOperator *myCopy = [super copyWithZone:zone];
    myCopy->isCalculated = isCalculated;
    myCopy->myLeftOperand = [myLeftOperand ref];
    myCopy->myRightOperand = [myRightOperand ref];
    return myCopy;
}



- (id)initWithCoder:(NSCoder *)aDecoder;
{
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    myLeftOperand = [[[aDecoder decodeObject] retain] ref];
    myRightOperand = [[[aDecoder decodeObject] retain] ref];
    [aDecoder decodeValuesOfObjCTypes:"c", &isCalculated];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myLeftOperand];
    [aCoder encodeObject:myRightOperand];
    [aCoder encodeValuesOfObjCTypes:"c", &isCalculated];
}

- setLeftOperand:leftOperand;
{
    if (leftOperand!=myLeftOperand)
	if ([leftOperand isKindOfClass:[MathMatrix class]] || !leftOperand) {
	    [myLeftOperand nxrelease];
	    myLeftOperand = leftOperand;
	    [myLeftOperand ref];
	    isCalculated = NO;
	}
    return self;
}

- leftOperand;
{
    return myLeftOperand;
}

- setRightOperand:rightOperand;
{
    if (rightOperand!=myRightOperand)
	if ([rightOperand isKindOfClass:[MathMatrix class]] || !rightOperand) {
	    [myRightOperand nxrelease];
	    myRightOperand = rightOperand;
	    [myRightOperand ref];
	    isCalculated = NO;
	}
    return self;
}

- rightOperand;
{
    return myRightOperand;
}

- setOperands:leftOperand :rightOperand;
{
    [self setLeftOperand:leftOperand];
    [self setRightOperand:rightOperand];
    return self;
}


- (selfvoid)setToEmptyCopyOfMatrix:aMatrix;
{
    [super setToEmptyCopyOfMatrix:aMatrix];
    isCalculated = NO;
}


- (id)emancipateWithMaxRetainCount:(unsigned int)maxRetainCount;
{
    BinaryMatrixOperator* emancipated = [super emancipateWithMaxRetainCount:maxRetainCount];
    [emancipated setOperands:nil :nil];
    emancipated->isCalculated = YES;
    return emancipated;
}

- (BOOL)isEmancipatedWithMaxRetainCount:(unsigned int)maxRetainCount;
{
  return [super isEmancipatedWithMaxRetainCount:maxRetainCount] && !myLeftOperand && !myRightOperand;
}

- (BOOL)isCalculated;
{
    return isCalculated && 
	    (!myLeftOperand || [myLeftOperand isCalculated]) && 
	    (!myRightOperand || [myRightOperand isCalculated]);
}

- (selfvoid)calculate;
{
    if ((!myLeftOperand || [myLeftOperand respondsToSelector:@selector(calculate)]) &&
	(!myRightOperand || [myRightOperand respondsToSelector:@selector(calculate)])) {
        
//        if ((!myLeftOperand || [[myLeftOperand calculate] isCalculated]) &&
//	    (!myRightOperand || [[myRightOperand calculate] isCalculated]) &&
//	    !isCalculated)
// folded out:
        BOOL success=YES;
        if (myLeftOperand) {
          [myLeftOperand calculate];
          success=[myLeftOperand isCalculated];
        }
        if (success && myRightOperand) {
          [myRightOperand calculate];
          success=[myRightOperand isCalculated];
        }
        if (success && !isCalculated) {
	    [self doCustomCalculation];
        }
    }
}

- calculateWith:leftOperand :rightOperand;
{
    [self setLeftOperand:leftOperand];
    [self setRightOperand:rightOperand];
    [self calculate];
    return self;
}

- recalculate;
{
    if ((!myLeftOperand || [myLeftOperand respondsToSelector:@selector(calculate)]) &&
	(!myRightOperand || [myRightOperand respondsToSelector:@selector(calculate)])) {
//	if ((!myLeftOperand || [myLeftOperand calculate]) &&
//	    (!myRightOperand || [myRightOperand calculate]))
//	    [self doCustomCalculation];

        if (myLeftOperand) {
          [myLeftOperand calculate];
        }
        if (myRightOperand) {
          [myRightOperand calculate];
        }	    
        [self doCustomCalculation];
    }
    return self;
}

- doCustomCalculation;
{
    isCalculated = YES;
    return self;
}

- result;
{
    return [self isCalculated] ? self : nil;
}

- undo;
{
    if (myLeftOperand) {
	[myLeftOperand ref];
	[self nxrelease];
	[myLeftOperand deRef];
	return myLeftOperand;
    }
    return self;
}

@end
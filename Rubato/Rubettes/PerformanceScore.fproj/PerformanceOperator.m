/*PerformanceOperator.m*/

#import "PerformanceOperator.h"
#import "PerformanceScore.h"
#import "PerformanceOperatorApplicator.h"
#import <Rubette/space.h>

@implementation PerformanceOperator

/* standard class methods to be overridden */
+ (void)initialize 
{
    [super initialize];
    if (self == [PerformanceOperator class]) {
	[PerformanceOperator setVersion:3];
    }
    return;
}

/* get the operator's nib file */
+ (NSString *)inspectorNibFile;
{
    return @"PerformanceOperatorInspector.nib";
}

/*apply operator on a LPS*/
+ applyTo:anLPS;
{
    int index;
    
    /* check whether this operator was already applied to anLPS.
     * If not, execute the operator application, else do nothing
     * and return nil to notify non-execution.
     */
    for (index = 0; index<[anLPS daughterCount] 
	    && [[anLPS daughterAt:index]operator]!=self; index++);

    if (index==[anLPS daughterCount]) {
	id applicator = [[[self applicatorClass]alloc]initFromLPS:anLPS];
	
	if ([applicator runDialog]) {
	    [self apply:applicator to:anLPS];
    
	    [applicator release];
            applicator = nil;
	    return self;
	}
	[applicator release];
        applicator = nil;
    }
    
    return nil;
}

+ apply:applicator to:anLPS;
{
    int index;
    id theDaughter = [anLPS makeDaughterWithOperator:self];

    [theDaughter setOperatorIndex:1];
    [theDaughter adjustHierarchy];

    if (applicator && strlen([applicator nameString]) )
	[[theDaughter getNameString] setStringValue:[NSString jgStringWithCString:[applicator nameString]]];
	
    /* not neccessary, already set by mother*/
    [theDaughter setInitialSet:[anLPS initialSet]];
    for (index=0; index<MAX_SPACE_DIMENSION; index++) {
	[theDaughter setFrame:[anLPS frameAt:index] at:index];
	[theDaughter setFieldTranslationAt:index 
		to:[applicator fieldTranslationAt:index]];
	[theDaughter setFieldDilatationAt:index 
		to:[applicator fieldDilatationAt:index]];
    }
    [theDaughter setSpaceTo:[applicator space]];
    //[theDaughter setKernel:[anLPS kernel]];
    //[theDaughter setInstrument:[anLPS instrument]];

    return self;
}

+ applicatorClass;
{
    return [PerformanceOperatorApplicator class];
}


/* Import the standard SpaceProtocolMethods */
#import "SpaceProtocolMethods.m"

/* standard object methods to be overridden */
- init;
{
    int i;
    [super init];
    /* class-specific initialization goes here */
    [myName setStringValue:NSStringFromClass([self class])];
    myConverter = [[StringConverter alloc]init];
    [self setWeightWatcher: [[WeightWatcher alloc]init]];
    myCalcDirection = 63; /* total EHLDGC space */
    mySpace = 0;
    for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	fieldTranslation[i] = 0.0;
	fieldDilatation[i] = 1.0;
	if(i<MAX_BASIS_DIMENSION) fieldIsParallel[i]=NO; 
    }
    return self;
}

- (void)dealloc;
{
    /* do NXReference houskeeping */

    /* class-specific initialization goes here */
    [myConverter release];
    myConverter = nil;
    [myWeightWatcher release];
    myWeightWatcher = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    int i, classVersion = [aDecoder versionForClassName:NSStringFromClass([PerformanceOperator class])];
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    myWeightWatcher = [[aDecoder decodeObject] retain];
    
    [aDecoder decodeValuesOfObjCTypes:"ic",  &myOperatorIndex, &mySpace];
    
    [aDecoder decodeArrayOfObjCType:"d" count:MAX_SPACE_DIMENSION at:&fieldTranslation];
    [aDecoder decodeArrayOfObjCType:"d" count:MAX_SPACE_DIMENSION at:&fieldDilatation];
    
    if(classVersion>2)
	[aDecoder decodeArrayOfObjCType:"c" count:MAX_BASIS_DIMENSION at:&fieldIsParallel];
    else
	for (i=0; i<MAX_BASIS_DIMENSION; i++)
	    fieldIsParallel[i]=NO; 
    
    if(classVersion>1)
    	[aDecoder decodeValueOfObjCType:"c" at:&myCalcDirection];

    myConverter = [[StringConverter alloc]init];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeObject:myWeightWatcher];

    [aCoder encodeValuesOfObjCTypes:"ic",  &myOperatorIndex, &mySpace];
    
    [aCoder encodeArrayOfObjCType:"d" count:MAX_SPACE_DIMENSION at:&fieldTranslation];
    [aCoder encodeArrayOfObjCType:"d" count:MAX_SPACE_DIMENSION at:&fieldDilatation];
    [aCoder encodeArrayOfObjCType:"c" count:MAX_BASIS_DIMENSION at:&fieldIsParallel];
   
    [aCoder encodeValueOfObjCType:"c" at:&myCalcDirection];
}


/* managing operator parameters */
- (spaceIndex)calcDirection;
{
    return myCalcDirection;
}

- setFieldDilatationAt:(int)index to:(double)aDouble;
{
    if (index<MAX_SPACE_DIMENSION) {
	if ((aDouble || fieldTranslation[index]) && fieldDilatation[index] != fabs(aDouble)) {
	    fieldDilatation[index] = fabs(aDouble);
	    [self invalidate];
	}
    }
    return self;
}

- (double)fieldDilatationAt:(int)index;
{
    if (index<MAX_SPACE_DIMENSION)
	return fieldDilatation[index];
    else
	return 1.0;
}

- setFieldTranslationAt:(int)index to:(double)aDouble;
{
    if (index<MAX_SPACE_DIMENSION) {
	if ((aDouble || fieldDilatation[index]) && fieldTranslation[index] != fabs(aDouble)) {
	    fieldTranslation[index] = fabs(aDouble);
	    [self invalidate];
	}
    }
    return self;
}

- (double)fieldTranslationAt:(int)index;
{
    if (index<MAX_SPACE_DIMENSION)
	return fieldTranslation[index];
    else
	return 0.0;
}


- setFieldIsParallelAt:(int)index to:(BOOL)flag;
{
    if (index<MAX_SPACE_DIMENSION) {
	if (fieldIsParallel[index] != flag) {
	    fieldIsParallel[index] = flag;
	    [self invalidate];
	}
    }
    return self;
}

- (BOOL)fieldIsParallelAt:(int)index;
{
    if (index<MAX_SPACE_DIMENSION)
	return fieldIsParallel[index%MAX_BASIS_DIMENSION];
    else
	return 0.0;
}


- setWeightWatcher:aWeightWatcher; /*can only be set once*/
{
    if (!myWeightWatcher && [aWeightWatcher isKindOfClass:[WeightWatcher class]]
	&& [aWeightWatcher setOwnerLPS:self]) {
	myWeightWatcher = aWeightWatcher;
	[self invalidate];
    }
    return self;
}

- weightWatcher;
{
    return myWeightWatcher;
}


- operator;
{
    return [self class];
}

- setOperatorIndex:(int)index;
{
    myOperatorIndex = index;
    return self;
}

- (int)operatorIndex;
{
    return myOperatorIndex;
}

/* operator-specific hierarchy recalculation */
- adjustHierarchy;
{
    /* to be implemented by subclasses */
    return self;
}

/* maintain calc optimization */
- (void)weightWatcherChanged;
{
    [self invalidate];
}


/*get the string representation and version of the operator*/
- (NSString *)stringValue;
{
    return @"(x)";
}

- (const char*)operatorString;
{
    [myConverter setStringValue:@"("];
    [myConverter concat:[myMother operatorString]];
    [myConverter concat:")"];
    
    return [[myConverter stringValue] cString];
}

- (const char*)versionString;
{
   [myConverter setIntValue:[[self class] version]];
   return [[myConverter stringValue] cString];
}

/* Calculate the Field of an Operator */
- calcPerformanceField:(double *)field at:anEvent;
{
    int i, d, di = [anEvent dimension];
    double sum = [myWeightWatcher weightSumAt:anEvent];
    [anEvent ref];

    /* First calculate all values without dilatation and translation ! */

    for (d=0; d<di; d++) {
	i = [anEvent indexOfDimension:d+1];
	if([self hierarchyTopAt:i]){
	    if(i<MAX_BASIS_DIMENSION || ![self fieldIsParallelAt:i]) {
		if([self directionAt:i]) /* basis coordinates or not parallel */
		    field[d] *= sum;

		continue; /* go to next coordinate */				
	    }
	    else { /* parallel pianola coordinates */
		id alterateEvent = [[anEvent alterate]ref];
		int b = [anEvent dimensionOfIndex:i-MAX_BASIS_DIMENSION];
		if(!([self directionAt:i] && [self directionAt:i-MAX_BASIS_DIMENSION])){
		    field[d] = [myMother calcFieldComponent:i-MAX_BASIS_DIMENSION at:alterateEvent];
		    /* now, field[d] is the alterated field of the mother */
		    if([self directionAt:i])
			field[d] = 2*sum*field[d] - field[b];
			/* attention: field[b] is already the new, weight-scaled one ! */
    
		    if([self directionAt:i-MAX_BASIS_DIMENSION])
			field[d] = 2*[myWeightWatcher weightSumAt:alterateEvent]*field[d] - field[b];
			/* attention: field[b] is already the new, weight-scaled one ! */
		    
		    else
			field[d] = 2*field[d] - field[b]; 
		}
		else/* this is the full tempo formula */
		    field[d] = [myWeightWatcher weightSumAt:alterateEvent]*
			    (field[d]+[myMother calcFieldComponent:i-MAX_BASIS_DIMENSION at:anEvent]) 
			    - field[b]; 
		    /* attention: field[b] is already the new, weight-scaled one ! */
    
		[alterateEvent release];
	    }
	}
    }

    /* Second calculate the dilatation and translation contributions! */
    for (d=0; d<di; d++) {
	i = [anEvent indexOfDimension:d+1];
	if([self hierarchyTopAt:i] && [self directionAt:i]) {
	    field[d] *= fieldDilatation[i];
	    field[d] += fieldTranslation[i];
	}
    }
    
    [anEvent release];
    return self;
}
@end

@implementation PerformanceOperator (SpaceProtocolMethods)
- setSpaceAt:(int)index to:(BOOL)flag;
{
    if ([self spaceAt:index]!=flag && index<MAX_SPACE_DIMENSION) {
	if (flag)
	    mySpace = mySpace | 1 << index;
	else
	    mySpace = mySpace & ~(1 << index);
	[self invalidate];
    }
    return self;
}
- setSpaceTo:(spaceIndex)aSpace;
{
    if (mySpace!=aSpace) {
	mySpace = aSpace;
	[self invalidate];
    }
    return self;
}

@end
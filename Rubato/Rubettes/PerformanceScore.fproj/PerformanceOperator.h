/*PerformanceOperator.h*/

#import "LocalPerformanceScore.h"

@interface PerformanceOperator: LocalPerformanceScore <SpaceProtocol>
{
    int	myOperatorIndex;	/* in case where several daugthers are produced */
    id	myWeightWatcher;	/* WeightWatcher object for Operator*/
    id	myConverter;		/*a StringConverter object*/
    spaceIndex myCalcDirection;	/* Space where performance caluclation is effective */
    spaceIndex mySpace;		/* Space where field rescaling is effective */
    double fieldTranslation[MAX_SPACE_DIMENSION];
    double fieldDilatation[MAX_SPACE_DIMENSION];
    BOOL   fieldIsParallel[MAX_BASIS_DIMENSION];
}

/* standard class methods to be overridden */
+ (void)initialize;

/* get the operator's nib file */
+ (NSString *)inspectorNibFile;

/*apply operator on a LPS*/
+ applyTo:anLPS;
+ apply:applicator to:anLPS;
+ applicatorClass;

/* standard object methods to be overridden */
- init;
- (void)dealloc;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

/* managing operator parameters */
- (spaceIndex)calcDirection;
- setFieldDilatationAt:(int)index to:(double)aDouble;
- (double)fieldDilatationAt:(int)index;
- setFieldTranslationAt:(int)index to:(double)aDouble;
- (double)fieldTranslationAt:(int)index;
- setFieldIsParallelAt:(int)index to:(BOOL)flag;
- (BOOL)fieldIsParallelAt:(int)index;

- setWeightWatcher:aWeightWatcher; /*can only be set once*/
- weightWatcher;

- operator;
- setOperatorIndex:(int)index;
- (int)operatorIndex;

/* operator-specific hierarchy recalculation */
- adjustHierarchy;

/* maintain calc optimization */
- (void)weightWatcherChanged;

/*get the string representation of the operator*/
- (NSString *)stringValue;
- (const char*)operatorString;
- (const char*)versionString;

/* Calculate the Field of an Operator */
- calcPerformanceField:(double *)field at:anEvent;

@end
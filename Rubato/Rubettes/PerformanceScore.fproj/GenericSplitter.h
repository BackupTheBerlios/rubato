/* GenericSplitter.h */

#import "PerformanceOperator.h"

#define CHANGE_DAUGHTER_INDEX 1
#define REMAINDER_DAUGHTER_INDEX 2

@interface GenericSplitter:PerformanceOperator
{
//    LPS_Frame mySplitFrame[MAX_SPACE_DIMENSION];
    spaceIndex myInitialActivation;
    spaceIndex myFinalActivation;
}

/* get the operator's nib files */
+ (NSString *)inspectorNibFile;

/*apply operator on a LPS*/
+ apply:applicator to:anLPS;

- init;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

/* operator sets kernel under restriction of frame */
- setKernel:aKernel;

- setFrame:(LPS_Frame *)aFrame at:(int)index;

#if 0
- (double)splitOriginAt:(int)index;
- (double)splitEndAt:(int)index;

- setSplitOriginAt:(int)index to:(double)initial;
- setSplitEndAt:(int)index to:(double)final;

- (BOOL)initialActivationAt:(int)index;
- (BOOL)finalActivationAt:(int)index;

- setInitialActivationAt:(int)index to:(BOOL)flag;
- setFinalActivationAt:(int)index to:(BOOL)flag;
#endif

@end
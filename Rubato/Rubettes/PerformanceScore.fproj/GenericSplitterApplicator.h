/* GenericSplitterApplicator.h */

#import "PerformanceOperatorApplicator.h"



@interface GenericSplitterApplicator:PerformanceOperatorApplicator
{
    
    id	mySplitFrameMatrix;
    id	myInitialActivMatrix;
    id	myFinalActivMatrix;
    LPS_Frame myFrame[MAX_SPACE_DIMENSION];
    LPS_Frame mySplitFrame[MAX_SPACE_DIMENSION];
    spaceIndex myInitialActivation;
    spaceIndex myFinalActivation;
}

- init;
- initFromLPS:anLPS;

- takeSplitFrameFrom:sender;
- collectValues:sender;

- setFrameToLPS:anLPS;

- (double)splitOriginAt:(int)index;
- (double)splitEndAt:(int)index;

- setSplitOriginAt:(int)index to:(double)initial;
- setSplitEndAt:(int)index to:(double)final;

- (BOOL)initialActivationAt:(int)index;
- (BOOL)finalActivationAt:(int)index;

- setInitialActivationAt:(int)index to:(BOOL)flag;
- setFinalActivationAt:(int)index to:(BOOL)flag;

- operatorClass;

@end
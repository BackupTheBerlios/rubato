
#import "GenericOperatorInspector.h"

@interface LPSInspector:GenericOperatorInspector
{
/*
    id	myMother;
    id	myDaughters;
    id	myInstrument;

    id myInitialSet;

    BOOL myHierarchy[Hierarchy_Size];

    NXRect myFrame[3];


    id	myKernel;
    performedEvent *myPerformanceKernel;
    int	countKernel;
*/
    id myFrameMatrix;

}

- init;
- (void)dealloc;

- setValue:sender;
- displayPatient:sender;

@end


#import "LPSInspector.h"
#import "LocalPerformanceScore.h"

@implementation LPSInspector

- init
{
    [super init];
    /* class-specific initialization goes here */
    return self;
}


- (void)dealloc
{
    /* class-specific initialization goes here */
    { [super dealloc]; return; };
}

- setValue:sender;
{
    return [super setValue:sender];
}

- displayPatient: sender
{
    int i;
    LPS_Frame frame;
    for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	frame = *[patient frameAt:i];
	[[myFrameMatrix cellAtRow:i column:0] setDoubleValue:frame.origin];
	[[myFrameMatrix cellAtRow:i column:1] setDoubleValue:frame.end];
    }
    return [super displayPatient:sender];
}


@end


#import "LPSView.h"
#import <Rubato/RubatoTypes.h>
#import <Rubette/MatrixEvent.h>
#import <PerformanceScore/LocalPerformanceScore.h>

@implementation LPSView


- setViewToLPSFrame:sender;
{
    [self setKernelFrame:myLPS];
    [self setNeedsDisplay:YES];
    return self;
}

- setShowPerformedKernel:sender;
{
    if ([sender respondsToSelector:@selector(intValue)]) {
	showPerformedKernel = (BOOL)[sender intValue];
	[self displayLPS:myLPS];
    }
    return self;
}

- displayLPS:anLPS;
{
    if (myLPS != anLPS) {
	[myLPS release];
	myLPS = anLPS;
	[myLPS ref];
    }
    if (showPerformedKernel)
	[self displayEventList:[myLPS performanceKernel]];
    else
	[self displayEventList:[myLPS kernel]];
    return self;
}

@end

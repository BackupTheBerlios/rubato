
#import <AppKit/AppKit.h>
#import "KernelView.h"

@interface LPSView:KernelView
{
    id	myLPS;
    BOOL showPerformedKernel;
    
}

- setViewToLPSFrame:sender;
- setShowPerformedKernel:sender;
- displayLPS:anLPS;

@end


#import "GenericOperatorInspector.h"
#import "PerformanceOperator.h"


@implementation GenericOperatorInspector

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


- displayPatient: sender
{
    [operatorStringField setStringValue:[NSString jgStringWithCString:[patient  operatorString]]];
    return [super displayPatient:sender];
}



@end


#import "WeightInspector.h"
#import "Weight.h"
#import "WeightView.h"


@implementation WeightInspector

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


- (void)setValue:(id)sender;
{
    id realSender = sender;
    if (realSender==myInvertSwitch) 
	[patient setInversion:[sender intValue]];
    
    if ([sender respondsToSelector:@selector(selectedCell)])
	realSender = [sender selectedCell];
    if (realSender==myToleranceField) 
	[patient setTolerance:[sender doubleValue]];
    if (realSender==myLowNormField) 
	[patient setLowNorm:[sender doubleValue]];
    if (realSender==myHighNormField) 
	[patient setHighNorm:[sender doubleValue]];
//    if (realSender==drawLinesSwitch)
//      ;// nothing
    [super setValue:sender];
}

- displayPatient: sender
{
    int i;
    NSMutableString *string=[NSMutableString new];
    [patient writeParametersToString:string];
    
    [myToleranceField setDoubleValue:[patient tolerance]];
    [myLowNormField setDoubleValue:[patient lowNorm]];
    [myHighNormField setDoubleValue:[patient highNorm]];
    [myInvertSwitch setDoubleValue:[patient isInverted]];
    [myMinField setDoubleValue:[patient minWeight]];
    [myMaxField setDoubleValue:[patient maxWeight]];
    [myMeanField setDoubleValue:[patient meanWeight]];
    [myNormMeanField setDoubleValue:[patient meanNormalizedWeight]];
    
    for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	[[myFrameMatrix cellAtRow:i column:0] setDoubleValue:[patient originAt:i]];
	[[myFrameMatrix cellAtRow:i column:1] setDoubleValue:[patient endAt:i]];
    }
    
    [myWeightParametersText setString:string];
    
    [myWeightView displayWeight:patient withInversion:[patient isInverted] andDeformation:[myDeformationField doubleValue]];


    return [super displayPatient:sender];
}



@end

#import "TempoOperatorInspector.h"

#import <Rubato/RubatoTypes.h>
#import <Rubette/SpaceProtocol.h>

#import "TempoOperator.h"

@implementation TempoOperatorInspector


- setValue:sender
{
    id realSender = sender;
// jg: Yes there are NSMatrix senders!
   if ([sender respondsToSelector:@selector(selectedCell)])
	realSender = [sender selectedCell];
    
    if (realSender==myAverageTempoField) 
	[patient setAverageTempo:[realSender doubleValue]];
    if (realSender==myIntegrationStepsField) 
	[patient setIntegrationSteps:[realSender intValue]];
    if (realSender==myApproximationStepsField) 
	[patient setApproximationSteps:[realSender intValue]];
    
    if (realSender==myAdaptationStartField) 
	[patient setAdaptationFrameAt:0 to:[realSender doubleValue]];
    if (realSender==myAdaptationEndField) 
	[patient setAdaptationFrameAt:1 to:[realSender doubleValue]];
    
    if (realSender==myHNeighborhoodField) 
	[[[[patient initialSet]initialSetAt:0]simplex]setNeighborhood:[realSender doubleValue]];
    if (realSender==myVNeighborhoodField) 
	[[[[patient initialSet]initialSetAt:1]simplex]setNeighborhood:[realSender doubleValue]];
    if (realSender==myONeighborhoodField) 
	[[patient currentOriginSimplex]setNeighborhood:[realSender doubleValue]];
	
    if (realSender==(id)[myCalcMethodPopUpBtn selectedItem]) 
	[patient setIntegrationMethod:[realSender tag]];
    return [super setValue:sender];
}


- displayPatient: sender
{
    [myAverageTempoField setDoubleValue:[patient averageTempo]];
    [myIntegrationStepsField setIntValue:[patient integrationSteps]];
    [myApproximationStepsField setIntValue:[patient approximationSteps]];
    [myErrorField setDoubleValue:[patient error]];

    [myAdaptationStartField setDoubleValue:[patient adaptationFrameStart]];
    [myAdaptationEndField setDoubleValue:[patient adaptationFrameEnd]];

    [myHNeighborhoodField setDoubleValue:[[[[patient initialSet]initialSetAt:0]simplex]neighborhood]];
    [myVNeighborhoodField setDoubleValue:[[[[patient initialSet]initialSetAt:1]simplex]neighborhood]];
    [myONeighborhoodField setDoubleValue:[[patient currentOriginSimplex]neighborhood]];

    [myCalcMethodPopUpBtn selectItemAtIndex:[myCalcMethodPopUpBtn indexOfItemWithTag:[patient integrationMethod]]];
    [myCalcMethodPopUpBtn setTitle:[[myCalcMethodPopUpBtn selectedItem] title]];
        
    return [super displayPatient:sender];
}


@end

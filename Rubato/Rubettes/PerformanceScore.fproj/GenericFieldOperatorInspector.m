#import "GenericFieldOperatorInspector.h"

#import "GenericFieldOperator.h"

@implementation GenericFieldOperatorInspector


- setValue:sender
{
    id realSender = sender;
// jg popups do not react to selectedCell.
// jg 25.9.01 but NSMatrix still do.
    if ([sender respondsToSelector:@selector(selectedCell)])
	realSender = [sender selectedCell];
    
    if (realSender==myAbsIntegrationErrorField) 
	[patient setAbsIntegrationError:[realSender doubleValue]];
    if (realSender==myRelIntegrationErrorField) 
	[patient setRelIntegrationError:[realSender doubleValue]];
    if (realSender==myMachineEpsilonField)
	[patient setMachepsilon:[realSender doubleValue]];
    if (realSender==myCmaxField) 
	[patient setCmax:[realSender intValue]];
    if (realSender==myLimitField) 
	[patient setLimit:[realSender intValue]];
    if (sender==myBackwardTimeGuessSwitch) 
	[patient setDoBackwardTimeGuess:[realSender intValue]];
    if (sender==myForwardTimeGuessSwitch) 
	[patient setDoForwardTimeGuess:[realSender intValue]];
    return [super setValue:sender];
}


- displayPatient: sender
{
    id abortedKernel = [patient abortedKernel];
    int i, success, abortCount = [abortedKernel count];

    [myAbsIntegrationErrorField setDoubleValue:[patient absIntegrationError]];
    [myRelIntegrationErrorField setDoubleValue:[patient relIntegrationError]];
    [myMachineEpsilonField setDoubleValue:[patient machEpsilon]];
    [myCmaxField setIntValue:[patient Cmax]];
    [myLimitField setIntValue:[patient limit]];
    [myBackwardTimeGuessSwitch setIntValue:[patient doBackwardTimeGuess]];
    [myForwardTimeGuessSwitch setIntValue:[patient doForwardTimeGuess]];

    for (success=0; success<5; success++) 
	[[mySuccessForm cellAtIndex:success] setIntValue:0];
    for (i=0; i<abortCount; i++) {
	switch (success=[[abortedKernel objectAt:i]doubleValue]) {
	    case 1:/* aborting before integrating (not used while integrating) */		
	    case 2:/* aborting by hit failure (not used while integrating) */	
	    case 3:/* too many function calls */
	    case 4:/* tolerance is too tight */
	    case 5:/* accuracy is too demanding */
		[[mySuccessForm cellAtIndex:success-1] setIntValue:[[mySuccessForm cellAtIndex:success-1] intValue]+1];
		break;
	}
    }
    [[myStatisticsForm cellAtIndex:0] setIntValue:[[patient kernel]count]];
    [[myStatisticsForm cellAtIndex:1] setIntValue:[patient hashTableSize]];
    [[myStatisticsForm cellAtIndex:2] setIntValue:[patient hashHits]];
    [[myStatisticsForm cellAtIndex:3] setIntValue:[patient calcCount]];
    [[myStatisticsForm cellAtIndex:4] setIntValue:[patient hitPointCalls]];
    
    return [super displayPatient:sender];
}


@end

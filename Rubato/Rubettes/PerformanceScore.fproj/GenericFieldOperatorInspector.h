
#import <AppKit/AppKit.h>
#import "PerformanceOperatorInspector.h"

@interface GenericFieldOperatorInspector:PerformanceOperatorInspector
{
    id	myAbsIntegrationErrorField;
    id	myRelIntegrationErrorField;
    id	myMachineEpsilonField;
    id	myCmaxField;
    id	myLimitField;
    id	myBackwardTimeGuessSwitch;
    id	myForwardTimeGuessSwitch;
    
    id	mySuccessForm;
    id	myStatisticsForm;
}


- (void)setValue:(id)sender;
- displayPatient:sender;

@end

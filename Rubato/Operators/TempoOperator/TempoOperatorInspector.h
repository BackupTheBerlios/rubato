
#import <AppKit/AppKit.h>
#import <PerformanceScore/GenericFieldOperatorInspector.h>

@interface TempoOperatorInspector:GenericFieldOperatorInspector
{
    id	myAverageTempoField;
    id	myIntegrationStepsField;
    id	myApproximationStepsField;
    id	myErrorField;
    id	myHNeighborhoodField;
    id	myVNeighborhoodField;
    id	myONeighborhoodField;
    id	myCalcMethodPopUpBtn;
    id	myAdaptationStartField;
    id	myAdaptationEndField;
}


- (void)setValue:(id)sender;
- displayPatient:sender;

@end

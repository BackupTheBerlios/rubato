/* PerformanceOperatorInspector.h */

#import "LPSInspector.h"

@interface PerformanceOperatorInspector:LPSInspector
{
    id	directionMatrix;
    id	distributionMatrix;
    id	parallelFieldMatrix;
}

- (void)setValue:(id)sender;
- displayPatient:sender;

@end

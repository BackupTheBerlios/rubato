/* PerformanceOperatorInspector.h */

#import "LPSInspector.h"

@interface PerformanceOperatorInspector:LPSInspector
{
    id	directionMatrix;
    id	distributionMatrix;
    id	parallelFieldMatrix;
}

- setValue:sender;
- displayPatient:sender;

@end

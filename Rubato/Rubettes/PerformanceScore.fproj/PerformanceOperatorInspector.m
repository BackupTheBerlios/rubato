/* PerformanceOperatorInspector.m */

#import "PerformanceOperatorInspector.h"
#import <Rubato/RubatoTypes.h>
#import <Rubette/SpaceProtocol.h>
#import "PerformanceOperator.h"

@implementation PerformanceOperatorInspector

- setValue:sender
{
    int i;
    if (sender==directionMatrix) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) 
	    [patient setSpaceAt:i to:[[sender cellWithTag:i] intValue]];
    if (sender==distributionMatrix) 
	for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	    [patient setFieldTranslationAt:i to:[[sender cellWithTag:i+MAX_SPACE_DIMENSION] doubleValue]];
	    [patient setFieldDilatationAt:i to:[[sender cellWithTag:i] doubleValue]];
	}
    if (sender==parallelFieldMatrix) 
	for (i=0; i<MAX_BASIS_DIMENSION; i++) 
	    [patient setFieldIsParallelAt:i to:[[sender cellWithTag:i] intValue]];
    return [super setValue:sender];
}


- displayPatient: sender
{
    int i;
    id cell;
    BOOL fieldParallel;
    for (i=0; i<MAX_SPACE_DIMENSION; i++) {
	fieldParallel = [patient fieldIsParallelAt:i];
	[[parallelFieldMatrix cellWithTag:i] setIntValue:fieldParallel];
	[[directionMatrix cellWithTag:i] setIntValue:[patient spaceAt:i]];
	
	[cell=[distributionMatrix cellWithTag:i] setDoubleValue:[patient fieldDilatationAt:i]];
	if (i>=MAX_BASIS_DIMENSION) [cell setEnabled:!fieldParallel];
	
	[cell=[distributionMatrix cellWithTag:i+MAX_SPACE_DIMENSION] setDoubleValue:[patient fieldTranslationAt:i]];
	if (i>=MAX_BASIS_DIMENSION) [cell setEnabled:!fieldParallel];
    }
    return [super displayPatient:sender];
}


@end

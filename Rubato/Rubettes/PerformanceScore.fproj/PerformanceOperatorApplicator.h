/* PerformanceOperatorApplicator.h */

#import "GenericOperatorApplicator.h"
#import <Rubato/RubatoTypes.h>
#import <Rubette/SpaceProtocol.h>

@interface PerformanceOperatorApplicator:GenericOperatorApplicator <SpaceProtocol>
{
    spaceIndex mySpace;
    double fieldTranslation[MAX_SPACE_DIMENSION];
    double fieldDilatation[MAX_SPACE_DIMENSION];
    id	directionMatrix;
    id	distributionMatrix;
}

- init;

- collectValues:sender;
- displayValues:sender;

- setFieldDilatationAt:(int)index to:(double)aDouble;
- (double)fieldDilatationAt:(int)index;
- setFieldTranslationAt:(int)index to:(double)aDouble;
- (double)fieldTranslationAt:(int)index;

- operatorClass;

@end

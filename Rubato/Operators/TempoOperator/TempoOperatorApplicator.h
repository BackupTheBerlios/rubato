/* TempoOperatorApplicator.h */

#import <PerformanceScore/GenericSplitterApplicator.h>

@interface TempoOperatorApplicator:GenericSplitterApplicator
{
    double simplexNeighborhood[3];
    id	simplexNeighborhoodForm;
}

- init;

- takeSimplexParameterFrom:sender;

- collectValues:sender;
- displayValues:sender;

- (double)simplexNeighborhoodAt:(int)index;

- operatorClass;

@end

/* TempoOperatorApplicator.m */

#import "TempoOperatorApplicator.h"
#import "TempoOperator.h"

@implementation TempoOperatorApplicator

#define SMPLX_NBRHD 1.0e-6

- init;
{
    int i;
    [super init];
    for (i=0; i<3; i++)
	simplexNeighborhood[i] = SMPLX_NBRHD;
    return self;
}



- takeSimplexParameterFrom:sender;
{
    int i;
    if (sender==simplexNeighborhoodForm)
    if ([sender respondsToSelector:@selector(cellAtIndex:)]) 
	    for (i=0; i<3; i++) 
		simplexNeighborhood[i] = [[simplexNeighborhoodForm cellAtIndex:i] doubleValue];
    
    return self;
}

- collectValues:sender;
{
    int i;
    if ([simplexNeighborhoodForm respondsToSelector:@selector(cellAtIndex:)]) 
	for (i=0; i<3; i++) 
	    simplexNeighborhood[i] = [[simplexNeighborhoodForm cellAtIndex:i] doubleValue];
    
    return [super collectValues:sender];
}

- displayValues:sender;
{
    if ([simplexNeighborhoodForm respondsToSelector:@selector(cellAtIndex:)]){
	int i;
        id cell;
	for (i=0; i<3; i++) {
            cell=[simplexNeighborhoodForm cellAtIndex:i];
	    if ([cell respondsToSelector:@selector(setDoubleValue:)]) 
	       [cell setDoubleValue:simplexNeighborhood[i]];
        }
    }
    return [super displayValues:sender];
}

- (double)simplexNeighborhoodAt:(int)index;
{
    if (index<3)
	return simplexNeighborhood[index];
    return SMPLX_NBRHD;
}

- operatorClass;
{
    return [TempoOperator class];
}

@end

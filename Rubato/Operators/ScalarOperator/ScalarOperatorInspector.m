
#import "ScalarOperatorInspector.h"
#import "ScalarOperator.h"
#import <Rubette/space.h>


@implementation ScalarOperatorInspector

- (void)setValue:(id)sender;
{
    if (sender==myCalcDirectionMatrix) {
      NSCell *cell;
      NSAssert([sender respondsToSelector:@selector(selectedCell)],@"ScalarOperatorInspector error");
      cell=[sender selectedCell];
      [patient setCalcDirectionAt:[cell tag] to:[cell intValue]];
    }
    [super setValue:sender];
}


- displayPatient: sender
{
    int i;
    for (i=0; i<MAX_SPACE_DIMENSION; i++)
	[[myCalcDirectionMatrix cellWithTag:i] setIntValue:[patient calcDirection]&spaceOfIndex(i)];
    return [super displayPatient:sender];
}


@end

/* WeightWatcherView.h */

#import <AppKit/NSView.h>
#import <AppKit/NSPopUpButton.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>

#import <Rubato/RubatoTypes.h>
#import "WeightyView.h"

@interface WeightWatcherView:WeightyView
{
    id	myWeightWatcher;
}

- initWithFrame:(NSRect)frameRect;
- (void)dealloc;
- (void)displayWeightWatcher:aWeightWatcher;

- (double)weightValueAtEvent:(id)event;
- (void)setCustomValues;
- (void)customDrawDim1;
- (void)customDrawDim2;
@end

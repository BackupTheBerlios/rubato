/* WeightView.h */

#import <AppKit/NSView.h>
#import <AppKit/NSPopUpButton.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubato/RubatoTypes.h>
#import "WeightyView.h"

@interface WeightView:WeightyView
{
    id	myWeight; // retained argument of displayWeight
//    id	theWeight; // weight to which display options are applied (modified copy of myWeight)
    BOOL	invertWeight; // flag of displayWeight:withInversion:flag andDeformation:
  double	deformationFactor;

}
- initWithFrame:(NSRect)frameRect;
- (void)dealloc;
- (void)displayWeight:aWeight;
- (void)displayWeight:aWeight withInversion:(BOOL)flag andDeformation:(double)deform;

- (void)drawDim1NoDeformation;

// overridden
- (double)weightValueAtEvent:(id)event;
- (void)setCustomValues;
- (void)customDrawDim1;
- (void)customDrawDim2;
- (void)drawDim1; // chooses drawDim1NoDeformation if !deform
@end

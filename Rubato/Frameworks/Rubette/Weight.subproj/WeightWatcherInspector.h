/* WeightWatcherInspector */

#import <AppKit/AppKit.h>

@protocol LPSEditedProtocol
- (void)setLPSEdited:(BOOL)yn;
@end

@interface WeightWatcherInspector : JgObject
{
    id	owner;
    id	myWeightWatcher;
    id	myWeightListManager;
    
    id	myInspectorPanel;
    id	myWeightView;
    id	myWeightViewPanel;
    id	myWeightSumView;
    id	myWeightSumViewPanel;

    id	myNameField;
    id	myBaryWeightField;
    id	myDeformationField;
     id	myToleranceField;
    id	myLowNormField;
    id	myHighNormField;
    id	myInvertSwitch;
    id	myProductSwitch;
    id	myMinField;
    id	myMaxField;
    id	myMeanField;
    id	myNormMeanField;
    
    id	myBrowser;
    id	myString;
    id	selected;
    int	selIndex;
    BOOL browserValid;
}
- (id<LPSEditedProtocol>) owner; // jg

- init;
- (void)dealloc;
- (void)awakeFromNib;

- setWeightWatcher:aWeightWatcher;
- takeWeightWatcherFrom:anLPS;
- (void)setSelectedCell:sender;

- takeNameFrom:sender;
- takeBaryWeightFrom:sender;
- takeDeformationFrom:sender;
- takeToleranceFrom:sender;
- takeLowNormFrom:sender;
- takeHighNormFrom:sender;
- takeInversionFrom:sender;
- takeProductFrom:sender;
- setWeight:sender;
- removeWeight:sender;

- displayWeightWatcher:sender;
@end

@interface WeightWatcherInspector(BrowserDelegate)
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
@end

@interface WeightWatcherInspector(WindowDelegate)
- (BOOL)windowShouldClose:(id)sender;
@end

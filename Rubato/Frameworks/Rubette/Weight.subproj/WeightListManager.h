/* WeightListManager.h */

#import <AppKit/AppKit.h>
#import <Rubato/RubatoController.h>

@interface WeightListManager : JgObject
{
    // this Owner is set nowhere.
    id owner; //Distributor, see PerformanceRubette.nib: Files Owner
              // jg owner is performanceRubetteDriver (says Debugger)
    NSMutableArray	*myWeightList;
    
    id	myInspectorPanel;
    
    id	myWeightWatcherInspector; // has Owner!
    
    id	myBrowser;
    id	myString;
    int selIndex;
    BOOL browserValid;
}

- init;
- (void)dealloc;
- (void)awakeFromNib;
//- forward:(SEL)aSelector :(marg_list)argFrame;
- (void)forwardInvocation:(NSInvocation *)invocation;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector; //necessary fuer forwardInvocation

- setWeightList:aWeightList;
- appendList:(NSArray *)aWeightList;
- addWeight:aWeight;
- updateWeightListFromLPS:anLPS;
- (NSMutableArray *)weightList;
- (unsigned int) count;
- selected;
- (void)setSelectedCell:sender;

@end

@interface WeightListManager(BrowserDelegate)
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
@end

@interface WeightListManager(WindowDelegate)
- (BOOL)windowShouldClose:(id)sender;
@end
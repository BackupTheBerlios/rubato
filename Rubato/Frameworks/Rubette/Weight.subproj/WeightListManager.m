/* WeightListManager.m */

#import "Weight.h"
#import "WeightWatcher.h"
//jg#import <PerformanceScoreApp/PerformanceOperator.h>
#import <Rubato/GenericObjectInspector.h>

#import "WeightListManager.h"
#import "WeightWatcherInspector.h"

@implementation WeightListManager

- init;
{
    [super init];
    /* class-specific initialization goes here */
    myWeightList = [[NSMutableArray alloc]init];
    myString = [[StringConverter alloc]init];
    return self;
}

- (void)dealloc;
{
    /* class-specific initialization goes here */
    [myInspectorPanel performClose:self];
    /* class-specific initialization goes here */
    [myInspectorPanel release]; myInspectorPanel = nil;
    [myWeightList release]; myWeightList = nil;
    [myString release]; myString = nil;
    [super dealloc];
}


- (void)awakeFromNib;
{
    [myInspectorPanel setFrameUsingName:NSStringFromClass([self class])];
    [myInspectorPanel setBecomesKeyOnlyIfNeeded:YES];
}

/* just in case the owner knows something, forward an unknown message */
/*jg copied from RubetteDriver.m
- forward:(SEL)aSelector :(marg_list)argFrame;
{
    if (owner)
	if ([owner respondsToSelector:aSelector])
	    return [owner performv:aSelector :argFrame];
	else
	    return [owner forward:aSelector :argFrame];
    return [super forward:aSelector :argFrame];
}
*/
// new source code copy
- (void)forwardInvocation:(NSInvocation *)invocation;
{
  if (owner) {
    if ([owner respondsToSelector:[invocation selector]])
        [invocation invokeWithTarget:owner];
    else
        [owner forwardInvocation:invocation];
  } else [super forwardInvocation:invocation];
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector; 
{
  id superSignature=[super methodSignatureForSelector:selector];
  if (superSignature)
    return superSignature;
  if (owner)  
      return [owner methodSignatureForSelector:selector];
  else
      return nil;
}


- setWeightList:aWeightList;
{
    [myWeightList empty];
    [self appendList:aWeightList];
    return self;
}

- appendList:(NSArray *)aWeightList;
{
    int i, c = [aWeightList count];
    for (i=0; i<c; i++)
	[self addWeight:[aWeightList objectAtIndex:i]];
    return self;
}

- addWeight:aWeight;
{
    if ([aWeight isKindOfClass:[Weight class]]) {
	[myWeightList addObjectIfAbsent:aWeight];
	browserValid = NO;
	[myBrowser validateVisibleColumns];
    }
    return self;
}

- updateWeightListFromLPS:anLPS;
{
    int dC, wC, d, w;
    if ([anLPS isKindOfClass:NSClassFromString(@"PerformanceOperator")]) {
	for (w=0, wC=[[anLPS weightWatcher]count]; w<wC; w++) 
	    [self addWeight:[[anLPS weightWatcher] weightObjectAt:w]];
    }
	
    for (d=0, dC=[anLPS daughterCount]; d<dC; d++) 
	[self updateWeightListFromLPS:[anLPS daughterAt:d]];
    
    return self;
}

- (NSMutableArray *)weightList;
{
    return myWeightList;
}

- (unsigned int) count;
{
    return [myWeightList count];
}

- selected;
{
    return [myWeightList objectAtIndex:selIndex];
}

- (void)setSelectedCell:sender;
{
    if ([sender isKindOfClass:[NSBrowser class]] && [sender selectedColumn]!=NSNotFound) 
	selIndex = [[sender matrixInColumn:[sender selectedColumn]] selectedRow];
    else
	selIndex = NSNotFound;

    browserValid = NO;
    [myBrowser validateVisibleColumns];
    browserValid = YES;

//jg was in NX:    [[self globalInspector] setSelected:[myWeightList objectAt:selIndex]];  // jg forward invocation
//jg is wrong:   [[[myWeightWatcherInspector owner] globalInspector] setSelected:[myWeightList objectAt:selIndex]];  // jg owner is Distributor
   [[[owner distributor] globalInspector] setSelected:[myWeightList objectAtIndex:selIndex]];  // jg owner is performanceRubetteDriver  
}


@end


@implementation WeightListManager(BrowserDelegate)
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    if (column)
	return 0;
    else
	return [myWeightList count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    if (!column) {
	id weight = [myWeightList objectAtIndex:row];
	if (weight) {
	    [myString setStringValue:[NSString jgStringWithCString:[weight rubetteName]]];
	    [myString concat:": "];
            [myString concat:[weight nameString]];
	    [cell setLoaded:YES];
	    [cell setStringValue:[myString stringValue]];
	    [cell setLeaf:YES];
	}
    }
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
{
    BOOL retVal;
    if (column) retVal = YES;
    else {
	retVal = ([NSView focusView] == [sender matrixInColumn:column]) ? YES : browserValid;
	//browserValid = YES;
    }
    return retVal;
}

@end

@implementation WeightListManager(WindowDelegate)
/* (WindowDelegate) methods */
- (BOOL)windowShouldClose:(id)sender;
{
    [myInspectorPanel saveFrameUsingName:NSStringFromClass([self class])];
    return YES;
}
@end

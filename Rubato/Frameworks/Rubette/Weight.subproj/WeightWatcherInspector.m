/* WeightWatcherInspector */

#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubato/RubatoTypes.h>
#import "WeightWatcher.h"
#import "Weight.h"
#import "WeightView.h"
#import "WeightListManager.h"
//jg#import <PerformanceScoreApp/PerformanceOperator.h>

#import "WeightWatcherInspector.h"
//jg#import "PerformanceRubetteDriver.h"


@implementation WeightWatcherInspector

- (id<LPSEditedProtocol>) owner;
{
  return owner;
}

- init;
{
    [super init];
    myString = [[StringConverter alloc]init];
    return self;
}

- (void)dealloc;
{
    [myInspectorPanel performClose:self];
    [myInspectorPanel release]; myInspectorPanel = nil;
    [myWeightViewPanel performClose:self];
    [myWeightViewPanel release]; myWeightViewPanel = nil;
    [myWeightSumViewPanel performClose:self];
    [myWeightSumViewPanel release]; myWeightSumViewPanel = nil;
    [myString release]; myString = nil;
    [super dealloc];
}

- (void)awakeFromNib;
{
    [myInspectorPanel setFrameUsingName:NSStringFromClass([self class])];
}

- setWeightWatcher:aWeightWatcher;
{
    if (!aWeightWatcher || [aWeightWatcher isKindOfClass:[WeightWatcher class]]) {
	myWeightWatcher = aWeightWatcher;
	browserValid = NO;
	[myString setStringValue:NSStringFromClass([self class])];
	if (aWeightWatcher) {
          [myString concat:" Ð "];
          [myString concat:[[aWeightWatcher ownerLPS]nameString]];
        }
	[myInspectorPanel setTitle:[myString stringValue]];
	[myBrowser validateVisibleColumns];
	[self setSelectedCell:myBrowser]; // jg: weightSumView not updated!
        [self displayWeightWatcher:self]; // jg added 7.12.2001 to update WeightSumView
    }
    return self;
}

- takeWeightWatcherFrom:anLPS;
{
    if ([anLPS respondsToSelector:@selector(weightWatcher)])
	[self setWeightWatcher:[anLPS weightWatcher]];
    else
	[self setWeightWatcher:nil];
    return self;
}


- (void)setSelectedCell:sender;
{
    if ([sender isKindOfClass:[NSBrowser class]] && [sender selectedColumn]!=NSNotFound) 
	selIndex = [[sender matrixInColumn:[sender selectedColumn]] selectedRow];
    else
	selIndex = NSNotFound;

    if (selIndex!=NSNotFound) {
	browserValid = NO;
	[myBrowser validateVisibleColumns];
	sender = nil;
    } 
	
    [self displayWeightWatcher:sender];
    browserValid = YES;
}

- takeNameFrom:sender;
{
    if ([sender respondsToSelector:@selector(stringValue)]) {
	[[myWeightWatcher weightObjectAt:selIndex]setNameString:[[sender stringValue] cString]];
	[owner setLPSEdited:YES];
	[self  displayWeightWatcher:self];
    }
    return self;
}

- takeBaryWeightFrom:sender;
{
    if ([sender respondsToSelector:@selector(doubleValue)]) {
	[myWeightWatcher setBaryWeight:[sender doubleValue] at:selIndex];
	[owner setLPSEdited:YES];
	[self  displayWeightWatcher:self];
    }
    return self;
}

- takeDeformationFrom:sender;
{
    if ([sender respondsToSelector:@selector(doubleValue)]) {
	[myWeightWatcher setDeformation:[sender doubleValue] at:selIndex];
	[owner setLPSEdited:YES];
	[self  displayWeightWatcher:self];
    }
    return self;
}

- takeToleranceFrom:sender;
{
    if ([sender respondsToSelector:@selector(doubleValue)]) {
	[myWeightWatcher setTolerance:[sender doubleValue] at:selIndex];
	[owner setLPSEdited:YES];
	[self  displayWeightWatcher:self];
    }
    return self;
}

- takeLowNormFrom:sender;
{
    if ([sender respondsToSelector:@selector(doubleValue)]) {
	[myWeightWatcher setLowNorm:[sender doubleValue] at:selIndex];
	[owner setLPSEdited:YES];
	[self  displayWeightWatcher:self];
    }
    return self;
}

- takeHighNormFrom:sender;
{
    if ([sender respondsToSelector:@selector(doubleValue)]) {
	[myWeightWatcher setHighNorm:[sender doubleValue] at:selIndex];
	[owner setLPSEdited:YES];
	[self  displayWeightWatcher:self];
    }
    return self;
}

- takeInversionFrom:sender;
{
    if ([sender respondsToSelector:@selector(intValue)]) {
	[myWeightWatcher setInversion:[sender intValue] at:selIndex];
	[owner setLPSEdited:YES];
	[self  displayWeightWatcher:self];
    }
    return self;
}

- takeProductFrom:sender;
{
    if ([sender respondsToSelector:@selector(intValue)]) {
	[myWeightWatcher setProduct:[sender intValue]];
	[owner setLPSEdited:YES];
	[self  displayWeightWatcher:self];
    }
    return self;
}


- setWeight:sender;
{
    [myWeightWatcher addWeightObject:[myWeightListManager selected]];
    [owner setLPSEdited:YES];
    [self setSelectedCell:nil];
    browserValid = NO;
//    [myBrowser loadColumnZero]; // jg: added otherwise strange column-messages in Browserdelegate
    [myBrowser validateVisibleColumns];
	[self  displayWeightWatcher:self]; // jg added 7.12.2001
    return self;
}

- removeWeight:sender;
{
    if (NSRunAlertPanel(@"Remove Weight", @"Do you really want to remove this weight from the Weight Watcher of the selected LPS?", @"", @"Cancel", nil, NULL)==NSAlertDefaultReturn){
	[myWeightWatcher removeWeightObjectAt:selIndex];
	[owner setLPSEdited:YES];
	[self setSelectedCell:nil];
	browserValid = NO;
	[myBrowser validateVisibleColumns];
    }
    return self;
}


- displayWeightWatcher:sender;
{
    if ([myWeightWatcher weightObjectAt:selIndex]) {
	[myNameField setStringValue:[NSString jgStringWithCString:[[myWeightWatcher weightObjectAt:selIndex]nameString]]];
	[myBaryWeightField setDoubleValue:[myWeightWatcher baryWeightAt:selIndex]];
	[myDeformationField setDoubleValue:[myWeightWatcher deformationAt:selIndex]];
	[myToleranceField setDoubleValue:[myWeightWatcher toleranceAt:selIndex]];
	[myLowNormField setDoubleValue:[myWeightWatcher lowNormAt:selIndex]];
	[myHighNormField setDoubleValue:[myWeightWatcher highNormAt:selIndex]];
	[myInvertSwitch setIntValue:[myWeightWatcher isInvertedAt:selIndex]];
	[myMinField setDoubleValue:[[myWeightWatcher weightObjectAt:selIndex] minWeight]];
	[myMaxField setDoubleValue:[[myWeightWatcher weightObjectAt:selIndex] maxWeight]];
	[myMeanField setDoubleValue:[[myWeightWatcher weightObjectAt:selIndex] meanWeight]];
	[myNormMeanField setDoubleValue:[[myWeightWatcher weightObjectAt:selIndex] meanNormalizedWeight]];
    } else {
	[myNameField setStringValue:@""];
	[myBaryWeightField setStringValue:@""];
	[myDeformationField setStringValue:@""];
	[myToleranceField setStringValue:@""];
	[myLowNormField setStringValue:@""];
	[myHighNormField setStringValue:@""];
	[myInvertSwitch setIntValue:0];
	[myMinField setStringValue:@""];
	[myMaxField setStringValue:@""];
	[myMeanField setStringValue:@""];
	[myNormMeanField setStringValue:@""];
    }
    [myProductSwitch setIntValue:[myWeightWatcher isProduct]];
    
    browserValid = NO;
    [myBrowser validateVisibleColumns]; 
    [myString setStringValue:[NSString jgStringWithCString:[[myWeightWatcher weightObjectAt:selIndex] rubetteName]]];
    [myString concat:": "];
    [myString concat:[[myWeightWatcher weightObjectAt:selIndex] nameString]];
    [myWeightViewPanel setTitle:[myString stringValue]];
    [myWeightView displayWeight:[myWeightWatcher weightObjectAt:selIndex] 
		    withInversion: [myWeightWatcher isInvertedAt:selIndex]
		    andDeformation:[myWeightWatcher deformationAt:selIndex]];
    if (sender) {
	[myWeightSumView displayWeightWatcher:myWeightWatcher];
	[myWeightSumViewPanel setTitle:[NSString jgStringWithCString:[[myWeightWatcher ownerLPS] nameString]]];
    }
    
    return self;
}


@end

@implementation WeightWatcherInspector(BrowserDelegate)
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    if (column)
	return 0;
    else
	return [myWeightWatcher count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    if (!column) {
	id weight = [myWeightWatcher weightObjectAt:row];
        if ([weight isKindOfClass:NSClassFromString(@"Weight")]) {
	    [myString setStringValue:[NSString jgStringWithCString:[weight rubetteName]]];
	    [myString concat:": "];
            [myString concat:[weight nameString]];
	    [cell setLoaded:YES];
	    [cell setStringValue:[myString stringValue]];
	    [cell setLeaf:YES];
	}
    }
}

// NSBrowser validateVisableColumns 
// invokes delegate method browser:isColumnValid: for visible columns.
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

@implementation WeightWatcherInspector(WindowDelegate)
/* (WindowDelegate) methods */
- (BOOL)windowShouldClose:(id)sender;
{
    [myInspectorPanel saveFrameUsingName:NSStringFromClass([self class])];
    return YES;
}
@end

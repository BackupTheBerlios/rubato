
#import "CompoundFormInspector.h"

#import <Predicates/predikit.h>
#import <RubatoDeprecatedCommonKit/StickyNXImage.h>

@implementation CompoundFormInspector

- (void)setValue:(id)sender;
{
    if ([sender selectedCell]==changeNameCheck)
	[patient setAllowsToChangeName:(BOOL)[sender intValue]];
    if ([sender selectedCell]==changeTypeCheck)
	[patient setAllowsToChangeType:(BOOL)[sender intValue]];
    if ([sender selectedCell]==changeValueCheck)
	[patient setAllowsToChangeValue:(BOOL)[sender intValue]];
    if ([sender selectedCell]==uniqueNameCheck)
	[patient setNeedsUniqueName:(BOOL)[sender intValue]];
    if ([sender selectedCell]==lockedFormCheck) {
	if (NSRunAlertPanel(@"Lock Form", [NSString stringWithCString:"Locking a form "
    			"is not reversible. Once a form is locked, it "
			"cannot be changed in any way or unlocked. Proceed?"], @"OK", @"Cancel", nil, NULL)==NSAlertDefaultReturn)
	    [patient setLocked:(BOOL)[sender intValue]];
    }
    [super setValue:sender];
}



- displayPatient: sender
{
    id form = patient;
    [changeNameCheck setIntValue:[form allowsToChangeName]];
    [changeTypeCheck setIntValue:[form allowsToChangeType]];
    [changeValueCheck setIntValue:[form allowsToChangeValue]];
    [uniqueNameCheck setIntValue:[form needsUniqueName]];
    [lockedFormCheck setIntValue:[form isLocked]];
    [lockedFormCheck setEnabled:![form isLocked]];
    [childBrowser validateVisibleColumns];
    return [super displayPatient:sender];
}



/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    if (column)
	return 0;
    else
	return [patient count];
}

//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    if (!column) {
	id predicate;
	id image, imageString = [[StringConverter alloc]init];
	predicate = [patient getValueAt:row];
	if (predicate) {
          id theName;
	    [cell setLoaded:YES];
	    [cell setStringValue:[NSString jgStringWithCString:[predicate nameString]]];
	    [cell setLeaf:YES];
	    [imageString setStringValue:[NSString jgStringWithCString:[predicate typeString]]];
            theName=[[NSBundle bundleForClass:[self class]] pathForImageResource:[imageString stringValue]];
            image = [[NSImage alloc]initByReferencingFile:theName];
            if (image) {
                [cell setImage:image];
                [image release];
            }
            [imageString concat:"H"];
            theName=[[NSBundle bundleForClass:[self class]] pathForImageResource:[imageString stringValue]];
            image = [[NSImage alloc]initByReferencingFile:theName];
            if (image) {
                [cell setAlternateImage:image];
                [image release];
            }
	}
	[imageString release];
    }
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
{
    return NO;
}
@end

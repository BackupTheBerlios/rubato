
#import <AppKit/AppKit.h>
#import "PredicateInspector.h"

@interface ListInspector:PredicateInspector
{
    id	childBrowser;
        
    id	newValue;
}

- (void)setValue:(id)sender;
- displayPatient:sender;

/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;

@end

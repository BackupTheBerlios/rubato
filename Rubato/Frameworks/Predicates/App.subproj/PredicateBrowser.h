#import <AppKit/AppKit.h>
#import "PredicateManager.h"

@interface PredicateBrowser : NSWindowController
{
  id	browser;
  id	browserWindow;
  id	selectedCell;
  BOOL browserIsValid;
}
/* copy & paste methods */
- copyToPasteboard:pboard;
- (void)copy:(id)sender;
- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type;
- (void)cut:(id)sender;
- (void)paste:(id)sender;

/* browser management */
- row:(int *)aRow andColumn:(int *)aCol ofPredicate:aPredicate;
- (void)setSelected: aPredicate;
- (void)setSelectedFrom:sender;
- selected;
- (void)setSelectedCell:sender;
- selectedCell;

- selectedInColumn:(int)column;
- browser:sender selectedInColumn: (int)column;
- browser:sender predicateAtRow:(int)row inColumn:(int)column;

- (void)invalidate;

/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
//- (const char *)browser:sender titleOfColumn:(int)column;
- (BOOL)browser:sender selectCellWithString:(NSString *)title inColumn:(int)column;
- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;

@end

/* JGSubDocumentsBrowser.h created by jg on Tue 23-May-2000 */
// A browser specialized to show the Structure of Documents

#import <AppKit/AppKit.h>
#import "JGSubDocumentWindowController.h"

@interface JGSubDocumentsBrowser : JGSubDocumentWindowController
{
  id browser;
  int validStringColumn;
}
- (id)initWithWindowNibName:(NSString *)windowNibName; // hook for debugging
- (void)dealloc; // hook for debugging

// Primitive method
- (id)browser;

// Display updates
//- (void)updateTitle;                   // called by -[document changedParentDocument]
- (void)validateColumn:(int)column;    // called by -[document changedChildDocumentNodeInDepth]

// Browser loading
- (NSArray *)documentsOfBrowser:(NSBrowser *)sender inColumn:(int)column; // base for following methods
- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;


//- (void) loadWindow; // overwrites NSWindowController

@end

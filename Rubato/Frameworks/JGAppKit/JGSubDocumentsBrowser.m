/* JGSubDocumentsBrowser.m created by jg on Tue 23-May-2000 */

#import "JGSubDocumentsBrowser.h"
#import "JGSubDocument.h"

@implementation JGSubDocumentsBrowser
- (id)initWithWindowNibName:(NSString *)windowNibName
{
  [super initWithWindowNibName:(NSString *)windowNibName];
  validStringColumn=-1;
  return self;
}
- (void)dealloc;
{
  [super dealloc];
}

// Primitive method
- (id) browser;
{
  return browser;
}

// Display updates

- (void)validateColumn:(int)column;
{
  if (validStringColumn>=column) {
    validStringColumn=column-1;
  }
  [[self browser] validateVisibleColumns];
}

- (NSArray *)documentsOfBrowser:(NSBrowser *)sender inColumn:(int)column;
{
  int r,i;
  JGSubDocument *doc=[self document];
  for(i=0; i<column;i++) {
    r=[sender selectedRowInColumn:i];
    doc=[[[doc subDocumentNode] childDocuments] objectAtIndex:r];
  }
  return [[doc subDocumentNode] childDocuments];
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
{
// though the string contents of the cells in column validStringColumn is correct, 
// the leaf-status might not be. So we subtract 1 of validStringColumn.
  return (column<=validStringColumn-1);
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
  NSArray *docs=[self documentsOfBrowser:sender inColumn:column];
  return [docs count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
  NSDocument *doc;
  JGSubDocumentNode *docNode;
  NSArray *docs=[self documentsOfBrowser:sender inColumn:column];
  doc=[docs objectAtIndex:row];
  docNode=[JGSubDocumentNode docNodeForDocument:doc];
  if (docNode) {
    [cell setStringValue:[docNode documentCreationStemma]];
    if ([[docNode childDocuments] count] > 0)
      [cell setLeaf:NO]; 
    else
      [cell setLeaf:YES];
  } else {
    [cell setStringValue:@"Custom Document"];
    [cell setLeaf:YES];
  }
  [cell setLoaded:YES];
  if (validStringColumn<column)
    validStringColumn=column;
}

/* 
// If this exists, NSDocumentController has no notion of currentDocument!
 // there is something that is overwritten by a implementation.
- (void)windowDidBecomeMain:(NSNotification *)notification;
{
  [super windowDidBecomeMain:notification];
  NSLog(@"SubDocBrowser is main");
}
*/

/* by jg does not work (multiple Windows for JGActivationSubDocument)
- (void) loadWindow;
{
  id bundle=[NSBundle bundleForClass:[JGSubDocumentsBrowser class]];
  id table=[NSDictionary dictionaryWithObject:[self owner] forKey:@"NSOwner"];
  id nibFile=[NSString stringWithFormat:@"%@.nib",[self windowNibName]];
  [bundle loadNibFile:nibFile externalNameTable:table withZone:[self zone]];
}
*/

@end

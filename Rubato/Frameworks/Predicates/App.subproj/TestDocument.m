#import "TestDocument.h"
#import "TestBrowser.h"
@implementation TestDocument

- (void)addTestBrowser;
{
   id subDocumentsBrowser=[[TestBrowser alloc] initWithWindowNibName:@"TestBrowser"];
   [self addWindowController:subDocumentsBrowser];
}
- (void)addTestBrowser:(id)sender;
{
  [self addTestBrowser];
  [self showWindows];
}
- (void)makeWindowControllers;
{
  [[self subDocumentNode] addSubDocumentsBrowser];
  [self addTestBrowser];
  [self showWindows];
}

@end


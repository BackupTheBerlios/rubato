#import <AppKit/AppKit.h>

@interface JGSubDocumentWindowController : NSWindowController
{
}
- (id)initWithWindowNibName:(NSString *)windowNibName; // hook for debugging
- (void)dealloc;

// Display updates
- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName;
- (void)updateTitle;                   // called by -[document changedParentDocument]
@end
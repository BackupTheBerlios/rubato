/* JGSubDocumentsBrowser.m created by jg on Tue 23-May-2000 */

#import "JGSubDocumentWindowController.h"
#undef DEBUG_SUBDOCUMENTWINDOWCONTROLLER

#ifdef DEBUG_SUBDOCUMENTWINDOWCONTROLLER
int openWindowControllers=0;
#endif

@implementation JGSubDocumentWindowController
- (id)initWithWindowNibName:(NSString *)windowNibName
{
#ifdef DEBUG_SUBDOCUMENTWINDOWCONTROLLER
  openWindowControllers++;
  NSLog(@"globally remaining controllers:%d",openWindowControllers);
#endif
  return [super initWithWindowNibName:(NSString *)windowNibName];
}
- (void)dealloc;
{
#ifdef DEBUG_SUBDOCUMENTWINDOWCONTROLLER
  openWindowControllers--;
  NSLog(@"globally remaining controllers:%d",openWindowControllers);
#endif
  [super dealloc];
}

// Display updates

- (void)updateTitle;
{
  NSString *title= [self windowTitleForDocumentDisplayName:[[self document] displayName]];
  [[self window] setTitle:title];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName;
{
  id classname=NSStringFromClass([self class]);
  if (displayName)
    return [NSString stringWithFormat:@"%@ %@",classname,displayName];
  else
    return [NSString stringWithFormat:@"%@ (no document)",classname];
}

@end

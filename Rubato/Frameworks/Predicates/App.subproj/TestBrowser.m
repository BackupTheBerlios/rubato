#import "TestBrowser.h"
@implementation TestBrowser:   NSWindowController
- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName;
{
  return [NSString stringWithFormat:@"TB %@",displayName];
}
@end

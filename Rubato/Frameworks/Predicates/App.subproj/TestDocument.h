#import <AppKit/AppKit.h>
#import <JGAppKit/JGActivationSubDocument.h>

@interface TestDocument:JGActivationSubDocument
{
  id myData;
}
- (void)addTestBrowser;
- (void)addTestBrowser:(id)sender;
- (void)makeWindowControllers;
@end


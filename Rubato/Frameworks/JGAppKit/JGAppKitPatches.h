#import <AppKit/NSControl.h>

@interface NSControl (JGAppKitPatchesNSControl)
// intValue and stringValue are o.k.
- (double)doubleValue;
- (float)floatValue;
@end

void NSDocumentControllerPatchFor2571388InstallIfNecessary(void);

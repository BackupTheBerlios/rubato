// looking for Nibs in loaded Frameworks
#import <AppKit/AppKit.h>
BOOL jgLoadNibNamedFu(NSString * nibName, id owner);

@interface NSBundleJg : NSObject

+ (BOOL)jgLoadNibNamed:(NSString *)nibName owner:(id)owner;

@end

@interface NSBundle (JgFrameworkNibLoading)

+ (BOOL)jgLoadNibNamed:(NSString *)nibName owner:(id)owner;

@end
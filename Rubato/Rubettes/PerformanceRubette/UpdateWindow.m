/* UpdateWindow.m */

#import "UpdateWindow.h"

@implementation UpdateWindow

- (void)update;
{
#warning ViewConversion:  The View 'update' method is obsolete; if the receiver of this method is an NSView convert to [<theView> setNeedsDisplay:YES]
    [contentView update];
    return self;
}


@end
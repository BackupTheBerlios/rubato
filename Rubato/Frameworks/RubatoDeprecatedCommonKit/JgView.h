#import <AppKit/NSView.h>

@interface JgView:NSView
{
}
// the following methods are only use to draw a frame. Then JGView should better be defined as 
// NSBox:NSView.
- (selfvoid)sizeBy:(double)x :(double)y;  // empty implementation.
- (selfvoid)moveBy:(double)x :(double)y;  // empty implementation.
@end

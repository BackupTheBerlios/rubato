/* ProgressPanel.h */

#import <AppKit/NSPanel.h>
#import <AppKit/NSProgressIndicator.h>

@protocol ProgressAborting
- (BOOL)abort;
@end

@interface ProgressPanel:NSPanel
{
    id myProgressView; //NSProgressIndicator
    id	myText;
    double incr;
    id delegate; // <ProgressAborting>
}

- initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
- (void)dealloc;
- (void)awakeFromNib;

/* interrupt event handling such as command '.' */
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;

- (NSProgressIndicator *)progressView;
- (selfvoid)increment:sender;
- (void)setString:(NSString *)aString;
- (void)setIncrement:(double)increment;

- (id)delegate;//<ProgressAborting>
- (void)setDelegate:(id<ProgressAborting>)d; // without retain.

@end

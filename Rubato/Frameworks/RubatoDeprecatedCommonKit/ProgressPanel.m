/* ProgressPanel.m */

#import <AppKit/NSTextField.h>
#import <AppKit/NSProgressIndicator.h>
#import <AppKit/NSEvent.h>
#import <Foundation/NSString.h>
#import "ProgressPanel.h"

@implementation ProgressPanel

// jg: Parameter buttonMask:(int)mask disappeared with Conversion.
- initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
{
    [super initWithContentRect:contentRect styleMask:aStyle /*jg |mask */ backing:bufferingType defer:flag];
    
    [self setBecomesKeyOnlyIfNeeded:YES];
    [self setFloatingPanel:YES];
    [myProgressView setDoubleValue:0.0];
    incr=1.0;
    delegate=nil;
    return self;
}

- (void)dealloc;
{
    // jg return 
  [super dealloc];
}


- (void)awakeFromNib;
{
//#error ViewConversion: 'setAutodisplay:' is obsolete
//jg commented out    [myProgressView setAutodisplay:YES];
//jg    return self;
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;
{
    if ([self delegate] &&
	theEvent && 
	[theEvent modifierFlags] & NSCommandKeyMask && 
        [[theEvent charactersIgnoringModifiers] isEqualToString:@"."])
	return [[self delegate] abort];
    if([[self delegate] respondsToSelector:@selector(performKeyEquivalent:)])
	return (BOOL) [[self delegate] performKeyEquivalent:theEvent];
    return NO;
}

- progressView;
{
    return myProgressView;
}


- (selfvoid)increment:sender
{
    [myProgressView incrementBy:incr];
    [myProgressView display];
    [self displayIfNeeded];
}

- (void)setString:(NSString *)aString;
{
//jg: 	was    [myText setStringValue:[NSString stringWithCString:aString]];
    [myText setStringValue:aString]; // jg: is
    [self display];
}

- (void)setIncrement:(double)increment;
{
  incr=increment;
}


- (id)delegate; // <ProgressAborting>
{
  return delegate;
}
- (void)setDelegate:(id<ProgressAborting>)d; // without retain.
{
  delegate=d;
}

@end

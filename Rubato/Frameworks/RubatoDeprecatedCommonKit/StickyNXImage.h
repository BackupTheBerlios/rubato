/* StickyNXImage.h */
/* StickyNXImage is a subclass of NXImage for the use with NXBrowserCells. 
 * Since NXBrowserCell's - setImage: frees the previously-set image, you're
 * expected to pass it a copy rather than a reference to a shared image.
 * StickyNXImage provides a workaround to this situation -- the overriden
 * - free method does nothing, but the image is freed by the - reallyFree
 * method instead.
 * This Class is implementated accodring to an idea by:
 * Ken Pelletier	ken@nika.com
 *			pelletk@swissbank.com
 */

#import <AppKit/NSImage.h>

@interface StickyNXImage:NSImage
{

}

- (void)dealloc;
// jg: void
- (void)reallyFree;

@end
/* StickyNXImage.m */

#import "StickyNXImage.h"
// jg: 
#import "JGList.h"

@implementation StickyNXImage

static JgList *myInstances;

+ (void)initialize;
{
    [super initialize];
    myInstances = [[JgList alloc]init];
}

+ instanceFreed:anImage;
{
    [myInstances removeObject:anImage];
    return self;
}

+ alloc;
{
    NSImage *new = [super alloc];
    [myInstances addObject:new];
    return new;
}

- (void)dealloc;
{
}

// jg: void
- (void)reallyFree;
{
    [[self class] instanceFreed:self];
    //jg return 
    [super dealloc];
}

@end
/* JgRefCountObject.h */

#import "JgObject.h"
#import "RefCounting.h"

#define INIT_REFCOUNT 0

@interface JgRefCountObject : JgObject <RefCounting>

/* Reference counting & NXReference methods */
- (void)nxrelease;
- (id)ref;
- (oneway void)deRef;
#if 0
- (unsigned int)references;
#endif
@end
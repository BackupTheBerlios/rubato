#ifdef JG_MAC_OS_X
#import <Foundation/NSNull.h>
#define JGNull NSNull
#else
#import <EOControl/EONull.h>
#define JGNull EONull
#endif

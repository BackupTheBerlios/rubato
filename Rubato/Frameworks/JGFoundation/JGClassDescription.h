#ifdef PRE_MAC_OS_X
#import <EOControl/EOClassDescription.h>
#define JGClassDescription EOClassDescription
#else
#import <Foundation/NSClassDescription.h>
#define JGClassDescription NSClassDescription
#endif

#ifdef PRE_MAC_OS_X
#import <EOControl/EOKeyValueCoding.h>
#define JGKeyValueCoding EOKeyValueCoding
#else
#import <Foundation/NSKeyValueCoding.h>
#define JGKeyValueCoding NSKeyValueCoding
#endif

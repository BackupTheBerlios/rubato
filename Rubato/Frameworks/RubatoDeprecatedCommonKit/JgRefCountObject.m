/* JgRefCountObject.m */
// RETAINCOUNTMINUS1 semantically is near to the NextStep-Retain-registry.
// is it not defined, this is near to the new Framework

#import "JgRefCountObject.h"

@implementation JgRefCountObject

- (void)dealloc;
{
  [super dealloc];
}

- (void)nxrelease;
{
//#ifdef SUPERFREE
//#warning Compiler option SUPERFREE defined.
//  if([self retainCount]!=2)
//    [self release];
//  else {
//    [self release]; // myRefCount
//    [self release]; // [super free]
//  }
//#else
//#warning Compiler option SUPERFREE not defined.
  [self release];
//#endif
}

- (id)ref;
{
    return [self retain];
}

- (oneway void)deRef;
{
// perhaps change this, because of different semantic in NextStep?
    [self release]; 
}

#if 0
- (unsigned int)references;
{
#ifdef RETAINCOUNTMINUS1
#warning Compiler option RETAINCOUNTMINUS1 defined.
   return [self retainCount]-1;
#else
#warning Compiler option RETAINCOUNTMINUS1 not defined.
   return [self retainCount];
#endif
}
#endif

@end
/* RefCounting Protocol */


@protocol RefCounting 
// jg <NXReference>

/* Reference counting & NXReference methods */
- (void)nxrelease; // Konvertierung: free -> release -> nxrelease
//- (void)dealloc;
#if 0
- (unsigned int)references;
#endif
/* RefCounting additional methods */
- (id)ref;
- (oneway void)deRef;

@end
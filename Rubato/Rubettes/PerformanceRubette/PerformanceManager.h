/* PerformanceManager */

#import <AppKit/AppKit.h>
#ifdef WITHMUSICKIT
#import <MusicKit/MusicKit.h>
#endif

@interface PerformanceManager : NSObject //JgObject
{
    id	owner;
    id	myLPS;
    id	myScore;// only if WITHMUSICKIT this is is set.
    id	myPerformanceList;
    id	myLPSview;
    
    int myPerformanceDepth;
    BOOL mergeParts;
    
    char *scorefile;
    char *stemmafile;
}

- init;
- (void)dealloc;
//- forward:(SEL)aSelector :(marg_list)argFrame;
- (void)forwardInvocation:(NSInvocation *)invocation;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector; //necessary for forwardInvocation

- setMergeParts:(BOOL)flag;
- takeMergePartsFrom:sender;
- setPerformanceDepth:(int)anInt;
- takePerformanceDepthFrom:sender;

- setScorefile:(const char *)aFilename;
- setStemmafile:(const char *)aFilename;
- saveScoreAs:sender;
- saveScore:sender;
- saveMidiAs:sender;
- saveMidi:sender;
- saveStemmaAs:sender;
- saveStemma:sender;
- loadStemma:sender;
- newStemma:sender;

- makePerformance:sender;
- makeScoreFromLPSList:aPerformanceList; // only reasonable, if MusicKit exists.
#ifdef WITHMUSICKIT
- makePartFromLPS:anLPS;
- makeNoteFromEvent:anEvent;
- makeMidiPerformanceOf:aScore;
#endif

@end
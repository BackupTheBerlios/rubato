/* PerformanceManager */

#import <float.h>
#import <Rubato/RubatoTypes.h>
#import <Rubato/Distributor.h> // stemmaDirectory
#import <PerformanceScore/LocalPerformanceScore.h>
#import <Rubette/MatrixEvent.h>
#import <Rubato/RubatoController.h>

#import "PerformanceManager.h"
#import <Rubette/WeightListManager.h>
#import "PerformanceRubetteDriver.h"
#import "LPSView.h"
#ifdef WITHMUSICKIT
#import <MusicKit/MusicKit.h>
#endif

// jg 16.Jan.2002
// There was a 4 instead of PERF_MAN_DURATION_FACTOR in the code, which stretched the timescale on MacOSX.
// I do not know why. Maybe MusicKit has changed the meaning of the time-tag initialization.
// A value of 1 seems to be more appropriate!

// jg 13.Mar.2002
// No! The score reader makes 4 quarter notes (4 seconds) into 1 E to work with 4/4 bars (/4)
// thats why we must scale here with *4 (see MKScoreReader.m)
// but why did I find a number of 1 at 16.Jan.2002?
#define PERF_MAN_DURATION_FACTOR 4
// Watchout: there can be still differences, when you play a midi file, because the performed Midi file
// has 60 BPM, whereas the read midi file might have other BPM, which has a meaning to midi players,
// but not to MKScoreReader 

/*
Class getMKScoreClass()
{
  Class mkscoreClass=NSClassFromString(@"MKScore");
  NSParameterAssert(mkscoreClass!=nil);
  return mkscoreClass;
}
*/

#ifdef WITHMUSICKIT
@interface MKScore (WriteNoExtension)
-(BOOL)writeMidifileNoExtension:(NSString *)aFileName;
@end
#endif


@implementation PerformanceManager

- init;
{
    [super init];
    /* class-specific initialization goes here */
#ifdef WITHMUSICKIT
    myScore = [[MKScore alloc]init];
#endif
    mergeParts = NO;
    return self;
}

- (void)dealloc;
{
    /* class-specific initialization goes here */
#ifdef WITHMUSICKIT
    [myScore release]; myScore = nil;
#endif
    if (scorefile) free(scorefile);
    [super dealloc];
}


/* just in case the owner knows something, forward an unknown message */
/*jg copied from RubetteDriver.m
- forward:(SEL)aSelector :(marg_list)argFrame;
{
    if (owner)
	if ([owner respondsToSelector:aSelector])
	    return [owner performv:aSelector :argFrame];
	else
	    return [owner forward:aSelector :argFrame];
    return [super forward:aSelector :argFrame];
}
*/
// new source code copy 
- (void)forwardInvocation:(NSInvocation *)invocation;
{
  if (owner) {
    if ([owner respondsToSelector:[invocation selector]])
        [invocation invokeWithTarget:owner];
    else
        [owner forwardInvocation:invocation];
  } else [super forwardInvocation:invocation];
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector; 
{
  id superSignature=[super methodSignatureForSelector:selector];
  if (superSignature)
    return superSignature;
  else if (owner)  
    return [owner methodSignatureForSelector:selector];
  else
    return nil;
}

- setMergeParts:(BOOL)flag;
{
    mergeParts = flag;
    return self;
}


- takeMergePartsFrom:sender;
{
    if ([sender respondsToSelector:@selector(intValue)]) {
	[self setMergeParts:[sender intValue]];
    }
    return self;
}

- setPerformanceDepth:(int)anInt;
{
    myPerformanceDepth = anInt;
    return self;
}

- takePerformanceDepthFrom:sender;
{
    if ([sender respondsToSelector:@selector(intValue)]) {
	[self setPerformanceDepth:[sender intValue]];
    }
    return self;
}


- setScorefile:(const char *)aFilename;
{
    /* this method taken from Garfinkel & Mahoney, p. 331 */
    if (scorefile) free(scorefile);
    scorefile = malloc(strlen(aFilename)+1);
    strcpy(scorefile, aFilename);
    return self;
}

- setStemmafile:(const char *)aFilename;
{
    /* this method taken from Garfinkel & Mahoney, p. 331 */
    if (stemmafile) free(stemmafile);
    stemmafile = malloc(strlen(aFilename)+1);
    strcpy(stemmafile, aFilename);
    return self;
}

- saveScoreAs:sender;
{
    /* this method taken from Garfinkel & Mahoney, p. 331 */
    id	panel;
    char path[MAXPATHLEN+1];
    
    /* prompt user for filename and save to that file */
    if (scorefile) {
	if (rindex(scorefile, '/')) 
	    strncpy(path, scorefile, rindex(scorefile, '/')-scorefile+1);
	else
	    strcpy(path, scorefile);
    }
    else {
	strcpy(path, [NSHomeDirectory() cString]);
	strcat(path, "/Library/Music/Score/");
    }

    panel = [NSSavePanel savePanel];
    [panel setRequiredFileType:[NSString jgStringWithCString:ScoreFileType]];
    if ([panel runModalForDirectory:@"" file:@""]) {
	[self setScorefile:[[panel filename] cString]];
	return [self saveScore:sender];
    }
    return nil; /*didn't save */
}

- saveScore:sender;
{
    if (myScore) {	
	if (scorefile==0) return [self saveScoreAs:sender];
	//[myWindow setTitle:"Saving Score¼"];

#ifdef WITHMUSICKIT	
	if (![myScore writeScorefile:[NSString stringWithCString:scorefile]])
	    NSRunAlertPanel(@"Save Scorefile¼", @"Couldn't write to scorefile", @"", nil, nil, NULL);
	//[myWindow setTitle:[[self class] rubetteName]];
#else
        NSRunAlertPanel(@"Save Scorefile¼",@"MusicKit not included", @"Sorry",nil,nil);
#endif
    }
    return self;
}

- saveMidiAs:sender;
{
    /* this method taken from Garfinkel & Mahoney, p. 331 */
    id	panel;
    char path[MAXPATHLEN+1];
    
    /* prompt user for filename and save to that file */
    if (scorefile) {
	if (rindex(scorefile, '/')) 
	    strncpy(path, scorefile, rindex(scorefile, '/')-scorefile+1);
	else
	    strcpy(path, scorefile);
    }
    else {
	strcpy(path, [NSHomeDirectory() cString]);
	strcat(path, "/Library/Music/Midi/");
    }

    panel = [NSSavePanel savePanel];
    [panel setRequiredFileType:ns_MidiFileType];
    if ([panel runModalForDirectory:@"" file:@""]) {
	[self setScorefile:[[panel filename] cString]];
        return [self saveMidi:sender];
    }
    return nil; /*didn't save */
}

- saveMidi:sender;
{
#ifdef WITHMUSICKIT	
    if (myScore) {
	id midiScore = [myScore copy];
	BOOL evalTempo = [MKScore midifilesEvaluateTempo];
	[MKScore setMidifilesEvaluateTempo:NO];
	
	[self makeMidiPerformanceOf:midiScore];
	if (scorefile==0) return [self saveMidiAs:sender];
	//[myWindow setTitle:"Saving MIDI¼"];
	
        if (![midiScore writeMidifileNoExtension:[NSString stringWithCString:scorefile]])
	    NSRunAlertPanel(@"Save MIDI file¼", @"Couldn't write to MIDI file", @"", nil, nil, NULL);
	//[myWindow setTitle:[[self class] rubetteName]];
	[midiScore release];
	
	[MKScore setMidifilesEvaluateTempo:evalTempo];
    }
    return self;
#else
        NSRunAlertPanel(@"Save Scorefile¼",@"MusicKit not included", @"Sorry",nil,nil);
	return self;
#endif
}

- saveStemmaAs:sender;
{
    /* this method taken from Garfinkel & Mahoney, p. 331 */
    id	panel;
    char path[MAXPATHLEN+1];
    
    /* prompt user for filename and save to that file */
    if (stemmafile) {
	if (rindex(stemmafile, '/')) 
	    strncpy(path, stemmafile, rindex(stemmafile, '/')-stemmafile+1);
	else
	    strcpy(path, stemmafile);
    }
    else {
	strcpy(path, [[[owner distributor]stemmaDirectory] cString]); // jg? not used
    }

    panel = [NSSavePanel savePanel];
    [panel setRequiredFileType:[NSString jgStringWithCString:StemmaFileType]];
    if ([panel runModalForDirectory:@"" file:@""]) {
	[self setStemmafile:[[panel filename] cString]];
	return [self saveStemma:sender];
    }
    return nil; /*didn't save */
}

- saveStemma:sender;
{
    if ([owner performanceScore]) {
	if (!stemmafile)
	    return [self saveStemmaAs:sender];
	else {
          NSString *type=[NSString stringWithCString:StemmaFileType];
          id archiver=[[owner distributor] archiverForType:type];
          NSData *d=[archiver archivedDataWithRootObject:[owner performanceScore]];
          [d writeToFile:[NSString jgStringWithCString:stemmafile] atomically:YES];
	}
    }
    return self;
}

- loadStemma:sender;
{
    [self newStemma:self];
    if(![owner performanceScore]) {
//	char path[MAXPATHLEN+1];
	NSArray *types = [NSArray arrayWithObject:[NSString jgStringWithCString:StemmaFileType]];
	const char *fname, *ftype="";
	id anLPS, openPanel;
	id returnValue = self; /* this variable is used in the load handler macro */
        
	openPanel = [NSOpenPanel openPanel];
	[openPanel setTitle:@"Open Stemma"];
        if([openPanel runModalForDirectory:[[owner distributor] stemmaDirectory] file:@"" types:types]) {
	    fname = [[openPanel filename] cString];
	    if(rindex(fname, '.')) /* increment ptr to actual filetype */
		ftype = rindex(fname, '.') +1;
	
	    if (!strcmp(ftype, StemmaFileType)) {/* if its a .operator Directory*/ // jg: comment wrong?
              NSString *type=[NSString stringWithCString:StemmaFileType];
              id unarchiver=[[owner distributor] unarchiverForType:type];
		[self setStemmafile:fname];
                NS_DURING
                anLPS=[unarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:[NSString jgStringWithCString:stemmafile]]];
		NS_HANDLER
		LOAD_HANDLER /* a load handler macro in macros.h */
		anLPS = nil;
		NS_ENDHANDLER /* end of handler */
		
		[owner setPerformanceScore:anLPS];
	    }
	}
	return returnValue;
    }
    return nil;
}


- newStemma:sender;
{
    if([owner performanceScore]) {
	int a = NSRunAlertPanel(sender==self ? @"Replace Stemma" : @"New Stemma", @"Do you want to save the exisiting stemma?", @"Yes", @"No", @"Cancel", NULL);

	switch(a) {
	    case NSAlertDefaultReturn:
		if ([self saveStemmaAs:self]) {
		    [owner setPerformanceScore:nil];
		    [self makePerformance:self];
		    if(stemmafile) {
			free(stemmafile);
			stemmafile = NULL;
		    }
		}
		break;
	    case NSAlertAlternateReturn:
		[owner setPerformanceScore:nil];
		[self makePerformance:self];
		if(stemmafile) {
		    free(stemmafile);
		    stemmafile = NULL;
		}
		break;
	    case NSAlertOtherReturn:
	    default:
		break;
	}
    }
    return self;
}


- makePerformance:sender;
{
  NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init]; // debug memory
    myLPS = [owner selected];
    [myLPS setPerformanceDepth:myPerformanceDepth];
    [myPerformanceList release];
    myPerformanceList = [[myLPS makePerformedLPSList]retain];
    [self makeScoreFromLPSList:myPerformanceList];
    [myLPSview display];
    [owner setLPSEdited:YES];
    [pool release]; // debug just leaking without 
    return self;
}

- makeScoreFromLPSList:anLPSList;
{
#ifdef WITHMUSICKIT
    int i, c = [anLPSList count];
  if ([myScore respondsToSelector:@selector(removeAllParts)]) {
    [myScore removeAllParts]; // OS X
  }
// else if ([myScore respondsToSelector:@selector(freeParts)]) {
//    [myScore freeParts]; // old MusicKit
//  }
    for (i=0; i<c; i++)
	[myScore addPart:[self makePartFromLPS:[anLPSList objectAt:i]]];
    return myScore;
#else
   return self;
#endif
}

#ifdef WITHMUSICKIT
- makePartFromLPS:anLPS;
{
    id newPart = nil, events  = [anLPS performanceKernel];
    int i, c = [events count];
    if (c) {
	newPart = [[MKPart alloc]init];
	for (i=0; i<c; i++)
	    [newPart addNote:[self makeNoteFromEvent:[events objectAt:i]]];
	MKRemoveObjectName(newPart);
        MKNameObject([NSString stringWithCString:[anLPS nameString]], newPart);
    }
    return newPart;
}
#endif

#ifdef WITHMUSICKIT
- makeNoteFromEvent:anEvent;
{
    id newNote = nil;
    if ([anEvent spaceAt:indexE] && [anEvent dimension]>1) {
	newNote = [[MKNote alloc]initWithTimeTag:[anEvent doubleValueAtIndex:indexE]*PERF_MAN_DURATION_FACTOR];
	[newNote setNoteType:MK_noteDur];

	if ([anEvent spaceAt:indexH]) {
	    int pitchBend;
	    double pitchDelta, pitch = [anEvent doubleValueAtIndex:indexH];
	    if ((pitch-floor(pitch))<0.5) {
		pitchDelta = pitch-floor(pitch);
		pitch = floor(pitch);
	     } else {
		pitchDelta = pitch-ceil(pitch);
		pitch = ceil(pitch);
	    }
	
	    [newNote setPar:MK_keyNum toInt:pitch];
	    if (pitchDelta) {
		pitch = MKFreqToKeyNum(MKTranspose(MKKeyNumToFreq((int)pitch), pitchDelta), &pitchBend, 1.0);
		[newNote setPar:MK_pitchBend toDouble:pitchBend];
		[newNote setPar:MK_pitchBendSensitivity toDouble:1.0];
	    }
	}

	if ([anEvent spaceAt:indexL])
	    [newNote setPar:MK_velocity toDouble:[anEvent doubleValueAtIndex:indexL]];

	if ([anEvent spaceAt:indexD])
	    [newNote setDur:[anEvent doubleValueAtIndex:indexD]*PERF_MAN_DURATION_FACTOR];

	if ([anEvent spaceAt:indexC])
	    [newNote setPar:MK_relVelocity toDouble:[anEvent doubleValueAtIndex:indexL]-[anEvent doubleValueAtIndex:indexC]];
    }
    return newNote;
}
#endif

#ifdef WITHMUSICKIT
- makeMidiPerformanceOf:aScore;
{
    int p, n, pc, nc, i;
    id part, note1, note2;
    if (mergeParts && (pc=[aScore partCount])>1) {
	id parts = [aScore parts];
	id firstPart = [parts objectAt:0];
	for (p=1; p<pc; p++) {
	    part = [parts objectAt:p];
	    while([part noteCount])
		[firstPart addNote:[part nth:0]];
	    [aScore removePart:part];
	    // removed in OSX [part freeSelfOnly];
	}
    }
    pc = [aScore partCount];
    for (p=0; p<pc; p++) {
	part = [[aScore parts]objectAt:p];
	[part combineNotes];
	[part sort];
	nc = [part noteCount];
	for (n=0; n<nc-1; n++) {
	    note1 = [part nth:n];
	    for (i=n+1; i<nc; i++) {
		note2 = [part nth:i];
		if (([note2 keyNum]==[note1 keyNum]) 
		    && ([note2 timeTag]<=[note1 timeTag]+[note1 dur]))
		    [note1 setDur:[note2 timeTag]-[note1 timeTag]-2*FLT_EPSILON];
	    }
	}
    }
    return self;
}
#endif
@end

#ifdef WITHMUSICKIT
@implementation MKScore (WriteNoExtension)
-(BOOL)writeMidifileNoExtension:(NSString *)fileName 
   	/* Write midi to file with specified name.
    This method is equivalent to MKScore -writeMidifile:(NSString *)aFileName
    Except, that it uses the filename directly instead of appending a fileExtension*/
{
    NSMutableData *stream = [NSMutableData data];
//    BOOL success;
    BOOL errorMsg=YES;
    double firstTimeTag=0.0;
    double lastTimeTag=MK_ENDOFTIME;
    double timeShift=0.0;
//    NSString *midifileExtension=nil;
    
    if (!fileName) return NO;
    if (![fileName length]) return NO;

    [self writeMidifileStream: stream
                 firstTimeTag: firstTimeTag
                  lastTimeTag: lastTimeTag
                    timeShift: timeShift];
//    success = _MKOpenFileStreamForWriting(aFileName, [[MKScore midifileExtensions] objectAtIndex: 0], stream, YES);
    if (![stream writeToFile:fileName atomically:YES]) {
        if (errorMsg)
            _MKErrorf(MK_cantOpenFileErr,fileName);
        return NO;
    } else {
        return YES;
    }
}
@end
#endif


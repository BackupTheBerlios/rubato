#ifdef WITHMUSICKIT
#import <MusicKit/MusicKit.h>
#endif
//#import <Predicates/MKScoreReader.h>
#import "MKScoreReader.h"

#import <Predicates/JgPrediBase.h>
#import <Rubato/RubatoController.h>
#import <Predicates/predikit.h>

#import <RubatoDeprecatedCommonKit/JGNXCompatibleUnarchiver.h>
#import <Predicates/CompoundPredicate.h>
#import <Rubette/Weight.h>

#import "PapaDocument.h"

@protocol DeprecatedMethodsForPapaDocument
- (id)values;
@end

@implementation PapaDocument
- init
{
  [super init];
  return self;
}
  
+ (NSArray *)readableTypes;
{
  static id arr;
  if (!arr) arr=[[NSArray alloc] initWithObjects:@"PrediBase",@"PrediBasePlist",@"Midi",@"Score",@"NextStepPrediBase",nil];
  return arr;
}
+ (NSArray *)writableTypes;
{
  static id arr;
  if (!arr) arr=[[NSArray alloc] initWithObjects:@"PrediBase",nil];
  return arr;
}
+ (BOOL)isNativeType:(NSString *)type;
{
  return [type isEqualToString:@"PrediBase"];
}

- (id)initWithContentsOfFile:(NSString *)fileName ofType:(NSString *)fileType;
{
  id ret=[super initWithContentsOfFile:fileName ofType:fileType];
  [ret setFileType:@"PrediBase"];
  return ret;
}
- (id)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)fileType;
{
  id ret=[super initWithContentsOfURL:url ofType:fileType];
  [ret setFileType:@"PrediBase"];
  return ret;
}

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType
{
  BOOL retVal=NO;
//  id prefixString=[NSString stringWithFormat:@"from %@ File: ",docType];

  if ([docType isEqualToString:@"PrediBasePlist"])
    retVal=[self loadPListFile:fileName];
  if ([docType isEqualToString:@"Midi"])
    retVal=[self loadMidiFile:fileName];
  if ([docType isEqualToString:@"Score"])
    retVal=[self loadScoreFile:fileName ];
  if ([docType isEqualToString:@"NextStepPrediBase"])
    retVal=[self loadOldPrediBase:fileName ];
  if (!retVal) {
    [super readFromFile:fileName ofType:docType];
  } else {
/*    [self setFileType:@"PrediBase"];
    [self setFileName:[prefixString stringByAppendingString:fileName]];
*/
    [self updateChangeCount:NSChangeDone];
  }
  //[self invalidate]; // jg 14.6.
  return retVal;
}

- (BOOL)loadOldPrediBase:(NSString *)fileName;
{
    NSString *sep=[[[self distributor] class] rubetteIndexSeparator];
    NSData *data=[NSData dataWithContentsOfFile:fileName];
    JGNXCompatibleUnarchiver *coder=[[JGNXCompatibleUnarchiver alloc] initForReadingWithData:data];
    NSEnumerator *e;
    id item;
    id myPredicateList,myFormList,myRubetteList,myWeightList;
    myPredicateList=[coder decodeObject];
    myFormList=[coder decodeObject];
    myRubetteList=[coder decodeObject];
    myWeightList=[coder decodeObject];

    [[self scorePredicate] addValue:myPredicateList];
    // forget myFormList // is it necessary to move all the form-pointers?
    e=[[myRubetteList values] objectEnumerator];
    while (item=[e nextObject]) {
        NSString *key=[NSString stringWithFormat:@"%@%@1",[item name],sep];
        [(GenericPredicate *)item setName:key];
        [self setPredicate:item forKey:key]; 
    }
    e=[myWeightList objectEnumerator];
    while (item=[e nextObject]) {
        const char *rn=[item rubetteName];
        NSString *key=[NSString stringWithFormat:@"%s%@1",rn,sep];
        if (rn)
            [self setWeight:item forKey:key];
    }
    return YES;
}

- (BOOL)loadPListFile:(NSString *)aFilename;
{ // rewrite myPredicateList
  /*
  if (aFilename) {
    JgPrediBase *pb=[[JgPrediBase alloc] init];

    [pb setFormManager:[[self distributor] globalFormManager]];
    if ([pb readPlist:aFilename]) {
        [pb plistToPreds];
        if (myPredicateList)
          [myPredicateList release];
//        [self addPredicate:[pb predicateList]];
        myPredicateList=[pb predicateList]; //jg?
    } else {
        return NO;
    }	
    return YES;
 } else return NO;
   */
  return NO;
}


- (BOOL)loadMidiFile:(NSString *)aFilename;
{
#ifdef WITHMUSICKIT
    if (aFilename) {
        int p, pc;
        id aScore, aMKPredList, aScoreFileReader;

        aScore = [[[MKScore setMidifilesEvaluateTempo:NO] allocWithZone:[self zone]]init];
        if ([aScore readMidifile:aFilename]) {
            id parts = [aScore parts];
            for (p=0, pc=[parts count]; p<pc; p++) {
                id part = [parts objectAtIndex:p];
                [part combineNotes];
                [part sort];
            }
//            [parts release]; // jg?? removed 15.02.2002
            //[self setScore:aScore];
            aScoreFileReader = [[MKScoreReader alloc]init];
            [aScoreFileReader setFormManager:self];
            aMKPredList = [aScoreFileReader makePredFromMKScore:aScore withName:NULL];
//            [self addPredicate:aMKPredList];
            [[self scorePredicate] addValue:aMKPredList];
            [aScoreFileReader release];

        } else {
            return NO;
        }	
        return YES;
    }
#else
NSRunAlertPanel(@"Load Score File", @"Cannont load Score and Midi file \nMusicKit is not included yet", @"Sorry", nil, nil);
#endif
    return NO;
}

- (BOOL)loadScoreFile:(NSString *)aFilename;
{
#ifdef WITHMUSICKIT
    if (aFilename) {
        id aScore, aMKPredList, aScoreFileReader;

        aScore = [[MKScore allocWithZone:[self zone]]init];
        if ([aScore readScorefile:aFilename]) {
            //[self setScore:aScore];
            aScoreFileReader = [[MKScoreReader alloc]init];
            [aScoreFileReader setFormManager:[[self distributor] globalFormManager]];
            aMKPredList = [aScoreFileReader makePredFromMKScore:aScore withName:NULL];
//    [self addPredicate:aMKPredList];
            [[self scorePredicate] addValue:aMKPredList];
            [aScoreFileReader release];

        } else {
            return NO;
        }	
        return YES;
    }
#else
  NSRunAlertPanel(@"Load Score File", @"Cannont load Score and Midi file \nMusicKit is not included yet", @"Sorry", nil, nil);
#endif
    return NO;
}

@end


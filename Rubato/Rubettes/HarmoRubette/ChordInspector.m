/* ChordInspector.m */


#import "ChordInspector.h"
#import <RubatoAnalysis/Chord.h>
#import <RubatoAnalysis/ThirdStream.h>
#import <Rubato/JGTitledScrollView.h>

@implementation ChordInspector

- init
{
    [super init];
    /* class-specific initialization goes here */
    return self;
}


- (void)dealloc
{
    /* class-specific initialization goes here */
  [super dealloc];
}

- (void)setValue:(id)sender;
{
    [super setValue:sender];
}

- displayPatient: sender
{
    id object, radiolist = [[myPitchClassView contentView] subviews];
    NSString *text;
    int i, c = [radiolist count];
    double level = 0.0, val = 0.0;
    

    [myOnsetField setDoubleValue:[patient onset]];
//    [myPitchCountField setIntValue:[patient pitchCount]]; // old
    [myPitchCountField setStringValue:[NSString stringWithFormat:@"%d: %@",[patient pitchCount],
      [patient pitchListStringWithPitchFormat:@"%1.1f" delimiter:@" " asInt:NO]]];

    text=[patient bestLocusName];
    if (!text)
      text=@"Out of harmonic context";
    [myBestPathLocusField setStringValue:text];
    
    for (i=0; i<c; i++) {
	object = [radiolist objectAtIndex:i];
	if ([object isKindOfClass:[NSButton class]])
	    [object setIntValue:[patient hasPitchClass:[object tag]]];
    }
    
    for (c=0; c<[patient locusCount]; c++) 
	val = MAX(val, [patient levelAtLocus:c]);

    {
      // Adjusting the riemannMatrix size
      NSDictionary *dict=[[patient ownerSequence] harmoSpace];
      NSArray *entry;
      entry=[dict objectForKey:@"Functions"];
      if (entry) {
        [[myRiemannMatrix jgTitledScrollView] setVerticalTitles:entry];
      }
      entry=[dict objectForKey:@"Tonalities"];
      if (entry) {
        [[myRiemannMatrix jgTitledScrollView] setHorizontalTitles:entry];
      }      
    }
    

    for (i=0; i<[patient functionCount]; i++)
	for (c=0; c<[patient tonalityCount]; c++) {
	    level = [patient levelAtFunction:i andTonality:c];
	    object = [myRiemannMatrix cellAtRow:i column:c];
	    [object setDoubleValue:level];
	    if (val>0)   // jg this switching is new.
     	      level = 1-(level/val);
            else 
              level = 1;
	    [object setBackgroundColor:[NSColor colorWithCalibratedWhite:level alpha:1.0]];
	    [object setTextColor:[NSColor colorWithCalibratedWhite:level<NSDarkGray ? NSWhite : NSBlack alpha:1.0]];
	}
    [self displayThirdStreamAt:0];
    [myThirdStreamCountField setIntValue:[[patient thirdStreamList]count]];
    return [super displayPatient:sender];
}

- displayThirdStreamAt:(int)index;
{
    int i, c, pc;
    id cell;
    ThirdStream *thirdStream;
    curThirdStreamIndex = index = mod(index, [[patient thirdStreamList]count]);
    thirdStream = [[patient thirdStreamList]objectAt:index];
    c = [thirdStream length];
    
    for (i=0; i<11; i++) {
	cell = [myThirdStreamMatrix cellWithTag:i];
	if (i<c) {
	    [cell setIntValue:[thirdStream thirdBitList] & 1<<i ? 4 : 3];
	    [cell setBordered:YES];
	} else {
	    [cell setStringValue:@""];
	    [cell setBordered:NO];
	}
    }
    
    for (i=0; i<12; i++) {
	cell = [myThirdStreamNamesMatrix cellWithTag:i];
	if (i<c+1) {
	    pc = [thirdStream pitchClassAt:i];
            [cell setStringValue:[patient pitchClassNameForIndex:pc]];
	    [cell setBackgroundColor:[NSColor colorWithCalibratedWhite:[patient hasPitchClass:pc] ? NSDarkGray : NSWhite alpha:1.0]];
	} else {
	    [cell setStringValue:@""];
//jg?#warning ColorConversion: [cell setDrawsBackground:NO] was [cell setBackgroundGray:-1]
	    [cell setDrawsBackground:NO];
	}
    }
    [myThirdStreamNumField setIntValue:curThirdStreamIndex+1];
    return self;
}

- displayNextThirdStream:sender;
{
    [self displayThirdStreamAt:++curThirdStreamIndex];
    return self;
}


@end

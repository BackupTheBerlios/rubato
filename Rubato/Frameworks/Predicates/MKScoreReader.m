#import <Rubato/RubatoTypes.h>

#ifdef WITHMUSICKIT
#import <MusicKit/MusicKit.h>
#endif

#import "MKScoreReader.h"

#import <Predicates/predikit.h>
#import <Rubato/RubatoController.h>

@implementation MKScoreReader

- init;
{
    [super init];
  myListForm=[CompoundForm listForm];
  myValueForm=[SimpleForm valueForm];
    return self;
}

- (void)dealloc;
{
    /* class-specific initialization goes here */

    return [super dealloc];
}

// jg?: does this awake some time? It ist not a Nib object, is it?
- (void)awakeFromNib;
{
   [self setFormManager:[owner globalFormManager]]; //jg warning is ok.
}

 - (void)setFormManager:(id )aFormManager;//<FormListProtocol>
{
  /*
//if ([aFormManager isKindOfClass:[FormManager class]]) {
  if ([aFormManager conformsToProtocol:@protocol(FormListProtocol)]) {
	myListForm = [[aFormManager formList] getFirstPredicateOfNameString:"MKValueListForm"];
	if (!myListForm) {
	    myListForm = [[CompoundForm allocWithZone:[self zone]]init];
	    [myListForm setTypeString:type_List];
	    [myListForm setNameString:"MKValueListForm"];
	    [myListForm setLocked:YES];
	    [myListForm setAllowsToChangeName:YES];
	    [myListForm setAllowsToChangeType:NO];
            [(id<FormListProtocol>)aFormManager addForm:myListForm];
	}
	
	myValueForm = [[aFormManager formList]  getFirstPredicateOfNameString:"MKValueForm"];
	if (!myValueForm) {
	    myValueForm = [[SimpleForm allocWithZone:[self zone]]init];
	    [myValueForm setTypeString:type_String];
	    [myValueForm setNameString:"MKValueForm"];
	    [myValueForm setLocked:YES];
	    [myValueForm setAllowsToChangeName:YES];
	    [myValueForm setAllowsToChangeType:NO];
            [(id<FormListProtocol>)aFormManager addForm:myValueForm];
	}
    }
   */
}

#ifdef WITHMUSICKIT
/* MusicKit to PrediKit object translation */
- makePredFromMKScore:(MKScore *)aScore withName:(const char *)aName;
{
    unsigned int i, count;
    char partName[15]; 
    id	aList, aMKListPredicate, aMKScorePredicate;

    count = [aScore partCount];
    /* get score info */
    aMKScorePredicate = [myListForm makePredicateFromZone:[self zone]];
    aMKListPredicate = [self makePredFromMKNote:[aScore infoNote] withName:"Score Info"];
    [aMKListPredicate setParent:aMKScorePredicate];
    [aMKScorePredicate setValue:aMKListPredicate];

    /* get the list of parts */
    aList = [aScore parts];

    /* get the name from the MKObject */ 
    if (MKGetObjectName(aScore))
	[aMKScorePredicate setNameString:[MKGetObjectName(aScore) cString]];
    else if(aName){
	[aMKScorePredicate setNameString:aName];
    } else {
	[aMKScorePredicate setNameString:"Score"];
    }

    for (i=0; i<count; i++) {
	sprintf(partName, "Part %d", i+1);
	aMKListPredicate = [self makePredFromMKPart:[aList objectAt:i] withName: partName];
	[aMKScorePredicate setValue:aMKListPredicate];
	[aMKListPredicate setParent:aMKScorePredicate];
    }
//    [aList release]; // jg removed 15.02.2002 there is no corresponding retain
    
    return aMKScorePredicate;
}

- makePredFromMKPart:(MKPart *)aPart withName:(const char *)aName;
{
    unsigned int i, count; 
    id	aList,aMKNotePredicate, aMKPartPredicate;

    /* prepare the part */
    [aPart sort];
    [aPart combineNotes];
    [aPart sort];
    /* get part info */
    count = [aPart noteCount];
    aMKPartPredicate = [myListForm makePredicateFromZone:[self zone]];
    aMKNotePredicate = [self makePredFromMKNote:[aPart infoNote] withName:"Part Info"];
    [aMKNotePredicate setParent: aMKNotePredicate];
    [aMKPartPredicate setValue:aMKNotePredicate];

    /* get the list of notes */
    aList = [aPart notes];

    /* get the name from the MKObject */ 
    if (MKGetObjectName(aPart))
	[aMKPartPredicate setNameString:[MKGetObjectName(aPart) cString]];
    else if(aName){
	[aMKPartPredicate setNameString:aName];
    } else {
	[aMKPartPredicate setNameString:"Part"];
    }

    for (i=0; i<count; i++) {
	aMKNotePredicate = [self makePredFromMKNote:[aList objectAt:i] withName:(char *)nil];
	[aMKPartPredicate setValue:aMKNotePredicate];
	[aMKNotePredicate setParent:aMKPartPredicate];
    }
//    [aList release]; // jg removed 15.02.2002 there is no corresponding retain
    
    return aMKPartPredicate;
}

- makePredFromMKNote:(MKNote *)aNote withName:(const char *)aName;
{
    void *aState;
    int par;
    id	aPred = nil, aMKNotePredicate;
    double aDVal;
    MKNoteType myNoteType;
    
    aMKNotePredicate = [myListForm makePredicateFromZone:[self zone]];

    myNoteType = [aNote noteType];
    if (MKGetObjectName(aNote))
	[aMKNotePredicate setNameString:[MKGetObjectName(aNote) cString]];
    else if(aName){
	[aMKNotePredicate setNameString:aName];
    } else {
	switch (myNoteType) {
	    case MK_mute:
		[aMKNotePredicate setNameString:"Muted"];
		break;
	    case MK_noteOn:
		[aMKNotePredicate setNameString:"Note ON"];
		break;
	    case MK_noteOff:
		[aMKNotePredicate setNameString:"Note OFF"];
		break;
	    case MK_noteDur:
		[aMKNotePredicate setNameString:"Note"];
		break;
	    case MK_noteUpdate:
		[aMKNotePredicate setNameString:"Note Update"];
		break;
	    default:
		[aMKNotePredicate setNameString:"Event"];
		break;
	}
    }
    if (!aNote) 
	return aMKNotePredicate; /* break here if no note */
    
    aDVal = [aNote timeTag];
    if (aDVal!=MK_ENDOFTIME && !MKIsNoDVal(aDVal)) {
	aDVal /= 4;
	aPred = [myValueForm makePredicateFromZone:[self zone]];
	[aPred setNameString:strE];
	[aPred setDoubleValue:aDVal];
	[aPred setTag:myNoteType];
	[aPred setParent: aMKNotePredicate];
	[aMKNotePredicate setValueAt:indexE to:aPred];
    }	
	
    if (MKIsNoteParPresent(aNote, MK_freq) || 
	MKIsNoteParPresent(aNote, MK_keyNum)) {
	/* Get the value of MK_keyNum and apply it. */
	aPred = [myValueForm makePredicateFromZone:[self zone]];
	[aPred setNameString:strH];
	[aPred setIntValue:[aNote keyNum]];
	[aPred setTag:MK_keyNum];
	[aPred setParent: aMKNotePredicate];
	[aMKNotePredicate setValueAt: indexH to:aPred];
    }	
	
    if (MKIsNoteParPresent(aNote, MK_velocity)) {
	/* Key velocity for noteOns -- also used as a 
	brightness and amp in Orchestra synthesis. */
	aPred = [myValueForm makePredicateFromZone:[self zone]];
	[aPred setNameString:strL];
	[aPred setStringValue:[aNote parAsString:MK_velocity]];
	[aPred setTag:MK_velocity];
	[aPred setParent: aMKNotePredicate];
	[aMKNotePredicate setValueAt: indexL to:aPred];
    }	
    
    aDVal = [aNote dur];
    if (!MKIsNoDVal(aDVal)) {
	aDVal /= 4;
	aPred = [myValueForm makePredicateFromZone:[self zone]];
	[aPred setNameString:strD];
	[aPred setDoubleValue:aDVal];
	[aPred setTag:MK_noteDur];
	[aPred setParent: aMKNotePredicate];
	[aMKNotePredicate setValueAt: indexD to:aPred];
    }	
	
    if (MKIsNoteParPresent(aNote, MK_relVelocity)) {
	/* Release key velocity. Asociated with noteOffs. */
	aPred = [myValueForm makePredicateFromZone:[self zone]];
	[aPred setNameString:strC];
//	if (!MKIsNoDVal(MKGetNoteParAsDouble(aNote, MK_velocity))
//	  & !MKIsNoDVal(MKGetNoteParAsDouble(aNote, MK_relVelocity))) {
	if (!MKIsNoDVal(MKGetNoteParAsDouble(aNote, MK_velocity))
     && !MKIsNoDVal(MKGetNoteParAsDouble(aNote, MK_relVelocity))) { // jg: this is, where an assertion error occours in MusicKit.
	    [aPred setDoubleValue:[aNote parAsDouble:MK_relVelocity]-
				    [aNote parAsDouble:MK_velocity]];
	} else {
	    [aPred setStringValue:[aNote parAsString:MK_relVelocity]];
	}
	[aPred setTag:MK_relVelocity];
	[aPred setParent: aMKNotePredicate];
	[aMKNotePredicate setValueAt: indexC to:aPred];
    }
    
    
    if (MKIsNoteParPresent(aNote, MK_freq)) {
	/* Get the value of MK_freq and apply it. */
	aPred = [myValueForm makePredicateFromZone:[self zone]];
	[aPred setNameString:"Frequency [Hz]"];
	[aPred setDoubleValue:[aNote freq]];
	[aPred setTag:MK_freq];
	[aPred setParent: aMKNotePredicate];
	[aMKNotePredicate setValue:aPred];
    }

    if (MKIsNoteParPresent(aNote, MK_amp)) {
	/* Get the value of MK_amp and apply it. */
	if (!strcmp([MKGetNoteParAsString(aNote, MK_amp) cString],nilStr)){
	    aPred = [myValueForm makePredicateFromZone:[self zone]];
	    [aPred setNameString:"Amplitude [dB]"];
	    [aPred setStringValue:[aNote parAsString:MK_amp]];
	    [aPred setTag:MK_amp];
	    [aPred setParent: aMKNotePredicate];
	    [aMKNotePredicate setValue:aPred];
	}
    }
    
    aState = MKInitParameterIteration(aNote);
    /* Get the parameters until the Note is exhausted. */
    while ((par = MKNextParameter(aNote, aState)) != MK_noPar)
    {
	/* Operate on the parameters of interest. */
	switch (par) 
	{
	    /* MIDI opcodes are represented by the presence of 
	     * one of the following 12 parameters, along with 
	     * the noteType
	     */
	    case MK_keyPressure:
	    /* MIDI voice msg. (See MIDI spec) */
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Key Pressure"];
		[aPred setIntValue:[aNote parAsInt:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    case MK_afterTouch:
	    /* MIDI voice msg */
	    
	    case MK_controlChange:
	    /* MIDI voice msg */
	    
	    case MK_pitchBend:
	    /* MIDI voice msg. Stored as 14-bit signed quantity, centered on 0x2000. */
		if (aPred = [aMKNotePredicate getFirstPredicateOfNameString:strH]) {
		    int pitchBend = [aNote parAsInt:par];
		    double freq, result, semitones;
		    freq = MKKeyNumToFreq([aPred intValue]);
		    result = MKAdjustFreqWithPitchBend(freq, pitchBend, 1.0);
		    semitones = 12*(log(result)-log(freq))/log(2);
		    [aPred setDoubleValue:[aPred doubleValue]+semitones];
		} else {
		    aPred = [myValueForm makePredicateFromZone:[self zone]];
		    [aPred setNameString:"Pitch Bend"];
		    [aPred setIntValue:[aNote parAsInt:par]];
		    [aPred setTag:par];
		    [aPred setParent: aMKNotePredicate];
		    [aMKNotePredicate setValue:aPred];
		}
		break;
	    case MK_programChange:
	    /* MIDI voice msg */ 
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Program Change"];
		[aPred setIntValue:[aNote parAsInt:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    case MK_timeCodeQ:
	    /* MIDI time code, quarter frame */
	    
	    case MK_songPosition:
	    /* MIDI system common msg (See MIDI spec) */
	    
	    case MK_songSelect:
	    /* MIDI system common msg */
	    
	    case MK_tuneRequest:
	    /* MIDI system common message. Significant by its presence alone. Its value is irrelevant. */
	    
	    case MK_sysExclusive:
	    /* MIDI system exclusive string (See MIDI Spec) */
	    
	    case MK_chanMode:
	    /* MIDI chan mode msg: takes a MKMidiParVal val */
	    
	    case MK_sysRealTime:
	    /* MIDI real time msg: takes a MKMidiParVal */ 

	    /* The remaining MIDI parameters provide additional 
	     * data needed to fully represent MIDI messages.
	     */ 

	    case MK_basicChan:
	    /* MIDI basic channel for MIDI mode messages */
	    
	    case MK_controlVal:
	    /* MIDI Controller value for MK_controlChange */
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Pitch Bend"];
		[aPred setIntValue:[aNote parAsInt:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    case MK_monoChans:
	    /* An arg for the MIDI monoMode msg arg */
	    
	    case MK_tempo:
	    /* Suggested performance tempo for the default conductor. 
	    	When a MIDI file is read, this parameter appears in the 
		score info note if the MIDI file has a tempo specified. */
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"BPM"];
		[aPred setStringValue:[aNote parAsString:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		if(!MKGetObjectName(aNote) && !aName)
		    [aMKNotePredicate setNameString:"Tempo"];
		break;
	    case MK_midiChan:
	    /* A suggested midi channel to which the app may want 
	    to connect to playing this part on MidiOut. */
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Midi Channel"];
		[aPred setIntValue:[aNote parAsInt:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    case MK_track:
		/* Track number. Set in Part info when a midifile is read.*/ 
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Midi Track"];
		[aPred setIntValue:[aNote parAsInt:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    case MK_sequence:
		/* Sequence number may be in the Part info. */  
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Midi Sequence"];
		[aPred setIntValue:[aNote parAsInt:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    case MK_title:
	    	/* A name for the piece. Used in Score info. */
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Title"];
		[aPred setStringValue:[aNote parAsString:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    case MK_text:
	    	/* Any text describing anything. */
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Text"];
		[aPred setStringValue:[aNote parAsString:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    case MK_copyright:
	    	/* Copyright notice. May be in Score info */
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Copyright Notice"];
		[aPred setStringValue:[aNote parAsString:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    case MK_lyric:
	    	/* Lyric to be sung */
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Lyric"];
		[aPred setStringValue:[aNote parAsString:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    case MK_marker:
	    	/* Rehearsal letter or section name */
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Marker"];
		[aPred setStringValue:[aNote parAsString:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    case MK_timeSignature: {
		/* Encoded as a string of 4 hex numbers, 
		separated by spaces. See MIDI file spec. */
		char *suffixStr;
                int int1,int2;// jg
		//id strVal;
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Time Signature"];

/*		strVal = [aPred getStringValue];
                [strVal setIntValue:strtol([[aNote parAsString:par] cString], &suffixStr, 16)];
		[[strVal concat:"/"]concatInt:pow(2,strtol(suffixStr, NULL, 16))];
*/ // jg Change:
                int1=strtol([[aNote parAsString:par] cString], &suffixStr, 16);
                int2=pow(2,strtol(suffixStr, NULL, 16));
                [aPred setStringValue:[NSString stringWithFormat:@"%d/%d",int1,int2]];

		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    }
	    case MK_keySignature: {
		/* Encoded as a string of 2 hex numbers, 
		separated by a space. See MIDI file spec. */
		char *key = "", *suffixStr;
		int mode, sign = strtol([[aNote parAsString:par] cString], &suffixStr, 16);
		mode = strtol(suffixStr, NULL, 16);
		switch(sign) {
		    case  7: key = mode ? "c#" : "C#"; break;
		    case  6: key = mode ? "f#" : "F#"; break;
		    case  5: key = mode ? "h"  : "H" ; break;
		    case  4: key = mode ? "e"  : "E" ; break;
		    case  3: key = mode ? "a"  : "A" ; break;
		    case  2: key = mode ? "d"  : "D" ; break;
		    case  1: key = mode ? "g"  : "G" ; break;
		    case  0: key = mode ? "c"  : "C" ; break;
		    case -1: key = mode ? "f"  : "F" ; break;
		    case -2: key = mode ? "b"  : "B" ; break;
		    case -3: key = mode ? "eb" : "Eb"; break;
		    case -4: key = mode ? "ab" : "Ab"; break;
		    case -5: key = mode ? "db" : "Db"; break;
		    case -6: key = mode ? "gb" : "Gb"; break;
		    case -7: key = mode ? "cb" : "Cb"; break;
		}
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Key Signature"];
		[aPred setStringValue:[NSString jgStringWithCString:key]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    }
	    case MK_instrumentName:
	    	/* Instrumentation to be used in the track */
		aPred = [myValueForm makePredicateFromZone:[self zone]];
		[aPred setNameString:"Instrument"];
		[aPred setStringValue:[aNote parAsString:par]];
		[aPred setTag:par];
		[aPred setParent: aMKNotePredicate];
		[aMKNotePredicate setValue:aPred];
		break;
	    }
    }

    return aMKNotePredicate;
}
#endif

@end

/* PrimaVistaPreferences.m */

#import <AppKit/NSForm.h>

#import "PrimaVistaPreferences.h"

@implementation PrimaVistaPreferences

- init;
{
    [super init];
    myFiletype = PV_PREF_FILETYPE;
    
    return self;
}

- (void)dealloc;
{
    return [self release];
}


- (void)awakeFromNib;
{
    [super awakeFromNib];
    if (!useFile) {
	[self resetAbsDynPrefValues:self];
	[self resetAbsDynPrefNames:self];
	[self resetRelDynPrefValues:self];
	[self resetRelDynPrefNames:self];
	[self resetRelTpoPrefValues:self];
	[self resetRelTpoPrefNames:self];
	[self resetArtiPrefValues:self];
	[self resetArtiPrefNames:self];
	
	[self collectPrefs];
    }
}


- showPrefs:sender;
{
    NSMutableString *mutableString = [NSMutableString new];
    [self appendPrefsToString:mutableString];
    
    [prefText setString:mutableString];
    
    return self;
}

- resetAbsDynPrefValues:sender;
{
    [[myAbsDynValueMatrix cellWithTag:PV_ppppp] setDoubleValue:1];
    [[myAbsDynValueMatrix cellWithTag:PV_mpppp] setDoubleValue:8];
    [[myAbsDynValueMatrix cellWithTag:PV_pppp] setDoubleValue:15];
    [[myAbsDynValueMatrix cellWithTag:PV_mppp] setDoubleValue:22];
    [[myAbsDynValueMatrix cellWithTag:PV_ppp] setDoubleValue:29];
    [[myAbsDynValueMatrix cellWithTag:PV_mpp] setDoubleValue:36];
    [[myAbsDynValueMatrix cellWithTag:PV_pp] setDoubleValue:43];
    [[myAbsDynValueMatrix cellWithTag:PV_mp] setDoubleValue:50];
    [[myAbsDynValueMatrix cellWithTag:PV_p] setDoubleValue:57];
    [[myAbsDynValueMatrix cellWithTag:PV_mf] setDoubleValue:64];
    [[myAbsDynValueMatrix cellWithTag:PV_f] setDoubleValue:71];
    [[myAbsDynValueMatrix cellWithTag:PV_mff] setDoubleValue:78];
    [[myAbsDynValueMatrix cellWithTag:PV_ff] setDoubleValue:85];
    [[myAbsDynValueMatrix cellWithTag:PV_mfff] setDoubleValue:92];
    [[myAbsDynValueMatrix cellWithTag:PV_fff] setDoubleValue:99];
    [[myAbsDynValueMatrix cellWithTag:PV_mffff] setDoubleValue:106];
    [[myAbsDynValueMatrix cellWithTag:PV_ffff] setDoubleValue:113];
    [[myAbsDynValueMatrix cellWithTag:PV_mfffff] setDoubleValue:120];
    [[myAbsDynValueMatrix cellWithTag:PV_fffff] setDoubleValue:127];
    
    return self;
}

- resetAbsDynPrefNames:sender;
{
    [[myAbsDynNameMatrix cellWithTag:PV_ppppp] setStringValue:@"ppppp"];
    [[myAbsDynNameMatrix cellWithTag:PV_mpppp] setStringValue:@"mpppp"];
    [[myAbsDynNameMatrix cellWithTag:PV_pppp] setStringValue:@"pppp"];
    [[myAbsDynNameMatrix cellWithTag:PV_mppp] setStringValue:@"mppp"];
    [[myAbsDynNameMatrix cellWithTag:PV_ppp] setStringValue:@"ppp"];
    [[myAbsDynNameMatrix cellWithTag:PV_mpp] setStringValue:@"mpp"];
    [[myAbsDynNameMatrix cellWithTag:PV_pp] setStringValue:@"pp"];
    [[myAbsDynNameMatrix cellWithTag:PV_mp] setStringValue:@"mp"];
    [[myAbsDynNameMatrix cellWithTag:PV_p] setStringValue:@"p"];
    [[myAbsDynNameMatrix cellWithTag:PV_mf] setStringValue:@"mf"];
    [[myAbsDynNameMatrix cellWithTag:PV_f] setStringValue:@"f"];
    [[myAbsDynNameMatrix cellWithTag:PV_mff] setStringValue:@"mff"];
    [[myAbsDynNameMatrix cellWithTag:PV_ff] setStringValue:@"ff"];
    [[myAbsDynNameMatrix cellWithTag:PV_mfff] setStringValue:@"mfff"];
    [[myAbsDynNameMatrix cellWithTag:PV_fff] setStringValue:@"fff"];
    [[myAbsDynNameMatrix cellWithTag:PV_mffff] setStringValue:@"mffff"];
    [[myAbsDynNameMatrix cellWithTag:PV_ffff] setStringValue:@"ffff"];
    [[myAbsDynNameMatrix cellWithTag:PV_mfffff] setStringValue:@"mfffff"];
    [[myAbsDynNameMatrix cellWithTag:PV_fffff] setStringValue:@"fffff"];
    
    return self;
}

- resetRelDynPrefValues:sender;
{
    [[myRelDynValueMatrix cellWithTag:PV_moltodim] setDoubleValue:50];
    [[myRelDynValueMatrix cellWithTag:PV_dim] setDoubleValue:62.5];
    [[myRelDynValueMatrix cellWithTag:PV_cresc] setDoubleValue:160];
    [[myRelDynValueMatrix cellWithTag:PV_moltocresc] setDoubleValue:200];

    [myRelDynToleranceField setDoubleValue:10];
    return self;
}

- resetRelDynPrefNames:sender;
{
    [[myRelDynNameMatrix cellWithTag:PV_moltodim] setStringValue:@"molto diminuendo"];
    [[myRelDynNameMatrix cellWithTag:PV_dim] setStringValue:@"diminuendo"];
    [[myRelDynNameMatrix cellWithTag:PV_cresc] setStringValue:@"crescendo"];
    [[myRelDynNameMatrix cellWithTag:PV_moltocresc] setStringValue:@"molto crescendo"];
    
    return self;
}

- resetRelTpoPrefValues:sender;
{
    [[myRelTpoValueMatrix cellWithTag:PV_moltoritard] setDoubleValue:50];
    [[myRelTpoValueMatrix cellWithTag:PV_ritard] setDoubleValue:80];
    [[myRelTpoValueMatrix cellWithTag:PV_accel] setDoubleValue:125];
    [[myRelTpoValueMatrix cellWithTag:PV_moltoaccel] setDoubleValue:200];
    [[myRelTpoValueMatrix cellWithTag:PV_fermata] setDoubleValue:50];
    [[myRelTpoValueMatrix cellWithTag:PV_fermatashift] setDoubleValue:100];
    [[myRelTpoValueMatrix cellWithTag:PV_fermatadelay] setDoubleValue:5];
    
    return self;
}

- resetRelTpoPrefNames:sender;
{
    [[myRelTpoNameMatrix cellWithTag:PV_moltoritard] setStringValue:@"molto ritardando"];
    [[myRelTpoNameMatrix cellWithTag:PV_ritard] setStringValue:@"ritardando"];
    [[myRelTpoNameMatrix cellWithTag:PV_accel] setStringValue:@"accelerando"];
    [[myRelTpoNameMatrix cellWithTag:PV_moltoaccel] setStringValue:@"molto accelerando"];
    [[myRelTpoNameMatrix cellWithTag:PV_fermata] setStringValue:@"fermata"];
    
    return self;
}

- resetArtiPrefValues:sender;
{
    [[myArtiValueMatrix cellWithTag:PV_moltostaccato] setDoubleValue:20];
    [[myArtiValueMatrix cellWithTag:PV_staccato] setDoubleValue:60];
    [[myArtiValueMatrix cellWithTag:PV_nonlegato] setDoubleValue:80];
    [[myArtiValueMatrix cellWithTag:PV_legato] setDoubleValue:120];
    [[myArtiValueMatrix cellWithTag:PV_moltolegato] setDoubleValue:150];
    
    return self;
}

- resetArtiPrefNames:sender;
{
    [[myArtiNameMatrix cellWithTag:PV_moltostaccato] setStringValue:@"molto staccato"];
    [[myArtiNameMatrix cellWithTag:PV_staccato] setStringValue:@"staccato"];
    [[myArtiNameMatrix cellWithTag:PV_nonlegato] setStringValue:@"non legato"];
    [[myArtiNameMatrix cellWithTag:PV_legato] setStringValue:@"legato"];
    [[myArtiNameMatrix cellWithTag:PV_moltolegato] setStringValue:@"molto legato"];

    return self;
}

- (double)relDynTolerance;
{
    return [self doubleValueOfParameter:REL_DYN_TOLERANCE_VAL];
}


- takeAbsDynValueFrom:sender;
{
    [self collectAbsoluteDynamicPrefs];
    return self;
}

- (const char*) absDynParaValueNameAt:(int)index;
{
    [myConverter setStringValue:[NSString jgStringWithCString:ABS_DYN_VALUES]];
    [myConverter concat:" "];
    [myConverter concatInt:index+1];
    return [[myConverter stringValue] cString]; //JGUniqueString([[myConverter stringValue] cString]);
}

- (const char*) absDynParaNameNameAt:(int)index;
{
    [myConverter setStringValue:[NSString jgStringWithCString:ABS_DYN_NAMES]];
    [myConverter concat:" "];
    [myConverter concatInt:index+1];
    return [[myConverter stringValue] cString]; //JGUniqueString([[myConverter stringValue] cString]);
}

- (int) indexOfAbsDynName:(const char*)aName;
{
    int i;
    const char *str;
    if (aName) {
	for (i=0; i<ABSDYN_RANGE && 
	    strcmp(aName, ((str=[self stringValueOfParameter:[self absDynParaNameNameAt:i]]) ? str : "")); i++);
	if (i<ABSDYN_RANGE)
	    return i;
    }
    return NSNotFound;
}

- (double)absDynValueAt:(int)index;
{
    return [self doubleValueOfParameter:[self absDynParaValueNameAt:index]];
}


- takeRelDynValueFrom:sender;
{
    [self collectRelativeDynamicPrefs];
    return self;
}

- (const char*) relDynParaValueNameAt:(int)index;
{
    switch(index) {
	case PV_moltodim: return MOLTO_DIM_VAL;
	case PV_dim: return DIMINUENDO_VAL;
	case PV_cresc: return CRESCENDO_VAL;
	case PV_moltocresc: return MOLTO_CRESC_VAL;
    }
    return "";
}

- (const char*) relDynParaNameNameAt:(int)index;
{
    switch(index) {
	case PV_moltodim: return MOLTO_DIM_NAME;
	case PV_dim: return DIMINUENDO_NAME;
	case PV_cresc: return CRESCENDO_NAME;
	case PV_moltocresc: return MOLTO_CRESC_NAME;
    }
    return "";
}

- (int) indexOfRelDynName:(const char*)aName;
{
    int i;
    const char *str;
    if (aName) {
	for (i=0; i<RELDYN_RANGE && 
	    strcmp(aName, ((str=[self stringValueOfParameter:[self relDynParaNameNameAt:i]]) ? str : "")); i++);
	if (i<RELDYN_RANGE)
	    return i;
    }
    return NSNotFound;
}

- (double)relDynValueAt:(int)index;
{
    [myConverter setStringValue:[NSString jgStringWithCString:[self relDynParaValueNameAt:index]]];
    return [self doubleValueOfParameter:[[myConverter stringValue] cString]];
}


- takeRelTpoValueFrom:sender;
{
    [self collectTempoPrefs];
    return self;
}

- (const char*) relTpoParaValueNameAt:(int)index;
{
    switch(index) {
	case PV_moltoritard: return MOLTO_RIT_VAL;
	case PV_ritard: return RITARDANDO_VAL;
	case PV_accel: return ACCELERANDO_VAL;
	case PV_moltoaccel: return MOLTO_ACC_VAL;
	case PV_fermata: return FERMATA_VAL;
	case PV_fermatashift: return FERMATA_SHIFT_VAL;
	case PV_fermatadelay: return FERMATA_DELAY_VAL;
    }
    return "";
}

- (const char*) relTpoParaNameNameAt:(int)index;
{
    switch(index) {
	case PV_moltoritard: return MOLTO_RIT_NAME;
	case PV_ritard: return RITARDANDO_NAME;
	case PV_accel: return ACCELERANDO_NAME;
	case PV_moltoaccel: return MOLTO_ACC_NAME;
	case PV_fermata: return FERMATA_NAME;
	case PV_fermatashift: return FERMATA_SHIFT_NAME;
	case PV_fermatadelay: return FERMATA_DELAY_NAME;
    }
    return "";
}

- (int) indexOfRelTpoName:(const char*)aName;
{
    int i;
    const char *str;
    if (aName) {
	for (i=0; i<RELTPO_RANGE && 
	    strcmp(aName, ((str=[self stringValueOfParameter:[self relTpoParaNameNameAt:i]]) ? str : "")); i++);
	if (i<RELTPO_RANGE)
	    return i;
    }
    return NSNotFound;
}

- (double)relTpoValueAt:(int)index;
{
    [myConverter setStringValue:[NSString jgStringWithCString:[self relTpoParaValueNameAt:index]]];
    return [self doubleValueOfParameter:[[myConverter stringValue] cString]];
}


- takeArtiValueFrom:sender;
{
    [self collectArticulationPrefs];
    return self;
}

- (const char*) artiParaValueNameAt:(int)index;
{
    switch(index) {
	case PV_moltostaccato: return MOLTO_STACCATO_VAL;
	case PV_staccato: return STACCATO_VAL;
	case PV_nonlegato: return NON_LEGATO_VAL;
	case PV_legato: return LEGATO_VAL;
	case PV_moltolegato: return MOLTO_LEGATO_VAL;
    }
    return "";
}

- (const char*) artiParaNameNameAt:(int)index;
{
    switch(index) {
	case PV_moltostaccato: return MOLTO_STACCATO_NAME;
	case PV_staccato: return STACCATO_NAME;
	case PV_nonlegato: return NON_LEGATO_NAME;
	case PV_legato: return LEGATO_NAME;
	case PV_moltolegato: return MOLTO_LEGATO_NAME;
    }
    return "";
}

- (int) indexOfArtiName:(const char*)aName;
{
    int i;
    const char *str;
    if (aName) {
	for (i=0; i<ARTI_RANGE && 
	    strcmp(aName, ((str=[self stringValueOfParameter:[self artiParaNameNameAt:i]]) ? str : "")); i++);
	if (i<ARTI_RANGE)
	    return i;
    }
    return NSNotFound;
}

- (double)artiValueAt:(int)index;
{
    [myConverter setStringValue:[NSString jgStringWithCString:[self artiParaValueNameAt:index]]];
    return [self doubleValueOfParameter:[[myConverter stringValue] cString]];
}

- collectPrefs;
{
    [self collectAbsoluteDynamicPrefs];
    [self collectRelativeDynamicPrefs];
    [self collectTempoPrefs];
    [self collectArticulationPrefs];
    return self;
}

- displayPrefs;
{
    [self displayAbsoluteDynamicPrefs];
    [self displayRelativeDynamicPrefs];
    [self displayTempoPrefs];
    [self displayArticulationPrefs];
    return self;
}

- collectAbsoluteDynamicPrefs;
{
    int i;
    double val=0;
    for (i=0; i<ABSDYN_RANGE; i++) {
	[self setParameter:[self absDynParaValueNameAt:i] 
	    toDoubleValue:val=[[myAbsDynValueMatrix cellWithTag:i]doubleValue]];
	[[myAbsDynSlideMatrix cellWithTag:i] setDoubleValue:val];
	[self setParameter:[self absDynParaNameNameAt:i] 
	    toStringValue:[[[myAbsDynNameMatrix cellWithTag:i] stringValue] cString]];
    }
    return self;
}

- collectRelativeDynamicPrefs;
{
    int i;
    [self setParameter:REL_DYN_TOLERANCE_VAL toDoubleValue:fabs([myRelDynToleranceField doubleValue])];

    for (i=0; i<RELDYN_RANGE; i++) {
	[self setParameter:[self relDynParaValueNameAt:i]
	    toDoubleValue:[[myRelDynValueMatrix cellWithTag:i] doubleValue]/100];
	[self setParameter:[self relDynParaNameNameAt:i] 
	    toStringValue:[[[myRelDynNameMatrix cellWithTag:i] stringValue] cString]];
    }
    return self;
}

- collectTempoPrefs;
{
    int i;
    for (i=0; i<RELTPO_RANGE; i++) {
	if (i<RELTPO_RANGE-1)
	    [self setParameter:[self relTpoParaValueNameAt:i] 
		toDoubleValue:[[myRelTpoValueMatrix cellWithTag:i] doubleValue]/100];
	else {
	    double val = [[myRelTpoValueMatrix cellWithTag:i] doubleValue];
	    val = val<50 ? val : 50-EPSILON;
	    [self setParameter:[self relTpoParaValueNameAt:i] 
		toDoubleValue:val/100];
	}
	[self setParameter:[self relTpoParaNameNameAt:i] 
	    toStringValue:[[[myRelTpoNameMatrix cellWithTag:i] stringValue] cString]];
    }
    return self;
}

- collectArticulationPrefs;
{
    int i;
    for (i=0; i<ARTI_RANGE; i++) {
	[self setParameter:[self artiParaValueNameAt:i] 
	    toDoubleValue:[[myArtiValueMatrix cellWithTag:i] doubleValue]/100];
	[self setParameter:[self artiParaNameNameAt:i] 
	    toStringValue:[[[myArtiNameMatrix cellWithTag:i] stringValue] cString]];
    }
    return self;
}



- displayAbsoluteDynamicPrefs;
{
    int i;
    double val=0;
    for (i=0; i<ABSDYN_RANGE; i++) {
	[[myAbsDynValueMatrix cellWithTag:i] setDoubleValue:val=[self doubleValueOfParameter:[self absDynParaValueNameAt:i]]];
	[[myAbsDynSlideMatrix cellWithTag:i] setDoubleValue:val];
	[[myAbsDynNameMatrix cellWithTag:i] setStringValue:[NSString jgStringWithCString:[self stringValueOfParameter:[self absDynParaNameNameAt:i]]]];
    }
    return self;
}

- displayRelativeDynamicPrefs;
{
    int i;
    [myRelDynToleranceField setDoubleValue:[self doubleValueOfParameter:REL_DYN_TOLERANCE_VAL]];

    for (i=0; i<RELDYN_RANGE; i++) {
	[[myRelDynValueMatrix cellWithTag:i] setDoubleValue:[self doubleValueOfParameter:[self relDynParaValueNameAt:i]]*100];
	[[myRelDynNameMatrix cellWithTag:i] setStringValue:[NSString jgStringWithCString:[self stringValueOfParameter:[self relDynParaNameNameAt:i]]]];
    }
    return self;
}

- displayTempoPrefs;
{
    int i;
    for (i=0; i<RELTPO_RANGE; i++) {
	[[myRelTpoValueMatrix cellWithTag:i] setDoubleValue:[self doubleValueOfParameter:[self relTpoParaValueNameAt:i]]*100];
	[[myRelTpoNameMatrix cellWithTag:i] setStringValue:[NSString jgStringWithCString:[self stringValueOfParameter:[self relTpoParaNameNameAt:i]]]];
    }
    return self;
}

- displayArticulationPrefs;
{
    int i;
    for (i=0; i<ARTI_RANGE; i++) {
	[[myArtiValueMatrix cellWithTag:i] setDoubleValue:[self doubleValueOfParameter:[self artiParaValueNameAt:i]]*100];
	[[myArtiNameMatrix cellWithTag:i] setStringValue:[NSString jgStringWithCString:[self stringValueOfParameter:[self artiParaNameNameAt:i]]]];
    }
    return self;
}



@end
/* PrimaVistaPreferences.h */

#import <Rubato/Preferences.h>

#import "PVTypes.h"

#define PV_PREF_FILETYPE "PVPrefs"

/* Name Definition of Default Weight Names */
#define ARTI_WEIGHT_NAME "PV Articulation"
#define DYN_WEIGHT_NAME "PV Dynamics"
#define TPO_WEIGHT_NAME "PV Tempo"
#define CSTM1D_WEIGHT_NAME "PV Custom 1D"
#define CSTM2D_WEIGHT_NAME "PV Custom 2D"

/* Name Definition of Parameter VALUES for myParameterTable */
#define REL_DYN_TOLERANCE_VAL "Relative Dynamics Tolerance Value"
#define ABS_DYN_VALUES "Absolute Dynamics Value"
#define REL_TPO_VALUES "Relative Tempo Values"

#define MOLTO_DIM_VAL "Molto Diminuendo Value"
#define	DIMINUENDO_VAL "Diminuendo Value"
#define	CRESCENDO_VAL "Crescendo Value"
#define MOLTO_CRESC_VAL "Molto Crescendo Value"

#define MOLTO_RIT_VAL "Molto Ritardando Value"
#define RITARDANDO_VAL "Ritardando Value"
#define ACCELERANDO_VAL "Accelerando Value"
#define MOLTO_ACC_VAL "Molto Accelerando Value"
#define FERMATA_VAL "Fermata Value"
#define FERMATA_SHIFT_VAL "Fermata Shift Value"
#define FERMATA_DELAY_VAL "Fermata Delay Value"

#define MOLTO_STACCATO_VAL "Molto Staccato Value"
#define STACCATO_VAL "Staccato Value"
#define NON_LEGATO_VAL "Non Legato Value"
#define LEGATO_VAL "Legato Value"
#define MOLTO_LEGATO_VAL "Molto Legato Value"

/* Name Definition of Parameter NAMES for myParameterTable */
#define REL_DYN_TOLERANCE_NAME "Relative Dynamics Tolerance Name"
#define ABS_DYN_NAMES "Absolute Dynamics Name"
#define REL_TPO_NAMES "Relative Tempo Names"
#define ABS_TPO_NAME "Tempo"
#define ABS_TPO_VALUE_NAME "BPM"
#define CUSTOM_PV_VALUE_NAME "PV"
#define ARTI_NAME "Articulation Name"

#define MOLTO_DIM_NAME "Molto Diminuendo Name"
#define	DIMINUENDO_NAME "Diminuendo Name"
#define	CRESCENDO_NAME "Crescendo Name"
#define MOLTO_CRESC_NAME "Molto Crescendo Name"

#define MOLTO_RIT_NAME "Molto Ritardando Name"
#define RITARDANDO_NAME "Ritardando Name"
#define ACCELERANDO_NAME "Accelerando Name"
#define MOLTO_ACC_NAME "Molto Accelerando Name"
#define FERMATA_NAME "Fermata Name"
#define FERMATA_SHIFT_NAME "Fermata Shift Name"
#define FERMATA_DELAY_NAME "Fermata Delay Name"

#define MOLTO_STACCATO_NAME "Molto Staccato Name"
#define STACCATO_NAME "Staccato Name"
#define NON_LEGATO_NAME "Non Legato Name"
#define LEGATO_NAME "Legato Name"
#define MOLTO_LEGATO_NAME "Molto Legato Name"


@interface PrimaVistaPreferences : Preferences
{
    //double myPtDynIncrease;
    id myRelDynToleranceField;
    id myAbsDefaultTpoField;
    
    id myAbsDynValueMatrix;
    id myAbsDynSlideMatrix;
    id myRelDynValueMatrix;
    id myRelTpoValueMatrix;
    id myArtiValueMatrix;
    
    id myAbsDynNameMatrix;
    id myRelDynNameMatrix;
    id myRelTpoNameMatrix;
    id myArtiNameMatrix;
    
    id prefText;
    
}

- init;
- (void)dealloc;
- (void)awakeFromNib;

//- setPtDyn:(double)ptDyna;
- showPrefs:sender;

- resetAbsDynPrefValues:sender;
- resetAbsDynPrefNames:sender;
- resetRelDynPrefValues:sender;
- resetRelDynPrefNames:sender;
- resetRelTpoPrefValues:sender;
- resetRelTpoPrefNames:sender;
- resetArtiPrefValues:sender;
- resetArtiPrefNames:sender;

- (double)relDynTolerance;

- takeAbsDynValueFrom:sender;
- (const char*) absDynParaValueNameAt:(int)index;
- (const char*) absDynParaNameNameAt:(int)index;
- (int) indexOfAbsDynName:(const char*)aName;
- (double)absDynValueAt:(int)index;

- takeRelDynValueFrom:sender;
- (const char*) relDynParaValueNameAt:(int)index;
- (const char*) relDynParaNameNameAt:(int)index;
- (int) indexOfRelDynName:(const char*)aName;
- (double)relDynValueAt:(int)index;

- takeRelTpoValueFrom:sender;
- (const char*) relTpoParaValueNameAt:(int)index;
- (const char*) relTpoParaNameNameAt:(int)index;
- (int) indexOfRelTpoName:(const char*)aName;
- (double)relTpoValueAt:(int)index;

- takeArtiValueFrom:sender;
- (const char*) artiParaValueNameAt:(int)index;
- (const char*) artiParaNameNameAt:(int)index;
- (int) indexOfArtiName:(const char*)aName;
- (double)artiValueAt:(int)index;

- collectPrefs;
- displayPrefs;

- collectAbsoluteDynamicPrefs;
- collectRelativeDynamicPrefs;
- collectTempoPrefs;
- collectArticulationPrefs;

- displayAbsoluteDynamicPrefs;
- displayRelativeDynamicPrefs;
- displayTempoPrefs;
- displayArticulationPrefs;





@end
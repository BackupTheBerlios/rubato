/* PrimaVistaRubetteDriver.h */

#import <Rubette/RubetteDriver.h>

@interface PrimaVistaRubetteDriver:RubetteDriver
{
    id	myArpeggioPrefsPanel;
    id	myArticulationPrefsPanel;
    id	myAbsDynamicPrefsPanel;
    id	myRelDynamicPrefsPanel;
    id	myOrnamentPrefsPanel;
    id	myRelTempoPrefsPanel;
    id	myTuningPrefsPanel;
    id	myOtherPrefsPanel;
    id	myOrnamentTypesPanel;
    
    id	myPVObject;    //PrimaVista
    id	myPreferences; //PrimaVistaPreferences
    id	myEventList;
    id	myCoordPopUp1; //NSPopUpButton
    id	myCoordPopUp2; //ebenso
    id	myValueNameField; //NSTextField
    
    id	predLHS;
}

- (void)dealloc;
- customAwakeFromNib;

- findArtiEvents:sender;
- findAbsDynEvents:sender;
- findRelDynEvents:sender;
- findAbsTpoEvents:sender;
- findRelTpoEvents:sender;
- findCustomEvents:sender;

- makeEventListOfType:(int)PVType;

- doMakeTempoWeight:sender;
- doMakeArtiWeight:sender;
- doMakeDynaWeight:sender;
- doMakeCustom1DWeight:sender;
- doMakeCustom2DWeight:sender;

/* window management */
- (IBAction)showWindow:(id)sender;
- hideWindow:sender;
- showArpeggio:sender;
- showArticulation:sender;
- showAbsDynamics:sender;
- showRelDynamics:sender;
- showOrnaments:sender;
- showRelTempo:sender;
- showTuning:sender;
- showOthers:sender;

/* methods to be overridden by subclasses */
- insertCustomMenuCells;

/* class methods to be overridden by subclasses */
+ (NSString *)nibFileName;
+ (const char *)rubetteName;
+ (const char *)rubetteVersion;
+ (spaceIndex)rubetteSpace;

@end

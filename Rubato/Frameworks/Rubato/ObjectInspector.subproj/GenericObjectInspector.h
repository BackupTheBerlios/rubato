
#import <AppKit/AppKit.h>
#import "ObjectInspectorDriver.h"

@interface GenericObjectInspector:JgObject
{
    id	owner; // the ObjectInspectorDriver
    
    // watch out: the subviews of the following Outlets will move to other parents!
    IBOutlet id	panel; // panel with a view or multiple subviews
    IBOutlet id	defaultView; 
    IBOutlet id	subviewContainer;
    IBOutlet id	currentView;

    // pointing to TabView
    BOOL use_tabView;
    int defaultTabViewIndex;
        
    id	patient; // not retained (?)
    id	savedPatient; //??? not clear how to use this
    BOOL patientChanged;
    BOOL patientEdited;
    BOOL patientNew;

    id	newButton;
    id	insertButton;
    id	removeButton;
    id	loadedButton;
    id	revertButton;
}

- (void)awakeFromNib;
- init;
- (void)dealloc;
- (BOOL)use_tabView;

- setUpMenu;
- updateMenuSelection;

- inspectorSubview;
- selectInspectorSubview:sender;
- (void)saveCurrentViewContent:(id)contentView;

- setOwner:anOwner;
- owner;

/* Patient maintenance */
- setPatient:aPatient;
- patient;
- savedPatient;
- savePatient;

/* Getting information about the patient */
- setPatientEdited:(BOOL)flag;
- (BOOL)patientEdited;

- (BOOL)patientChanged;
- (BOOL)patientNew;


- (void)setValue:(id)sender;
- revert:sender;
- displayPatient:sender;

- showObjectInspector:sender;

@end

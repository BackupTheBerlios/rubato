
#import <AppKit/AppKit.h>
#import <RubatoDeprecatedCommonKit/JgObject.h>
#import <Rubato/Inspectable.h>

@interface GlobalInspectorHolder:NSObject
{
  IBOutlet id globalInspector;
}
- (id)globalInspector;
@end

// The purpose of this class is to provide manage the display of objects, that are <Inspectable>
// Their inspectorNibFile can contain more than one view, in which case a Menu is constructed
// From the titles of the views.
@interface ObjectInspectorDriver:JgObject
{
    id	owner; // unused  
    id	manager; // can be used from objectInspector. Nearly not used here:
                 // [manager invalidate] called, if defined and
                 // ([objectInspector patientChanged] || [objectInspector patientEdited])
    
    id	selected; // the object to be inspected 
    BOOL inspectorChanged; // true if newNibFileName!=oldNibFileName
    BOOL isAwake; // YES after awakeFromNib
    
// Interface Builder objects:
    id	inspectorPanel; // outer frame for Inspector // not retained/released
    id	objectInspector; // GenericObjectInspector
    id  inspectorBox; // NSBox of inspectorPanel where the objectInspector views are displayd
    id	inspectorMenuBtn;  // the NSPopUpButton
    IBOutlet NSTabView *tabView;
    IBOutlet NSTextField *shortInfoTextField;
}
- debugSelectInspectorSubview:sender;

- (void)awakeFromNib;

/* access to instance variables */
- setManager:aManager;
- manager;

- inspectorMenuBtn; 
- inspectorMenu; // gives inspectorMenuBtn->target (==self)
- updateMenuButton;

- (void)setSelected: aPatient;
- selected;
- patient;
- savedPatient;
- deselect:sender;
- revert:sender;

- setPatientEdited:(BOOL)flag;

- showClass;
- displayPatient:sender;
- (void)update;

- loadInspectorFor:aPatient;
- loadDefaultInspector;
- selectInspectorSubview:sender;
- showInspectorSubview:sender;
- showInspectorPanel:sender;

- (void) emancipatedCopyOfInspector;
- (void) emancipatedCopyOfInspector:(id)sender; // "Freeze"
- (void) showKVBrowserWithSelection:(id)sender;
- (void) setShortInfo:(NSString *)info;
- (void) showKVBrowserForObject:(id)obj;
@end

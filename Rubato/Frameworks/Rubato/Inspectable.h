/* Inspectable Protocol */

@protocol Inspectable

- (NSString *) inspectorNibFile;

@end

@protocol Inspector
- setManager:aManager;
- manager;

- inspectorMenuBtn;
- inspectorMenu; // liefert inspectorMenuBtn->target (==self)
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
@end

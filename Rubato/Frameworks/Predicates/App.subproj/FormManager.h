/* FormManager.h */

#import <AppKit/AppKit.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubato/FormListProtocol.h>

@interface FormManager: NSWindowController <FormListProtocol>  //JgObject
{
    id	owner; //<Distributor>
    id	inspector;
    id	browser;
    id	browserWindow;
    id	selectedCell;
    id	manager;
    
    id X;
    id Y;
    
    id	myFormList;
    id	selected;
    BOOL browserIsValid;
    int columnChanged;
    
    char* filename;
}

/* standard object methods to be overridden */
- init;
- (void)dealloc;
//- read:(NXTypedStream *)stream;
//- write:(NXTypedStream *)stream;

- (void)awakeFromNib;

/* access to instance variables */
- formList;
- setManager:aManager;
- manager;
- signInManager:aManager;
- signOutManager:aManager;

/* copy & paste methods */
- copyToPasteboard:pboard;
- (void)copy:(id)sender;
- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type;
- (void)cut:(id)sender;
- (void)paste:(id)sender;

/* save & load methods */
- setFilename:(const char*) aFilename;
- saveAs:sender;
- save:sender;
- loadFile:(const char*) aFilename;
- revertToSaved:sender;
- (void)setDocumentEdited:(BOOL)flag;

/* form list management */
- addPredicateForm:aForm;
- addForm:aForm;
/* list management */
- addPredicate: aPredicate;
- addPredicate: aPredicate Before: bPredicate;
- before: aPredicate;
- after: aPredicate;
- removePredicate: aPredicate;
- removePredicateAt:(unsigned int)index;
- deletePredicate: aPredicate;
- deletePredicateAt:(unsigned int)index;

- newForm:sender;
- deleteForm:sender;

- row:(int *)aRow andColumn:(int *)aCol ofPredicate:aPredicate;
- (void)setSelected: aPredicate;
- (void)setSelectedFrom:sender;
- selected;
- (void)setSelectedCell:sender;
- selectedCell;

- selectedInColumn:(int)column;
- browser:sender selectedInColumn: (int)column;
- browser:sender predicateAtRow:(int)row inColumn:(int)column;

- (void)invalidate;

/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
//- (const char *)browser:sender titleOfColumn:(int)column;
- (BOOL)browser:sender selectCellWithString:(NSString *)title inColumn:(int)column;
- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
//- browserWillScroll:sender;
//- browserDidScroll:sender;

/* (WindowDelegate) methods */
//- windowWillClose:sender;
//- windowWillReturnFieldEditor:sender toObject:client;
//- windowWillResize:sender toSize:(NXSize *)frameSize;
//- windowDidResize:sender;
//- windowDidExpose:sender;
//- windowWillMove:sender;
//- windowDidMove:sender;
//- windowDidBecomeKey:sender;
//- windowDidResignKey:sender;
//- windowDidBecomeMain:sender;
//- windowDidResignMain:sender;
//- windowWillMiniaturize:sender toMiniwindow:miniwindow;
//- windowDidMiniaturize:sender;
//- windowDidDeminiaturize:sender;
//- windowDidUpdate:sender;
//- windowDidChangeScreen:sender;

@end

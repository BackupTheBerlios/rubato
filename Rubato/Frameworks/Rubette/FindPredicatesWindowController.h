
#import <AppKit/AppKit.h>

@protocol FindPredicateSpecification
- (NSString *)findString;
- (int)findWhat;
- (int)findHow;
- (int)findSource;
- (int) findLevels;
- (BOOL) cascadeSearch;
@end

@protocol FindPredicatesWindowControllerDelegate
- (void)initSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
- (void)doSearchWithFindPredicateSpecification:(id<FindPredicateSpecification>)specification;
- (void)readRubetteData;
- (void)writeRubetteData;
@end

// jg: why is this a subclass of NSWindowController?
@interface FindPredicatesWindowController:NSWindowController <FindPredicateSpecification>
{
  id delegate; // the one that does the search

  // these variables might be set, even when the IB-Objects dont exist yet.
  NSString *findString;
  int levels;
  BOOL cascadeSearch;
  BOOL readRubetteDataIfBecomeKey;
  BOOL writeRubetteDataIfResignKey;    


// Waschechte IB-Objekte    
    IBOutlet NSTextField *findNameTextField;  // NSTextField
    IBOutlet NSTextField *findLevelsTextField; // TextField
    IBOutlet NSPopUpButton *findLevelsMenu; 
    IBOutlet NSPopUpButton *findWhatPopUpButton; // Name/Type/FormName  Tags:0,2,4
    IBOutlet NSPopUpButton *findHowPopUpButton; // PopupListe Has.../Contains...  Tags:0,1
    IBOutlet NSTextField *findSourceTextField; // TextField
    IBOutlet NSButton *cascadeSearchButton; // NSButton [bool state]

// Export:
    IBOutlet NSButton *readRubetteDataIfBecomeKeySwitch;
    IBOutlet NSButton *writeRubetteDataIfResignKeySwitch;    
}

+ (NSString *)findPredicatesPanelNibName;
- (id)initWithWindow:(NSWindow *)window;
- (void)awakeFromNib;

- (NSView *)importView;

/* access to instance variables */
- (id) delegate;
- (void) setDelegate:(id)newDelegate; // not retained

  /* public methods for getting and setting the state of the panel */
  // uncommented methods are not used yet
  - (NSString *)findString;
  - (void)setFindString:(NSString *)newFindString;
  - (int)findWhat;
  //- (void)setFindWhat:(int)tag;
  - (int)findHow;
  //- (void)setFindHow:(int)tag;
  - (int)findSource;
  //- (void)setFindSource:(int)tag;
  - (int) findLevels;
  - (void) setFindLevels:(int)newLevels;
  - (BOOL) cascadeSearch;
  - (void) setCascadeSearch:(BOOL)newCascadeSearch;
- (BOOL) readRubetteDataIfBecomeKey;
- (void) setReadRubetteDataIfBecomeKey:(BOOL)newReadRubetteDataIfBecomeKey;

- (BOOL) writeRubetteDataIfResignKey;
- (void) setWriteRubetteDataIfResignKey:(BOOL)newWriteRubetteDataIfResignKey;


/* IB methods private to this class */
- (IBAction)changeFindSource:sender;
- (IBAction)changeFindLevels:sender;
- (IBAction)cascadeSearchToggle:sender;
- (IBAction)readWriteToggle:sender;

// passed to delegates
- (IBAction)newPressed:sender; // [delegate initSearchWithFindPredicateSpecification:self]
- (IBAction)doSearch:sender; // [delegate doSearchWithFindPredicateSpecification:self]
- (IBAction)readRubetteData:sender; // if delegate responds to readRubetteData
- (IBAction)writeRubetteData:sender;// if delegate responds to readRubetteData
@end

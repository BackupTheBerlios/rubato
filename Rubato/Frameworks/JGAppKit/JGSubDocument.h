// JGSubDocument.h

#import <AppKit/AppKit.h>

/*
 JGSubDocument is a NSDocument subclass, that realizes recursivly structured documents.
 Each JGSubDocument has a list of all its children and a reference to its father.
 A Document gets a child by "addDocument".
 Is a Document going to be dealloced, the father takes over the fathership for the children. ("dealloc")
 The real father unsubscribes with the grandfather.
 There are serveral kinds of window closing behaviours:
 a. The Document shuts down all its children : "closeSelfAndSubDocuments"
 b. To clean up, it is possible to delete only the children (recursively)  "closeSubDocuments"
 c. The document gives the children to its own father (see above) "close"
*/

@interface JGSubDocumentNode : NSObject {
 id document; // content
 id parentDocumentNode; // JGSubDocumentNode
 id childDocuments; // NSMutableArray of NSDocuments
 NSString *documentCreationStemma;
 int globalDocumentNr;
 int lastChildDocumentNr; // creation number of last child
 BOOL moveChildren; // YES is set in init. influences dealloc
}
+ (JGSubDocumentNode *)docNodeForDocument:(id)doc;
+ (NSString *)nsDocumentClassDisplayNameForDocument:(NSDocument *)doc;

/* Primitives */
- (id)document;
- (void)setDocument:(NSDocument *)doc;
// Parent/Child relations
- (JGSubDocumentNode *)parentDocumentNode;
- (void)setParentDocumentNode:(JGSubDocumentNode *)documentNode;
- (NSArray *)childDocuments;
- (void)addChildDocument:(NSDocument *)document;
- (void)addChildDocuments:(NSArray *)documents;
- (void)removeChildDocument:(NSDocument *)document;
// Primitives for managing generic document names (for JGSubDocumentsBrowser Title)
- (NSString *)documentCreationStemma;
- (void)setDocumentCreationStemma:(NSString *)path;

/* customizable simple methods */
// Primitives for managing generic document names (for JGSubDocumentsBrowser Title)
- (int)globalDocumentNr;
- (NSString *)rootPosition;     // default: "globalDocumentNr"
- (NSString *)documentPosition; // Position within actual document hierarchy

/* non primitives */
// Methods that change the Parent/Child relations
- (void)changedChildDocumentNodeInDepth:(int)depth;  // recursive notifications for validating JGSubDocumentsBrowsers browser
- (void)changedParentDocument; // recursive notifications for updating JGSubDocumentsBrowsers title
- (void)registerNewChild:(NSDocument *)newDoc;
- (void)unregister;
- (void)moveChildrenToParent:(JGSubDocumentNode *)parent;

// Multiple closing Documents.
- (BOOL)canCloseSubDocuments;
- (void)closeSelfAndSubDocuments; // based on -close
- (void)closeSubDocuments;        // based on -close

// Creation of Interface
- (void)addSubDocumentsBrowser;   // e.g. put into makeWindowControllers


// Must override! Ab hier nur noch Kommentar im Framework.
- (void)updateTitle; // calls all WindowControllers to update their titles.
- (NSString *)displayName; // used by WindowControllers for setting Titles

@end

@interface JGSubDocument : NSDocument {
  JGSubDocumentNode *subDocumentNode;
}
+ (id)subDocumentNodeClass;
- (JGSubDocumentNode *)subDocumentNode;
- (void)addDocument:(id)sender;
- (void)close;                    // overridden
- (void)addDocument;              // not reusable, because it needs Class (Type) of JGSubDocument
- (void)makeWindowControllers;	  // overwrite
- (void)windowControllerDidLoadNib:(NSWindowController *) aController;   // overwrite
- (NSData *)dataRepresentationOfType:(NSString *)aType;                  // override
- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType;  // override

// IB Action Methods
- (IBAction)closeSelfAndSubDocuments:(id)sender;
- (IBAction)closeSubDocuments:(id)sender;
- (void)addSubDocumentsBrowser:(id)sender;
@end

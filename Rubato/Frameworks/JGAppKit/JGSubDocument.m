// JGSubDocument.m
#define MAKE_WINDOW_CONTROLLERS
#define DEBUG_DOCUMENT_M

#import "JGSubDocument.h"
#import "JGSubDocumentsBrowser.h"

#ifdef DEBUG_DOCUMENT_M
int jgSubDocumentCounter=0;
#endif

int globalDocumentCreationCounter=0;

// must the parent and children always also have a JGSubDocumentNode?
// this would ease the code but is less general.
// maybe at least the parent should have, so the leafs may not.
// this would allow reordering of intermediate nodes and a reasonable path.

@implementation JGSubDocumentNode
#ifdef DEBUG_INITIALIZE
+ (void)initialize;
{
  NSLog(@"initialize JGSubDocument");
}
#endif

+ (JGSubDocumentNode *)docNodeForDocument:(id)doc;
{
 // usage: [JGSubDocumentNode docNodeForDocument:doc]
 JGSubDocumentNode *ret=nil;
 if ([doc respondsToSelector:@selector(subDocumentNode)])
   ret=[doc subDocumentNode];
 return ret;
}

+ (NSString *)nsDocumentClassDisplayNameForDocument:(NSDocument *)doc;
{
  NSString *ret;
  SEL sel=@selector(displayName);
  id (*fu)(id, SEL);
  fu = (id (*)(id, SEL))[NSDocument instanceMethodForSelector:sel];
  ret=fu(doc,sel);
  return ret;
}


- (id)init;
{
 [super init];
#ifdef DEBUG_DOCUMENT_M
 jgSubDocumentCounter++;
#endif
 document=nil;
 moveChildren=YES;
 parentDocumentNode=nil;
 childDocuments=[[NSMutableArray alloc] init];
 globalDocumentCreationCounter++;
 globalDocumentNr=globalDocumentCreationCounter;
// documentCreationStemma=[[NSString alloc] initWithFormat:@"%d",globalDocumentNr]; //doesnt work!
 documentCreationStemma=[[NSString stringWithFormat:@"%d",globalDocumentNr] retain];
 lastChildDocumentNr=0;
 return self;
}

- (void)dealloc;
{
#ifdef DEBUG_DOCUMENT_M
 NSLog(@"release of %@",[self documentCreationStemma]);
 jgSubDocumentCounter--;
 NSLog(@"remaining docs:%d",jgSubDocumentCounter);
 NSLog(@"remaining windowControllers:%d",[[[self document]windowControllers] count]);
#endif

 // necessary, or should we require, that unregister is called before dealloc?
 [self unregister];
 [childDocuments release];
 [documentCreationStemma release];
 [super dealloc];
}

/* Primitives */

- (id)document;
{
  return document;
}

- (void)setDocument:(NSDocument *)doc;
{
  [doc retain];
  [document release];
  document=doc;
}

// Parent/Child relations
- (JGSubDocumentNode *)parentDocumentNode;
{
 return parentDocumentNode;
}
// no retain cycles! ? Closing is different from Releasing. If somone uses JGSubDocumentNodes,
// he must remove the nodes before releasing the document
- (void)setParentDocumentNode:(JGSubDocumentNode *)documentNode;
{
 [documentNode retain];
 [parentDocumentNode release];
 parentDocumentNode=documentNode;
}

- (NSArray *)childDocuments;
{
 return childDocuments;
}
- (void)addChildDocument:(NSDocument *)doc;
{
 [childDocuments addObject:doc];
 [self changedChildDocumentNodeInDepth:0];
}
- (void)addChildDocuments:(NSArray *)documents;
{
 [childDocuments addObjectsFromArray:documents];
 [self changedChildDocumentNodeInDepth:0];
}
- (void)removeChildDocument:(NSDocument *)doc;
{
 [childDocuments removeObject:doc];
 [self changedChildDocumentNodeInDepth:0];
}

// Primitives for managing generic document names (for JGSubDocumentsBrowser Title)

- (NSString *)documentCreationStemma;
{
 return documentCreationStemma;
}
- (void)setDocumentCreationStemma:(NSString *)path;
{
 id newPath=[path copy];
 [documentCreationStemma release];
 documentCreationStemma=newPath;
}

/* customizable simple methods */
// Primitives for managing generic document names (for JGSubDocumentsBrowser Title)

- (int)globalDocumentNr;
{
 return globalDocumentNr;
}

- (NSString *)rootPosition;
{
 return [NSString stringWithFormat:@"%d",[self globalDocumentNr]];
}

- (NSString *)documentPosition;
{
 JGSubDocumentNode *parent=[self parentDocumentNode];
 if (parent) {
   int nr=[[parent childDocuments] indexOfObject:[self document]];
   return [NSString stringWithFormat:@"%@:%d",[parent documentPosition],nr+1];
 } else
   return [[self rootPosition] copy];
}

- (void)registerNewChild:(NSDocument *)newDoc;
{
 JGSubDocumentNode *subDocumentNode=[JGSubDocumentNode docNodeForDocument:newDoc];
 [subDocumentNode setParentDocumentNode:self];
 [subDocumentNode setDocumentCreationStemma:
   [[self documentCreationStemma] stringByAppendingFormat:@":%d",++lastChildDocumentNr]];
 [self addChildDocument:newDoc]; // remove takes place in close of the subordinate Documents
 [subDocumentNode changedParentDocument];
}

- (void)unregister;
{
 JGSubDocumentNode *parent;
 if (moveChildren) {
   parent=[self parentDocumentNode];
   if (parent)
     [parent removeChildDocument:[self document]];
   [self moveChildrenToParent:parent]; // might be nil. O.k.
 }
 [self setParentDocumentNode:nil];
}

- (void)moveChildrenToParent:(JGSubDocumentNode *)parent;
{
 int i;
 id docs=[self childDocuments];
 NSDocument *doc;
 if (parent)
  [parent addChildDocuments:docs];
 for (i=0; i<[docs count]; i++) {
   JGSubDocumentNode *docNode;
   doc=[docs objectAtIndex:i];
   docNode=[JGSubDocumentNode docNodeForDocument:doc];
   [docNode setParentDocumentNode:parent];
   [docNode changedParentDocument];
 }
 [docs removeAllObjects];
}


/* dealing with GUI and the NSDocument aspects. */
// Methods that change the Parent/Child relations

- (void)changedChildDocumentNodeInDepth:(int)depth; // notification, when there is a SubSub...SubDocument added (>=1*Sub)
{
 int i;
 NSArray *wcs=[[self document] windowControllers];
 JGSubDocumentWindowController *wc;
 for (i=0; i<[wcs count]; i++) {
   wc=[wcs objectAtIndex:i];
   if ([wc isKindOfClass:[JGSubDocumentsBrowser class]])
     [(JGSubDocumentsBrowser *)wc validateColumn:depth];
 }
 if ([self parentDocumentNode])
   [[self parentDocumentNode] changedChildDocumentNodeInDepth:depth+1];
}

- (void)updateTitle;
{
  int i;
  NSArray *wcs=[[self document] windowControllers];
  JGSubDocumentWindowController *wc;
  for (i=0; i<[wcs count]; i++) {
    wc=[wcs objectAtIndex:i];
    if ([wc respondsToSelector:@selector(updateTitle)])
      [wc updateTitle];
  }
}

- (void)changedParentDocument;
{
  int i;
  id doc;
  [self updateTitle];
  for (i=0; i<[[self childDocuments] count]; i++) {
   doc=[[self childDocuments] objectAtIndex:i];
   [[JGSubDocumentNode docNodeForDocument:doc] changedParentDocument];
  }
}

// Creation and Deletion of Documents.

- (BOOL)canCloseSubDocuments;
/* if any subdocument is dirty, return NO */
{
 id docs=[self childDocuments];
 BOOL ret=YES;
 int i,c;
 c=[docs count];
 for (i=0; ret && i<c; i++) {
   NSDocument *doc;
   doc=[docs objectAtIndex:i];
   ret=![doc isDocumentEdited]; 
   if (ret) {
     JGSubDocumentNode *docNode=[JGSubDocumentNode docNodeForDocument:doc];
     if (docNode)
       ret=[docNode canCloseSubDocuments];
   }
 }
 return ret;
}

- (void)closeSelfAndSubDocuments;
{
   [self closeSubDocuments];
   [[self document] close];
   [parentDocumentNode removeChildDocument:[self document]]; // necessary?
   [self setParentDocumentNode:nil]; // necessary?
}

- (void)closeSubDocuments;
{
 id doc,docs=[self childDocuments];
 int i,c;
 c=[docs count];
#ifdef DEBUG_DOCUMENT_M
 NSLog(@"%@ closes subdocs %@",[self documentCreationStemma],[docs description]);
#endif
 for (i=c-1; i>=0; i--) {
   JGSubDocumentNode *docNode;
   doc=[docs objectAtIndex:i];
   docNode=[JGSubDocumentNode docNodeForDocument:doc];
   if (docNode)
     [docNode closeSelfAndSubDocuments];
   else 
     [doc close];
 }
}

// Creation of Interface

- (void)addSubDocumentsBrowser;
{
 id subDocumentsBrowser=[[JGSubDocumentsBrowser alloc] initWithWindowNibName:@"JGSubDocumentsBrowser"];
 [[self document] addWindowController:subDocumentsBrowser];
 [subDocumentsBrowser updateTitle];
 [[subDocumentsBrowser window] display];
 [subDocumentsBrowser release]; // addWindowController keeps a reference.
}

- (NSString *)subDocumentPathName;
{
  JGSubDocumentNode *parent;
  NSString *fn=[[self document] fileName];
  if (fn)
    return [JGSubDocumentNode nsDocumentClassDisplayNameForDocument:[self document]];
  parent=[self parentDocumentNode];
  if (parent) {
    int nr=[[parent childDocuments] indexOfObject:[self document]];
    return [NSString stringWithFormat:@"%@/%d",[parent subDocumentPathName],nr+1];
  } else
    return [[self rootPosition] copy];
}

- (NSString *)displayName;
{
  NSString *pos, *stemma;
  NSMutableString *title= [NSMutableString stringWithFormat:@"%@ (%d",
      [self subDocumentPathName],[self globalDocumentNr]];
  pos=[self documentPosition];
  if (![pos isEqualToString:[self rootPosition]]) {
    [title appendFormat:@" %@",pos];
    stemma=[self documentCreationStemma];
    if (![pos isEqualToString:stemma])
      [title appendFormat:@" %@",stemma];
  }
  [title appendString:@")"];
  return title;
/*    
  NSString *title= [NSString stringWithFormat:
                    @"%@ (SubDoc %d (Pos %@, Creation %@) %@",
                    [super displayName],
    	            [self subDocumentPathName],
                    [self globalDocumentNr],
                    [self documentPosition],
                    [self documentCreationStemma],
		    [self fileName]
                   ];
*/
}

@end

@implementation JGSubDocument
+ (id)subDocumentNodeClass;
{
  return [JGSubDocumentNode class];
}
- (id)init;
{
  [super init];
  subDocumentNode=[[[[self class] subDocumentNodeClass] alloc] init];
  [subDocumentNode setDocument:self];
  return self;
}
- (JGSubDocumentNode *)subDocumentNode;
{
  return subDocumentNode;
}
// IB Action Methods
- (IBAction)closeSelfAndSubDocuments:(id)sender;
{
 [subDocumentNode closeSelfAndSubDocuments];
}
- (IBAction)closeSubDocuments:(id)sender;
{
 [subDocumentNode closeSubDocuments];
}
- (void)addSubDocumentsBrowser:(id)sender;
{
 [subDocumentNode addSubDocumentsBrowser];
}

- (void)addDocument:(id)sender;
{
 [self addDocument];
}

- (void)close;
{
 [subDocumentNode unregister];
 [super close];
}

- (void)addDocument;
{
 id newDoc=[[NSDocumentController sharedDocumentController]
            openUntitledDocumentOfType:@"DocumentType" display:YES];
 [subDocumentNode registerNewChild:newDoc];
}


- (void)makeWindowControllers;	
{
 [subDocumentNode addSubDocumentsBrowser];
 [self showWindows];
}


- (void)windowControllerDidLoadNib:(NSWindowController *) aController;
{
   [super windowControllerDidLoadNib:aController];
   // Add any code here that need to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataRepresentationOfType:(NSString *)aType;
{
   return nil;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType;
{
   return YES;
}

@end

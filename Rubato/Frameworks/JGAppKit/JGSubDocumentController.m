/* JGSubDocumentController.m created by jg on Tue 30-May-2000 */

#import "JGSubDocumentController.h"
#import <AppKit/NSDocumentController.h>
//#import <ObjectInspectorApp/ObjectInspectorDriver.h>
#define MAIN_DOCUMENT_CLASS JGActivationSubDocument
#define MAIN_DOCUMENT_CLASS_STRING @"JGActivationSubDocument"

#define HARDCODED

id globalSubDocumentController;


@implementation JGSubDocumentController
#ifdef DEBUG_INITIALIZE
+ (void)initialize;
{
  NSLog(@"initialize SubDocumentController");
}
#endif


+ (JGSubDocumentController *)sharedDocumentController;
{
  if (!globalSubDocumentController) {
    [[[JGSubDocumentController alloc] init] release]; // init includes 2 retains
  }
  return globalSubDocumentController;
}

- (id)init;
{
  [super init];

  docClassDictionary=[[NSMutableDictionary alloc] init];

#ifdef HARDCODED
  [docClassDictionary setObject:@"JGActivationSubDocument" forKey:@"JGActivationSubDocument"];
#else
  [docClassDictionary setObject:MAIN_DOCUMENT_CLASS_STRING forKey:MAIN_DOCUMENT_CLASS_STRING];
#endif
  [docClassDictionary setObject:@"PrediBase" forKey:@"PrediBase"];
  [docClassDictionary setObject:@"TestDocument" forKey:@"TestDocument"];

  loadedRubettesViewer=nil;
//  globalInspector=nil;
  if (!globalSubDocumentController) { // problem with subclassing?
    globalSubDocumentController=[self retain];
  }
  return self;
}

- (void)dealloc;
{
  if (self==globalSubDocumentController)
    globalSubDocumentController=nil;
  [docClassDictionary release];
  [super dealloc];
}

// primitives

- (NSDictionary *)docClassDictionary;
{
  return docClassDictionary;
}
- (id)loadedRubettesViewer;
{
  return loadedRubettesViewer;
}

// methods:

- (void)loadDocumentBundle;
{
  NSArray *fileTypes = [NSArray arrayWithObject:@"dtxdoc"];
  [self loadBundlesOfTypes:fileTypes];
  [self updateToolsMenu];
}

- (void)updateToolsMenu;
{
  NSMenu *submenu=[[NSMenu alloc] initWithTitle:@"Add Tool to Doc"];
  NSEnumerator *keyEnumerator=[[self docClassDictionary] keyEnumerator];
  id key;
  while (key=[keyEnumerator nextObject]) {
    [[submenu addItemWithTitle:key action:@selector(addSubDocument:) keyEquivalent:@""] setTarget:self];
  }
  [addSubToolsMenuCell setMenu:submenu];
}

- (void)loadBundlesOfTypes:(NSArray *)fileTypes;
{
  int result;
  NSOpenPanel *oPanel = [NSOpenPanel openPanel];
  NSString *title=[NSString stringWithFormat:@"Load Bundle %@",[fileTypes description]];
  NSMutableArray *failed=[NSMutableArray array];

  [oPanel setAllowsMultipleSelection:YES];
  [oPanel setTreatsFilePackagesAsDirectories:NO];
  [oPanel setTitle:title];

  result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil
      types:fileTypes];
  if (result == NSOKButton) {
     NSArray *filesToOpen = [oPanel filenames];
     int i, count = [filesToOpen count];
     for (i=0; i<count; i++) {
       NSString *aFile = [filesToOpen objectAtIndex:i];
       if (![self loadBundleFromFile:aFile]) {
          [failed addObject:aFile];
         NSLog(@"failed to load bundle:%@",aFile);
       }
     }
  }
}

- (BOOL)loadBundleFromFile:(NSString *)fileName
{
  id mainClass,bundle;
  NSString *fnWithoutPath=[fileName lastPathComponent];
  if (![docClassDictionary objectForKey:fnWithoutPath]) {
     bundle=[[NSBundle alloc] initWithPath:fileName];
     mainClass=[bundle principalClass];
     if (mainClass)
       [docClassDictionary setObject:NSStringFromClass(mainClass) forKey:fnWithoutPath];
     else
       return NO;
  }
  return YES; // jg??
}

- (void)addSubDocumentOfClassName:(NSString *)className;
{
  id docCtrl=[NSDocumentController sharedDocumentController];
  id activeDoc=[docCtrl currentDocument];
  id newDoc;
/* release does not work properly.
  id newDoc=[[NSClassFromString(className) alloc] init];
*/
  // incl windowController. className must be entered in CustomInfo.plist.
  newDoc=[docCtrl openUntitledDocumentOfType:className display:YES];
  if (newDoc && [newDoc isKindOfClass:[MAIN_DOCUMENT_CLASS class]]) {
    [[JGSubDocumentNode docNodeForDocument:activeDoc] registerNewChild:newDoc];
//    [newDoc makeWindowControllers];
    [newDoc showWindows];
  } else
    NSLog(@"error at addSubDocumentOfClassName: tried to instanciate %@.",className);
}


- (NSArray *)rootSubDocuments;
{
  NSArray *a=[[NSDocumentController sharedDocumentController] documents];
  NSMutableArray *b=[NSMutableArray array];
  int i,c;
  c=[a count];
  for (i=0;i<c;i++) {
    id doc=[a objectAtIndex:i];
    if ([doc respondsToSelector:@selector(subDocumentNode)] && ![[doc subDocumentNode] parentDocumentNode])
      [b addObject:doc];
  }
  return b;
}

// IB Methods
- (IBAction)loadDocumentBundle:(id)sender;
{
  [[JGSubDocumentController sharedDocumentController] loadDocumentBundle];
}

- (IBAction)addSubDocument:(id)sender;
{
  NSString *key=[sender title];
  NSString *className;
  if (key)
    className=[[self docClassDictionary] objectForKey:key];
  else
    className=MAIN_DOCUMENT_CLASS_STRING;
  //className=@"JGActivationSubDocument";
  if (!className)
    NSLog(@"SubDocumentController: addSubDocument failed (!className)");
  else
    [self addSubDocumentOfClassName:className];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
  [self updateToolsMenu];
//  [self showWindows];
}
@end

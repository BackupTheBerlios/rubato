/* JGSubDocumentController.h created by jg on Tue 30-May-2000 */
// This class controlls the top Documents in Rubato. It has a globalInspector and
// administrative information about JGSubDocument subclasses.
// instanciate only once!

#import <AppKit/AppKit.h>
#import "JGActivationSubDocument.h"

@interface JGSubDocumentController : NSObject //: SubDocument
{
  id addSubToolsMenuCell;
  id toolMenuCell;
  NSMutableDictionary *docClassDictionary;
  id loadedRubettesViewer;
}


+ (JGSubDocumentController *)sharedDocumentController; 
- (id)init;

// primitives
- (NSDictionary *)docClassDictionary;
- (id)loadedRubettesViewer;

// methods:
- (void)loadDocumentBundle;
- (void)updateToolsMenu;
- (void)loadBundlesOfTypes:(NSArray *)fileTypes;
- (BOOL)loadBundleFromFile:(NSString *)fileName;
- (void)addSubDocumentOfClassName:(NSString *)className;
//- (void)showGlobalInspector;
- (NSArray *)rootSubDocuments;

// IB Methods
- (IBAction)loadDocumentBundle:(id)sender;
//- (IBAction)showGlobalInspector:sender;
- (IBAction)addSubDocument:(id)sender;
@end

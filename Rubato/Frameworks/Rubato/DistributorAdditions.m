#import "Distributor.h"
@protocol LoadPListFileShowFindPanel
- (void)loadPListFile:(NSString *)file;
- (void)showFindPanel:(id)sender;
@end

@implementation Distributor (DistributorDebugAdditions)
- debugOpenStandardFile:(id)sender;
{
  [self showPredicateBrowser:self];

  [prediBase loadPListFile:@"/Local/Users/jg/daten/rubtest.pred.plist"];
  return self;
}

- debugLoadMetroRubette:(id)sender;
{
  [self loadRubetteByFilename:@"/Local/Users/jg/rubato/Rubettes/debuglink/Metro.rubette"];
  return self;
}
- debugLoadPerformanceRubette:(id)sender;
{
  [self loadRubetteByFilename:@"/Local/Users/jg/rubato/Rubettes/debuglink/Performance.rubette"];
  return self;
}
- debugLoadMeloRubette:(id)sender;
{
  [self loadRubetteByFilename:@"/Local/Users/jg/rubato/Rubettes/debuglink/Melo.rubette"];
  return self;
}
- debugLoadHarmoRubette:(id)sender;
{
  [self loadRubetteByFilename:@"/Local/Users/jg/rubato/Rubettes/debuglink/Harmo.rubette"];
  return self;
}
- debugLoadPrimaVistaRubette:(id)sender;
{
  [self loadRubetteByFilename:@"/Local/Users/jg/rubato/Rubettes/debuglink/PrimaVista.rubette"];
  return self;
}
@end

@implementation Distributor (RubatoArchivers)

// Bugfix of MPWXMLKit sent to Marcel Weiher on 25.6.2001
// encodeObjCType "#" to be reported
// MPW is not so good at object graphs: the same Stemma of the performanceRubette
// with NSArchiver and XML:
// -rw-r--r--  1 jg    wheel    61641 Jun 27 17:52 ste.stemma
// -rw-r--r--  1 jg    wheel  1975444 Jun 27 17:45 stemma.stemma
// maybe, if we turn off indentation, we only get a 4 times larger file.
// nevertheless, its good for debugging.

- (id<CommonArchiverInterface>)archiverForType:(NSString *)aType;
                         /*"if aType hasSuffix:@"XML" returns MPWXmlArchiver."*/
{

  id archiverClass=nil;
/*
#ifdef WITH_MPWXmlKit
  if ([[self archiverClassName] isEqualToString:@"XMLArchiver"] || [aType hasSuffix:@"XML"])
    archiverClass=[MPWXmlArchiver class];
  else
#endif
    archiverClass=[NSArchiver class];
*/
  archiverClass=NSClassFromString([self archiverClassName]);
  return archiverClass;
}

- (id<CommonUnarchiverInterface>)unarchiverForType:(NSString *)aType;
  /*"defaults to MPWXmlUnarchiver"*/
{
  id unarchiverClass=nil;
/*
#ifdef WITH_MPWXmlKit
  if ([[self archiverClassName] isEqualToString:@"XMLArchiver"] || [aType hasSuffix:@"XML"])
    unarchiverClass=[MPWXmlUnarchiver class];
  else
#endif
    unarchiverClass=[NSUnarchiver class];
 */
  unarchiverClass=NSClassFromString([self unarchiverClassName]);
  return unarchiverClass;
}

- (void)debugSetNSArchiver:(id)sender;
{
  [self setArchiverClassName:@"NSArchiver"];
  [self setUnarchiverClassName:@"NSUnarchiver"];
}
- (void)debugSetXMLArchiver:(id)sender;
{
  [self setArchiverClassName:@"MPWXmlArchiver"];
  [self setUnarchiverClassName:@"MPWXmlUnarchiver"];
}
- (void)debugSetNXArchiver:(id)sender;
{
  [self setArchiverClassName:@"NSArchiver"];
  [self setUnarchiverClassName:@"JGNXCompatibleUnarchiver"];
}
@end


@implementation Distributor (DistributorInterfaceAdditions)
/* show window calls */
- (void)showAlertPanel:sender
{
    if (!alertPanel)
        [NSBundle loadNibNamed:@"Alert.nib" owner:self];
    [alertPanel makeKeyAndOrderFront:self];
}

- (void)showInfoPanel:sender
{
    if (!infoPanel)
        [NSBundle loadNibNamed:@"Info.nib" owner:self];
    [infoPanel makeKeyAndOrderFront:self];
}

- (void)showEditWindow:sender  // jg?: does this still exist?
{
    if (!editWindow)
        [NSBundle loadNibNamed:@"Edit.nib" owner:self];
    [editWindow makeKeyAndOrderFront:self];
}

- (void)showInterpreterWindow:sender
{
    [[[Distributor globalDistributor] interpreterWindow] makeKeyAndOrderFront:nil];
}

- (void)showInspector:sender
{
    [[self globalInspector]  showInspectorPanel:self];
}

- (void)showPredicateBrowser:sender
{
    [self showInspector:self];
    [self loadNibNamed:@"PredicateBrowser.nib" forClassName:@"PrediBaseDocument"];
//    jgLoadNibNamedFu(@"PredicateBrowser.nib",self);
}

- (void)showPredicateFinder:sender
{
    if (!predicateFinder)
        [self  loadNibNamed:@"Find.nib" forClassName:@"PrediBaseDocument"];
    [predicateFinder showFindPanel:self];
}

- (void)showMakroPalette:sender;  // jg?: does this still exist? not found
{
    if (!makroPalette)
            [NSBundle loadNibNamed:@"MakroPalette.nib" owner:self];
    [makroPalette makeKeyAndOrderFront:self];
}

- (void)showFormBrowser:sender
{
    if (!globalInspector )
        [self showInspector:self];
    [self globalFormManager];
    [globalFormBrowser orderFront:self];
}

@end

@implementation Distributor (KVCoding)
/*
 - (NSArray *)fskvUnclassifiedRelationshipKeys;
{
    static NSArray *keys=nil;
    if (!keys)
        keys=[[NSArray alloc] initWithObjects:@"toolDictionary",nil];
    return keys;
}
*/
- (NSArray *)toOneRelationshipKeys;
{
    static NSArray *keys=nil;
    if (!keys)
        keys=[[NSArray alloc] initWithObjects:@"prediBase",@"toolDictionary",@"preferences",@"activeRubette",nil];
    return keys;    
}
@end
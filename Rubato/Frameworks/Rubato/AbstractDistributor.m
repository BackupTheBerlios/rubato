/* Distributor.m */
/* Version Control:
   $Header: /home/xubuntu/berlios_backup/github/tmp-cvs/rubato/Repository/Rubato/Frameworks/Rubato/AbstractDistributor.m,v 1.2 2002/10/05 01:21:20 garbers Exp $
   $Log: AbstractDistributor.m,v $
   Revision 1.2  2002/10/05 01:21:20  garbers
   Changed the Userinterface of HarmoRubette to be flexible in HarmoSpace.

   Revision 1.1.1.1  2002/08/07 13:14:10  garbers
   Initial import

   Revision 1.1.1.1  2001/05/04 16:23:50  jg
   OSX build 1

   Revision 1.3  1999/12/09 10:30:06  jg
   vor Predicate Umbau

   Revision 1.2  1999/09/09 09:52:52  jg
   Added CVS-Keywords

*/

#import "AbstractDistributor.h"
#import	"RubetteTypes.h"

//#import <ObjectInspectorApp/ObjectInspectorDriver.h>

//#import "Rubato.h"
//#import <Predicates/predikit.h>
//#import <Predicates/PredicateManager.h>
//#import <Predicates/FormManager.h>
//#import <RubatoDeprecatedCommonKit/JgFrameworkNibLoading.h>


// id globalDistributor;

@implementation AbstractDistributor

+ (id/* <Distributor> */)globalDistributor;
{
/*  if (!globalDistributor) {
    [[[RubatoController alloc] init] release]; // init includes 2 retains.
  }
  return globalDistributor;
*/
  id applicationDelegate=[[NSApplication sharedApplication] delegate];
  NSParameterAssert((applicationDelegate==nil) || [applicationDelegate isKindOfClass:[AbstractDistributor class]] || [applicationDelegate conformsToProtocol:@protocol(Distributor)]);
  return applicationDelegate;
/*
 if ([d conformsToProtocol:@protocol(Distributor)])
    return d;
  else
    return nil;
*/
}
- (id/* <Distributor> */)globalDistributor;
{
  return [[self class] globalDistributor];
}

/*
+ (void)setGlobalDistributor:(id)distributor;
{
  if (globalDistributor)
    [globalDistributor release];
  globalDistributor=[distributor retain];
}
*/
@end

@implementation AbstractDistributor (RubatoArchivers)
- (id<CommonArchiverInterface>)archiverForType:(NSString *)aType;
{
  return [NSArchiver class];
}
- (id<CommonUnarchiverInterface>)unarchiverForType:(NSString *)aType;
{
  return [NSUnarchiver class];
}
@end

@implementation AbstractDistributor (ResourceDirectories)
- (NSString *)rubetteDirectory;
{
  return [[self globalDistributor] rubetteDirectory];
}
- (NSString *)operatorDirectory;
{
  return [[self globalDistributor] operatorDirectory];
}
- (NSString *)stemmaDirectory;
{
  return [[self globalDistributor] stemmaDirectory];
}
- (NSString *)weightDirectory;
{
  return [[self globalDistributor] weightDirectory];
}
@end


@implementation AbstractDistributor (DistributorAppKit)

- (id<Inspector>)globalInspector;
{
  return [[self globalDistributor] globalInspector];
}
- (id)globalFormManager;
{
  return [[self globalDistributor] globalFormManager];
}
- (id)predicateFinder;
{
  return [[self globalDistributor] predicateFinder];
}

@end
@implementation AbstractDistributor (RubetteActivation)
- (id)prediBase;
{
  return [[self globalDistributor] prediBase];
}
- (void)setPrediBase:(id)pm;
{
  [[self globalDistributor] setPrediBase:pm];
}

- (void)setActiveRubette:(id<RubetteDriver>)newActiveRubette;
{
  [[self globalDistributor] setActiveRubette:newActiveRubette];
}
- activeRubette;
{
  return [[self globalDistributor] activeRubette];
}
@end

@implementation AbstractDistributor (AddingTools)
// primitives
- (NSMenuItem *)toolsMenuItem; // where to put the toolMenuItems
{
  return nil;
}
- (NSMutableDictionary *)toolDictionary; // where to put the tools
{
  return nil;
}

- (void)addToolMenuItem:(NSMenuItem *)menuItem;
{
  NSMenu *submenu;
  if (menuItem) {
    NSMenuItem *item=[self toolsMenuItem];
    submenu = [item submenu];
    if (!submenu) {
        submenu = [[NSMenu alloc] initWithTitle:[item title]];
        [item setSubmenu:submenu];
    }
    [submenu addItem:menuItem];
    [item setEnabled:YES];
  }
}

- (void)removeToolMenuItem:(NSMenuItem *)menuItem;
{
  NSMenuItem *item=[self toolsMenuItem];
  id rubettesMenu=[item submenu];
  if (rubettesMenu) {
    int idx;
    idx=[rubettesMenu indexOfItem:menuItem];
    if (idx!=NSNotFound)
      [rubettesMenu removeItemAtIndex:idx];
  }
}

- (id)toolForKey:(NSString *)key;
{
  return [[self toolDictionary] objectForKey:key];
}

- (void)setTool:(id)tool forKey:(NSString *)key replaceOld:(BOOL)replaceOld;
{
  NSMutableDictionary *tools=[self toolDictionary];
  id oldTool=[tools objectForKey:key];

  if (!oldTool||replaceOld) {
    if ([oldTool respondsToSelector:@selector(toolMenuItem)]) {
      id item=[oldTool toolMenuItem];
      if (item) {
         [self removeToolMenuItem:item];
      }
    }
    if (oldTool)
      [tools removeObjectForKey:key];
    if ([tool respondsToSelector:@selector(toolMenuItem)]) {
      id item=[tool toolMenuItem];
      if (item) {
        [self addToolMenuItem:item];
      }
    }
    if (tool)
      [tools setObject:tool forKey:key];
  }
}
@end

// needs AddingTools
@implementation AbstractDistributor (RubetteLogin)
// might want to override, so that a rubetteDriver with an already inserted key
// changes its key (by appending a number) and is inserted afterwards.
- (void)addRubette:(id<RubetteDriver>)rubetteDriver replaceOld:(BOOL)yn;
{
  NSString *key=[rubetteDriver rubetteKey];
  [self setTool:rubetteDriver forKey:key replaceOld:yn];
}
- (void)removeRubette:(id<RubetteDriver>)rubetteDriver;
{
  NSString *key=[rubetteDriver rubetteKey];
  [self setTool:nil forKey:key replaceOld:YES];
}

- (NSArray *)rubetteList; // Array of RubetteDrivers
{
  NSDictionary *dict=[self toolDictionary];
  NSEnumerator *e=[dict objectEnumerator];
  NSMutableArray *a=[NSMutableArray array];
  id obj;
  while (obj=[e nextObject]) {
    if ([obj conformsToProtocol:@protocol(RubetteDriver)])
      [a addObject:obj];
  }
  return a;
}

// <Distributor> is sufficient for self
- (BOOL)signInRubette:(id<RubetteDriver>)rubetteDriver;
{
  BOOL conform=[rubetteDriver conformsToProtocol:@protocol(RubetteDriver)];
  NSAssert(conform,
           @"signInRubette does not conform to <RubetteDriver>");
  if (conform) {
        if (![self rubetteIsLoaded:rubetteDriver]) {
            /* set input & output if rubettes */
//            [rubetteDriver setInput:nil];
            /* set the current predicateManager */
            [rubetteDriver setPrediBase:[self prediBase]];
            /* now constitute and insert the menu of the new rubette*/
//            [rubetteDriver setUpMenu];

            //[myRubetteList addObject:rubetteDriver];
            [self addRubette:rubetteDriver replaceOld:YES];
            return YES;
        }
    }
    return NO;
}

- (void)signOutRubette:(id<RubetteDriver>)rubetteDriver;
{
// rubettesMenuCell== "Tools/Rubettes"
// rubettesMenu="LoadRubette,MeloRubette,..."
// submenuCell="MetroRubette"
// submenu= "MetroLoad,MetroSaveWeight,...,Close"

    if ([self rubetteIsLoaded:rubetteDriver]) {
/*
        id submenu, submenuCell = nil, submenuCellList,rubettesMenu;//, submenuMatrix;
        unsigned int i, count;
//	int row, col;	

        // get the submenu, its matrix and cellList
        submenu = [rubetteDriver rubetteMenu];
//	submenuMatrix = [rubettesMenuCell itemMatrix];
////        submenuCellList = [rubettesMenuCell itemArray];
        rubettesMenu=[rubettesMenuCell submenu];
        submenuCellList = [rubettesMenu itemArray];
        // now find the cell which has submenu as target
        count = [submenuCellList count];
        for (i=0; i<count && !submenuCell; i++) { // submenuCell is at last the looked for.
            submenuCell = [submenuCellList objectAtIndex:i];
            submenuCell = [submenuCell target]==submenu ? submenuCell : nil;
        }
        // get row of submenus trigger cell and delete it
//	[submenuMatrix getRow:&row column:&col ofCell:submenuCell];
//	[submenuMatrix removeRow:row];
////	[rubettesMenuCell removeItemAtIndex:i];
        if (submenuCell)
          [rubettesMenu removeItemAtIndex:i-1]; // i is increased to much by 1 
// are resize and display necessary?
        // resize the matrix
//	[submenuMatrix sizeToCells];
        // resize and redisplay the menu
//	[[rubettesMenuCell target] sizeToFit];
//	[[rubettesMenuCell target] display];

        // set input & output if rubettes
#if 0
        index = [myRubetteList indexOfObject:rubetteDriver];
        [[myRubetteList objectAt:index+1] removeInput:rubetteDriver];
        [[myRubetteList objectAt:index+1] setInput:[myRubetteList objectAt:index-1]];
#endif
*/
//        [rubetteDriver setInput:nil];
        [rubetteDriver setPrediBase:nil];
        [self removeRubette:rubetteDriver];
    }
}

+ (NSString *)rubetteIndexSeparator;
{
    return @"_";
}

// as a side effect alters the name of rubetteDriver, if it is a new instance.
- (BOOL)rubetteIsLoaded:(id<RubetteDriver>)rubetteDriver;
{
    BOOL isLoaded = NO, isNew=NO;
#if 0
  unsigned int i, count;
    count = [myRubetteList count];
    for (i=0;i<count && !isLoaded; i++){ // check whether this rubette is already in the list
      isLoaded = [[myRubetteList objectAtIndex:i] isMemberOfClass:[rubetteDriver class]];
    }
#else
    NSString *key=[rubetteDriver rubetteKey];
    id oldTool=[[self toolDictionary] objectForKey:key];
    if (oldTool&&(oldTool==(id)rubetteDriver))
      isLoaded=YES;
    else {
      int i=1;
      NSString *newKey;
      while (!isLoaded && !isNew) {
        newKey=[key stringByAppendingFormat:@"%@%d",[[self class] rubetteIndexSeparator], i];
        oldTool=[[self toolDictionary] objectForKey:newKey];
        if (oldTool) {
          if (oldTool==(id)rubetteDriver)
            isLoaded=YES;
          i++;
        } else
          isNew=YES;
      }
      if (isNew)
        [rubetteDriver setRubetteKey:newKey];
    }
#endif
    return isLoaded;
}
@end

@implementation AbstractDistributor (RubetteLoading)
- (NSArray *)rubetteFileTypes;
{
  return [NSArray arrayWithObjects:ns_RubetteFileType,ns_BundleFileType,nil];
}

- (NSArray *)rubetteContainerFileTypes;
{
  return [NSArray arrayWithObjects:@"app",@"framework",nil];
}

- (NSArray *)loadRubetteFileTypes;
{
  return [[self rubetteFileTypes] arrayByAddingObjectsFromArray:
    [self rubetteContainerFileTypes]];
}

- (void)loadRubette:(id)sender;
{
    NSOpenPanel *openPanel;

    openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setTreatsFilePackagesAsDirectories:NO];
    [openPanel setTitle:@"Load Rubette"];
    if([openPanel runModalForDirectory:[self rubetteDirectory] file:@"" types:[self loadRubetteFileTypes]]) {
      [self loadRubetteByFilename:[openPanel filename]];
    }
}

/*" Enters a Bundle designated by fname and calls [self method:bundle] with the method specified in the bundles infoDictionary or defaultLoadBundle: by default "*/
- (void)loadRubetteByFilename:(NSString *)fname;
{
  NSBundle *bundle;
  bundle = [[NSBundle alloc] initWithPath:fname];
  if (bundle) {
    NSDictionary *infoDict;
    NSString *rubetteBundleLoaderName;
    SEL rubetteBundleLoaderSelector;;

    infoDict=[bundle infoDictionary];
    rubetteBundleLoaderName=[infoDict objectForKey:@"RubetteBundleLoaderMethod"];
    if (rubetteBundleLoaderName) {
      rubetteBundleLoaderSelector=NSSelectorFromString(rubetteBundleLoaderName);
      if (rubetteBundleLoaderSelector && [self respondsToSelector:rubetteBundleLoaderSelector]) {
        // call the method
        [self performSelector:rubetteBundleLoaderSelector withObject:bundle];
      }
    } else {
      [self defaultLoadBundle:bundle];
    }
    [bundle release];
  }
}

/*" If the resources are not found but specified, an error is indicated by returning an empty array. If no resources are specified, nil is returned. "*/
- (NSArray *)rubettesSpecifiedInInfoDictionaryOfBundle:(NSBundle *)bundle;
{
  NSDictionary *infoDict=[bundle infoDictionary];
  NSMutableArray *array=nil;
  NSString *fname;
  if (infoDict) {
    id rubetteBundleNames=[infoDict objectForKey:@"RubetteBundles"];
    if (rubetteBundleNames) {
      array=[NSMutableArray array];
      if ([rubetteBundleNames isKindOfClass:[NSString class]]) {
        fname=[bundle pathForResource:rubetteBundleNames ofType:nil];
        if (fname) [array addObject:fname];
      }
      if ([rubetteBundleNames isKindOfClass:[NSArray class]]) {
        NSEnumerator *e=[rubetteBundleNames objectEnumerator];
        id next;
        while (next=[e nextObject]) {
          if ([next isKindOfClass:[NSString class]]) {
            fname=[bundle pathForResource:next ofType:nil];
            if (fname && ![array containsObject:fname])
              [array addObject:fname];
          }
        }
      }
    }
  }
  return array;
}

- (NSArray *)rubettesSpecifiedAsResourcesOfBundle:(NSBundle *)bundle;
{
  return [bundle pathsForResourcesOfType:ns_RubetteFileType inDirectory:nil];
}

/*" If bundle is a framework, load it. If it is an application, run it.
    Afterwards look for Rubettes contained in the bundle and try to load them. "*/
- (void)defaultLoadBundle:(NSBundle *)bundle;
{
  NSString *path=[bundle bundlePath];
  NSString *pathExtension=[path pathExtension];
  if ([[self rubetteContainerFileTypes] containsObject:pathExtension]) {
    [self loadBundleContainer:bundle];
  } else {
    [self loadRubetteBundle:bundle];
  }
}

- (void)loadBundleContainer:(NSBundle *)bundle;
{
  NSString *path=[bundle bundlePath];
  NSString *pathExtension=[path pathExtension];
  NSArray *specifiedResources=[self rubettesSpecifiedInInfoDictionaryOfBundle:bundle];
  NSMutableArray *array;
  NSEnumerator *e;
  NSString *next;
  if (specifiedResources) {
    if (![specifiedResources count])
      return; // error
    else
      array=[specifiedResources mutableCopy];
  } else {
    array=[NSMutableArray array];
  }
  e=[[self rubettesSpecifiedAsResourcesOfBundle:bundle] objectEnumerator];
  while (next=[e nextObject])
    if (![array containsObject:next])
      [array addObject:next];
  if ([array count]) {
    // get the bundle loaded
    if ([pathExtension isEqualToString:@"app"]) {
      // run Applications
      if (![[NSWorkspace sharedWorkspace] launchApplication:path])
        return;
    }
    if ([pathExtension isEqualToString:@"framework"]) {
      // load frameworks (bundles might depend on them)
      [bundle load];
    }
    // get all contained bundles loaded
    e=[array objectEnumerator];
    while (next=[e nextObject]) {
      bundle = [[NSBundle alloc] initWithPath:next];
      [self loadRubetteBundle:bundle];
      [bundle release];
    }
  }
}

// You can set @"RubetteBundlePrincipalClass":@"RubetteBundlePrincipalClass" in infoDictionary,
// if You want the default behaviour (using infoDictionary)
- (void)loadRubetteBundle:(NSBundle *)bundle;
{
  NSDictionary *infoDict=[bundle infoDictionary];
  id/*<RubetteBundlePrincipalClass>*/ pc=nil;
  [bundle load]; // this imports the symbols of the bundle

  // load Patch in same Directory or in Directory where main bundle is.
  if (bundle) {
    NSString *patchPath=[[bundle bundlePath] stringByAppendingString:@".patch"];
    NSBundle *patchBundle=[NSBundle bundleWithPath:patchPath];
    if (!patchBundle) {
      patchPath=[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:[patchPath lastPathComponent]];
      patchBundle=[NSBundle bundleWithPath:patchPath];      
    }
    if (patchBundle)
      [patchBundle principalClass];
  }
  
  if (infoDict) {
    id rubetteLoaderName=[infoDict objectForKey:@"RubetteBundlePrincipalClass"];
    if (rubetteLoaderName && [rubetteLoaderName isKindOfClass:[NSString class]])
      pc=NSClassFromString(rubetteLoaderName);
    if (!pc)
      pc=[bundle principalClass];
    if ([pc conformsToProtocol:@protocol(RubetteBundlePrincipalClass)])
      [pc initializeBundle:bundle withDistributor:self display:YES];
  } 
}

@end

@implementation AbstractDistributor (Distributor) 
// sum of the above
// this results in compile time warnings, but otherwise 
// [AbstractDistributor conformsToProtocol:@protocol(Distributor)] would return NO!
// see the following standalone-code for reference:
/*
@protocol P1
- (void)m1;
@end
@protocol P <P1>
@end

@interface C1 : NSObject 
@end
@interface C1 (P1) <P1>
- (void)m1;
@end
@interface C1 (P) <P>
@end

@implementation C1 
@end
@implementation C1 (P1)
- (void)m1;
{  NSLog(@"m");
}
@end

#define withEmptyDef
#ifdef withEmptyDef
// if with, warnings during compile, but at runtime YES, YES.
// if without, no warnings, but NO,NO
@implementation C1 (P)
@end
#endif


int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    BOOL b;
    id c1;
    c1=[[C1 alloc] init];
    b=[c1 conformsToProtocol:@protocol(P)];
    if (b) NSLog(@"YES"); else NSLog(@"NO");
    [pool release];
    return 0;
}
*/
@end



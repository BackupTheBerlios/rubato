#import "FScriptRubetteDriver.h"
#import <FScript/System.h>
#import <FScript/FSServicesProvider.h>
#import <FScript/FSInterpreter.h>

@protocol InterpreterProviderFScriptRubetteDriver
-(id)interpreter;
@end

@implementation FScriptRubetteDriver


/* class methods to be overriden */
+ (NSString *)nibFileName;
{
    return @"FScript.nib";
}

+ (const char *)rubetteName;
{
    return "FScript";
}
  
- (void)awakeFromNib;
{
//  static id servicesProvider=nil;
  id interpreter=[interpreterView interpreter];
  [interpreter setShouldJournal:NO];
  [interpreterWindow makeKeyAndOrderFront:nil];

/*
//  if (!servicesProvider) {
    servicesProvider=[[FSServicesProvider alloc] initWithFScriptInterpreterViewProvider:self];
  //  [servicesProvider registerServicesProvider];
    [servicesProvider registerServerConnection:@"Rubato"];
//  }
 */
}

- (id)interpreterView;
{
  return interpreterView;
}

- (void)wasAwakeFromNib:(id)aDistributor;
{
  id interpreter=[interpreterView interpreter];
  [interpreter setObject:aDistributor forIdentifier:@"distributor"];
}

// Menu methods
- setUpMenu;
{
    if (!myMenu) {
      NSString *menuName=[[self rubetteKey] stringByAppendingString:@" - Rubette"];
        myMenu = [[NSMenu allocWithZone:[[self distributor] zone]]initWithTitle:menuName];
        [[myMenu addItemWithTitle:@"Info" action:@selector(showRubetteInfoPanel:) keyEquivalent:@""] setTarget:self];
        [[myMenu addItemWithTitle:@"Import" action:@selector(showFindPredicatesWindow:) keyEquivalent:@""] setTarget:self];
        [[myMenu addItemWithTitle:@"Help" action:@selector(showRubetteHelpPanel:) keyEquivalent:@""] setTarget:self];
        [self insertCustomMenuCells];
        [[myMenu addItemWithTitle:@"Show" action:@selector(showWindow:) keyEquivalent:@""] setTarget:self];
        [[myMenu addItemWithTitle:@"Hide" action:@selector(hideWindow:) keyEquivalent:@""] setTarget:self];
        [[myMenu addItemWithTitle:@"Close" action:@selector(closeRubette:) keyEquivalent:@""] setTarget:self];	
    }
    return self;
}

- (void)showRubetteInfoPanel:(id)sender;
{
  if (!infoPanel) {
    id bundle=[NSBundle bundleForClass:[System class]];
    if (![bundle loadNibNamed:@"FScriptAppInfo" owner:self])  {
      NSLog(@"Failed to load FScriptAppInfo.nib");
      NSBeep();
      return;
    }
    [infoPanel center];
  }
  [infoPanel makeKeyAndOrderFront:nil];
}
@end

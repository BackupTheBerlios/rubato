#import <Rubette/NibDrivenRubetteDriver.h>

// experimental. 
// where should the instances go? 
// main instance into Rubato main app for doing the external communication?
@interface FScriptRubetteDriver : NibDrivenRubetteDriver 
{
  id infoPanel;
  IBOutlet NSWindow *interpreterWindow;
  IBOutlet id interpreterView;
}
@end

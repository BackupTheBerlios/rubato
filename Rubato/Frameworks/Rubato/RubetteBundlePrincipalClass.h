
#import <Foundation/Foundation.h>
#import "RubatoController.h"

@interface RubetteBundlePrincipalClass : NSObject
{
  id/* <Distributor> */ distributor;
  NSBundle *bundle;
  BOOL display;
}
// the one method called by Distributor
// if display=NO, skip creating interface (see NSDocumentController)
+ (void)initializeBundle:(NSBundle *)bundle withDistributor:(id/* <Distributor> */)distributor display:(BOOL)display;
- (id)initWithBundle:(NSBundle *)aBundle distributor:(id/* <Distributor> */)aDistributor display:(BOOL)yn;
- (NSArray *)rubetteDriverClasses;
- (void)registerRubettes;
- (void)registerRubette:(id)rubetteDriverClass;
@end

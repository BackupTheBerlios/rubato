#import "RubetteBundlePrincipalClass.h"

@implementation RubetteBundlePrincipalClass
+ (void)initializeBundle:(NSBundle *)aBundle withDistributor:(id/* <Distributor> */)aDistributor display:(BOOL)yn;
{
  RubetteBundlePrincipalClass *instance=[[self alloc] initWithBundle:aBundle distributor:aDistributor display:yn];
//  [self loadNibNamed:[MetroRubetteDriver nibFileName]];
  [instance registerRubettes];
  [instance release];
}

- (id)initWithBundle:(NSBundle *)aBundle distributor:(id/* <Distributor> */)aDistributor display:(BOOL)yn;
{
  [super init];
  bundle=[aBundle retain];
  distributor=[aDistributor retain];
  display=yn;
  return self;
}

- (void)dealloc;
{
  [bundle release];
  [distributor release];
}

// jg: error catching to be done
- (NSArray *)rubetteDriverClasses;
{
  NSMutableArray *ret=[NSMutableArray array];
  NSArray *a=[[bundle infoDictionary] objectForKey:@"RubetteDriverClasses"];
  NSEnumerator *e=[a objectEnumerator];
  NSString *next;
  while (next=[e nextObject]) {
    id cl=NSClassFromString(next);
    if (cl)
      [ret addObject:cl];
  }
  return ret;
}

- (void)registerRubettes;
{
  NSEnumerator *e=[[self rubetteDriverClasses] objectEnumerator];
  id rubetteDriverClass;
  while (rubetteDriverClass=[e nextObject]) {
    [self registerRubette:rubetteDriverClass];
  }
}
- (void)registerRubette:(id)rubetteDriverClass;
{
  [rubetteDriverClass initializeBundle:bundle withDistributor:distributor display:display];
}
@end

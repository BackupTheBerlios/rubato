#import "RubatoController.h"

@interface AbstractDistributor : NSObject 
//:JgObject // <NSMenuActionResponder> is now integrated in NSObject as Category NSMenuValidation (see NSMenu.h)
{
}
+ (id)globalDistributor;
- (id/* <Distributor> */)globalDistributor;
@end
@interface AbstractDistributor (RubatoArchivers) <RubatoArchivers>
@end
@interface AbstractDistributor (ResourceDirectories) <ResourceDirectories>
@end
@interface AbstractDistributor (AddingTools) <AddingTools> 
@end
@interface AbstractDistributor (RubetteLogin) <RubetteLogin> 
@end
@interface AbstractDistributor (RubetteLoading) <RubetteLoading> 
@end
@interface AbstractDistributor (RubetteActivation) <RubetteActivation> 
@end
@interface AbstractDistributor (DistributorAppKit) <DistributorAppKit> 
@end
@interface AbstractDistributor (Distributor) //avoid compiler errors <Distributor>
// sum of the above
@end

#if 0
@interface AbstractDistributor (Dependencies)
// AddingTools
- (NSMenuItem *)toolsMenuItem; // where to put the toolMenuItems
- (NSMutableDictionary *)toolDictionary; // where to put the tools
// RubetteLogin
- (void)setTool:(id)tool forKey:(NSString *)key replaceOld:(BOOL)replaceOld;
@end
#endif

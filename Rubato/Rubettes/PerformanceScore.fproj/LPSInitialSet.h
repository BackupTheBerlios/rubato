/* LPSInitialSet.h */

#import "InitialSet.h"

#define Hierarchy_Size 64

@interface LPSInitialSet:InitialSet
{
    id myLPS;
}

/* class methods specialized creation of initialSets */
+ newBPSetForLPS:anLPS atIndex:(int)basis;
+ newBPListForLPS:anLPS withSpace:(spaceIndex)basisSpace;
+ newWallSystemForLPS:anLPS inSpace:(spaceIndex)aSpace;
+ newWallForLPS:anLPS inSpace:(spaceIndex)aSpace at:(int)index;
+ newDefaultInitialSetForLPS:anLPS;

/* standard object methods to be overridden */
- init;
- (void)dealloc;
- copyWithZone:(NSZone*)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- setOwnerLPS:aLPS;
- ownerLPS;

@end



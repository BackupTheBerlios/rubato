/* InitialSet.h */

#import <RubatoDeprecatedCommonKit/commonkit.h>

#import "Simplex.h"
#import <Rubato/RubatoTypes.h>
#import <Rubette/SpaceProtocol.h>


@interface InitialSet:JgObject <SpaceProtocol>
{
    id myList;
    id mySimplex;
    BOOL isList;
}

/* standard class methods to be overridden */
+ (void)initialize;

/* standard object methods to be overridden */
- init;
- (void)dealloc;
- copyWithZone:(NSZone*)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- simplex;
- setSimplex:aSimplex;

- (BOOL) isInitialSimplex;
- (BOOL) isInitialList;
- (BOOL) isFlat;
- convertToInitialList;

- veryNearInitialSetTo:anEvent;

/* convert self to a single-list-initial list */
- realizeAsList;

/* insert self into a single-list-initial list */
- wrapSelfInList;

- makeListWith:anInitialSet;
- flatten;

/* restriction to resp. exclusion from a frame */
- restrictTo:aFrameObject;
- excludeFrom:aFrameObject;

- initialSetAt:(int)index;
- setInitialSet:initialSet at:(int)index;
//- addInitialSet:initialSet;
- lastInitialSet;
- (unsigned int)indexOfObject:anInitialSet;
- (BOOL) contains:anInitialSet;

- (int) listCount;

/* implemented methods of SpaceProtocol */
/* Managing the mySpace variable of an Object */
- setSpaceAt:(int)index to:(BOOL)flag;
- (BOOL) spaceAt:(int)index;
- setSpaceTo:(spaceIndex)aSpace;
- (spaceIndex) space;

/* synonyms for space access */
- (BOOL) directionAt:(int)index;
- (spaceIndex) direction;

/* Dimension and inclusion calculation */
- (int) dimension;
- (int) dimensionAtIndex:(int)index;
- (int) dimensionOfIndex:(int)index;
- (int) indexOfDimension:(int)dimension;
- (BOOL) isSubspaceFor:(spaceIndex) aSpace;
- (BOOL) isSuperspaceFor:(spaceIndex) aSpace;




@end
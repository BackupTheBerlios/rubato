/* SpaceProtocol.h Protocol */

#import <Rubato/SpaceTypes.h>

@protocol SpaceProtocol

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
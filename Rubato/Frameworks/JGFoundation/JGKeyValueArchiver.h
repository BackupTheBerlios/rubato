/* JGKeyValueArchiver.h created by jg on Thu 17-Aug-2000 */

#import <Foundation/Foundation.h>
#import "JGPropertyArchiver.h"

@interface JGKeyValueArchiver : JGPropertyArchiver
{
  BOOL getAttributesAsString; /*" (YES) valueForAttribute returns [att description] if yes "*/
  BOOL useEntityNameForClass;
  BOOL separateKeys;
}
- (id)init;

- (BOOL) getAttributesAsString;
- (void) setGetAttributesAsString:(BOOL)newGetAttributesAsString;
- (BOOL) useEntityNameForClass;
- (void) setUseEntityNameForClass:(BOOL)newUseEntityNameForClass;
- (BOOL) separateKeys;
- (void) setSeparateKeys:(BOOL)newSeparateKeys;


/*" overridden methods"*/
- (id)classInfoForObject:(id)obj;
- (void)addToDictionary:(NSMutableDictionary *)dict representationForObject:(id)obj;

/*" added methods"*/
- (id)valueForAttribute:(id)att;
@end

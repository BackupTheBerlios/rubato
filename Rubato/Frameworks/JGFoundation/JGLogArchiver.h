/* JGLogArchiver.h created by jg on Thu 06-May-1999 */

#import <Foundation/Foundation.h>

@interface JGLogArchiver:NSArchiver
{
}

- (void)encodeObject:(id)object;
- (void)encodeValueOfObjCType:(const char*)typestr at:(void *)adress;


@end

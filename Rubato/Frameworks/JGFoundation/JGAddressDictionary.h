/* JGAddressDictionary.h created by jg on Wed 23-Jun-1999 */

#import <Foundation/Foundation.h>
#import "JGAddressDictionaryValue.h"

@interface UniqueNessDictionary : NSObject
{
  NSMutableDictionary *dict;
}
- (id)init;
- (void)insertKey:(id) key;
- (BOOL)isUnique:(id) key;

@end

typedef struct _JGAddressDictionaryInfo {
  NSNumber *key;
  JGAddressDictionaryValue *val;
  NSString *name;
  BOOL unique;
} structJGAddressDictionaryInfo;


// Key:(NSNumber long)Adresse, Val: JGAddressDictionaryValue (Number, NSString)
@interface JGAddressDictionary : NSObject
{
   NSMutableDictionary *addresses;
   long counter; // starts at 0. Negative Numbers mean failure.
   UniqueNessDictionary *names; // Key:NSString (Val:NSNumber (BOOL))

   structJGAddressDictionaryInfo info; 
}

- (id)init;
- objectForKey:key;
- (BOOL)containsAddress:(void *)address; 
- (void)insertAddress:(void *)address withName:(NSString *)aName;
- (NSString *)getNumberStringForAddress:(void *)address;
- (NSMutableString *)getNameForAddress:(void *)address;
- (NSString *)getUniqueNameForAddress:(void *) address;

@end

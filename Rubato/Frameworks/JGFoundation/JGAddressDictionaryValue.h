/* JGAddressDictionaryValue.h created by jg on Thu 24-Jun-1999 */

#import <Foundation/Foundation.h>

// name is a copy of aName. That allows name to be renamed.
@interface JGAddressDictionaryValue : NSObject
{
  long number; // numbered
  NSMutableString *name; // named
}

+ (JGAddressDictionaryValue *) addressDictionaryValueWithNumber:(long)number andName:(NSString *)aName;
- (JGAddressDictionaryValue *) initWithNumber:(long)n andName:(NSString *)aName;
- (long)getNumber;
- (NSMutableString *)getName;
- (NSString *)getNumberString;
@end

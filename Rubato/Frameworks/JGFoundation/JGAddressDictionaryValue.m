/* JGAddressDictionaryValue.m created by jg on Thu 24-Jun-1999 */

#import "JGAddressDictionaryValue.h"

@implementation JGAddressDictionaryValue
+ (JGAddressDictionaryValue *)addressDictionaryValueWithNumber:(long)n andName:(NSString *)aName;
{
  JGAddressDictionaryValue *a=[JGAddressDictionaryValue new];
  [a initWithNumber:n andName:aName];
  return a;
}

- (JGAddressDictionaryValue *) initWithNumber:(long)n andName:(NSString *)aName;
{
  number=n;
  name=[NSMutableString stringWithString:aName];
  return self;
}

- (long)getNumber;
{ return  number;}
- (NSMutableString *)getName;
{ return name;}
- (NSString *)getNumberString;
{ return [NSString stringWithFormat:@"%d", number];}
@end

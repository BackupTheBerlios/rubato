#import <RubatoDeprecatedCommonKit/CommonTypes.h>

@interface JgFract:NSObject
{
   RubatoFract fract;
}
- (id)init;
- (id)initWithFract:(RubatoFract) aFract;

- (RubatoFract) fract;
- (void) setFract: (RubatoFract)aFract;

- (NSString *)type;

- (NSString *) stringValue;
- (int) 	intValue;
- (float)	floatValue;
- (double) doubleValue;
- (BOOL) boolValue;
- (RubatoFract) fractValue;

@end
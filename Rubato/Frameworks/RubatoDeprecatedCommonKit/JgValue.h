#import "CommonTypes.h"

@interface JgValue:NSObject
{
   int interpretation;
   id value;
}
- (id)init;
- (id)initWithFract:(RubatoFract) aFract;

- (void setValue:(id)value;
- (void)setStringValue:(NSString *)aString; 
- (void)setIntValue:(int)aInt;
- (void)setFloatValue:(float)aFloat;
- (void)setDoubleValue:(double)aDouble;
- (void)setBoolValue: (BOOL)aBool;
- (void)setFractValue: (RubatoFract)aFract; 

- (NSString *)type;

- (NSString *) stringValue;
- (int)        intValue;
- (float)      floatValue;
- (double)     doubleValue;
- (BOOL)       boolValue;
- (RubatoFract)      fractValue;

@end

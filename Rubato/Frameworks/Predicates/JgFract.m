#import "JgFract.h"
#import <Rubato/PredicateTypes.h>
@implementation JgFract

- (id)init;
{
  [super init];
  fract=nilFract;
  return self;
}

- (id)initWithFract:(RubatoFract) aFract;
{
  [super init];
  fract=aFract;
  return self;
}

- (id)initWithCoder:(NSCoder *)coder;
{
  char boolval;
  [super init];
  [coder decodeValuesOfObjCTypes:"dlc",&(fract.numerator),&(fract.denominator),&boolval];
  fract.isFraction=(BOOL)boolval;
  return self;
}
- (void)encodeWithCoder:(NSCoder *)coder;
{
//  [super encodeWithCoder:coder];
  char boolval=(char)fract.isFraction;
  [coder encodeValuesOfObjCTypes:"dlc",&(fract.numerator),&(fract.denominator),&boolval];
}

- (RubatoFract) fract;
{
  return fract;
}

- (void)setFract: (RubatoFract)aFract;
{
   fract=aFract;
}

- (NSString *)type;
{
  return ns_type_Fract;
}

// identical to the behaviour of the StringConverter-Class.
- (NSString *) stringValue;
{
    if (fract.isFraction) 
      return [NSString stringWithFormat:@"%.15g/%lu",fract.numerator,fract.denominator];
    else
      return [NSString stringWithFormat:@"%.15g",fract.numerator];
} 

- (int) 	intValue;
{
    return (int)[self doubleValue];
}

- (float)	floatValue;
{
    return (float)[self doubleValue];
}

- (double) doubleValue;
{
    return (!fract.isFraction ? fract.numerator :
                (fract.denominator ? fract.numerator/fract.denominator : 0));
}

- (BOOL) boolValue;
{
  return (BOOL)[self doubleValue];
}

- (RubatoFract) fractValue;
{
  return fract;
}


@end

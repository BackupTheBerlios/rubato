#import <RubatoDeprecatedCommonKit/CommonTypes.h>
#import <Rubato/PredicateTypes.h>
#import <Foundation/Foundation.h>

@implementation NSString (ValueExtensions)
- (NSString *)stringValue;
{
  return self;
}

- (BOOL)boolValue;
{
  return (BOOL)[self doubleValue];
}

- (RubatoFract)fractValue;
{
    const char *myString=[self cString];

    RubatoFract fract = nilFract;
    if (strlen(myString)) {
        const char *postfix, *denom, *slash, *str;
        char **endp = &postfix;
        double signedDenom=0;
        double num2=0;
        str = myString;
        postfix = str;
        slash = strchr(str, '/');

        str = strpbrk(str, "-0123456789I"); /* I is included for Infinity */
        if(str && (!slash || (slash - str)>0)) {
            fract.numerator = strtod(str, endp);
        }

        if (slash) {
            denom = strpbrk(slash, "-0123456789I");
            fract.isFraction = YES;
            if (denom)
                signedDenom = strtod(denom, (char**)NULL);

            str = strpbrk(*endp, "-0123456789");
            if(str && (slash - str)>0) {
                num2 = strtod(str, endp);
            }

            if (signedDenom <0) {
                if (num2)
                    num2 = -num2;
                else
                    fract.numerator = -fract.numerator;

                signedDenom = -signedDenom;
            }

            fract.denominator = (int)signedDenom;
            if (num2)
                if (fract.numerator<0 && num2>0)
                    fract.numerator = fract.numerator * signedDenom - num2;
                else
                    fract.numerator = fract.numerator * signedDenom + num2;

        }
    }
   return fract;
}

/* I do not like them. These methods are meant to collect values from NSCell or NSControl.
- (void)takeDoubleValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(doubleValue)])
        [self setDoubleValue:[sender doubleValue]];
}

- (void)takeFloatValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(floatValue)])
        [self setFloatValue:[sender floatValue]];
}

- (void)takeIntValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(intValue)])
        [self setIntValue:[sender intValue]];
}

- (void)takeBoolValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(boolValue)])
        [self setBoolValue:[sender boolValue]];
}

- (void)takeStringValueFrom:(id)sender
{
    if ([sender respondsToSelector:@selector(stringValue)])
        [self setStringValue:[sender stringValue]];
}
*/
@end

@implementation NSNumber (ValueExtensions)
- (RubatoFract)fractValue;
{
  RubatoFract f;
  f.numerator = [self doubleValue];
  f.denominator=0;
  f.isFraction=NO;
  return f;
}

- (NSString *)type; // used in SimplePredicate
{
  if(!strcmp([self objCType],@encode(int)) ||
     !strcmp([self objCType],@encode(short)) ||
     !strcmp([self objCType],@encode(unsigned int)) ||
     !strcmp([self objCType],@encode(unsigned short))
    )
    return ns_type_Int;
  if(!strcmp([self objCType],@encode(float)))
    return ns_type_Float;
  if(!strcmp([self objCType],@encode(double)))
    return ns_type_Float;
  if(!strcmp([self objCType],@encode(BOOL)))
    return ns_type_Bool;
  return @"error";
}

@end

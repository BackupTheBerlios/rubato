@interface NSString (ValueExtensions)
// I dont want stringValue here, since it is inherited to MutableString.
// I dont want to give back self. And I dont want to copy (immutable) (but possible) (jg).
- (NSString *)stringValue;  // it is so easy to use... All Simple Praedikates respond to  stringValue,intValue,fractValue,floatValue,doubleValue,boolValue
- (RubatoFract)fractValue;
- (BOOL)boolValue;

// e.g. used in ValueInspector.
/* I do not like them. These methods are meant to collect values from NSCell or NSControl.

- (void)takeDoubleValueFrom:(id)sender;
- (void)takeFloatValueFrom:(id)sender;
- (void)takeIntValueFrom:(id)sender;
- (void)takeBoolValueFrom:(id)sender;
- (void)takeStringValueFrom:(id)sender;
*/
@end

@interface NSNumber (ValueExtensions)
- (RubatoFract)fractValue;
- (NSString *)type; // used in SimplePredicate
@end

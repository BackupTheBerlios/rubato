/*ScalarOperator.h*/

#import <PerformanceScore/GenericFieldOperator.h>

@interface ScalarOperator: GenericFieldOperator
{

}


/* get the operator's nib files */
+ (NSString *)inspectorNibFile;

- init;

- setCalcDirectionAt:(int)index to:(BOOL)flag;

/* specific adjustment */
- adjustHierarchy;

- validate;

/*get the string representation of the operator*/
- (NSString *)stringValue;
- (const char*)operatorString;

@end
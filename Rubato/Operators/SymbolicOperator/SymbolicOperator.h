/* SymbolicOperator */
/* This one changes the symbolic events, but only to calulate the performance, not to change the data! */

#import <PerformanceScore/PerformanceOperator.h>

@interface SymbolicOperator:PerformanceOperator
{
    id	myInheritedKernel;
    BOOL isKernelCalculated;
}

/* get the operator's nib file */
+ (NSString *)inspectorNibFile;

- init;
- (void)dealloc;
- (id)initWithCoder:(NSCoder *)aDecoder;

- setKernel:aKernel;

- setFieldDilatationAt:(int)index to:(double)aDouble;
- setFieldTranslationAt:(int)index to:(double)aDouble;

/* maintain calc optimization */
- weightWatcherChanged;
- validate;

/* calculation of new symbolic events */
- calcAlterateKernel;
- brutalizeEventAt:(int)index;

/*get the string representation of the operator*/
- (NSString *)stringValue;
- (const char*)operatorString;

/* Calculate the Field of an Operator */
- calcPerformanceField:(double *)field at:anEvent;

@end
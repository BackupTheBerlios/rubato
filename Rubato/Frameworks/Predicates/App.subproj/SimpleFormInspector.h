
#import <AppKit/AppKit.h>
#import "PredicateInspector.h"

@interface SimpleFormInspector:PredicateInspector
{
    int	valueTag;
    
    id	stringField;
    id	intField;
    id	floatField;
    id	doubleField;
    id	boolField;
    id	fractField;
    
    id	uniqueNameCheck;
    id	changeNameCheck;
    id	changeTypeCheck;
    id	changeValueCheck;
    id	lockedFormCheck;
    
    id	newValue;
}

- setValue:sender;
- displayPatient:sender;

- setValueType:sender;

- showString;
- showInt;
- showFloat;
- showBool;
- showFract;

@end

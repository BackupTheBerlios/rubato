
#import <AppKit/AppKit.h>
#import "PredicateInspector.h"

@interface ValueInspector:PredicateInspector
{
    id	childName; // IB-Objekt?
    int	valueTag;  // IB-Objekt?
    int	childTag;  // IB-Objekt?
    
    id	stringField;
    id	intField;
    id	floatField;
    id	doubleField;
    id	boolField;
    id	fractField;
    
    id	newValue;
}

- setValue:sender;
- displayPatient:sender;

- setValueType:sender;
- setChildTag:sender;

- showString;
- showInt;
- showFloat;
- showBool;
- showFract;

@end

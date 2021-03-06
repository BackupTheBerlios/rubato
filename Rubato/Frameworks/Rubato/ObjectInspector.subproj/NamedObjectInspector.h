
#import "GenericObjectInspector.h"

@protocol NameProvider
- (id)setNameString:(const char *)name;
- (const char *)nameString;
@end

@interface NamedObjectInspector:GenericObjectInspector
{
    id	nameField;
}

- init;
- (void)dealloc;

- (void)setValue:(id)sender;
- displayPatient:sender;

@end

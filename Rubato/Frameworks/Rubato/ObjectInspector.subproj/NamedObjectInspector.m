
#import "NamedObjectInspector.h"
//20.10.00 #import <Predicates/GenericPredicate.h>

@implementation NamedObjectInspector

- init
{
    [super init];
    /* class-specific initialization goes here */
    return self;
}


- (void)dealloc
{
    /* class-specific initialization goes here */
    { [super dealloc]; return; };
}


- (void)setValue:(id)sender;
{
    if (sender==nameField) {
	if ([sender respondsToSelector:@selector(stringValue)])
	    [patient setNameString:[[sender stringValue] cString]];  // patient probably is a Predicate. Warnig is no  problem
    }	
//jg? selectedCell is not a method of PopUps. fixit?
// jg 25.09.01 but still of NSMatrixes.
    else if ([sender respondsToSelector:@selector(selectedCell)])
	if ([sender selectedCell]==nameField)
	    if ([[sender selectedCell] respondsToSelector:@selector(stringValue)])
		[patient setNameString:[[[sender selectedCell] stringValue] cString]];
	
    [super setValue:sender];
}

- displayPatient: sender
{
    [nameField setStringValue:[NSString jgStringWithCString:(const char*)[patient nameString]]];
    return [super displayPatient:sender];
}



@end

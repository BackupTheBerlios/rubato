
#import "ValueInspector.h"



@implementation ValueInspector

- setValue:sender
{
    id aCell = [sender selectedCell];
    [self setValueType:sender];
    if (!childTag) 
	switch(valueTag) {
	    case 0: [patient setStringValue:[aCell stringValue]];
		    break;
	    case 1: [patient setIntValue:[aCell intValue]];
		    break;
	    case 2: [patient setFloatValue:[aCell floatValue]];
		    break;
	    case 3: [patient setDoubleValue:[aCell doubleValue]];
		    break;
	    case 4: [patient setBoolValue:(BOOL)[aCell intValue]];
		    break;
	}
    else 
	switch(valueTag) {
	    case 0: [patient setStringValueOf:[[childName stringValue] cString] to:[[aCell stringValue] cString]];
		    break;
	    case 1: [patient setIntValueOf:[[childName stringValue] cString] to:[aCell intValue]];
		    break;
	    case 2: [patient setFloatValueOf:[[childName stringValue] cString] to:[aCell floatValue]];
		    break;
	    case 3: [patient setDoubleValueOf:[[childName stringValue] cString] to:[aCell doubleValue]];
		    break;
	    case 4: [patient setBoolValueOf:[[childName stringValue] cString] to:(BOOL)[aCell intValue]];
		    break;
	}
    return [super setValue:sender];
}

- setValueType:sender;
{
    valueTag = [[sender selectedCell] tag];
    return self;
}

- setChildTag:sender
{
    childTag = [[sender selectedCell] tag];
    [self displayPatient:sender];
    return self;
}


// jg : in if case here there was allways takeStringValueFrom:patient.
// that is not possible any more, because the patient changes (from NSString to NSNumber)
// and is not changed.
- showString
{
   if (patient) {
	if (!childTag)
	    [stringField setStringValue:[patient stringValue]];
	else
	    [stringField setStringValue:[NSString jgStringWithCString:[patient stringValueOf:[[childName stringValue] cString]]]];
    } else
	[stringField setStringValue:@""];	
    return self;
}

- showInt
{
   if (patient) {
	if (!childTag)
	    [intField setIntValue:[patient intValue]];
	else
	    [intField setIntValue:[patient intValueOf:[[childName stringValue] cString]]];
    } else
	[intField setStringValue:@""];	
    return self;
}

- showFloat
{
   if (patient) {
	if (!childTag)
	    [floatField setFloatValue:[patient floatValue]];
	else
	    [floatField setFloatValue:[patient floatValueOf:[[childName stringValue] cString]]];
    } else
	[floatField setStringValue:@""];	
    return self;
}

- showDouble
{
   if (patient) {
	if (!childTag)
	    [doubleField setDoubleValue:[patient doubleValue]];
	else
	    [doubleField setDoubleValue:[patient doubleValueOf:[[childName stringValue] cString]]];
    } else
	[doubleField setStringValue:@""];	
    return self;
}

- showBool
{
   if (patient) {
	if (!childTag)
	    [boolField setIntValue:[patient boolValue]];
	else
	    [boolField setIntValue:[patient boolValueOf:[[childName stringValue] cString]]];
    } else
	[boolField setIntValue:0];	
    return self;
}


- showFract
{
   RubatoFract fVal;
   if (patient) {
	id strVal = [[StringConverter alloc]init];
	
	if (!childTag)
	    fVal = [patient fractValue];
	else
	    fVal = [patient fractValueOf:[[childName stringValue] cString]];
	
	if (fVal.isFraction) {
	    [fractField setIntValue:fVal.denominator];
	    [strVal setDoubleValue:fVal.numerator];
	    [strVal concat:"/"];
	    [strVal concatWith:fractField];
	    [fractField setStringValue:[strVal stringValue]];
	} else
	    [fractField setDoubleValue:fVal.numerator];
	
	[strVal release];
    } else
	[fractField setStringValue:@""];	
    return self;
}



- displayPatient: sender
{
    [self showString];
    [self showInt];
    [self showFloat];
    [self showDouble];
    [self showBool];
    [self showFract];
    return [super displayPatient: sender];
}


@end

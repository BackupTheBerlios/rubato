
#import "SimpleFormInspector.h"

#import <Predicates/predikit.h>

@implementation SimpleFormInspector

- setValue:sender
{
    id aCell = [sender selectedCell];
    if (aCell==changeNameCheck)
	[patient setAllowsToChangeName:(BOOL)[sender intValue]];
    else if (aCell==changeTypeCheck)
	[patient setAllowsToChangeType:(BOOL)[sender intValue]];
    else if (aCell==changeValueCheck)
	[patient setAllowsToChangeValue:(BOOL)[sender intValue]];
    else if (aCell==uniqueNameCheck)
	[patient setNeedsUniqueName:(BOOL)[sender intValue]];
    else if (aCell==lockedFormCheck) {
	if (NSRunAlertPanel(@"Lock Form", [NSString jgStringWithCString:"Locking a form "
    			"is not reversible. Once a form is locked, it "
			"cannot be changed in any way or unlocked. Proceed?"], @"OK", @"Cancel", nil, NULL)==NSAlertDefaultReturn)
	    [patient setLocked:(BOOL)[sender intValue]];
    }
    else {
	[self setValueType:sender];
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
    }
    return [super setValue:sender];
}

- setValueType:sender;
{
    valueTag = [[sender selectedCell] tag];
    return self;
}


- showString
{
   if (patient) {
	[stringField takeStringValueFrom:patient];
    } else
	[stringField setStringValue:@""];	
    return self;
}

- showInt
{
   if (patient) {
	[intField takeIntValueFrom:patient];
    } else
	[intField setStringValue:@""];	
    return self;
}

- showFloat
{
   if (patient) {
	[floatField takeFloatValueFrom:patient];
    } else
	[floatField setStringValue:@""];	
    return self;
}

- showDouble
{
   if (patient) {
	[doubleField takeDoubleValueFrom:patient];
    } else
	[doubleField setStringValue:@""];	
    return self;
}

- showBool
{
   if (patient) {
	[boolField setIntValue:[patient boolValue]];
    } else
	[boolField setIntValue:0];	
    return self;
}


- showFract
{
   RubatoFract fVal;
   if (patient) {
	id strVal = [[StringConverter alloc]init];
	
	fVal = [patient fractValue];
	
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
    id form = patient;
    [changeNameCheck setIntValue:[form allowsToChangeName]];
    [changeTypeCheck setIntValue:[form allowsToChangeType]];
    [changeValueCheck setIntValue:[form allowsToChangeValue]];
    [uniqueNameCheck setIntValue:[form needsUniqueName]];
    [lockedFormCheck setIntValue:[form isLocked]];
    [lockedFormCheck setEnabled:![form isLocked]];

    [self showString];
    [self showInt];
    [self showFloat];
    [self showDouble];
    [self showBool];
    [self showFract];
    return [super displayPatient:sender];
}


@end

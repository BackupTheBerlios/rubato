
#import "PredicateInspector.h"

#import "PredicateManager.h"
#import "FormManager.h"

#define tag_Generic 	0
#define tag_Empty 	1
#define tag_Predicate 	2
#define tag_String 	3
#define tag_Int 	4
#define tag_Float 	5
#define tag_Bool 	6
#define tag_Coproduct	7
#define tag_List 	8
#define tag_Product 	9
#define tag_Subset 	10
#define tag_Musical 	11
#define tag_Form	12

@implementation PredicateInspector

- doCanChangeType:sender; // sender ist PopUpList.
{
    int i;
    NSArray *cellList = [sender itemArray]; // was: sender cells
    for (i=0; i<[cellList count]; i++) {
	id cell = [cellList objectAtIndex:i];
	if (patient) {
	    switch([cell tag]) {
		case tag_Generic: [cell setEnabled:[patient canChangeTypeString:type_Generic]];
			break;
		case tag_Empty: [cell setEnabled:[patient canChangeTypeString:type_Empty]];
			break;
		case tag_Predicate: [cell setEnabled:[patient canChangeTypeString:type_Predicate]];
			break;
		case tag_String: [cell setEnabled:[patient canChangeTypeString:type_String]];
			break;
		case tag_Int: [cell setEnabled:[patient canChangeTypeString:type_Int]];
			break;
		case tag_Float: [cell setEnabled:[patient canChangeTypeString:type_Float]];
			break;
		case tag_Bool: [cell setEnabled:[patient canChangeTypeString:type_Bool]];
			break;
		case tag_Coproduct: [cell setEnabled:[patient canChangeTypeString:type_Coproduct]];
			break;
		case tag_List: [cell setEnabled:[patient canChangeTypeString:type_List]];
			break;
		case tag_Product: [cell setEnabled:[patient canChangeTypeString:type_Product]];
			break;
		case tag_Subset:[cell setEnabled:[patient canChangeTypeString:type_Subset]];
			break;
		case tag_Musical:[cell setEnabled:[patient canChangeTypeString:type_Musical]];
			break;
	    }
	}
	else
	    [cell setEnabled:YES];
    }
    return self;
}

- doChangeType:sender
{
    id parent = [patient parent];

    typeTag = [sender selectedTag];
    	
    if (parent) {
	int index = [parent indexOfValue:patient];
	[parent removeValue:patient];
	patientChanged = [self changeIt];
	patientEdited = patientChanged;
	/* set state here because manager setSelected clears patientChanged flag */
	[parent setValueAt:index to:patient];
	[[owner manager] selectPredicate:patient];
	[[owner manager] setDocumentEdited:YES];
    } else {
	patientChanged = [self changeIt];
	patientEdited = patientChanged;
    }
    
    [owner setSelected:patient];
    return self;
}

- (BOOL)changeIt;
{
    if (patient) {
	switch(typeTag) {
	    case tag_Generic: patient = [patient changeTypeString:type_Generic];
		    break;
	    case tag_Empty: patient = [patient changeTypeString:type_Empty];
		    break;
	    case tag_Predicate: patient = [patient changeTypeString:type_Predicate];
		    break;
	    case tag_String: patient = [patient changeTypeString:type_String];
		    break;
	    case tag_Int: patient = [patient changeTypeString:type_Int];
		    break;
	    case tag_Float: patient = [patient changeTypeString:type_Float];
		    break;
	    case tag_Bool: patient = [patient changeTypeString:type_Bool];
		    break;
	    case tag_Coproduct:  patient = [patient changeTypeString:type_Coproduct];
		    break;
	    case tag_List: patient = [patient changeTypeString:type_List];
		    break;
	    case tag_Product: patient = [patient changeTypeString:type_Product];
		    break;
	    case tag_Subset: patient = [patient changeTypeString:type_Subset];
		    break;
	    case tag_Musical: patient = [patient changeTypeString:type_Musical];
		    break;
	}
	return YES;
    }
    return NO;
}


- revert: sender;
{
    if (savedPatient) {
	id reverted, oldValue;
	if (NSRunAlertPanel(@"Revert", @"Revert predicate to previous state?", @"Revert", @"Cancel", nil)) {
	    if ([patient parent])
		[[patient parent] replaceValue:patient with: savedPatient];
	    [patient release]; patient=nil;
	    reverted = savedPatient;
	    savedPatient = nil;
	    /*the following obscure calls restores the parent of the values,
	     *which actuially points to a freed object. 
	     */
	    oldValue = [reverted getAllPredicatesOfName:nil];/*get everything*/
	    if (oldValue)
		[reverted setValue:oldValue];/*force parents of oldValue to be reset*/
	    if ([reverted parent])
		[[owner manager] selectPredicate:reverted];
	    else
		[owner setSelected:reverted];
	    [revertButton setEnabled:NO];
	}
    }
    else 
	NSBeep();
    return self;
}

- showType
{
    GenericPredicate *p=(GenericPredicate *)patient;
    int cellTag=-1;

    if ([[p typeName]isEqualToString:ns_type_Generic]) 
	cellTag = tag_Generic;
    if ([[p typeName]isEqualToString:ns_type_Empty]) 
	cellTag = tag_Empty;
    if ([[p typeName]isEqualToString:ns_type_Predicate]) 
	cellTag = tag_Predicate;
    if ([[p typeName]isEqualToString:ns_type_String]) 
	cellTag = tag_String;
    if ([[p typeName]isEqualToString:ns_type_Int]) 
	cellTag = tag_Int;
    if ([[p typeName]isEqualToString:ns_type_Float]) 
	cellTag = tag_Float;
    if ([[p typeName]isEqualToString:ns_type_Bool]) 
	cellTag = tag_Bool;
    if ([[p typeName]isEqualToString:ns_type_Coproduct]) 
	cellTag = tag_Coproduct;
    if ([[p typeName]isEqualToString:ns_type_List]) 
	cellTag = tag_List;
    if ([[p typeName]isEqualToString:ns_type_Product]) 
	cellTag = tag_Product;
    if ([[p typeName]isEqualToString:ns_type_Subset]) 
	cellTag = tag_Subset;
    if ([[p typeName]isEqualToString:ns_type_Musical]) 
	cellTag = tag_Musical;
    
    if ([typeField respondsToSelector:@selector(setStringValue:)])
	[typeField setStringValue:[[p form] name]];
    
//    [[typeMenu itemMatrix] selectCellWithTag:cellTag];
    [typeMenu selectItemAtIndex:[typeMenu indexOfItemWithTag:cellTag]];
//    [typeMenu setTitle:[[[typeMenu itemMatrix] selectedCell] title]];
    [typeMenu setTitle:[[typeMenu selectedItem] title]];
//    [self doCanChangeType:[typeMenu itemMatrix]];
    [self doCanChangeType:typeMenu];
    /* get target and itemlist because IB connects to the Button 
and not to the popupList's Matrix directly!!!! */
    return self;
}



- displayPatient: sender
{
    /* now display the predicate */
/*    
    [newButton setEnabled:[patient respondsTo:@selector(makePredicate)]];
    [insertButton setEnabled:patientNew && patient];
    [removeButton setEnabled:(int)patient];
    [removeButton setState:patientNew];
    [[loadedButton setState:patientNew] setTransparent: !patient];
    [revertButton setEnabled:savedPatient && patientEdited];
*/
    [self showType];

    return [super displayPatient:sender];
}

#if 0
- newPredicate:sender;
{
    if (patientNew)
	[patient release];
    patient = [[[owner globalFormManager]selected]makePredicate];
    selected = nil;
    savedPatient = [savedPatient release];/* WARNING Hier gibts Probleme */
    [self changeIt];
    patientChanged = YES;
    patientEdited = NO;
    inspectorChanged = YES;
    patientNew = YES;
    [self displayPatient:self];
    return self;
}

- addPredicate:sender;
{
    if (patient)
	[[owner manager] addPredicate:patient];
    patientNew = NO;
    [self displayPatient:self];
    return self;
}

- removePredicate:sender;

{
    if (!patientNew) {
	[[owner manager] removePredicate:patient];
	selected = nil;
    } else {
	patient = [patient release];
	patientChanged = YES;
	patientEdited = NO;
	inspectorChanged = YES;
	patientNew = NO;
    }
    [self displayPatient:self];
    return self;
}

#endif

@end


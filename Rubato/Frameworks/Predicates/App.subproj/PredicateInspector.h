
#import <AppKit/AppKit.h>
#import <Rubato/NamedObjectInspector.h>

#import <Predicates/predikit.h>


@interface PredicateInspector:NamedObjectInspector
{
    id	typeMenu;
    int	typeTag;
    
    id	typeField;

/*
    id	newButton;
    id	insertButton;
    id	removeButton;
    id	loadedButton;
    id	revertButton;
*/
}


- doCanChangeType:sender;
- doChangeType:sender;
- (BOOL)changeIt;

- revert:sender;

- showType;
- displayPatient:sender;

/*
- newPredicate:sender;
- addPredicate:sender;
- removePredicate:sender;
*/

@end

#import "PredicateFinder.h"

#import "PredicateManager.h"
#import "FormManager.h"
#import <Rubato/PredicateTypes.h>
#import <Predicates/GenericPredicate.h>
//#import <streams/streamsimpl.h>

@implementation PredicateFinder

- (void)awakeFromNib;
{
    [findPanel setFrameUsingName:[findPanel title]];
}


/* access to instance variables */
- setManager:aManager;
{
    if ([aManager isKindOfClass:[PredicateManager class]] || [aManager isKindOfClass:[FormManager class]] || !aManager)
	manager = aManager;
    return self;
}

- manager;
{
    return manager;
}


- changeFindLevels:sender;
{
    [findLevels setIntValue:[[sender selectedCell] tag]]; // jg: selectedItem?
    return self;
}

/* finding predicates */
- (void)doSearch:(id)sender;/* action method for find buttons */
{
    if (![[findName stringValue] isEqualToString:ns_nilStr]) {
	[foundPredicates release];
	foundPredicates = [self searchForPredicates];
    }
    [self getMathStringOfFound:mathText];
}

- searchForPredicatesWithName:(const char*)aPredicateName inLevels:(int)levels;
{
    id aPredicate = [manager selected] ? [manager selected] : [manager predicateList];
    return [aPredicate getAllPredicatesOf:@selector(isPredicateOfName:)
	with:[NSString stringWithCString:aPredicateName] inLevels:levels];  // jg was: findName instead of aPredicateName
}

- searchForPredicates;
{
    SEL testMethod = @selector(isPredicateOfName:);
    id aPredicate = [manager selected] ? [manager selected] : [manager predicateList];
    switch ([[findWhat selectedItem] tag]  // jg? is this ok? somewhere the tags must be initialized!
	    +[[findHow selectedItem] tag]) {  // Has/Contains
	case 0: testMethod = @selector(isPredicateOfName:);  // Interface: "Has..."
		break;
	case 1: testMethod = @selector(hasPredicateOfName:); // Interface: "Contains..."
		break;
	case 2: testMethod = @selector(isPredicateOfType:);
		break;
	case 3: testMethod = @selector(hasPredicateOfType:);
		break;
	case 4: testMethod = @selector(isPredicateOfFormName:);
		break;
	case 5: testMethod = @selector(hasPredicateOfFormName:);
		break;
	case 6: testMethod = @selector(isPredicateOfForm:);
		break;
	case 7: testMethod = @selector(hasPredicateOfForm:);
		break;
    }
    return [aPredicate getAllPredicatesOf:testMethod
	with:[findName stringValue] inLevels:[findLevels intValue]]; // jg findName is TextFeld. was: without stringValue.
}

- getMathStringOfFound:sender;
{
    if ([sender respondsToSelector:@selector(setString:)]) {
	NSMutableString *mutableString = [NSMutableString new];
	unsigned int i, count;
	[mutableString appendFormat:@"%s", "{"];
	count = [foundPredicates count];
	for (i=0; i<count; i++) {
	    [[foundPredicates objectAt:i] appendToMathString:mutableString andTabs:0];
	    if (i < count-1) [mutableString appendFormat:@"%s", ","];
	}
	[mutableString appendFormat:@"%s", "\n}\n"];
	[sender setString:mutableString];
    }
    return self;
}

- (void)showFindPanel:sender;
{
    [findPanel makeKeyAndOrderFront:self];
}

@end

@implementation PredicateFinder(WindowDelegate)
/* (WindowDelegate) methods */

- (BOOL)windowShouldClose:(id)sender;
{
    [findPanel saveFrameUsingName:[findPanel title]];
    return YES;
}


@end

#import "ListInspector.h"
//#import <Rubato/PredicateTypes.h>
#import <Predicates/predikit.h>
#import <RubatoDeprecatedCommonKit/StickyNXImage.h>


@implementation ListInspector

- (void)setValue:(id)sender;
{
    [super setValue:sender];
}



- displayPatient: sender
{
    [childBrowser validateVisibleColumns];
    return [super displayPatient: sender];
}



/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    if (column)
	return 0;
    else
	return [patient count];
}

//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    if (!column) {
	id predicate;
	id image, imageString = [[StringConverter alloc]init];
	predicate = [patient getValueAt:row];
	if (predicate) {
	    if ([predicate isKindOfClass:[SimplePredicate class]]) {
		const char *pnam=[predicate nameString], *pval=[[predicate stringValue] cString],
				    *delim = ": ";
		char * str = malloc(strlen(pnam)+strlen(pval)+strlen(delim)+1);
		strcpy(str, pnam);
		strcat(str, delim);
		strcat(str, pval);
		[cell setLoaded:YES];
		[cell setStringValue:[NSString jgStringWithCString:str]];
		[cell setLeaf:YES];
		free(str);
	    } else {
              id theName;
		[cell setLoaded:YES];
		[cell setStringValue:[NSString jgStringWithCString:[predicate nameString]]];
		[cell setLeaf:YES];
		[imageString setStringValue:[NSString jgStringWithCString:[predicate typeString]]];
                theName=[[NSBundle bundleForClass:[self class]] pathForImageResource:[imageString stringValue]];
                image = [[NSImage alloc]initByReferencingFile:theName];
                if (image) {
                    [cell setImage:image];
                    [image release];
                }
                [imageString concat:"H"];
                theName=[[NSBundle bundleForClass:[self class]] pathForImageResource:[imageString stringValue]];
                image = [[NSImage alloc]initByReferencingFile:theName];
                if (image) {
                    [cell setAlternateImage:image];
                    [image release];
                }
	    }
	}
	[imageString release];
    }
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
{
    return NO;
}
@end

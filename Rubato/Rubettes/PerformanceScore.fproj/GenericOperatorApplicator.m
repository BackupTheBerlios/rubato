/* GenericOperatorApplicator.m */

#import <RubatoDeprecatedCommonKit/StringConverter.h>

#import "GenericOperatorApplicator.h"
#import <Rubato/RubatoTypes.h>
#import "PerformanceOperator.h"

@implementation GenericOperatorApplicator

/* get the applicator's nib file */
+ (NSString *)nibFileName;
{    
/*    int sl = [NSStringFromClass([self class]) length] + strlen(".nib") + 1;
    char *name = malloc(sl);
    strcpy (name, [NSStringFromClass([self class]) cString]);
    strcat (name, ".nib");
    return name;
*/
  return [NSStringFromClass([self class]) stringByAppendingString:@".nib"];
}


- init;
{
    [super init];
    
    myNameString = [[StringConverter alloc]init];
    return self;
}

- initFromLPS:anLPS;
{
    [self init];
    
    return self;
}

- (void)dealloc;
{
    [myNameString release];
    myNameString = nil;
    [myDialogPanel close];
    [myDialogPanel release];
    myDialogPanel = nil;
    [super dealloc];
}

- setOperator:anOperator;
{
    if ([anOperator isKindOfClass:[self operatorClass]])
	myOperator = anOperator;
    return self;
}


- takeNameFrom:sender;
{
    if ([sender respondsToSelector:@selector(stringValue)]) {
	[myNameString setStringValue:[sender stringValue]];
	[myOperator setNameString:[[sender stringValue] cString]];
    }
    [self displayValues:self];
    return self;
}


- (const char*) nameString;
{
    return [[myNameString stringValue] cString];
}
- (NSString *)name; // jg added
{
    return [NSString jgStringWithCString:[self nameString]];
}


- collectValues:sender;
{
    if ([myNameField respondsToSelector:@selector(stringValue)]) {
	[myNameString setStringValue:[myNameField stringValue]];
	[myOperator setNameString:[[myNameField stringValue] cString]];
    }
    [self displayValues:self];
    return self;
}

- displayValues:sender;
{
    if ([myNameField respondsToSelector:@selector(setStringValue:)]) {
	[myNameField setStringValue:[myNameString stringValue]];
    }
    return self;
}


/* get the applicator's nib file */
- (NSString *)nibFileName;
{
    return [[self class]nibFileName];
}

- loadNibFile;
{
   NSString *path;
   path = [[NSBundle bundleForClass:[self class]] pathForResource:NSStringFromClass([self class]) ofType:@"nib"];
   if(![NSBundle loadNibFile:path externalNameTable:[NSDictionary dictionaryWithObjectsAndKeys:self, @"NSOwner", nil] withZone:[self zone]]) {
	/* if we couldn't get a valid path try it in the App's directory */
	[NSBundle loadNibNamed:NSStringFromClass([self class]) owner:self];
    }
   [myNameField setStringValue:NSStringFromClass([self operatorClass])];
    return self;
}

/* Running the Applicator */
- (int) runDialog;
{
    int retVal = 0;
    if (!myDialogPanel)
	[self loadNibFile];
    [self displayValues:self];
    retVal = [[NSApplication sharedApplication] runModalForWindow:myDialogPanel]; 
    [myDialogPanel close];
    return retVal;
}


- ok:sender;
{
    [[NSApplication sharedApplication] stopModalWithCode:NSAlertDefaultReturn]; /* return 1 */
    [self collectValues:self];
    return self;
}

- (void)cancel:(id)sender;
{
    [[NSApplication sharedApplication] stopModalWithCode:NSAlertAlternateReturn]; /* return 0 */
}

- operatorClass;
{
    return [PerformanceOperator class];
}

@end

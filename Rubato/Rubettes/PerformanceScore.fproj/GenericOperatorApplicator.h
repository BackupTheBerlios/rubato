/* GenericOperatorApplicator.h */

#import <AppKit/AppKit.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>

@interface GenericOperatorApplicator:JgObject
{
    id	myOperator;
    id	myNameString;
    id	myNameField;
    id	myDialogPanel;
}

/* get the applicator's nib file */
+ (NSString *)nibFileName;

- init;
- initFromLPS:anLPS;
- (void)dealloc;

- setOperator:anOperator;

- takeNameFrom:sender;
- (const char*) nameString;
- (NSString *)name; // jg added

- collectValues:sender;
- displayValues:sender;

/* get the applicator's nib file */
- (NSString *)nibFileName;
- loadNibFile;

/* Running the Applicator */
- (int) runDialog;
- ok:sender;
- (void)cancel:(id)sender;

- operatorClass;

@end

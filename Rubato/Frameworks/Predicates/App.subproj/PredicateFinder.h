
#import <AppKit/AppKit.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>

@interface PredicateFinder:JgObject
{
    id	manager;

// IB-Objekts  
    id findPanel;
    id foundPredicates;
    id findName;  // jg NSTextField in Nib
    id findLevels;
    id findLevelsMenu;
    id findWhat; // Name/Type/FormName  Tags:0,2,4
    id findHow; // PopupListe Has.../Contains...  Tags:0,1
    id mathText;
}

- (void)awakeFromNib;

/* access to instance variables */
- setManager:aManager;
- manager;

- changeFindLevels:sender;

/* finding predicates */
- (void)doSearch:sender;/* action method for find buttons */
- searchForPredicatesWithName:(const char*)aPredicateName inLevels:(int)levels;
- searchForPredicates;
- getMathStringOfFound:sender;

- (void)showFindPanel:sender;

@end

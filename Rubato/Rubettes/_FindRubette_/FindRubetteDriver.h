
#import <AppKit/AppKit.h>

#import "Rubato/Rubettes.h"

@interface FindRubetteDriver:RubetteDriver
{
    /* preferences objects */
    id	showType;
    id	showName;
    id	showForm;
    id	showValue;
    id	new;
    id	indent;
    id	start;
    id	end;
    id	fieldStart;
    id	fieldEnd;
    id	fieldDelimiter;
    id	myPreferencesPanel;
    id	myText;
}

- (void)dealloc;
- customAwakeFromNib;

- readCustomData;
- writeCustomData;

/* finding predicates */
- doSearch:sender;/* action method for find buttons */
- initSearch:sender;

- getStringOfFound:sender;
- writeCustomStream:(NXStream *)stream;

- insertCustomMenuCells;

/* methods to be overridden by subclasses */
+ (const char*)nibFileName;
+ (const char *)rubetteName;
+ (const char *)rubetteVersion;

@end

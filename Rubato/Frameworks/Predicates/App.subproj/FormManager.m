/* FormManager.m */

#import <RubatoDeprecatedCommonKit/Macros.h>
#import <Predicates/predikit.h>
#import "FormManager.h"
//#import "PredicateInspector.h"
#import "PredicateManager.h"
#import <Rubato/RubatoController.h>
#import <RubatoDeprecatedCommonKit/StickyNXImage.h>
#import <RubatoDeprecatedCommonKit/JGNXCompatibleUnarchiver.h>

#define numMaxVisibleColumns 10

@implementation FormManager

/* standard object methods to be overridden */
- init
{
    id listForm;
    [super init];
    /* class-specific initialization goes here */
/* jg 13.6.00
    listForm = [[CompoundForm allocWithZone:[self zone]]init];
    [listForm setTypeString:type_List];
    [listForm setNameString:"ListForm"];
    [listForm setLocked:YES];
    [listForm setAllowsToChangeType:NO];
*/
    listForm = [CompoundForm listForm];
    
    myFormList = [listForm makePredicateFromZone:[self zone]];
    [[myFormList setNameString:"List Of ALL Forms"]setValueAt:0 to:listForm];
    selected = nil;
    selectedCell = nil;
    browserIsValid = NO;
    return self;
}


- (void)dealloc {
    /* class-specific initialization goes here */
    if (myFormList)
	[myFormList release];
    if (filename) free(filename);
    { [super dealloc]; return; };
}
//- read:(NXTypedStream *)stream;
//- write:(NXTypedStream *)stream;

- (void)awakeFromNib;
{
    NSRect columnRect;
    
    [browser loadColumnZero];
    [browserWindow setFrameUsingName:[browserWindow title]];
    inspector = [owner globalInspector];
    [inspector setManager:self];
    columnRect = [[browser matrixInColumn:0] frame];
    [browser setMinColumnWidth:NSWidth(columnRect)];
    [browser setMaxVisibleColumns:numMaxVisibleColumns];
    //[browserWindow makeKeyAndOrderFront:self];
}


/* access to instance variables */
- formList;
{
    return myFormList;
}

- setManager:aManager;
{
    if (manager!=aManager && ([aManager isKindOfClass:[PredicateManager class]] || !aManager)) {
	manager = aManager;
    }
	    
    return self;
}

- manager;
{
    return manager;
}


- signInManager:aManager;
{
    if (aManager) {
	[myFormList setValue:[aManager formList]];
	browserIsValid=NO;
	[self invalidate];
    }
    return self;
}

- signOutManager:aManager;
{
    if (aManager) {
	[myFormList removeValue:[aManager formList]];
	browserIsValid=NO;
	[self invalidate];
    }
    return self;
}


/* copy & paste methods */
- copyToPasteboard:pboard;
{
    NSData *dataBuffer;
    
    [pboard declareTypes:[NSArray arrayWithObject:[NSString jgStringWithCString:PredFileType]] owner:self];

    dataBuffer= [NSArchiver archivedDataWithRootObject:selected];
    [pboard setData:dataBuffer forType:[NSString jgStringWithCString:PredFileType]];	
    return self;
}

- (void)copy:(id)sender;
{
    if (selected) {
	[self copyToPasteboard:[NSPasteboard generalPasteboard]];
    } else
	NSBeep();
}

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type;
{
  // to be implemented
}

- (void)cut:(id)sender;
{
    if (selected) {
	[self copyToPasteboard:[NSPasteboard generalPasteboard]];
	[self removePredicate:selected];
    } else
	NSBeep();
}

- (void)paste:(id)sender;
{
    id pboard, predicate;
    NSData *dataBuffer;
    NSString *firstType;
    
    pboard = [NSPasteboard generalPasteboard];
    firstType = [pboard availableTypeFromArray:[NSArray arrayWithObject:[NSString jgStringWithCString:PredFileType]]];
    if (firstType) {
	if (dataBuffer = [pboard dataForType:firstType]) {
	    predicate = [NSUnarchiver unarchiveObjectWithData:dataBuffer];
	    [self addPredicate:predicate];
	
	} else
	    NSBeep();
    } else
	NSBeep();
}


/* save & load methods */
- setFilename:(const char*) aFilename;
{
    /* this method taken from Garfinkel & Mahoney, p. 331 */
    if (filename) free(filename);
    filename = malloc(strlen(aFilename)+1);
    strcpy(filename, aFilename);
    [browserWindow setTitleWithRepresentedFilename:[NSString jgStringWithCString:aFilename]];
    return self;
}

- saveAs:sender;
{
    /* this method taken from Garfinkel & Mahoney, p. 331 */
    id	panel;
    const char* dir;
    char* file;
    
    /* prompt user for filename and save to that file */
    if (filename==0) {
	/* no filename, set up defaults */
	dir = [NSHomeDirectory() cString];
	file = (char *)[[browserWindow title] cString];
    } else {
	file = rindex(filename, '/');
	if (file) {
	    dir = filename;
	    *file = 0;
	    file++;
	} else {
	    dir = filename;
	    file = (char*)[[browserWindow title] cString];
	}
    }
//#warning FactoryMethods: [SavePanel savePanel] used to be [SavePanel new].  Save panels are no longer shared.  'savePanel' returns a new, autoreleased save panel in the default configuration.  To maintain state, retain and reuse one save panel (or manually re-set the state each time.)
    panel = [NSSavePanel savePanel];
    [panel setRequiredFileType:[NSString jgStringWithCString:FormFileType]];
    [panel setTreatsFilePackagesAsDirectories:NO];
    if ([panel runModalForDirectory:@"" file:@""]) {
	[self setFilename:[[panel filename] cString]];
	return [self save:sender];
    }
    return nil; /*didn't save */
}

- save:sender;
{
    id returnValue = self; /* this variable is used in the load handler macro */
    
    if (filename==0) return [self saveAs:sender];
    [browserWindow setTitle:@"Saving¼"];
        
    NS_DURING
    [[NSArchiver archivedDataWithRootObject:myFormList] writeToFile:[NSString jgStringWithCString:filename] atomically:YES];

    NS_HANDLER
    LOAD_HANDLER  /* a load handler macro in macros.h */
    NS_ENDHANDLER /* end of handler */
    
    [browserWindow setTitleWithRepresentedFilename:[NSString jgStringWithCString:filename]];
    [browserWindow setDocumentEdited:NO];
    return returnValue;
}


- loadFile:(const char*) aFilename;
{
    NSUnarchiver *theStream;
    NSData *data=[NSData dataWithContentsOfFile:[NSString jgStringWithCString:aFilename]];
    theStream = [[JGNXCompatibleUnarchiver alloc] initForReadingWithData:data];
    if(theStream) {
	id returnValue = self; /* this variable is used in the load handler macro */
	[browserWindow setTitle:@"Loading¼"];
	[myFormList release]; /* free current list object */
	
	NS_DURING
	myFormList = [[theStream decodeObject] retain];
	
	NS_HANDLER
	LOAD_HANDLER  /* a load handler macro in macros.h */
	myFormList = nil;
	NS_ENDHANDLER /* end of handler */
	
	[self setFilename:aFilename];
	[theStream release];
	
	browserIsValid = NO;
	[self setSelected:nil];
	return returnValue;
    }
    return nil;
}


- revertToSaved:sender;
{
    const char *fname;
    int q;
    
    fname = filename ? filename : [[sender title] cString];
    if(rindex(fname, '/')) /* increment ptr to actual filename */
	fname = rindex(filename, '/') +1;
    q = NSRunAlertPanel(@"Revert", @"Revert %s to last saved version", @"Revert", @"Cancel", nil, fname);
    if (q==NSAlertDefaultReturn) {
	[self loadFile:filename];
	[self setDocumentEdited:NO];
	[self invalidate];
    }
    return self;
}

- (void)setDocumentEdited:(BOOL)flag;
{
    [browserWindow setDocumentEdited:flag];
    /* something has changed, invalidates all browser columns */
    browserIsValid = NO;
}

/* form list management */
- addPredicateForm:aForm;
{
    if ([aForm isKindOfClass:[GenericForm class]]) { /* not nil & really form */
	[myFormList setValue:aForm];
	if ([aForm count]>1) {
	    unsigned int theCount = [aForm count], index;
	    for (index = 0;index<theCount;index++) {
		[self addPredicateForm:[aForm getValueAt:index]];
	    }
	}
    }
    return self;
}

- addForm:aForm;
{
    if ([aForm isKindOfClass:[GenericForm class]]) { /* not nil & really form */
	[self addPredicateForm:aForm];
	[[self document] updateChangeCount:NSChangeDone];
    } else
	NSBeep();
    return self;
}


/* list management */
- addPredicate: aPredicate;
{
    /* insert it */
    [self addPredicate: aPredicate Before: nil];
    return self;
}

- addPredicate: aPredicate Before: bPredicate;
{
    unsigned int index;
    int row=-1, column=-1;
    id parent;
    
    if ([aPredicate isKindOfClass:[GenericForm class]]) {
	/* decide insertion point of new predicates by current selection*/
	parent = selected;
	
	/* determine bPredicates index */
	if (parent) {
	    index = [parent indexOfValue: bPredicate];
    
	    if (!(index==NSNotFound))
		[parent setValueAt:index to:aPredicate];
	    else 
		[parent setValue: aPredicate];/* insert aPredicate */
	}
	[self addPredicateForm:aPredicate];
	/* set selection to the new inserted predicate*/
	[[self document] updateChangeCount:NSChangeDone];
	[self row:&row andColumn:&column ofPredicate:aPredicate];
	columnChanged = column;
	[self setSelected: aPredicate];
    } else
	NSBeep();
    return self;
}

- before: aPredicate;
{
    int index;
    id parent = (selected ? selected : myFormList);
    if (parent) {
	index = [parent indexOfValue:aPredicate];
	return [parent getValueAt:index-1];
    } else 
	return nil;
}

- after: aPredicate;
{
    int index;
    id parent = (selected ? selected : myFormList);
    if (parent) {
	index = [parent indexOfValue:aPredicate];
	return [parent getValueAt:index+1];
    } else 
	return nil;
}

- removePredicate: aPredicate;
{
    id removed = nil;
    id parent = (selected ? selected : myFormList);
    if (parent) {
	removed=[parent removeValue:aPredicate];
	[[self document] updateChangeCount:NSChangeDone];
 	[self setSelected:parent];
   }
    return removed;
}

- removePredicateAt:(unsigned int)index;
{
    id removed=nil;
    id parent = (selected ? selected : myFormList);
    if (parent) {
	removed = [parent getValueAt:index];
	removed = [parent removeValue:removed];
	[[self document] updateChangeCount:NSChangeDone];
	[self setSelected:parent];
    }
    return removed;
}

- deletePredicate: aPredicate;
{
    [[self removePredicate:aPredicate] release];
    return self;
}

- deletePredicateAt:(unsigned int)index;
{
    [[self removePredicateAt:index] release];
    return self;
}

- newForm:sender;
{
    id aForm = [[SimpleForm allocWithZone:[self zone]]init];
    [self addPredicate:aForm];
    return self;
}

- deleteForm:sender;
{
    if (![selected isLocked])
	[self deletePredicate:selected];
    return self;
}


- row:(int *)aRow andColumn:(int *)aCol ofPredicate:aPredicate;
{/* This method tries to find the coordinates of aPredicate in the
  * currently selected tree. If aPredicate is not in this tree, no
  * further searching is done.
  */
  
    int row, col, column=-1, selCol;
    id predicate = myFormList;
    selCol = [browser selectedColumn];
    selCol = selCol>-1 ? selCol : 0;

	for (row=NSNotFound, col=0; col<=selCol+1; col++) {
	    row = [predicate indexOfValue:aPredicate];
	    column = col;
	    if (row!=NSNotFound)
		break;
	    predicate = [predicate getValueAt:[[browser matrixInColumn:col] selectedRow]];
	}
	
    column = row==NSNotFound ? -1 : column;
    row = row==NSNotFound ? -1 : row;
    *aRow = row;
    *aCol = column;

    return self;
}

- (void)setSelected: aPredicate;
{
    int row = -1, column = -1;
    
    if (aPredicate) {/* only try to get row and col if not nil*/
	[self row:&row andColumn:&column ofPredicate:aPredicate];
    }
    selected = ((row>-1) ? aPredicate : nil);
    
    [Y setIntValue:row];
    [X setIntValue:column];

    [self invalidate];
    [[browser matrixInColumn:column] selectCellAtRow:row column:0];
    selectedCell = [[browser matrixInColumn:column] selectedCell];
    [inspector setSelected: selected];
}

- (void)setSelectedFrom:sender;
{
    int oldRow, oldCol, newCol = [sender selectedColumn];
     
    [self row:&oldRow andColumn:&oldCol ofPredicate:selected];
    selected = [self browser:sender selectedInColumn:[sender selectedColumn]];
    selectedCell = [sender selectedCell];
    browserIsValid = newCol<=oldCol;
//    if ([inspector manager]=self)
    [inspector setSelected: selected];
}

- selected;
{
    return selected;
}

- (void)setSelectedCell:sender;
{
    selectedCell = [sender selectedCell];
}
- selectedCell;
{
    return selectedCell;
}

- selectedInColumn:(int)column;
 {
    int col;
    id predicate=myFormList;
    
    if (!(column<0)) { /* if column is negativ there is nothing selected */
	
	for (col=0; col<=column; col++) {
	    predicate = [predicate getValueAt:[[browser matrixInColumn:col] selectedRow]];
	}
	return predicate;
    }    
    return nil;
 }
 
 - browser:sender selectedInColumn:(int)column;
{
    return [self browser:sender predicateAtRow:[[sender matrixInColumn:column] selectedRow] inColumn:column];
}

- browser:sender predicateAtRow:(int)row inColumn:(int)column;
{
    if (!(column<0)) { /* if column is negativ there is nothing selected */
	id predicate = myFormList;
	int col;
	for (col=0; col<column; col++) {
	    predicate = [predicate getValueAt:[[sender matrixInColumn:col] selectedRow]];
	}

	return [predicate getValueAt:row];
    }
    return nil;
}

- (void)invalidate;
{
    [browser validateVisibleColumns];
}

/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    if (column)
	return [[self browser:sender selectedInColumn:column-1] count];
    else
	return [myFormList count];
}

//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    id image, predicate;
    id imageString = [[StringConverter alloc]init];
//    int	index=0, i;
    predicate = [self browser:sender predicateAtRow:row inColumn: column];
    if (predicate) {
      id theName;
	if ([predicate isKindOfClass:[SimpleForm class]]) {
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
	    [cell setLoaded:YES];
	    [cell setStringValue:[NSString jgStringWithCString:[predicate nameString]]];
	    [cell setLeaf:NO];
	}
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

    } else {
	if (!(row<0)) {
	    /* don't call for negative rows */
	    predicate = [self browser:sender selectedInColumn: column-1];
	    if (predicate) {
/*		if ([predicate isKindOf:[MusicalPredicate class]]) {
		    for (i=0; i<=row; index++)
			if ([predicate hasPredicateAt:index])
			    i++;
		    [cell setStringValue:[predicate stringValueAt:index-1]];
		} else
*/		    if ([predicate hasPredicateAt:row])
			[cell setStringValue:[NSString jgStringWithCString:[predicate stringValueAt:row]]];
		[cell setLoaded:YES];
		[cell setLeaf:YES];
	    }
	}
    }
    [imageString release];
}

//- (const char *)browser:sender titleOfColumn:(int)column;
- (BOOL)browser:sender selectCellWithString:(NSString *)title inColumn:(int)column;
{
    int row=-1;
    id	matrix = [sender matrixInColumn:column];

    if ([matrix getRow:&row column:&column ofCell:selectedCell]) {
        [matrix selectCellAtRow:row column:0];
	return YES;
    } else
	return NO;
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column;
{
/* browserIsValid doesn't work to simply invalidate columns, because
*  if a column is invalidated, its selection is cleared.
*  This results in erratic browser behaviour, if all the
*  columns are invalidated every time some predicate was changed.
*/
#if 0
    int selCol = [sender selectedColumn];
    if (column<selCol || browserIsValid)
	return YES;
    else {
	if (column>selCol) {
	    browserIsValid = YES;
	}
	return NO;
    }
#endif
//#error ViewConversion: '-focusView' in NSApplication has been replaced by '+focusView' in NSView
    return ([NSView focusView] == [sender matrixInColumn:column]);
}

//- browserWillScroll:sender;
//- browserDidScroll:sender;

@end


@implementation FormManager(WindowDelegate)
/* (WindowDelegate) methods */

- (BOOL)windowShouldClose:(id)sender;
{
#if 0
    if ([sender isDocumentEdited]) {
	const char *fname;
	int q;
	
	fname = filename ? filename : [[sender title] cString];
	if(rindex(fname, '/')) /* increment ptr to actual filename */
	    fname = rindex(fname, '/') +1;
	q = NSRunAlertPanel(@"Save", @"Save changes to %s", @"Save", @"Don't Save", @"Cancel", fname);
	if (q==1){ /* save */
	    if (![self save:nil]) {
		return nil; /* didn't save */
	    }
	}
	if (q==-1) { /* cancel */
	    return nil;
	}
    }
    [browserWindow saveFrameUsingName:[browserWindow title]];
    [inspector setSelected:nil];
    /* tell browser window we're gone */
    [sender setDelegate:nil];
    [inspector setManager:nil];
    [self release];
#endif
    return YES;
}

//#warning NotificationConversion: windowDidBecomeKey:(NSNotification *)notification is an NSWindow notification method (used to be a delegate method); delegates of NSWindow are automatically set to observe this notification; subclasses of NSWindow do not automatically receive this notification
- (void)windowDidBecomeKey:(NSNotification *)notification;
{
    [inspector setManager:self];
    [inspector setSelected:selected];
}

/*- windowDidMove:sender;
{
    [browserWindow saveFrameUsingName:[browserWindow title]];
    return self;
}
*/
@end



/* PredicateManager.m */

//#ifdef WITHMUSICKIT
//#import <MusicKit/MusicKit.h>
//#endif

#import <Rubato/RubatoController.h>
#import <Rubato/DistributorToolbar.h>

#import <Predicates/predikit.h>
//12.11.01 #import <Predicates/MKScoreReader.h>

#import <Predicates/JgPrediBase.h>
#import <JGFoundation/JGLogUnarchiver.h>

#import "PredicateManager.h"
#import "PredicateInspector.h"
#import "FormManager.h"

#import "PrediBaseDocument.h"

#import "JGPredicateConverter.h"
#import <FScript/FSPropertyList2Lisp.h>
#import <FScript/FSLisp2PropertyList.h>

#define FSLisp2PropertyList_Class NSClassFromString(@"FSLisp2PropertyList")
#define FSPropertyList2Lisp_Class NSClassFromString(@"FSPropertyList2Lisp")

#define numMaxVisibleColumns 10

#undef jgShowPredibase
#define jgShowPredibaseVal 0

@implementation PredicateManager

/* standard class methods to be overridden */
+ (void)initialize;
{
    [super initialize];
    if (self == [PredicateManager class]) {
	[PredicateManager setVersion:1];
    }
}


/* standard object methods to be overridden */

- (id)initWithWindowNibName:(NSString *)nibName;
{
  [super initWithWindowNibName:nibName];
  selectedCell = nil;
  selectedPredicate = nil;
  rootPredicate=nil;
  browserIsValid = NO;
  return self;
}  

- (void)dealloc {
    /* class-specific initialization goes here */
  [rootPredicate release];
    [super dealloc];
}


/*
- (void)updateTitle;
{
  NSString *title= [self windowTitleForDocumentDisplayName:[[self document] displayName]];
  [[self browserWindow] setTitle:title];  // self window exists at least partially not yet
}
*/


- (id/* <Distributor> */)distributor;
{
  return [[self document] distributor];
}

- (id)browser;
{
  return browser;
}
- (id)browserWindow;
{
  return [self window];
}


/* access methods to instance variables */
- (void)setBrowserIsValid:(BOOL)v;
{
  browserIsValid=v;
}

- (void)setRootPredicate:(GenericPredicate *)pred;
{
  [pred retain];
  [rootPredicate release];
  rootPredicate=pred;
  [browser reloadColumn:0];
}

// jg? obsolete?
/*
- formList;
{
  return [[self document] formList];
}
*/

- rootPredicate;
{
  return rootPredicate;
}
- predicateList;
{
  return rootPredicate;
}

/*
- rubetteList;
{
  return [[self document] rubetteList];
}

- weightList;
{
  return [[self document] weightList];
}
*/

/* copy & paste methods */
// see FormManager.m
- copyToPasteboard:pboard;
{
    NSData *dataBuffer;
    NSArray *typeList = [NSArray arrayWithObjects:[NSString jgStringWithCString:PredFileType],NSStringPboardType,nil];
  
    [pboard declareTypes:typeList owner:self];
    
    dataBuffer= [NSArchiver archivedDataWithRootObject:selectedPredicate];
    [pboard setData:dataBuffer forType:[NSString jgStringWithCString:PredFileType]];	

    
    return self;
}

- (void)copy:(id)sender;
{
    if (selectedPredicate) {
	[self copyToPasteboard:[NSPasteboard generalPasteboard]];
    } else
	NSBeep();
}

// for StringConverter-Representation
- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type;
{
// perhaps we should use XML here for String type.
    if ([type isEqualToString:NSStringPboardType]) {
	NSString *firstType;
//	const char *data;
	NSData *dataBuffer;
//	int length, maxlen;
	id predicate;
    
// first the binary representation (produced by self) is got
	firstType = [sender availableTypeFromArray:[NSArray arrayWithObject:[NSString jgStringWithCString:PredFileType]]];
	if (firstType) {
            dataBuffer = [sender dataForType:firstType];
	    if (dataBuffer) {
		predicate = [JGLogUnarchiver unarchiveObjectWithData:dataBuffer];
		if (predicate) {
// then it is written as ASCII.
                  static int kindOfString=1;
                  NSString *str=nil;
                  if (kindOfString==0) {
                    NSMutableString *mutableString = [NSMutableString new];
                    [predicate appendToMathString:mutableString andTabs:0];
                    str=mutableString;
                  } else if (kindOfString==1) {
                    id plist=[JGPredicateConverter listForPredicate:predicate useNames:YES];
                    if (plist){
                      str=[FSPropertyList2Lisp_Class macroStringForArrays:plist];
                    }
                  }
                  if (str) 
                    [sender setString:str forType:NSStringPboardType];
                  else
                    NSBeep();
		}
	    }
	}
    }
}

// sometimes works not as intendet. See removePredicate comments
- (void)cut:(id)sender;
{
    if (selectedPredicate) {
	[self copyToPasteboard:[NSPasteboard generalPasteboard]];
	[self removePredicate:selectedPredicate];
    } else
	NSBeep();
}
// paste should instead of add use insert!
- (void)paste:(id)sender;
{
// new, see FormManager.m
  id pboard, predicate=nil;
  NSData *dataBuffer;
  NSString *firstType;
  id predType=[NSString stringWithCString:PredFileType];
  
  pboard = [NSPasteboard generalPasteboard];
  firstType = [pboard availableTypeFromArray:[NSArray arrayWithObjects:predType,NSStringPboardType,nil]];
  if ([firstType isEqualToString:predType]) {
    if (dataBuffer = [pboard dataForType:firstType]) {
      predicate = [JGLogUnarchiver unarchiveObjectWithData:dataBuffer];
    }
  } else if ([firstType isEqualToString:NSStringPboardType]) {
    NSString *str=[pboard stringForType:firstType];
    if (str) {
      id plist=[FSLisp2PropertyList_Class plistForCyclicLispString:str];
      if (plist) {
        predicate=[JGPredicateConverter predicateForList:plist];
      }
    }
  }
  if (predicate)
    [[self document] addPredicate:predicate];
  else
    NSBeep();
}


- (id)parentOfPredicate:aPredicate;
{
  int row, col;
  id parent;
  [self row:&row andColumn:&col ofPredicate:aPredicate];
  parent = [self selectedInColumn:col-1];
  return parent;
}

- (id)siblingOfPredicate:aPredicate withOffset:(int)offset;
{
  int index;
  id parent=[self parentOfPredicate:aPredicate];
  if (parent) {
      index = [parent indexOfValue:aPredicate];
      return [parent getValueAt:index+offset];
  } else
      return nil;
}

- before: aPredicate;
/*" returns the sibling of aPredicate that occurs before aPredicate "*/
{
  return [self siblingOfPredicate:aPredicate withOffset:-1];
}

- after: aPredicate;
  /*" returns the sibling of aPredicate that occurs after aPredicate "*/
{
  return [self siblingOfPredicate:aPredicate withOffset:-1];
}

//jg: this does not work correctly for predicates that are shared in different branches of the browser!
//    [self row:&row andColumn:&col ofPredicate:aPredicate];
//    returns one branch, not necessarily the correct one.
- removePredicate: aPredicate;
/*" removes aPredicate from father "*/
{
    int row, col;
    id parent = nil;
    id removed = nil;
    id newSelected = nil;
    [self row:&row andColumn:&col ofPredicate:aPredicate];  
    if (col>0)
	parent = [self selectedInColumn:col-1];
    else if(col==0)
	parent = [self rootPredicate];
    if (parent) {
        int cnt;
	removed=[parent removeValue:aPredicate];
	[[self document] updateChangeCount:NSChangeDone];
        cnt=[parent count];
//	newSelected = newSelected ? newSelected : parent; // removed with if statement 28.3.2002
        if (cnt>0)
            if (cnt>row)
              newSelected = [parent getValueAt:row];
            else
              newSelected = [parent getValueAt:cnt-1];
        else 
   	  newSelected = parent;
	[[self browser] displayColumn:col];
//	[self selectPredicate:newSelected];
        [self setSelectedPredicateAndNotify:newSelected];
    }
    return removed;
}

// this is not checked, because it is not used besides deletePredicateAt:
- removePredicateAt:(unsigned int)index;
 /*" removes sibling of selected with index index "*/
{
    id parent= [self parentOfPredicate:selectedPredicate];
    id removed = nil;
    if (parent) {
	removed = [parent getValueAt:index];
	removed = [parent removeValue:removed];
	[[self document] updateChangeCount:NSChangeDone];
	[self selectPredicate:parent];
    }
    return removed;
}

- deletePredicate: aPredicate;
{
    [self removePredicate:aPredicate];// release];
    return self;
}

// this is not checked, because it is not used
- deletePredicateAt:(unsigned int)index;
{
    [self removePredicateAt:index]; // release];
    return self;
}

/* form list management */
/*
- addPredicateForm:aForm;
{
    if ([aForm isKindOfClass:[GenericForm class]]) { // not nil & really form 
	[[self formList] setValue:aForm];
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
    if (aForm) { // not nil & really form 
	[self addPredicateForm:aForm];
	[[self document] updateChangeCount:NSChangeDone];
    } else
	NSBeep();
    return self;
}
*/

/* browser management */
- (void)row:(int *)aRow andColumn:(int *)aCol ofPredicate:(id)aPredicate;
{/* This method tries to find the coordinates of aPredicate in the
  * predicate tree. If aPredicate is not in this tree, no
  * further searching is done.
  */
    
    int row=-1, column=-1;
    id rowPred, predicate = [self rootPredicate];
    
    for (column=-1; [predicate hasPredicate:aPredicate] && (predicate!=aPredicate); column++) {
	for (row=0; row<[predicate count]; row++) {
	    rowPred = [predicate getValueAt:row];
	    if (rowPred==aPredicate || [rowPred hasPredicate:aPredicate]) {
		predicate = rowPred;
		break;
	    }
	}
    };
    column = predicate==[self rootPredicate] ? -1 : column;
    
    if (column>-1) {	    
	column = row==NSNotFound ? -1 : column;
	row = row==NSNotFound ? -1 : row;
    }
    *aRow = row;
    *aCol = column;
}

// not really checked. Where is it used? In PredicateInspector (removed from removePredicate: 28.03.2002)
- (void)selectPredicate: aPredicate;
/*" this will find aPredicate in Browser and select it "*/
{
    id obj;
    int oldRow=-1, oldCol=-1, newRow = -1, newCol = -1;
    
    if (aPredicate) {/* only try to get row and col if not nil*/
	[self row:&newRow andColumn:&newCol ofPredicate:aPredicate];
    }
    if (selectedPredicate) {/* only try to get row and col if not nil*/
	[self row:&oldRow andColumn:&oldCol ofPredicate:selectedPredicate];
    }

  if ([obj=[self selectedInColumn:oldCol-1] hasPredicate:selectedPredicate]&&[obj hasPredicate:aPredicate]) {
	[[[self browser] matrixInColumn:newCol] selectCellAtRow:newRow column:0];
	[[[self browser] matrixInColumn:newCol] sendAction];
    }
    else if (newRow>-1 && newCol>-1) {
	int row, col, cols, *rowList = NULL;
	id colMatrix, rowPred, predicate = [self rootPredicate];
	
	/* get the row for every column, i.e. path to aPredicate */
	for (cols=0; [predicate hasPredicate:aPredicate]  && (predicate!=aPredicate); cols++) {
	    rowList = realloc(rowList, cols+1*sizeof(int));
	    rowList[cols] = -1;
	    for (row=0; row<[predicate count]; row++) {
		rowPred = [predicate getValueAt:row];
		if (rowPred==aPredicate || [rowPred hasPredicate:aPredicate]) {
		    predicate = rowPred;
		    rowList[cols] = row;
		    break;
		}
	    }
	};
	
	//[browser loadColumnZero];
	
	for (col=0; col<cols; col++) {
	    colMatrix = [[self browser] matrixInColumn:col];
	    if ([colMatrix selectedRow]!=rowList[col]) {
		[colMatrix selectCellAtRow:rowList[col] column:0];
		[colMatrix sendAction];
	    }
	}
    } else
	[[self browser] loadColumnZero];
    
    [self setNewSelectedCell:[[[self browser] matrixInColumn:newCol] selectedCell]];

    browserIsValid = browserIsValid && (newCol<=oldCol);
    [self setSelectedPredicateAndNotify:((newRow>-1) ? aPredicate : nil)];
}

- (void)setSelectedFrom:sender;
{
    int oldRow, oldCol, newCol = [sender selectedColumn];
     
    [self row:&oldRow andColumn:&oldCol ofPredicate:selectedPredicate];
    [self setSelectedPredicate:[self browser:sender selectedInColumn:[sender selectedColumn]]];
    [self setNewSelectedCell:[sender selectedCell]];
    browserIsValid = browserIsValid && (newCol<=oldCol);
//    if ([inspector manager]=self)
    [[self document] setSelected:selectedPredicate];
    [[[self distributor] globalInspector] setSelected: selectedPredicate];
}

- (void)setSelectedPredicate:(id)newPredicate;
{
  [newPredicate retain];
  [selectedPredicate release];
  selectedPredicate=newPredicate;
}

- (void)setSelectedPredicateAndNotify:(id)newPredicate;
{
    [self setSelectedPredicate:newPredicate];
    [self invalidate];
    [[self document] setSelected:selectedPredicate];
    [[[self distributor] globalInspector] setSelected:selectedPredicate];
}

- selectedPredicate;
{
    return selectedPredicate;
}
- selected;
{
  return selectedPredicate;
}

- (void)setNewSelectedCell:(id)newCell;
{
    [newCell retain];
    [selectedCell release];
    selectedCell=newCell;
}
- (void)setSelectedCell:sender;
{
    [self setNewSelectedCell:[sender selectedCell]];
}
- selectedCell;
{
    return selectedCell;
}


- (id)selectedInColumn:(int)column;
{
    int col;
    id predicate;
    
    if ((column<0)) { // if column is negativ there is nothing selected
      return nil;
    } else {
      predicate=[self rootPredicate];
      for (col=0; col<=column; col++) {
	predicate = [predicate getValueAt:[[[self browser] matrixInColumn:col] selectedRow]];
      }
     return predicate;
   }    
}
 
 - browser:sender selectedInColumn:(int)column;
{
    return [self browser:sender predicateAtRow:[[sender matrixInColumn:column] selectedRow] inColumn:column];
}


- browser:sender predicateAtRow:(int)row inColumn:(int)column;
{
    if (column<0) { /* if column is negativ there is nothing selected */
      return nil;
    } else {
      id predicate;
      predicate= [[sender selectedCellInColumn:column] representedObject];
      return predicate;
/*
      predicate = [self rootPredicate];
 	for (col=0+jgShowPredibaseVal; col<column; col++) {
	    selRow = [[sender matrixInColumn:col] selectedRow];
	    for (i=0; i<=selRow && [predicate hasPredicateAt:i]; i++);
	    predicate = [predicate getValueAt:i-1];
	}

	for (i=0; i<=row && [predicate hasPredicateAt:i]; i++);
	return [predicate getValueAt:i-1];
 */
    }
}

- (void)invalidate;
{
    [[self browser] validateVisibleColumns];
}

/* (BrowserDelegate) methods */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    if (jgShowPredibaseVal && (column==0)) {
      return 3;
    } else {
      if (column)
	return [[self browser:sender selectedInColumn:column-1] count];
      else
	return [[self rootPredicate] count]; // old code
    }
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
  GenericPredicate *predicate;
  CompoundPredicate *father;
  NSString *role;
  NSString *str;
  if (column==0)
    father=[self rootPredicate];
  else
    father=[[sender selectedCellInColumn:column-1] representedObject];
  role=[[father form] roleAtIndex:row];
  predicate=[father getValueAt:row];
  [cell setRepresentedObject:predicate];
  
  if ([predicate isKindOfClass:[SimplePredicate class]]) {
      str=[NSString stringWithFormat:@"%@:%@: %@",role,[predicate name],[predicate stringValue]];
      [cell setLoaded:YES];
      [cell setStringValue:str];
      [cell setLeaf:YES];
  } else {
    NSString *imageName;
    NSString *theName;
    NSImage *image;
      str=[NSString stringWithFormat:@"%@:%@",    role,[predicate name]];
      [cell setLoaded:YES];
      [cell setStringValue:str];
      [cell setLeaf:NO];
      imageName=[NSString jgStringWithCString:[predicate typeString]];
      theName=[[NSBundle bundleForClass:[self class]] pathForImageResource:imageName];
      image = [[NSImage alloc]initByReferencingFile:theName];
      if (image) {
          [cell setImage:image];
          [image release];
      }
      theName=[[NSBundle bundleForClass:[self class]] pathForImageResource:[imageName stringByAppendingString:@"H"]];
      image = [[NSImage alloc]initByReferencingFile:theName];
      if (image) {
          [cell setAlternateImage:image];
          [image release];
      }
  }
}


//- (int)browser:sender fillMatrix:matrix inColumn:(int)column;
/*
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    GenericPredicate *predicate;
    NSString *str;
    NSString *role;
    id image, imageString = [[StringConverter alloc]init];
    int	index=0, i;
    predicate = [self browser:sender predicateAtRow:row inColumn: column];
    if (predicate) {
        if (column>0) {
          int fatherCol=column-1;
          int fatherRow=[[sender matrixInColumn:fatherCol] selectedRow];
          CompoundPredicate *father=[self browser:sender predicateAtRow:fatherRow inColumn:fatherCol];
          role=[[father form] roleAtIndex:row];
        } else
          role=[CompoundForm roleWithoutFather];

	if ([predicate isKindOfClass:[SimplePredicate class]]) {
            str=[NSString stringWithFormat:@"%@:%@:%@: %@",role,[predicate name],[[predicate form] name], [predicate stringValue]];
	    [cell setLoaded:YES];
	    [cell setStringValue:str];
	    [cell setLeaf:YES];
	} else {
          id theName;
            str=[NSString stringWithFormat:@"%@:%@:%@",    role,[predicate name],[[predicate form] name] ];
            [cell setLoaded:YES];
            [cell setStringValue:str];
	    [cell setLeaf:NO];
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
    } else { // jg?: is this case possible?
	if (!(row<0)) {
	    // don't call for negative rows 
	    predicate = [self browser:sender selectedInColumn: column-1];
	    if (predicate) {
		for (i=0, index=0; i<=row; index++)
		    if ([predicate hasPredicateAt:index])
			i++;
		[cell setStringValue:[[predicate cellAtIndex:index-1] stringValue]];
		[cell setLoaded:YES];
		[cell setLeaf:YES];
	    }
	}
    }
    [imageString release];
}
*/

//- (const char *)browser:sender titleOfColumn:(int)column;
- (BOOL)browser:sender selectCellWithString:(NSString *)title inColumn:(int)column;
{
    int row=-1;
    id	matrix = [sender matrixInColumn:column];

    /*predicate = [self selectedInColumn:column];
    if (predicate) {
	if (column>0)
	    row = [[self selectedInColumn:column-1] indexOfValue:predicate];
	else
	    row = [[self rootPredicate] indexOfValue:predicate];
    }
    */

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
    int selCol = [sender selectedColumn];
//#error ViewConversion: '-focusView' in NSApplication has been replaced by '+focusView' in NSView
// jg??: problem: changing s.th. in path to selected does not result in redisplaying.
// but also s.o.
    if (([NSView focusView] == [sender matrixInColumn:column]) || column<selCol || browserIsValid)
	return YES; 
    else {
	if (column>selCol) {
	    browserIsValid = YES;
	}
	return NO;
    }
}

//- browserWillScroll:sender;
//- browserDidScroll:sender;
- (void)addSubDocumentsBrowser:(id)sender;
{
  [[self document] addSubDocumentsBrowser];
}

- (void)addPredicateBrowser:(id)sender;
{
  [[self document] addPredicateBrowser:sender];
}
- (void)addRubetteBrowser:(id)sender;
{
  [[self document] addRubetteBrowser:sender];
}

@end


@implementation PredicateManager(WindowDelegate)
/* (WindowDelegate) methods */

// jg changed 21.03.2002
#ifdef DEPRECATED_CLOSING
- (BOOL)windowShouldClose:(id)sender;
{
  BOOL ret=[[self document] shouldCloseWindowController:self];
  if (!ret) return NO;
#else
  - (void)windowWillClose:(NSNotification *)notification;
{
    id sender=[notification object];
    if (![sender isKindOfClass:[NSWindow class]])
        NSLog(@"PredicateManager warning: not a window");
#endif
  [[self document] setSelected:nil]; // is this desired?
  [[[self distributor] globalInspector] setSelected:nil];
    /* tell browser window we're gone */
//    [sender setDelegate:nil]; // not necessary in NSWindowController? Even inhibits [document close] !
    [[[self distributor] globalInspector] setManager:nil];
    [[[self distributor] predicateFinder] setManager:nil];
//    [[[self distributor] globalFormManager] signOutManager:self];
//    [[[self distributor] globalFormManager] setManager:nil];
//    [[self distributor] setPrediBase:nil];
//    [self release];  // ???

#ifdef DEPRECATED_CLOSING
    return YES;
#endif
}

- (void)predicateManagerDidBecomeActive;
{
/*
  int wheel=1;
  id ctrl=[NSDocumentController sharedDocumentController];
  id currentDoc=[ctrl currentDocument];
  if (wheel==0) [[self document] windowDidBecomeMain:notification];
  if (wheel==1) [[NSDocumentController sharedDocumentController] windowDidBecomeMain:notification];
*/
  [[self distributor] setActiveRubette:nil]; 
  [[self distributor] setPrediBase:[self document]]; 
  [[[self distributor] globalInspector] setManager:[self document]];
    [[self document] setSelected:selectedPredicate];
    [[[self distributor] globalInspector] setSelected:selectedPredicate];
//    [[[self distributor] globalFormManager] setManager:[self document]];
    [[[self distributor] predicateFinder] setManager:[self document]];
}

- (void)windowDidBecomeMain:(NSNotification *)notification;
{
  [self predicateManagerDidBecomeActive];
}
- (void)windowDidBecomeKey:(NSNotification *)notification;
{
  [self predicateManagerDidBecomeActive];
}
- (void)windowDidLoad; // jg 14.6.
{
  [super windowDidLoad];
  [self setBrowserIsValid:NO];
  [[self document] setSelected:nil];
  [self setSelectedPredicate:nil];
//  [[[self distributor] globalFormManager] signInManager:self];
  [self updateTitle];
  [(Distributor *)[self distributor] setupToolbarWithWindow:[self window]];
  [self invalidate]; 
}
- (void)windowWillLoad; // jg 14.6.
{
  [super windowWillLoad];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName;
{
//  NSString *str=(rootPredicate ? [rootPredicate name] : nil);
//  if (str)
//    return [NSString stringWithFormat:@"PM:%@ %@",str,displayName];
//  return [NSString stringWithFormat:@"PM: %@",displayName];
  return [NSString stringWithFormat:@"%@",displayName];
}

@end



//
//  JGTableDataViewController.m
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Wed Jun 19 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "JGTableViewTextController.h"
#import "JGTableDataViewController.h"

@implementation JGTableDataViewController
+ (NSArray *)selectedColumnNamesForTableView:(NSTableView *)tv allIfEmpty:(BOOL)allIfEmpty;
{
  NSArray *tableColumns=[tv tableColumns];
  NSMutableArray *selectedColumnNames=[NSMutableArray array];
  NSTableColumn *tc;
  NSEnumerator *e;
  NSString *s;
  id item;
  int idx;

  if ([tv numberOfSelectedColumns]) {
    e=[tv selectedColumnEnumerator];
    while (item=[e nextObject]) {
      idx=[item intValue];
      tc=[tableColumns objectAtIndex:idx];
      s=[tc identifier];
      NSParameterAssert(s!=nil);
      [selectedColumnNames addObject:s];
    }
  } else if (allIfEmpty) { // if there is no selection, use all
    e=[tableColumns objectEnumerator];
    while (item=[e nextObject]) {
      s=[item identifier];
      NSParameterAssert(s!=nil);
      [selectedColumnNames addObject:s];
    }
  }
  return selectedColumnNames;
}

+ (NSArray *)selectedRowNumbersForTableView:(NSTableView *)tv allIfEmpty:(BOOL)allIfEmpty;
{
  NSMutableArray *selectedRowNumbers=[NSMutableArray array];
  NSEnumerator *e;
  NSNumber *item;
  int i;

  if ([tv numberOfSelectedRows]) {
    e=[tv selectedRowEnumerator];
    while (item=[e nextObject]) {
      [selectedRowNumbers addObject:item];
    }
  } else if (allIfEmpty) {  // if there is no selection, use all
    for (i=0;i<[tv numberOfRows];i++)
      [selectedRowNumbers addObject:[NSNumber numberWithInt:i]];
  }
  return selectedRowNumbers;
}

+ (void)tableView:(NSTableView *)tv setHeadersWithTableData:(JGTableData *)td;
{
  int i,c;
  NSArray *titles=[td titles];
  while([[tv tableColumns] count] > 0)
    [tv removeTableColumn:[[tv tableColumns] objectAtIndex:0]];

  for (i = 0, c = [titles count]; i < c; i++)
  {
    NSString *title=[titles objectAtIndex:i];
    NSTableColumn *column = [[[NSTableColumn alloc] initWithIdentifier:title] autorelease];
    [[column headerCell] setStringValue:title];
    [column setEditable:YES];
    [tv addTableColumn:column];
  }
}

+ (id)controllerWithTableView:(NSTableView *)tv tableData:(JGTableData *)td setHeaders:(BOOL)setHeaders newTableData:(BOOL)newTableData setDataSource:(BOOL)setDataSource;
{
  return [[[self alloc] initWithTableView:tv tableData:td setHeaders:setHeaders newTableData:newTableData setDataSource:setDataSource] autorelease];
}
+ (id)controllerWithTableView:(NSTableView *)tv;
{
  id result=[self controllerWithTableView:tv tableData:nil setHeaders:NO newTableData:YES setDataSource:YES];
  return result;
}
+ (id)controllerWithTableData:(JGTableData *)td;
{
  id result=[self controllerWithTableView:nil tableData:td setHeaders:YES newTableData:NO setDataSource:YES];
  return result;
}


// designated Initializer
- (id)init;
{
  [super init];
  tableView=nil;
  tableData=nil;
  tableViewTextController=nil;
  return self;
}
- (id)initWithTableView:(NSTableView *)tv tableData:(JGTableData *)td setHeaders:(BOOL)setHeaders
           newTableData:(BOOL)newTableData setDataSource:(BOOL)setDataSource;
{
  static BOOL doSetSelfDelegate=YES;
  self=[self init];
  tableView=[tv retain];
  tableData=[td retain];
  if (!tableView) {
    NSWindow *w;
    [NSBundle loadNibNamed:@"JGTableDataView.nib" owner:self];
    w=[tableView window];
    if (doSetSelfDelegate && ![w delegate])
      [w setDelegate:self]; // this allows us to use copy: from the menu!
  }
  if (setHeaders)
    [[self class] tableView:tableView setHeadersWithTableData:tableData];
  if (newTableData) {
    [tableData release];
    tableData=[[JGTableData newWithTitlesFromHeadersOfTableView:tableView] retain];
  }
  if (setDataSource)
    [tableView setDataSource:tableData];
  return self;
}

- (void)dealloc;
{
  [tableView release];
  [tableData release];
  [super dealloc];
}

- (void)awakeFromNib;
{ /*" if tableData==nil, creates a JGTableData dataSource instance with titles from tableView identifiers and sets it as the tableView dataSource "*/
  if (!tableData) {
    tableData=[[JGTableData newWithTitlesFromHeadersOfTableView:tableView] retain];
    [tableView setDataSource:tableData];
  }
}

- (IBAction)showTableViewTextController:(id)sender;
{
  id window;
  if (!tableViewTextController) {
    tableViewTextController=[[JGTableViewTextController alloc] init];
    [tableViewTextController setTableDataViewController:self];
    [NSBundle loadNibNamed:@"JGTableViewTextController.nib" owner:tableViewTextController];
    [tableViewTextController setFieldsFromTableData:tableData];
  }
  [tableViewTextController testPressed:nil];
  window=[tableViewTextController window];
  [window makeKeyAndOrderFront:sender];
}

- (NSTableView *)tableView;
{
  return tableView;
}
- (JGTableData *)tableData;
{
  return tableData;
}

- (void)removeColumnsWithTitles:(NSArray *)titles;
{
  NSEnumerator *e=[titles objectEnumerator];
  NSString *title;
  while (title=[e nextObject]) {
    NSTableColumn *tc=[tableView tableColumnWithIdentifier:title];
    [tableView removeTableColumn:tc];
  }
  [tableData removeColumnsWithTitles:titles];
}

- (void)removeSelectedColumnsAndRows;
{
  NSArray *cols,*rows;
  cols=[JGTableDataViewController selectedColumnNamesForTableView:tableView allIfEmpty:NO];
  rows=[JGTableDataViewController selectedRowNumbersForTableView:tableView allIfEmpty:NO]; // are sorted?

  if ([cols count]) {
    [self removeColumnsWithTitles:cols];
  }
  if ([rows count]) {
    [tableData removeRows:(NSArray *)rows sortedAscending:NO];
  }  
}


//////////////////////////
// NSPasteboard support
//////////////////////////

- (void)pasteboard:(NSPasteboard *)pboard copyWithTitles:(BOOL)withTitles underline:(NSString *)underline;
{
  JGTableData *table=[tableData subTableWithSelectionFromTableView:tableView];
  NSString *s=[table tableTextWithTitles:withTitles underline:underline];
  [pboard declareTypes:[NSArray arrayWithObjects:NSTabularTextPboardType,NSStringPboardType,nil] owner:nil];
  [pboard setString:s forType:NSTabularTextPboardType];
  [pboard setString:s forType:NSStringPboardType];
}

- (void)pasteboard:(NSPasteboard *)pboard copyWithNames:(id)sender;
{
  [self pasteboard:pboard copyWithTitles:YES underline:@"-----"];
}

- (void)copy:(id)sender;
{
  [self pasteboard:[NSPasteboard generalPasteboard] copyWithTitles:[tableData textWithTitles] underline:[tableData  textWithUnderline]];
}

- (void)cut:(id)sender; 
{
  [self copy:sender];
  [self removeSelectedColumnsAndRows];
  [tableView reloadData];
}
- (void)paste:(id)sender;
{
  NSPasteboard *pboard=[NSPasteboard generalPasteboard];
  int selectedRow=[tableView selectedRow];
  if (selectedRow==-1) // no row selected
    [tableData pasteRowsFromPasteboard:pboard];
  else
    [tableData pasteboard:pboard pasteToRow:selectedRow];
  [tableView reloadData];
}
@end


/*
@implementation JGTableData(NSTableViewDelegate)

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView;
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row;
- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(NSTableColumn *)tableColumn;

- (void) tableView:(NSTableView*)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn;
- (void) tableView:(NSTableView*)tableView didClickTableColumn:(NSTableColumn *)tableColumn;
- (void) tableView:(NSTableView*)tableView didDragTableColumn:(NSTableColumn *)tableColumn;
@end

@implementation JGTableData(NSTableViewNotifications)
/*
 - (void)tableViewSelectionDidChange:(NSNotification *)notification;
 - (void)tableViewColumnDidMove:(NSNotification *)notification;
 - (void)tableViewColumnDidResize:(NSNotification *)notification;
 - (void)tableViewSelectionIsChanging:(NSNotification *)notification;
@end
*/

// jg: see SDTableview for more elaborate delegate.
@implementation JGDraggableTableView
- (id)initWithFrame:(NSRect)frameRect;
{
  self=[super initWithFrame:frameRect];
  [self registerForDraggedTypes:[NSArray arrayWithObjects:NSTabularTextPboardType,NSStringPboardType,nil]];
  return self;
}
// Standard for TableView is NSDragOperationNone for isLocal= NO, NSDragOperationAll_Obsolete for isLocal=YES
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal;
{
  if ([draggableDelegate respondsToSelector:@selector(draggingSourceOperationMaskForLocal:)])
    return [draggableDelegate draggingSourceOperationMaskForLocal:isLocal];
  if (isLocal) return NSDragOperationEvery;
  else return NSDragOperationCopy;
}

@end

@implementation JGTableDataViewController (SDTableViewDelegate)
- (unsigned int)dragReorderingMask:(int)forColumn;
{
  return NSShiftKeyMask;
}
// Delegate called after the reordering of cells, you must reorder your data.
// Returning YES will cause the table to be reloaded.
- (BOOL)tableView:(NSTableView *)tv didDepositRow:(int)rowToMove at:(int)newPosition;
{
  return YES;
}
// This gives you a chance to decline to drop particular rows on other particular
// row. Return YES if you don't care
- (BOOL) tableView:(/*SDTableView */NSTableView *)tableView draggingRow:(int)draggedRow overRow:(int) targetRow;
{
  return YES;
}
@end


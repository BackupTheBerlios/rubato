//
//  JGTableDataViewController.h
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Wed Jun 19 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "JGTableData.h"

@interface JGTableDataViewController : NSObject
{
  IBOutlet NSTableView *tableView;
  JGTableData *tableData; // set up in awakeFromNib
  id tableViewTextController;
}
//// NSTableView utilities
// helpers: produce indices, that can be used with - (JGTableData *)subTableWithColumns:(NSArray *)cols rows:(NSArray *)rows;
+ (NSArray *)selectedColumnNamesForTableView:(NSTableView *)tv allIfEmpty:(BOOL)allIfEmpty;
+ (NSArray *)selectedRowNumbersForTableView:(NSTableView *)tv allIfEmpty:(BOOL)allIfEmpty;

+ (void)tableView:(NSTableView *)tableView setHeadersWithTableData:(JGTableData *)tableData;


+ (id)controllerWithTableView:(NSTableView *)tv tableData:(JGTableData *)td setHeaders:(BOOL)setHeaders newTableData:(BOOL)newTableData setDataSource:(BOOL)setDataSource;
+ (id)controllerWithTableView:(NSTableView *)tv;
+ (id)controllerWithTableData:(JGTableData *)td;

- (id)init; // designated initializer
- (id)initWithTableView:(NSTableView *)tv tableData:(JGTableData *)td setHeaders:(BOOL)setHeaders
           newTableData:(BOOL)newTableData setDataSource:(BOOL)setDataSource;

- (void)awakeFromNib;
- (IBAction)showTableViewTextController:(id)sender;

- (NSTableView *)tableView;
- (JGTableData *)tableData;

- (void)removeColumnsWithTitles:(NSArray *)titles;
- (void)removeSelectedColumnsAndRows;

  //// NSPasteboard/Drag and Drop  interfaces
- (void)copy:(id)sender;
- (void)pasteboard:(NSPasteboard *)pboard copyWithTitles:(BOOL)withTitles underline:(NSString *)underline;
- (void)pasteboard:(NSPasteboard *)pboard copyWithNames:(id)sender;
@end

// uses single move and copy/cut/paste
@interface JGDraggableTableView : SDTableView
{
  id draggableDelegate;
}
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal;
@end

// This is only good for dragging single rows in the same Table.
@interface JGTableDataViewController (SDTableViewDelegate) <SDMovingRowsProtocol>
- (unsigned int)dragReorderingMask:(int)forColumn;
- (BOOL)tableView:(NSTableView *)tv didDepositRow:(int)rowToMove at:(int)newPosition;
- (BOOL) tableView:(/*SDTableView */NSTableView *)tableView draggingRow:(int)draggedRow overRow:(int) targetRow;
@end

/*
 - (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
 - (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(int)row;
 - (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView;
 - (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row;
 - (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(NSTableColumn *)tableColumn;
 - (void) tableView:(NSTableView*)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn;
 - (void) tableView:(NSTableView*)tableView didClickTableColumn:(NSTableColumn *)tableColumn;
 - (void) tableView:(NSTableView*)tableView didDragTableColumn:(NSTableColumn *)tableColumn;
 - (void)tableViewSelectionDidChange:(NSNotification *)notification;
 - (void)tableViewColumnDidMove:(NSNotification *)notification;
 - (void)tableViewColumnDidResize:(NSNotification *)notification;
 - (void)tableViewSelectionIsChanging:(NSNotification *)notification;
 */


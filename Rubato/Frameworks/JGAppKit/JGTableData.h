//
//  JGTableData.h
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Mon May 06 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

// grep "^[+-]" JGTableData.m

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SDTableView.h"
#import "JGAccessorMacros.h"

//  Entwickle Rubette, die die Predicate-Selection nach gegebenen Parametern durchsucht und darauf aufbauend eine Tabelle mit den Parametern/Werten erstellt.

@interface JGTableData : NSObject
{
  NSArray *titles; // of Strings
  NSMutableArray *fields; // of Strings
  // the following ivars are used when printing or scanning Text
  NSString *recordSeparator,*fieldSeparator; 
  BOOL textWithTitles;
  NSString *textWithUnderline;
}

+ (JGTableData *)newWithTitlesFromHeadersOfTableView:(NSTableView *)tableView;

- (id)initWithTitles:(NSArray *)tableTitles;
- (void)dealloc;

// access to instances:
- (NSArray *)titles;

accessor_h(NSMutableArray *,fields,setFields);
accessor_h(NSString *,recordSeparator,setRecordSeparator);
accessor_h(NSString *,fieldSeparator,setFieldSeparator);
accessor_h(NSString *,textWithUnderline,setTextWithUnderline);
scalarAccessor_h(BOOL,textWithTitles,setTextWithTitles);

//- (NSMutableArray *)fields;
//- (void)setRecordSeparator:(NSString *)newRS;
//- (void)setFieldSeparator:(NSString *)newFS;

- (id)copyWithoutFields;

// access to fields
- (void)addFields:(NSArray *)f; // Array of an number of Values (use at own risk)
- (void)addRecordsFields:(NSArray *)f; // Array of n*<number of columns> Values
- (void)addRecordFields:(NSArray *)f; // Array of <number of colums> Values
- (int)fieldsIndexForColumnIdentifier:(NSString *)col row:(int)row;

- (void)removeColumnsWithTitles:(NSArray *)titles;
- (void)removeRowsInRange:(NSRange)range;
- (void)removeRows:(NSArray *)rows sortedAscending:(BOOL)sorted;

// derived values
- (int)colCount;
- (int)rowCount;

// convenience methods to add/get values in different order
- (NSArray *)getRow:(int)row; // Array of Values
- (NSDictionary *)getRecord:(int)row; // mixed with titles
- (NSArray *)getAllRecords;
- (NSArray *)getColumn:(int)col; // Array of Values
- (NSDictionary *)getColumnsDictionary; // Dictionary of Array of Values
// for the following two methods the added columns must fit exactly the table columns.
- (void)addColumns:(NSArray *)cols; // Array of Array of Values
- (void)addDictionaryOfColumns:(NSDictionary *)dict; // Dictionary of Array of Values (matches getColumnsDictionary)
// for the following two methods, dictionaries can be under- and overspecified (filtered to columns)
- (void)addRecord:(NSDictionary *)record; // Dictionary of Values
- (void)addRecords:(NSArray *)records; // Array of Dictionary of Values
- (void)addRecordsFromTableData:(JGTableData *)otherTableData;
- (void)insertRecords:(NSArray *)records atRow:(int)row;
- (void)insertRecordsFromTableData:(JGTableData *)otherTableData  atRow:(int)row;

- (NSDictionary *)dictionaryWithTitlesAndFields; // {"titles":array; "fields":fields}
- (NSArray *)arrayWithDictionaries; // Array of Dictionaries of title/Value pairs

//// Converting to and from text
// producing a text version
- (void)string:(NSMutableString *)str appendFields:(id)f start:(int)start end:(int)end useRS:(BOOL)useRS;
- (NSString *)tableTextWithTitles:(BOOL)printTitle underline:(NSString *)underline;
- (NSString *)tableText; // use values from self 
// getting from text
- (void)addFieldsFromText:(NSString *)text getTitles:(BOOL)getTitles skipUnderline:(BOOL)skipUnderline;

- (JGTableData *)subTableWithColumns:(NSArray *)cols rows:(NSArray *)rows;
- (JGTableData *)subTableWithSelectionFromTableView:(NSTableView *)tv;

@end

@interface JGTableData(NSTableDataSource)
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard;

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op;

@end

@interface JGTableData (Pasteboard)
APPKIT_EXTERN NSString *JGTableDataPasteboardType;
APPKIT_EXTERN NSString *JGColumnDictionaryPasteboardType;

- (BOOL)pasteboard:(NSPasteboard *)pb pasteToRow:(int)row;
- (NSArray *)pasteboardTypes;
+ (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type;
- (void)pasteboard:(NSPasteboard *)pboard provideDataForType:(NSString *)type;
- (JGTableData *)tableDataFromPasteBoard:(NSPasteboard *)pboard;
- (void)pasteRowsFromPasteboard:(NSPasteboard *)pboard;

@end



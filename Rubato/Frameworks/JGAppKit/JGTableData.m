//
//  JGTableData.m
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Mon May 06 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "JGTableData.h"
#import "JGTableDataViewController.h"

#import <AppKit/AppKit.h>

NSString *JGTableDataTitlesKey=@"titles"; 
NSString *JGTableDataFieldsKey=@"fields";

@implementation JGTableData
+ (JGTableData *)newWithTitlesFromHeadersOfTableView:(NSTableView *)tv;
{ /*" autoreleased, empty instance (titles are set) "*/
  id result;
  NSTableColumn *column;
  NSArray *tableColumns=[tv tableColumns];
  NSMutableArray *a=[NSMutableArray array];
  NSEnumerator *e=[tableColumns objectEnumerator];
  while (column=[e nextObject]) {
    NSString *identifier=[column identifier];
    NSParameterAssert(identifier!=nil);
    [a addObject:identifier];
  }
  result=[[[JGTableData alloc] initWithTitles:a] autorelease];
  return result;
}


- (void)encodeWithCoder:(NSCoder *)coder;
{
  char c=(char)textWithTitles;
  [coder encodeObject:titles];
  [coder encodeObject:fields];
  [coder encodeObject:recordSeparator];
  [coder encodeObject:fieldSeparator];
  [coder encodeValueOfObjCType:@encode(char) at:&c];
  [coder encodeObject:textWithUnderline];
}
- (id)initWithCoder:(NSCoder *)coder;
{
  char c;
  [super init];
  titles=[[coder decodeObject] retain];
  fields=[[coder decodeObject] retain];
  recordSeparator=[[coder decodeObject] retain];
  fieldSeparator=[[coder decodeObject] retain];
  [coder decodeValueOfObjCType:@encode(char) at:&c];
  textWithTitles=(BOOL)c;
  textWithUnderline=[[coder decodeObject] retain];  
  return self;
}
- (id)initWithTitles:(NSArray *)tableTitles;
{
  [super init];
  recordSeparator=[@"\n" retain]; // Default for NSTabularTextPboardType
  fieldSeparator=[@"\t" retain]; // Default for NSTabularTextPboardType
  titles=[tableTitles copy];
  fields=[[NSMutableArray alloc] init];
  textWithTitles=NO;
  textWithUnderline=nil;
  return self;
}
- (void)dealloc;
{
  [recordSeparator release];
  [fieldSeparator release];
  [titles release];
  [fields release];
  [super dealloc];
}

- (id)copyWithoutFields;
{
  id newInst=[[[self class] alloc] initWithTitles:titles];
  [newInst setRecordSeparator:[recordSeparator copy]];
  [newInst setFieldSeparator:[fieldSeparator copy]];
  return newInst;
}

- (NSArray *)titles;
{
  return titles;
}
- (void)setTitles:(NSArray *)newTitles;
{
  id newVal=[newTitles copy];
  [titles release];
  titles=newVal;
}

accessor(NSMutableArray *,fields,setFields)
accessor(NSString *,recordSeparator,setRecordSeparator)
accessor(NSString *,fieldSeparator,setFieldSeparator)
accessor(NSString *,textWithUnderline,setTextWithUnderline)
scalarAccessor(BOOL,textWithTitles,setTextWithTitles)

/*
 - (NSMutableArray *)fields;
{
  return fields;
}
- (void)setFields:(NSMutableArray *)newFields;
{
  [newFields retain];
  [fields release];
  fields=newFields;
}

- (void)setRecordSeparator:(NSString *)newRS;
{
  id val=[newRS copy];
  [recordSeparator release];
  recordSeparator=val;
}
- (void)setFieldSeparator:(NSString *)newFS;
{
  id val=[newFS copy];
  [fieldSeparator release];
  fieldSeparator=val;
}
*/

- (void)addFields:(NSArray *)f;
{
  NSEnumerator *e=[f objectEnumerator];
  id item;
  while (item=[e nextObject]) {
    NSString *copy=[[item description] copy]; // independend String
    [fields addObject:copy];
    [copy release];
  }
}

- (void)addRecordsFields:(NSArray *)f;
{
  NSParameterAssert(([f count]%[titles count]==0));
  [self addFields:f];
}
- (void)addRecordFields:(NSArray *)f;
{
  NSParameterAssert([f count]==[titles count]);
  [self addFields:f];
}

- (int)fieldsIndexForColumnIdentifier:(NSString *)col row:(int)row;
{
  int offset=(col ? [titles indexOfObject:col] : NSNotFound);
  int index;
  NSAssert2(offset!=NSNotFound,@"Table column identifier %@ not known in table data titles %@", col,titles);
  index=row*[titles count]+offset;
  if (offset!=NSNotFound)
    return index;
  else
    return NSNotFound;
}

- (NSArray *)getRow:(int)row;
{
  NSMutableArray *a=[NSMutableArray array];
  int i,tc=[titles count];
  NSParameterAssert((row+1)*tc<=[fields count]);
  for (i=row*tc; i<(row+1)*tc; i++)
    [a addObject:[fields objectAtIndex:i]];
  return a;
}
- (NSDictionary *)getRecord:(int)row;
{
  NSDictionary *d=[NSDictionary dictionaryWithObjects:[self getRow:row] forKeys:titles];
  return d;
}
- (NSArray *)getAllRecords;
{
  NSMutableArray *result=[NSMutableArray array];
  int i,c;
  c=[self rowCount];
  for (i=0;i<c;i++)
    [result addObject:[self getRecord:i]];
  return result;
}

- (NSArray *)getColumn:(int)col;
{
  NSMutableArray *a=[NSMutableArray array];
  int i,tc=[titles count];
  int fc=[fields count];
  for (i=col; i<fc; i+=tc)
    [a addObject:[fields objectAtIndex:i]];
  return a;
}

- (NSDictionary *)getColumnsDictionary;
{
  NSMutableDictionary *d=[NSMutableDictionary dictionary];
  int i,tc=[titles count];
  for (i=0;i<tc;i++) {
    [d setObject:[self getColumn:i] forKey:[titles objectAtIndex:i]];
  }
  return d;
}
- (void)addColumns:(NSArray *)cols;
/*" Assertion : [cols count]==[titles count] "*/
{
  NSEnumerator *colEnumerator,*colsEnumerator=[cols objectEnumerator];
  NSArray *col;
  NSMutableArray *es=[NSMutableArray array]; // Array of enumerators
  int i,newRows=-1;
  NSParameterAssert([cols count]==[titles count]);
  while (col=[colsEnumerator nextObject]) {
    if (newRows==-1)
      newRows=[col count];
    NSParameterAssert([col count]==newRows);
    [es addObject:[col objectEnumerator]];
  }
  for (i=0;i<newRows;i++) {
    colsEnumerator=[es objectEnumerator];
    while (colEnumerator=[colsEnumerator nextObject]) {
      [fields addObject:[colEnumerator nextObject]];
    }
  }
}
- (void)addDictionaryOfColumns:(NSDictionary *)dict;
  /*" Assertion : [[dict allKeys] isEqual:titles] "*/
{
  NSMutableArray *cols=[NSMutableArray array];
  int i,tc=[titles count];
  for (i=0;i<tc;i++) {
    NSArray *a=[dict objectForKey:[titles objectAtIndex:i]];
    NSParameterAssert(a!=nil);
    [cols addObject:a];
  }
  [self addColumns:cols];
}

- (void)addRecord:(NSDictionary *)record;
{
  int i,tc=[titles count];
  for (i=0;i<tc;i++) {
    NSString *s=[record objectForKey:[titles objectAtIndex:i]];
    [fields addObject:(s ? s : @"")];
  }
}
- (void)addRecords:(NSArray *)records;
{
  NSEnumerator *e=[records objectEnumerator];
  NSDictionary *item;
  while (item=[e nextObject])
    [self addRecord:item];
}
- (void)addRecordsFromTableData:(JGTableData *)otherTableData;
{
  NSArray *recs=[otherTableData getAllRecords];
  [self addRecords:recs];
}
- (void)insertRecords:(NSArray *)records atRow:(int)row;
{
  NSArray *end;
  NSRange endRange;
  int c=[self colCount];
  endRange.location=row*c;
  endRange.length=[fields count]-endRange.location;
  end=[fields subarrayWithRange:endRange];
  [fields removeObjectsInRange:endRange];
  [self addRecords:records];
  [fields addObjectsFromArray:end];
}
- (void)insertRecordsFromTableData:(JGTableData *)otherTableData  atRow:(int)row;
{
  NSArray *recs=[otherTableData getAllRecords];
  [self insertRecords:recs atRow:row];
}

- (NSDictionary *)dictionaryWithTitlesAndFields;
{
  return [NSDictionary dictionaryWithObjectsAndKeys:titles,JGTableDataTitlesKey,fields,JGTableDataFieldsKey,nil];
}

- (NSArray *)arrayWithDictionaries;
{
  NSMutableArray *array=[NSMutableArray array];
  int tc,fc,i,j;
  tc=[titles count];
  fc=[fields count];
  NSParameterAssert(fc%tc==0);
  for (i=0;i<fc/tc;i++) {
    NSMutableDictionary *d=[NSMutableDictionary dictionary];
    for (j=0;j<tc;j++)
      [d setObject:[fields objectAtIndex:j] forKey:[titles objectAtIndex:j]];
    [array addObject:d];
  }
  return array;
}

// f is either NSArray or NSString, which is then repeated.
// end is exclusive
- (void)string:(NSMutableString *)str appendFields:(id)f start:(int)start end:(int)end useRS:(BOOL)useRS;
{
  int i,tc,fieldIndex;
  BOOL isString=[f isKindOfClass:[NSString class]];
  tc=[titles count];
  [str appendString:(isString ? f : [f objectAtIndex:start])];
  fieldIndex=0;
  if (useRS && (tc==1))
    [str appendString:recordSeparator];
  for (i=start+1;i<end;i++) {
    fieldIndex++;
    if ((!useRS) || ((fieldIndex)%tc != 0))
      [str appendString:fieldSeparator];
    [str appendString:(isString ? f : [f objectAtIndex:i])];
    if (useRS && ((fieldIndex+1)%tc ==0))
      [str appendString:recordSeparator];
  }
}
- (NSString *)tableTextWithTitles:(BOOL)printTitle underline:(NSString *)underline;
{
  NSMutableString *str=[NSMutableString string];
  if (printTitle) {
    [self string:str appendFields:titles start:0 end:[titles count] useRS:YES];
    if (underline) {
      [self string:str appendFields:underline start:0 end:[titles count] useRS:YES];
    }
  }
  [self string:str appendFields:fields start:0 end:[fields count] useRS:YES];
  return str;
}
- (NSString *)tableText;
{
  return [self tableTextWithTitles:[self textWithTitles] underline:[self textWithUnderline]];
}

- (void)addFieldsFromText:(NSString *)text getTitles:(BOOL)getTitles skipUnderline:(BOOL)skipUnderline;
/*" if getTitles, sets Titles from Text and adds Fields (without removing previous fields).
    otherwise, it uses the text entries from left to right to fill new corresponding rows.
"*/
{
  NSEnumerator *lineEnumerator;
  NSArray *lineFields,*lines;
  NSString *line,*field;
  int i,lineFieldsCount,lineNr=0;
  int fieldCount=([titles count] ? [titles count] : 1);
  lines=[text componentsSeparatedByString:recordSeparator];
  if ([[lines lastObject] isEqualToString:@""]) {
    NSMutableArray *mlines=[[lines mutableCopy] autorelease];
    [mlines removeLastObject];
    lines=mlines;
  }
  lineEnumerator=[lines objectEnumerator];
  while (line=[lineEnumerator nextObject]) {
    lineNr++;
    lineFields=[line componentsSeparatedByString:fieldSeparator];
    lineFieldsCount=[lineFields count];
    if (getTitles && (lineNr==1)) {
      if (lineFieldsCount) {
        [self setTitles:lineFields];
        fieldCount=lineFieldsCount;
      } else {
        [self setTitles:[NSArray arrayWithObjects:@"?",nil]];
        fieldCount=1;
      }
      if (skipUnderline)
        [lineEnumerator nextObject];
    } else {
      for (i=0;i<fieldCount;i++) {
        if (i>=[lineFields count])
          field=@"";
        else
          field=[lineFields objectAtIndex:i];
        [fields addObject:field];
      }
    }
  }
}


- (JGTableData *)subTableWithColumns:(NSArray *)cols rows:(NSArray *)rows;
{
  // cols given as Strings, rows as Numbers
  // if rows is nil, take the whole column.
  JGTableData *newTable=[[[JGTableData alloc] initWithTitles:cols] autorelease];
  NSMutableArray *newFields=[newTable fields];
  NSEnumerator *rowE,*colE;
  NSString *colItem;
  NSNumber *rowItem;
  int cc=[cols count];
  int tc=[titles count];
  int *offset=calloc(cc,sizeof(int));
  int i,maxRow=[fields count]/tc;

  colE=[cols objectEnumerator];
  i=0;
  while (colItem=[colE nextObject]) {
    offset[i]=[titles indexOfObject:colItem];
    NSParameterAssert(offset[i]!=NSNotFound);
    i++;
  }
  if (rows) {
    rowE=[rows objectEnumerator];
    while (rowItem=[rowE nextObject]) {
      int row=[rowItem intValue];
      NSParameterAssert(row<=maxRow);
      for (i=0;i<cc;i++) {
        int index=row*tc+offset[i];
        [newFields addObject:[fields objectAtIndex:index]];
      }
    }
  } else {
    int row;
    int rowCount=[self rowCount];
    for (row=0; row<rowCount; row++) {
      for (i=0;i<cc;i++) {
        int index=row*tc+offset[i];
        [newFields addObject:[fields objectAtIndex:index]];
      }        
    }
  }
  free(offset);
  return newTable;
}

- (JGTableData *)subTableWithSelectionFromTableView:(NSTableView *)tv;
{
  JGTableData *result;
  NSArray *cols,*rows;
  cols=[JGTableDataViewController selectedColumnNamesForTableView:tv allIfEmpty:YES];
  rows=[JGTableDataViewController selectedRowNumbersForTableView:tv allIfEmpty:YES];
  result=[self subTableWithColumns:cols rows:rows];
  return result;
}

- (int)colCount;
{
  return [titles count];
}
- (int)rowCount;
{
  return [fields count]/[titles count];
}

- (void)removeColumnsWithTitles:(NSArray *)theTitles;
{
  NSMutableArray *restTitles=[[self titles] mutableCopy];
  JGTableData *result;
  [restTitles removeObjectsInArray:theTitles];
  result=[self subTableWithColumns:restTitles rows:nil];
  [self setTitles:restTitles];
  [self setFields:[result fields]];
}

- (void)removeRowsInRange:(NSRange)range;
{
  int factor=[self colCount];
  range.location *=factor;
  range.length *= factor;
  [fields removeObjectsInRange:range];
}

- (void)removeRows:(NSArray *)rows sortedAscending:(BOOL)sorted;
{
  NSArray *sortedRows;
  NSEnumerator *e;
  NSNumber *n;
  NSRange r;
  r.length=1;
  if (sorted)
    sortedRows=rows;
  else
    sortedRows=[rows sortedArrayUsingSelector:@selector(compare:)];
  e=[sortedRows reverseObjectEnumerator];
  while (n=[e nextObject]) {
    r.location=[n intValue];
    [self removeRowsInRange:r];
  }
}

@end

@implementation JGTableData (Pasteboard)

NSString *JGTableDataPasteboardType=@"JGTableDataPasteboardType";
NSString *JGColumnDictionaryPasteboardType=@"JGColumnDictionaryPasteboardType";

- (NSArray *)pasteboardTypes;
{
  return [NSArray arrayWithObjects:JGTableDataPasteboardType,JGColumnDictionaryPasteboardType,
    NSTabularTextPboardType,NSStringPboardType,nil];
}

+ (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type;
{
  NSData *d=[sender dataForType:JGTableDataPasteboardType];
  JGTableData *tableData=[NSUnarchiver unarchiveObjectWithData:d];
  [tableData pasteboard:sender provideDataForType:type];
}

- (void)pasteboard:(NSPasteboard *)pboard provideDataForType:(NSString *)type;
{
  if ([type isEqualToString:JGColumnDictionaryPasteboardType])
    [pboard setPropertyList:[self getColumnsDictionary] forType:JGColumnDictionaryPasteboardType];
  if ([type isEqualToString:NSTabularTextPboardType])
    [pboard setString:[self tableTextWithTitles:textWithTitles underline:textWithUnderline] forType:NSTabularTextPboardType];
  if ([type isEqualToString:NSStringPboardType])
    [pboard setString:[self tableTextWithTitles:textWithTitles underline:textWithUnderline] forType:NSTabularTextPboardType];
}

- (JGTableData *)tableDataFromPasteBoard:(NSPasteboard *)pboard;
{
  NSString *type=[pboard availableTypeFromArray:[self pasteboardTypes]];
  JGTableData *tableData=nil;
  if ([type isEqualToString:JGTableDataPasteboardType]) {
    NSData *d=[pboard dataForType:type];
    tableData=[[NSUnarchiver unarchiveObjectWithData:d] retain];
  }
  if ([type isEqualToString:JGColumnDictionaryPasteboardType]) {
    NSDictionary *d=[pboard propertyListForType:type];
    tableData=[[JGTableData alloc] initWithTitles:[d objectForKey:JGTableDataTitlesKey]];
    [tableData addDictionaryOfColumns:d];
  }
  if ([type isEqualToString:NSTabularTextPboardType] || [type isEqualToString:NSStringPboardType]) {
    NSString *s=[pboard stringForType:type];
    tableData=[self copyWithoutFields];
    [tableData addFieldsFromText:s getTitles:textWithTitles skipUnderline:(textWithUnderline ? YES:NO)];
  }
  return [tableData autorelease];
}

- (BOOL)pasteboard:(NSPasteboard *)pboard pasteToRow:(int)row;
{
    JGTableData *newInst=[self tableDataFromPasteBoard:pboard];
    int rows=[self rowCount];
    NSRange destRange,sourceRange;
    if (row>rows)
      row=rows;
    destRange.location=row*[titles count];
    destRange.length=0; // nothing gets replaced.
    sourceRange.location=0;
    sourceRange.length=[[newInst fields] count];
    if (newInst) {
      if ([[newInst titles] isEqual:titles])
        [fields replaceObjectsInRange:destRange withObjectsFromArray:[newInst fields] range:sourceRange];
      else
        [self insertRecordsFromTableData:newInst atRow:row];
      return YES;      
    } else
      return NO;
}

- (void)pasteRowsFromPasteboard:(NSPasteboard *)pboard;
{
  JGTableData *td=[self tableDataFromPasteBoard:pboard];
  if (td)
    [self addRecordsFromTableData:td];
  else
    NSBeep();
}

@end

@implementation JGTableData(NSTableDataSource)
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
{
  return [self rowCount];
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
  int index=[self fieldsIndexForColumnIdentifier:[tableColumn identifier] row:row];
  return [fields objectAtIndex:index];
}
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
  int index=[self fieldsIndexForColumnIdentifier:[tableColumn identifier] row:row];
  if (index==[fields count])
    [fields addObject:object];
  else if (index<[fields count])
    [fields replaceObjectAtIndex:index withObject:object];
}

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard;
{
  NSArray *cols=[JGTableDataViewController selectedColumnNamesForTableView:tv allIfEmpty:YES];
  JGTableData *table=[self subTableWithColumns:cols rows:rows];
  id owner=[self class];
  NSData *data=[NSArchiver archivedDataWithRootObject:table];
  [pboard declareTypes:[self pasteboardTypes] owner:owner];
  return [pboard setData:data forType:JGTableDataPasteboardType];
}


 - (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
 {
  NSPasteboard *pb=[info draggingPasteboard];
  if ([[pb types] containsObject:NSTabularTextPboardType] || [[pb types] containsObject:NSStringPboardType])
    return NSDragOperationCopy;
  else
    return NSDragOperationNone;
 }

 - (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op;
{ // This method is called when the mouse is released over an outline view that previously decided to allow a drop via the validateDrop method.  The data source should incorporate the data from the dragging pasteboard at this time.
  NSPasteboard *pb=[info draggingPasteboard];
  return [self pasteboard:pb pasteToRow:row];
}
@end


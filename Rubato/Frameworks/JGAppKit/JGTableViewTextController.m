//
//  JGTableViewTextController.m
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Wed Jun 19 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "JGTableViewTextController.h"
#import "JGTableDataViewController.h"
#import "JGAccessorMacros.h"

@implementation JGTableViewTextController
accessor(id,tableDataViewController,setTableDataViewController)
readAccessor(id,window)

- init;
{
  int i,j;
  [super init];
  sampleTableData=[[JGTableData alloc] initWithTitles:[NSArray arrayWithObjects:@"A",@"B",@"C",nil]];
  for (i=1;i<6;i++)
    for (j=1;j<=[sampleTableData colCount]; j++) 
      [[sampleTableData fields] addObject:[NSString stringWithFormat:@"%d,%d",i,j]];
  return self;
}
- (void)dealloc;
{
  [sampleTableData release];
  [super dealloc];
}
- (void)setValuesToTableData:(JGTableData *)tableData;
{
  BOOL state;
  [tableData setRecordSeparator:[recordSeparatorTextView string]];
  [tableData setFieldSeparator:[fieldSeparatorTextView string]];
  state=[textWithUnderlineSwitch state];
  if (state)
    [tableData setTextWithUnderline:[textWithUnderlineTextField stringValue]];
  else
    [tableData setTextWithUnderline:nil];
  [tableData setTextWithTitles:[textWithTitlesSwitch state]];  
}
- (void)setFieldsFromTableData:(JGTableData *)tableData;
{
  NSString *u;
  [recordSeparatorTextView setString:[tableData recordSeparator]];
  [fieldSeparatorTextView setString:[tableData fieldSeparator]];
  [textWithTitlesSwitch setState:[tableData textWithTitles]];
  u=[tableData textWithUnderline];
  if (u) {
    [textWithUnderlineTextField setStringValue:u];
    [textWithUnderlineSwitch setState:YES];
  } else {
    [textWithUnderlineTextField setStringValue:@""];
    [textWithUnderlineSwitch setState:NO];
  }
}
- (void)updateSampleTextViewFromTableData:(JGTableData *)td;
{
  NSString *text;
  if (td==sampleTableData)
    [sampleTextViewInfoTextField setStringValue:@"Pasting to Text will look like this:"];
  else
    [sampleTextViewInfoTextField setStringValue:@"Text representation of the table:"];
  text=[td tableText];
  [sampleTextView setString:text];
  [sampleTextView setNeedsDisplay:YES];
}
- (IBAction)okPressed:(id)sender;
{
  id td=[tableDataViewController tableData];
  [self setValuesToTableData:td];
  [self updateSampleTextViewFromTableData:td];
}
- (IBAction)revertPressed:(id)sender;
{
  id td=[tableDataViewController tableData];
  [self setFieldsFromTableData:td];
  [self updateSampleTextViewFromTableData:td];
}
- (IBAction)testPressed:(id)sender;
{
  [self setValuesToTableData:sampleTableData];
  [self updateSampleTextViewFromTableData:sampleTableData];
}
@end

//
//  JGTableViewTextController.h
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Wed Jun 19 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "JGTableData.h"
#import "JGAccessorMacros.h"

@interface JGTableViewTextController : NSObject
{
  id tableDataViewController; // - (JGTableData *)tableData;
  id sampleTableData;
  
  IBOutlet NSWindow *window;
  IBOutlet NSTextView *recordSeparatorTextView;
  IBOutlet NSTextView *fieldSeparatorTextView;
  IBOutlet NSTextField *textWithUnderlineTextField;
  IBOutlet NSButton *textWithTitlesSwitch;
  IBOutlet NSButton *textWithUnderlineSwitch;
  IBOutlet NSTextView *sampleTextView;
  IBOutlet NSTextField *sampleTextViewInfoTextField;
}
accessor_h(id,tableDataViewController,setTableDataViewController)
- (id)window;

- (void)setValuesToTableData:(JGTableData *)tableData;
- (void)setFieldsFromTableData:(JGTableData *)tableData;
- (IBAction)testPressed:(id)sender;
- (IBAction)okPressed:(id)sender;
- (IBAction)revertPressed:(id)sender;
@end

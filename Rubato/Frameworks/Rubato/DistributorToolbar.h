//
//  DistributorToolbar.h
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Wed Mar 27 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Rubato/Distributor.h>

@interface Distributor (ToolbarController)
- (void) setupToolbarWithWindow:(NSWindow *)window;
- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted;
- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar;
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar;
@end

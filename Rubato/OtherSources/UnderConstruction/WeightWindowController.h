//
//  WeightWindowController.h
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Mon Jul 01 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WindowTabViewItemRelation : NSObject
{
  NSTabViewItem *tabViewItem;
  NSWindow *window;
}

@end
@interface WeightWindowController : NSObject {
  IBOutlet NSDrawer *drawer;
  IBOutlet NSTabView *windowTabView;
  IBOutlet NSTabView *drawerTabView;
  IBOutlet id weightView;
  IBOutlet id weightTableView;

  NSMenu *windowTabViewMenu;
  NSMenu *drawerTabViewMenu;
}
- (void)tabView:(NSTabView *)tv addViewFromWindow:(NSWindow *)w;
{
  NSView *contentView=[[[w contentView] retain] autorelease];
  NSString *title=[w title];
  NSView *newView=[[[NSView alloc] initWithFrame:[contentView frame]] autorelease];
  int bc=3;
  NSButton *b1=[[NSButton alloc] initWithFrame:
  [newView addSubView:
}
- (void)tabView:(NSTabView *)tv addView:(NSView *)v withTitle:(NSString *)t;
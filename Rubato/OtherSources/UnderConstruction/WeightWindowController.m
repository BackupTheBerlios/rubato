//
//  WeightWindowController.m
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Mon Jul 01 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//  State: Under construction

#import "WeightWindowController.h"


@implementation WeightWindowController

- (void) setupToolbarWithWindow:(NSWindow *)window;
{
  // Create a new toolbar instance, and attach it to our document window
  NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier: @"WeightWindowToolbar"] autorelease];

  // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults
  [toolbar setAllowsUserCustomization: YES];
  [toolbar setAutosavesConfiguration: YES];
  [toolbar setDisplayMode: NSToolbarDisplayModeLabelOnly]; // NSToolbarDisplayModeIconAndLabel

  // We are the delegate
  [toolbar setDelegate: self];

  // Attach the toolbar to the document window
  [window setToolbar: toolbar];
}

- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted;
{
  // Required delegate method   Given an item identifier, self method returns an item
  // The toolbar will use self method to obtain toolbar items that can be displayed in the customization sheet, or in the toolbar itself
  NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];

  if ([itemIdent isEqual: @"WindowMenu"]) {
    // Set the text label to be displayed in the toolbar and customization palette
    [toolbarItem setLabel: @"WindowMenu"];
    [toolbarItem setPaletteLabel: @"WindowMenu"];

    // Set up a reasonable tooltip, and image   Note, these aren't localized, but you will likely want to localize many of the item's properties
    [toolbarItem setToolTip: @"Show General Purpose Object Inspector"];
    [toolbarItem setImage: [NSImage imageNamed: @"Find"]];

    // Tell the item what message to send when it is clicked
    [toolbarItem setTarget: self];
    [toolbarItem setAction: @selector(showInspector:)];
  } else if([itemIdent isEqual: @"Rubettes"]) {
    NSMenu *submenu = [rubettesMenuCell submenu]; // always the same instance (allows us to add to submenu in one place only)
    NSMenuItem *menuFormRep = nil;
    NSRect r=NSMakeRect(0.0,0.0,150.0,30.0);
    NSPopUpButton *popUpButton=[[NSPopUpButton alloc] initWithFrame:r pullsDown:NO];
    [popUpButton setMenu:submenu];
    //        [popUpButton setTitle:@"Custom"];

    // Set up the standard properties
    [toolbarItem setLabel: @"Rubettes"];
    [toolbarItem setPaletteLabel: @"Rubettes"];
    [toolbarItem setToolTip: @"Menu for local Rubettes"];

    // Use a custom view, a text field, for the search item
    [toolbarItem setView:popUpButton];
    [toolbarItem setMinSize:NSMakeSize(150,NSHeight([popUpButton frame]))];
    [toolbarItem setMaxSize:NSMakeSize(250,NSHeight([popUpButton frame]))];

    // By default, in text only mode, a custom items label will be shown as disabled text, but you can provide a
    // custom menu of your own by using <item> setMenuFormRepresentation]
    menuFormRep = [[[NSMenuItem alloc] init] autorelease];
    [menuFormRep setSubmenu: submenu];
    [menuFormRep setTitle: [toolbarItem label]];
    [toolbarItem setMenuFormRepresentation: menuFormRep];
    } else {
      // itemIdent refered to a toolbar item that is not provide or supported by us or cocoa
      // Returning nil will inform the toolbar self kind of item is not supported
      toolbarItem = nil;
    }
  return toolbarItem;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar;
{
  // Required delegate method   Returns the ordered list of items to be shown in the toolbar by default
  // If during the toolbar's initialization, no overriding values are found in the user defaults, or if the
  // user chooses to revert to the default items self set will be used
  return [NSArray arrayWithObjects: @"Inspector",@"Rubettes", nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar;
{
  // Required delegate method   Returns the list of all allowed items by identifier   By default, the toolbar
  // does not assume any items are allowed, even the separator   So, every allowed item must be explicitly listed
  // The set of allowed items is used to construct the customization palette
  return [NSArray arrayWithObjects: @"Inspector",@"Rubettes",NSToolbarCustomizeToolbarItemIdentifier,
    NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier, NSToolbarSeparatorItemIdentifier, nil];
}

@end

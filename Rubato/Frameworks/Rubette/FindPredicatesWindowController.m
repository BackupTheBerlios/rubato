#import "FindPredicatesWindowController.h"

#define ALL_LEVELS -2

@implementation FindPredicatesWindowController

+ (NSString *)findPredicatesPanelNibName;
{
  return @"FindPredicatesPanel";
}

- (id)initWithWindow:(NSWindow *)window;
{ // is this o.k.? needed in awakeFromNib?
  [super initWithWindow:window]; // jg 22.3.2002
  levels=ALL_LEVELS;
  cascadeSearch=NO;
  readRubetteDataIfBecomeKey=YES;
  writeRubetteDataIfResignKey=NO;
  findString=@"";
  return self;
} 

- (void)awakeFromNib;
{
  [findLevelsTextField setIntValue:levels];
  [cascadeSearchButton setState:cascadeSearch];
  [readRubetteDataIfBecomeKeySwitch setState:readRubetteDataIfBecomeKey];
  [writeRubetteDataIfResignKeySwitch setState:writeRubetteDataIfResignKey];
  [self setFindString:findString];
}

- (NSView *)importView;
{
  return [[self window] contentView];
}
- (id) delegate
{
	return delegate;
}

- (void) setDelegate:(id)newDelegate
{
	delegate = newDelegate;
}

/* public methods */
- (NSString *)findString;
{
  if (findNameTextField) // so I dont need an extra action method.
    return [findNameTextField stringValue];
  else
    return findString;
}
- (void)setFindString:(NSString *)newFindString;
{
  [newFindString retain];
  [findString release];
  findString=newFindString;
  if (findNameTextField)
    [findNameTextField setStringValue:newFindString];
}
- (int)findWhat;
{
  return [[findWhatPopUpButton selectedItem] tag];
}
//- (void)setFindWhat:(int)tag;
- (int)findHow;
{
  return [[findHowPopUpButton selectedItem] tag];
}
//- (void)setFindHow:(int)tag;
- (int)findSource;
{
  return [findSourceTextField intValue];
}
- (void)setFindSource:(int)tag;
{
  [findSourceTextField setIntValue:tag];
}
- (int) findLevels
{
  return levels;
}

- (void) setFindLevels:(int)newLevels
{
  levels=newLevels;
  [findLevelsTextField setIntValue:newLevels];
}

- (BOOL) cascadeSearch
{
  return cascadeSearch;
}

- (void) setCascadeSearch:(BOOL)newCascadeSearch
{
  cascadeSearch=newCascadeSearch;
  [cascadeSearchButton setState:newCascadeSearch];
}
- (BOOL) readRubetteDataIfBecomeKey
{
	return readRubetteDataIfBecomeKey;
}

- (void) setReadRubetteDataIfBecomeKey:(BOOL)newReadRubetteDataIfBecomeKey
{
	readRubetteDataIfBecomeKey = newReadRubetteDataIfBecomeKey;
  [readRubetteDataIfBecomeKeySwitch setState:newReadRubetteDataIfBecomeKey];
}

- (BOOL) writeRubetteDataIfResignKey
{
	return writeRubetteDataIfResignKey;
}

- (void) setWriteRubetteDataIfResignKey:(BOOL)newWriteRubetteDataIfResignKey
{
	writeRubetteDataIfResignKey = newWriteRubetteDataIfResignKey;
  [writeRubetteDataIfResignKeySwitch setState:newWriteRubetteDataIfResignKey];
}



/* IB methods */
- (void)changeFindSource:sender;
{
  [self setFindSource:[[sender selectedItem] tag]]; 
}
- (void)changeFindLevels:sender;
{
  [self setFindLevels:[[sender selectedItem] tag]];
}
- (IBAction)cascadeSearchToggle:sender;
{
  [self setCascadeSearch:[sender state]];
}
- (IBAction)readWriteToggle:sender;
{
  if (sender==readRubetteDataIfBecomeKeySwitch) 
    [self setReadRubetteDataIfBecomeKey:[sender state]];
  else if (sender==writeRubetteDataIfResignKeySwitch)
    [self setWriteRubetteDataIfResignKey:[sender state]];
}

- (IBAction)newPressed:sender;
{
  [delegate initSearchWithFindPredicateSpecification:self];
}
- (void)doSearch:sender;/* action method for find buttons */
{
  [delegate doSearchWithFindPredicateSpecification:self];
}

- (IBAction)readRubetteData:sender;
{
  if ([delegate respondsToSelector:@selector(readRubetteData)])
    [delegate readRubetteData];
}
- (IBAction)writeRubetteData:sender;
{
  if ([delegate respondsToSelector:@selector(writeRubetteData)])
    [delegate writeRubetteData];
}

@end

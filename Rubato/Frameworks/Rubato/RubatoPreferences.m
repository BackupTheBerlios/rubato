/* RubatoPreferences.h */

#import <AppKit/AppKit.h>

#import "RubatoPreferences.h"

@implementation RubatoPreferences

- init;
{
    [super init];
    myFiletype = RUBATO_PREFS_FILE_TYPE;
    return self;	
}


- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    if (!useFile) {
	if (![self getDefaultValueWithName:RUBETTE_DIR_NAME])
            [rubetteDirField setStringValue:@""]; // look in builtInPlugInDir
//	    [rubetteDirField setStringValue:@"~/Library/Rubato/Rubettes"];
	else
	    [rubetteDirField setStringValue:[NSString jgStringWithCString:[self getDefaultValueWithName:RUBETTE_DIR_NAME]]];
	
	if (![self getDefaultValueWithName:OPERATOR_DIR_NAME])
            [operatorDirField setStringValue:@""]; // look in builtInPlugInDir
//	    [operatorDirField setStringValue:@"~/Library/Rubato/Operators"];
	else
	    [operatorDirField setStringValue:[NSString jgStringWithCString:[self getDefaultValueWithName:OPERATOR_DIR_NAME]]];
	
	if (![self getDefaultValueWithName:STEMMA_DIR_NAME])
	    [stemmaDirField setStringValue:@"~/Library/Rubato/Stemmata"];
	else
	    [stemmaDirField setStringValue:[NSString jgStringWithCString:[self getDefaultValueWithName:STEMMA_DIR_NAME]]];
	
	if (![self getDefaultValueWithName:WEIGHT_DIR_NAME])
	    [weightDirField setStringValue:@"~/Library/Rubato/Weights"];
	else
	    [weightDirField setStringValue:[NSString jgStringWithCString:[self getDefaultValueWithName:WEIGHT_DIR_NAME]]];
	
	if (![self getDefaultValueWithName:MUSIC_FILE_DIR_NAME])
	    [musicDirField setStringValue:@"~/Library/Predicates"];
	else
	    [musicDirField setStringValue:[NSString jgStringWithCString:[self getDefaultValueWithName:MUSIC_FILE_DIR_NAME]]];
    }
}


- getRubetteDirectory:sender;
{
//#warning FactoryMethods: [OpenPanel openPanel] used to be [OpenPanel new].  Open panels are no longer shared.  'openPanel' returns a new, autoreleased open panel in the default configuration.  To maintain state, retain and reuse one open panel (or manually re-set the state each time.)
    id panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];  //war:    [panel chooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setTreatsFilePackagesAsDirectories:NO];
    [panel setTitle:@"Locate Rubette Directory"];
    if ([panel runModalForDirectory:@"" file:@""])
	[rubetteDirField setStringValue:[panel filename]];
    return self;
}

- getOperatorDirectory:sender;
{
//#warning FactoryMethods: [OpenPanel openPanel] used to be [OpenPanel new].  Open panels are no longer shared.  'openPanel' returns a new, autoreleased open panel in the default configuration.  To maintain state, retain and reuse one open panel (or manually re-set the state each time.)
    id panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];  //war:    [panel chooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setTreatsFilePackagesAsDirectories:NO];
    [panel setTitle:@"Locate Operator Directory"];
    if ([panel runModalForDirectory:@"" file:@""])
	[operatorDirField setStringValue:[panel filename]];
    return self;
}

- getStemmaDirectory:sender;
{
//#warning FactoryMethods: [OpenPanel openPanel] used to be [OpenPanel new].  Open panels are no longer shared.  'openPanel' returns a new, autoreleased open panel in the default configuration.  To maintain state, retain and reuse one open panel (or manually re-set the state each time.)
    id panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];  //war:    [panel chooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setTreatsFilePackagesAsDirectories:NO];
    [panel setTitle:@"Locate Stemma Directory"];
    if ([panel runModalForDirectory:@"" file:@""])
	[stemmaDirField setStringValue:[panel filename]];
    return self;
}

- getWeightDirectory:sender;
{
//#warning FactoryMethods: [OpenPanel openPanel] used to be [OpenPanel new].  Open panels are no longer shared.  'openPanel' returns a new, autoreleased open panel in the default configuration.  To maintain state, retain and reuse one open panel (or manually re-set the state each time.)
    id panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];  //war:    [panel chooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setTreatsFilePackagesAsDirectories:NO];
    [panel setTitle:@"Locate Weight Directory"];
    if ([panel runModalForDirectory:@"" file:@""])
	[weightDirField setStringValue:[panel filename]];
    return self;
}

- getFileDirectory:sender;
{
//#warning FactoryMethods: [OpenPanel openPanel] used to be [OpenPanel new].  Open panels are no longer shared.  'openPanel' returns a new, autoreleased open panel in the default configuration.  To maintain state, retain and reuse one open panel (or manually re-set the state each time.)
    id panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];  //war:    [panel chooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setTreatsFilePackagesAsDirectories:NO];
    [panel setTitle:@"Locate Music Files Directory"];
    if ([panel runModalForDirectory:@"" file:@""])
	[musicDirField setStringValue:[panel filename]];
    return self;
}


- (NSString *)rubetteDirectory;
{
  NSString *str=[rubetteDirField stringValue];
  if (!str || [str isEqualToString:@""])
    str=[[NSBundle mainBundle] builtInPlugInsPath];
  return str;
}

- (NSString *)operatorDirectory;
{
  NSString *str=[operatorDirField stringValue];
  if (!str || [str isEqualToString:@""])
    str=[[NSBundle mainBundle] builtInPlugInsPath];
  return str;
}

- (NSString *)stemmaDirectory;
{
    return [stemmaDirField stringValue];
}

- (NSString *)weightDirectory;
{
    return [weightDirField stringValue];
}

- (NSString *)fileDirectory;
{
    return [musicDirField stringValue];
}


- collectPrefs;
{
    [self setParameter:RUBETTE_DIR_NAME toStringValue:[[rubetteDirField stringValue] cString]];
    [self setParameter:OPERATOR_DIR_NAME toStringValue:[[operatorDirField stringValue] cString]];
    [self setParameter:STEMMA_DIR_NAME toStringValue:[[stemmaDirField stringValue] cString]];
    [self setParameter:WEIGHT_DIR_NAME toStringValue:[[weightDirField stringValue] cString]];
    [self setParameter:MUSIC_FILE_DIR_NAME toStringValue:[[musicDirField stringValue] cString]];
    [self setParameter:WEIGHT_DIR_NAME toStringValue:[[weightDirField stringValue] cString]];
   
    return self;
}

- displayPrefs;
{
    [rubetteDirField setStringValue:[NSString jgStringWithCString:[self stringValueOfParameter:RUBETTE_DIR_NAME]]];
    [operatorDirField setStringValue:[NSString jgStringWithCString:[self stringValueOfParameter:OPERATOR_DIR_NAME]]];
    [stemmaDirField setStringValue:[NSString jgStringWithCString:[self stringValueOfParameter:STEMMA_DIR_NAME]]];
    [weightDirField setStringValue:[NSString jgStringWithCString:[self stringValueOfParameter:WEIGHT_DIR_NAME]]];
    [musicDirField setStringValue:[NSString jgStringWithCString:[self stringValueOfParameter:MUSIC_FILE_DIR_NAME]]];
    return self;
}

- writePrefsToDB;
{
    [super writePrefsToDB];
    
    [self writeDefault:[[rubetteDirField stringValue] cString]
	withName:RUBETTE_DIR_NAME];
    [self writeDefault:[[operatorDirField stringValue] cString]
	withName:OPERATOR_DIR_NAME];
    [self writeDefault:[[stemmaDirField stringValue] cString]
	withName:STEMMA_DIR_NAME];
    [self writeDefault:[[weightDirField stringValue] cString]
	withName:WEIGHT_DIR_NAME];
    [self writeDefault:[[musicDirField stringValue] cString]
	withName:MUSIC_FILE_DIR_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize]; // hmm? needed? jg 17.7.01
    return self;
}

- readPrefsFromDB;
{
    [super readPrefsFromDB];
    
    [rubetteDirField setStringValue:[NSString jgStringWithCString:[self getDefaultValueWithName:RUBETTE_DIR_NAME]]];
    [operatorDirField setStringValue:[NSString jgStringWithCString:[self getDefaultValueWithName:OPERATOR_DIR_NAME]]];
    [stemmaDirField setStringValue:[NSString jgStringWithCString:[self getDefaultValueWithName:STEMMA_DIR_NAME]]];
    [weightDirField setStringValue:[NSString jgStringWithCString:[self getDefaultValueWithName:WEIGHT_DIR_NAME]]];
    [musicDirField setStringValue:[NSString jgStringWithCString:[self getDefaultValueWithName:MUSIC_FILE_DIR_NAME]]];
    return self;
}


@end
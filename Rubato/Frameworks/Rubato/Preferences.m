/* Preferences.m */

#import "Preferences.h"
#import "MathMatrixProtocols.h"

#import <AppKit/AppKit.h>
//20.10.00 #import <MathMatrixKit/MathMatrix.h>

#define BEGIN_MATRIX "{"
#define END_MATRIX "}"
#define COEFF_DELIM ", "
#define ROW_DELIM ", "


@implementation Preferences

//	    [myWindow setFrameUsingName:[[self class] rubetteName]];
//	[sender saveFrameUsingName:[sender title]];

- init;
{
    [super init];
    myOwner = nil;
    myOwnerName = [[[NSProcessInfo processInfo] processName] cString];
    myFilename = NULL;
    myFiletype = DEFAULT_FILETYPE;
    useFile = NO;
    myPanel = nil;
    myConverter = [[StringConverter alloc]init];
    myParameterTable = [[NSMutableDictionary alloc]init];
    
    return self;
}


- (void)dealloc;
{
    if(myFilename) free(myFilename);
    [myConverter release];
    [myPanel close];
    [myPanel release];
    [myParameterTable release];
    [super dealloc];
}


- (void)awakeFromNib;
{
//    char path[MAXPATHLEN+1];
    NSString *path;
    if (path = [[NSBundle bundleForClass:[self class]] pathForResource:@"" ofType:[NSString jgStringWithCString:myFiletype]]) {
	    [self setFilename:[path cString]];
	    if([self readPrefsFromFile:myFilename])
		[self setUseFile:YES];
	    else
		[self setFilename:NULL];
    }
}


- setOwner:anObject;
{
    if(!myOwner)
	myOwner = anObject;
    return self;
}

- owner;
{
    return myOwner;
}

- setPanel:aPanel;
{
    if (!myPanel && [aPanel isKindOfClassNamed:"Window"])
	myPanel = aPanel;
    return self;
}

- panel;
{
    return myPanel;
}

- (const char*)ownerName;
{
    return myOwnerName;
}


- setFilename:(const char *)aFilename;
{
    if (myFilename) free(myFilename);
    myFilename = NULL;
    if (aFilename) {
	myFilename = malloc(strlen(aFilename)+1);
	strcpy(myFilename, aFilename);
    }
    return self;
}

- (NSString *)filename;
{
    return [NSString jgStringWithCString:myFilename];
}

- setUseFile:(BOOL)flag;
{
    useFile = flag;
    return self;
}

- (BOOL)useFile;
{
    return useFile;
}



- setParameter:(const char*)paraName toStringValue:(const char*)paraVal;
{
    if (paraName && paraVal) {
//	paraName = JGUniqueString(paraName);
	
        [myParameterTable setObject:[NSString jgStringWithCString:paraVal] forKey:[NSString jgStringWithCString:paraName]];
    }
    return self;
}

- setParameter:(const char*)paraName toIntValue:(int)paraVal;
{
    [myConverter setIntValue:paraVal];
    [self setParameter:paraName toStringValue:[myConverter cString]];
    return self;
}

- setParameter:(const char*)paraName toDoubleValue:(double)paraVal;
{
    [myConverter setDoubleValue:paraVal];
    [self setParameter:paraName toStringValue:[myConverter cString]];
    return self;
}

- setParameter:(const char*)paraName toBoolValue:(BOOL)paraVal;
{
    [myConverter setBoolValue:paraVal];
    [self setParameter:paraName toStringValue:[myConverter cString]];
    return self;
}

- setParameter:(const char*)paraName toMatrix:aMatrix;
{
    int rows, cols, r, c;
    id cell;
    BOOL isMath = [aMatrix isKindOfClass:NSClassFromString(@"MathMatrix")];
    [aMatrix getNumberOfRows:&rows columns:&cols];
    [myConverter setStringValue:[NSString jgStringWithCString:BEGIN_MATRIX]];
    for (r=0; r<rows; r++) {
	for (c=0; c<cols; c++) {
	    if (isMath)
		[myConverter concatDouble:[[aMatrix numberAt:r:c] doubleValue]];
	    else {
		cell = [aMatrix cellAtRow:r column:c];
		if ([cell isKindOfClass:[NSButtonCell class]])
		    [myConverter concatBool:[cell intValue]];
		else
		    [myConverter concat:[[cell stringValue] cString]];
	    }
	    if (c<cols-1) [myConverter concat:COEFF_DELIM];
	}
	[myConverter concat:ROW_DELIM];
    }
    [myConverter concat:END_MATRIX];
    [self setParameter:paraName toStringValue:[[myConverter stringValue] cString]];
    return self;
}


- (const char*)stringValueOfParameter:(const char*)paraName;
{
  return [[myParameterTable objectForKey:[NSString jgStringWithCString:paraName]] cString];
}

/* not possible because of fracts...
- (int)intValueOfParameter:(const char*)paraName;
{
  return [[myParameterTable ObjectForKey:[NSString stringWithCString:paraName]] intValue];
}

- (double)doubleValueOfParameter:(const char*)paraName;
{
  return [[myParameterTable ObjectForKey:[NSString stringWithCString:paraName]] doubleValue];
}
*/
- (int)intValueOfParameter:(const char*)paraName;
{
    const char *tmp=[self stringValueOfParameter:paraName];
    return [[myConverter setCStringValue:tmp]intValue];
}

- (double)doubleValueOfParameter:(const char*)paraName;
{
  const char *tmp=[self stringValueOfParameter:paraName];
  return [[myConverter setCStringValue:tmp]doubleValue];
}


- (BOOL)boolValueOfParameter:(const char*)paraName;
{
  const char *tmp=[self stringValueOfParameter:paraName];
  return [[myConverter setCStringValue:tmp]boolValue];
}

- getParameter:(const char*)paraName forMatrix:aMatrix;
{
    int rows, cols, r, c;
    id tokens, cell;
    BOOL isMath = [aMatrix isKindOfClass:NSClassFromString(@"MathMatrix")];
    [aMatrix getNumberOfRows:&rows columns:&cols];
    [myConverter setStringValue:[myParameterTable objectForKey:[NSString jgStringWithCString:paraName]]];
    tokens = [myConverter tokenizeToStringsWith:BEGIN_MATRIX END_MATRIX ROW_DELIM COEFF_DELIM];
    for (r=0; r<rows; r++) {
	for (c=0; c<cols; c++) {
	    if (isMath)
		[aMatrix setDoubleValue:[[tokens objectAt:(r*cols)+c]doubleValue] at:r:c];
	    else {
		cell = [aMatrix cellAtRow:r column:c];
		if ([cell isKindOfClass:[NSButtonCell class]])
		    [cell setIntValue:[[tokens objectAt:(r*cols)+c]boolValue]];
		else
		    [cell setStringValue:[[tokens objectAt:(r*cols)+c] stringValue]];
	    }
	}
    }
    return self;
}


- makeParametersUnique;
{
/* probably not necessary, because NSDictionary doesnot have duplicate entries anyway.
    id newTable = [[NXStringTable alloc]init];
    const void  *key; 
	  void  *value; 
    NXHashState  state = [myParameterTable initState]; 
    while ([myParameterTable nextState: &state key: &key value: &value]) {
	[newTable insertKey:NXUniqueString(key) value:NXCopyStringBufferFromZone(value, (NXZone *)[self zone])];
    }
    
    [[myParameterTable freeObjects] release];
    myParameterTable = newTable;
*/
    return self;
}


- showPrefsPanel:sender;
{
    //if (!myPanel)
	//[NXApp loadNibSection: "Info.nib" owner:self];
    [myPanel makeKeyAndOrderFront:self];
    return self;
}


- ok:sender;
{
    [self writePrefs];
    return self;
}

- reset:sender;
{
    [self readPrefs];
    return self;
}


- collectPrefs;
{
    return self;
}


- displayPrefs;
{
    return self;
}


- writePrefs;
{
    if(useFile)
	[self writePrefsToFile:myFilename];
    else
	[self writePrefsToDB];
    return self;
}

- writePrefsToDB;
{
    [self collectPrefs];
    return self;
}

- writePrefsToFile:(const char*)file;
{
    if (!file) return [self savePrefsFileAs:self];
    [self collectPrefs];
    [myParameterTable writeToFile:[NSString jgStringWithCString:file] atomically:YES];
    return self;
}


- appendPrefsToString:(NSMutableString *)mutableString;
{
    StringConverter *aString = [[StringConverter alloc]init];
    JgList *stringList, *sortList;
//    char *data;
    int i, c;//, len, maxlen;
//    NSMutableString *privateStream = JGOpenMemory(NULL,0,NX_READWRITE);
    
    [self collectPrefs];
//    JGSeek(privateStream, 0L, NX_FROMSTART);
//    [myParameterTable appendToString:privateStream];
//    JGSeek(privateStream, 0L, NX_FROMSTART);
//    JGGetMemoryBuffer(privateStream, &data, &len, &maxlen);
//    [aString setStringValue:privateStream];
    [aString setStringValue:[myParameterTable description]];
    
    stringList = [aString tokenizeToStringsWith:"\n"];
    sortList = [[[OrderedList alloc]init]appendList:stringList];
    [aString release];
    
    for (i=0, c=[sortList count]; i<c; i++) {
	aString = [sortList objectAt:i];
	[mutableString appendFormat:@"%@",[aString stringValue]];
	if (i<c-1) [mutableString appendFormat:@"%s","\n"];
    }
    
    [sortList release];
//    JGCloseMemory(privateStream, NX_FREEBUFFER);
    return self;
}

- readPrefs;
{
    if(useFile)
	[self readPrefsFromFile:myFilename];
    else
	[self readPrefsFromDB];
	
    return self;
}

- readPrefsFromDB;
{
    [self makeParametersUnique];
    [self displayPrefs];
    return self;
}

- readPrefsFromFile:(const char*)file;
{
    if (!file) [self openPrefsFile:self];
    if(myParameterTable) [myParameterTable release];
    myParameterTable=[[NSMutableDictionary alloc] initWithContentsOfFile:[NSString jgStringWithCString:file]];
    [self makeParametersUnique];
    [self displayPrefs];
    return self;
}

/* not called
- readPrefsFromStream:(NSMutableString *)mutableString;
{
    if (mutableString) {
	[myParameterTable readFromStream:mutableString];
	[self makeParametersUnique];
	[self displayPrefs];
    }
    return self;
}
*/

- openPrefsFile:sender;
{
    char path[MAXPATHLEN+1];
    NSString *nspath;
    NSArray *types = [NSArray arrayWithObject:[NSString jgStringWithCString:myFiletype]];
    char *oldfile=NULL;
    id openPanel;

    if (myFilename) {
	oldfile = malloc(strlen(myFilename)+1);
	strcpy(oldfile, myFilename);
	if (rindex(myFilename, '/')) 
	    strncpy(path, myFilename, rindex(myFilename, '/')-myFilename+1);
	else
	    strcpy(path, myFilename);
    }
    else {
        nspath = [[NSBundle bundleForClass:[self class]] pathForResource:@"" ofType:[NSString jgStringWithCString:myFiletype]];
	if(nspath == nil) {
	    strcpy(path, [NSHomeDirectory() cString]);
	    strcat(path, "/Library/");
	    strcat(path, [[[NSProcessInfo processInfo] processName] cString]);
	} else strcpy(path,[nspath cString]);
    }

//#warning FactoryMethods: [OpenPanel openPanel] used to be [OpenPanel new].  Open panels are no longer shared.  'openPanel' returns a new, autoreleased open panel in the default configuration.  To maintain state, retain and reuse one open panel (or manually re-set the state each time.)
    openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:@"Open Preferences"];
    [openPanel setTreatsFilePackagesAsDirectories:YES];
    if([openPanel runModalForDirectory:[NSString jgStringWithCString:(const char *)path] file:@"" types:types]) {
	[self setFilename:[[openPanel filename] cString]];
	if([self readPrefsFromFile:myFilename])
	    return [self setUseFile:YES];
    }
    [self setFilename:oldfile];
    if(oldfile) free(oldfile);
    return nil;

}

- savePrefsFile:sender;
{
    if (!myFilename) return [self savePrefsFileAs:self];
    
    if ([self writePrefsToFile:myFilename])
	return [self setUseFile:YES];
    
    [self setFilename:NULL]; /* couldn't use this file, forget it */
    return nil;
}

- savePrefsFileAs:sender;
{
    /* this method taken from Garfinkel & Mahoney, p. 331 */
    id	panel;
    char path[MAXPATHLEN+1], *oldfile=NULL;
    NSString *nspath;
    
    /* prompt user for filename and save to that file */
    if (myFilename) {
	oldfile = malloc(strlen(myFilename)+1);
	strcpy(oldfile, myFilename);
 	if (rindex(myFilename, '/')) 
	    strncpy(path, myFilename, rindex(myFilename, '/')-myFilename+1);
	else
	    strcpy(path, myFilename);
    }
    else {
        nspath = [[NSBundle bundleForClass:[self class]] pathForResource:@"" ofType:[NSString jgStringWithCString:myFiletype]];
	if (nspath == nil) {
	    strcat(path, "/.");
	    strcat(path, myFiletype);
	    if (rindex(path, '/')) 
		[self setFilename:rindex(path, '/')+1];
	    else
		[self setFilename:path];
	} else strcpy(path,[nspath cString]);
    }

//#warning FactoryMethods: [SavePanel savePanel] used to be [SavePanel new].  Save panels are no longer shared.  'savePanel' returns a new, autoreleased save panel in the default configuration.  To maintain state, retain and reuse one save panel (or manually re-set the state each time.)
    panel = [NSSavePanel savePanel];
    [panel setRequiredFileType:[NSString jgStringWithCString:myFiletype]];
    [panel setTreatsFilePackagesAsDirectories:YES];
    if ([panel runModalForDirectory:@"" file:@""]) {
	[self setFilename:[[panel filename] cString]];
	return [self savePrefsFile:sender];
    }
    [self setFilename:oldfile];
    if(oldfile) free(oldfile);
    return nil; /*didn't save */
}

- (const char*)getDefaultValueWithName:(const char*)name;
{
  return [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString jgStringWithCString:name]] cString];
}

- (void)writeDefault:(const char*)value withName:(const char*)name;
{	
  [[NSUserDefaults standardUserDefaults] setObject:[NSString jgStringWithCString:value] forKey:[NSString jgStringWithCString:name]];
}
  

//jg The Default-Methods are very contentless and are not called! Thats why its commented out.
/*
// These are class methods to the corresponding NX... functions
+ (int) registerDefaultsVector:(const NXDefaultsVector)vector ofOwner:(const char *)owner;
{
    if (owner && vector)
#error DefaultsConversion: NXRegisterDefaults() is obsolete. Construct a dictionary of default registrations and use the NSUserDefaults 'registerDefaults:' method
	return NXRegisterDefaults(owner, vector);
    return 0;
}

+ (const char*)getDefaultValueOfOwner:(const char*)owner withName:(const char*)name;
{
    if (owner && name)
#warning DefaultsConversion: This used to be a call to NXGetDefaultValue with the owner owner.  If the owner was different from your applications name, you may need to modify this code.
	return [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithCString:name]] cString];
    return NULL;
}

+ (const char*)readDefaultOfOwner:(const char*)owner withName:(const char*)name;
{
    if (owner && name)
#warning DefaultsConversion: If you were using NXReadDefault() to avoid searching the GLOBAL domain or to search a different domain than your app domain, you must set the NSUserDefault searchlist to the appropriate domains and use NSUserDefaults 'objectForKey:'
	return ([[NSUserDefaults standardUserDefaults] synchronize], [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithCString:name]] cString]);
    return NULL;
}

+ (int)setDefault:(const char*)value ofOwner:(const char*)owner withName:(const char*)name;
{
    if (owner && name && value)
#warning DefaultsConversion: This used to be a call to NXSetDefault with the owner owner.  If the owner was different from your applications name, you may need to modify this code.
	return [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:value] forKey:[NSString stringWithCString:name]];
    return 0;
}

+ (int)writeDefault:(const char*)value ofOwner:(const char*)owner withName:(const char*)name;
{
    if (owner && name && value)
#warning DefaultsConversion: [<NSUserDefaults> setObject:...forKey:...] used to be NXWriteDefault(owner, name, value). Defaults will be synchronized within 30 seconds after this change.  For immediate synchronization, call '-synchronize'. Also note that the first argument of NXWriteDefault is now ignored; to write into a domain other than the apps default, see the NSUserDefaults API.
	return [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:value] forKey:[NSString stringWithCString:name]];
    return 0;
}

+ (int)writeDefaultsVector:(NXDefaultsVector)vector ofOwner:(const char *)owner;
{
    if (owner && vector)
#error DefaultsConversion: NXWriteDefaults() is obsolete; use 'setObject:forKey:' instead
	return NXWriteDefaults(owner, vector);
    return 0;
}

+ (const char*)updateDefaultOfOwner:(const char*)owner withName:(const char*)name;
{
    if (owner && name)
	return [[NSUserDefaults standardUserDefaults] synchronize];;
    return NULL;
}

+ (void)updateDefaults;
{
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int)removeDefaultOfOwner:(const char*)owner withName:(const char*)name;
{
    if (owner && name)
#warning DefaultsConversion: [<NSUserDefaults> removeObjectForKey:...] used to be NXRemoveDefault(owner, name). Defaults will be synchronized within 30 seconds after this change.  For immediate synchronization, call '-synchronize'. Also note that the first argument of NXRemoveDefault is now ignored; to write into a domain other than the apps default, see the NSUserDefaults API.
	return [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithCString:name]];
    return 0;
}

+ (const char *)setDefaultsUser:(const char *)newUser;
{
    if (newUser)
#error DefaultsConversion: NXSetDefaultsUser() is obsolete; use [[NSUserDefaults alloc] initWithUser:<user>] to read another users defaults
	return NXSetDefaultsUser(newUser);
    return NULL;
}


// instance methods for default database maintenance 
- (int) registerDefaultsVector:(const NXDefaultsVector)vector;
{
    return [[self class] registerDefaultsVector:vector ofOwner:myOwnerName];
}

- (const char*)getDefaultValueWithName:(const char*)name;
{
    return [[self class] getDefaultValueOfOwner:myOwnerName withName:name];
}

- (const char*)readDefaultWithName:(const char*)name;
{
    return [[self class] readDefaultOfOwner:myOwnerName withName:name];
}

- (int)setDefault:(const char*)value withName:(const char*)name;
{
    return [[self class] setDefault:value ofOwner:myOwnerName withName:name];
}

- (int)writeDefault:(const char*)value withName:(const char*)name;
{
    return [[self class] writeDefault:value ofOwner:myOwnerName withName:name];
}

- (int)writeDefaultsVector:(NXDefaultsVector)vector;
{
    return [[self class] writeDefaultsVector:vector ofOwner:myOwnerName];
}

- (const char*)updateDefaultWithName:(const char*)name;
{
    return [[self class] updateDefaultOfOwner:myOwnerName withName:name];
}

- (void)updateDefaults;
{
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)removeDefaultWithName:(const char*)name;
{
    return [[self class] removeDefaultOfOwner:myOwnerName withName:name];
}

- setDefaultsUser:(const char *)newUser;
{
    return [[self class] setDefaultsUser:newUser];
}
*/
@end
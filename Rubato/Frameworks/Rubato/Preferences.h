/* Preferences.h */

#import <Foundation/NSUserDefaults.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>

#define DEFAULT_FILETYPE "prefs"

@interface Preferences : JgObject
{
    id	myOwner;
    const char *myOwnerName;
    char *myFilename;
    const char* myFiletype;
    id	myPanel;
    StringConverter *myConverter;
    NSMutableDictionary *myParameterTable;
    BOOL useFile;
}

- init;
- (void)dealloc;
- (void)awakeFromNib;

- setOwner:anObject;
- owner;
- setPanel:aPanel;
- panel;
- (const char*)ownerName;
- setFilename:(const char *)aFilename;
- (NSString *)filename;
- setUseFile:(BOOL)flag;
- (BOOL)useFile;

- setParameter:(const char*)paraName toStringValue:(const char*)paraVal;
- setParameter:(const char*)paraName toIntValue:(int)paraVal;
- setParameter:(const char*)paraName toDoubleValue:(double)paraVal;
- setParameter:(const char*)paraName toBoolValue:(BOOL)paraVal;
- setParameter:(const char*)paraName toMatrix:aMatrix;
- (const char*)stringValueOfParameter:(const char*)paraName;
- (int)intValueOfParameter:(const char*)paraName;
- (double)doubleValueOfParameter:(const char*)paraName;
- (BOOL)boolValueOfParameter:(const char*)paraName;
- getParameter:(const char*)paraName forMatrix:aMatrix;

- makeParametersUnique;

- showPrefsPanel:sender;
- ok:sender;
- reset:sender;

- collectPrefs;
- displayPrefs;

- writePrefs;
- writePrefsToDB;
- writePrefsToFile:(const char*)file;
- appendPrefsToString:(NSMutableString *)mutableString;
- readPrefs;
- readPrefsFromDB;
- readPrefsFromFile:(const char*)file;
//- readPrefsFromStream:(NSMutableString *)mutableString;

- openPrefsFile:sender;
- savePrefsFile:sender;
- savePrefsFileAs:sender;

- (const char*)getDefaultValueWithName:(const char*)name;
- (void)writeDefault:(const char*)value withName:(const char*)name;
//jg The Default-Methods are very contentless and are not called! Thats why its commented out.
/*
// These are class methods to the corresponding NX... functions 
+ (int) registerDefaultsVector:(const NXDefaultsVector)vector ofOwner:(const char *)owner;
+ (const char*)getDefaultValueOfOwner:(const char*)owner withName:(const char*)name;
+ (const char*)readDefaultOfOwner:(const char*)owner withName:(const char*)name;
+ (int)setDefault:(const char*)value ofOwner:(const char*)owner withName:(const char*)name;
+ (int)writeDefault:(const char*)value ofOwner:(const char*)owner withName:(const char*)name;
+ (int)writeDefaultsVector:(NXDefaultsVector)vector ofOwner:(const char *)owner;
+ (const char*)updateDefaultOfOwner:(const char*)owner withName:(const char*)name;
+ (void)updateDefaults;
+ (int)removeDefaultOfOwner:(const char*)owner withName:(const char*)name;
+ (const char *)setDefaultsUser:(const char *)newUser;

// instance methods for default database maintenance 
- (int) registerDefaultsVector:(const NXDefaultsVector)vector;
- (const char*)getDefaultValueWithName:(const char*)name;
- (const char*)readDefaultWithName:(const char*)name;
- (int)setDefault:(const char*)value withName:(const char*)name;
- (int)writeDefault:(const char*)value withName:(const char*)name;
- (int)writeDefaultsVector:(NXDefaultsVector)vector;
- (const char*)updateDefaultWithName:(const char*)name;
- (void)updateDefaults;
- (int)removeDefaultWithName:(const char*)name;
- setDefaultsUser:(const char *)newUser;
*/

@end
/* RubatoPreferences.h */

#import "Preferences.h"

#define RUBETTE_DIR_NAME "RubetteDir"
#define OPERATOR_DIR_NAME "OperatorDir"
#define STEMMA_DIR_NAME "StemmaDir"
#define WEIGHT_DIR_NAME "WeightDir"
#define MUSIC_FILE_DIR_NAME "MusicFileDir"
#define RUBATO_PREFS_FILE_TYPE "RubatoPrefs"

@interface RubatoPreferences : Preferences
{
    id	rubetteDirField;
    id	operatorDirField;
    id	musicDirField;
    id	stemmaDirField;
    id	weightDirField;
}


- init;
- (void)awakeFromNib;

- getRubetteDirectory:sender;
- getOperatorDirectory:sender;
- getStemmaDirectory:sender;
- getWeightDirectory:sender;
- getFileDirectory:sender;

- (NSString *)rubetteDirectory;
- (NSString *)operatorDirectory;
- (NSString *)stemmaDirectory;
- (NSString *)weightDirectory;
- (NSString *)fileDirectory;

- collectPrefs;
- displayPrefs;
- writePrefsToDB;
- readPrefsFromDB;

@end
#import "PrediBaseDocument.h"

@interface PapaDocument : PrediBaseDocument
{
}
+ (NSArray *)readableTypes;
+ (NSArray *)writableTypes;
+ (BOOL)isNativeType:(NSString *)type;

- (BOOL)loadOldPrediBase:(NSString *)fileName;
- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType;
- (BOOL)loadPListFile:(NSString *)aFilename; // jg added
- (BOOL)loadMidiFile:(NSString *)aFilename;
- (BOOL)loadScoreFile:(NSString *)aFilename;
@end


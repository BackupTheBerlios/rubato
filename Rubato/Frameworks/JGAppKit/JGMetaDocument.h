#import <AppKit/AppKit.h>
@interface JGMetaDocument : NSDocument
{
  NSMutableDictionary *subDocuments;
}
- (NSMutableDictionary*) subDocuments;
- (void) setSubDocuments:(NSMutableDictionary*)newSubDocuments;
- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType;
@end



// is there code in Gnustep?
//@interface DocumentProxy : NSProxy
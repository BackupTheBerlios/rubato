#import "JGSubDocument.h"

@interface JGActivationSubDocumentNode : JGSubDocumentNode
{}
// overridden:
  // remove child from subDocActivationList
- (void)removeChildDocument:(NSDocument *)document;
@end

@interface JGActivationSubDocument : JGSubDocument
{
  NSMutableArray *subDocActivationList; //Array of Documents (no id twice)
}

- (void)setActiveSubDocument:(NSDocument *)doc;
- (NSDocument *)lastActiveSubDocument;
- (NSDocument *)lastActiveSubDocumentBut:(int)but; // but=0 -> activeSubDocument
- (NSDocument *)lastActiveSubDocumentOfClassName:(NSString *)name;
- (void)removeDocumentFromActivationList:(NSDocument *)document;

@end

@interface JGActivationSubDocument (JgObjectCompatibility)  // copy of JgObject methods.
/*
+ (NSString *)getClassName;
- copyWithZone:(NSZone *)zone;
// catch legacy calls to jgCopyWithZone
- jgCopyWithZone:(NSZone *)zone;
*/
- (NSString *)name;

@end

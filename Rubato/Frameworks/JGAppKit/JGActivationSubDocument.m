#import "JGActivationSubDocument.h"

@implementation JGActivationSubDocumentNode 
// overridden:
  // remove child from subDocActivationList
- (void)removeChildDocument:(NSDocument *)aDocument;
{
  JGActivationSubDocument *doc=[self document];
  [doc removeDocumentFromActivationList:aDocument];
  [super removeChildDocument:aDocument];
}
@end


@implementation JGActivationSubDocument
#ifdef DEBUG_INITIALIZE
+ (void)initialize;
{
  NSLog(@"initialize JGActivationSubDocument");
}
#endif
+ (id)subDocumentNodeClass;
{
  return [JGActivationSubDocumentNode class];
}

- (id)init;
{
  [super init];
  subDocActivationList=[[NSMutableArray alloc] init];
  return self;
}
- (void)dealloc;
{
  [subDocActivationList release];
  [super dealloc];
}

- (void)setActiveSubDocument:(NSDocument *)doc;
{
  if ([subDocActivationList containsObject:doc])
    [subDocActivationList removeObject:doc];
  [subDocActivationList addObject:doc];
}
- (NSDocument *)lastActiveSubDocument;
{
  return [subDocActivationList lastObject]; // might be nil
}
- (NSDocument *)lastActiveSubDocumentBut:(int)but;
{
  int c=[subDocActivationList count]-1-but;
  if (c>=0) return [subDocActivationList objectAtIndex:c];
  else return nil;
}
- (NSDocument *)lastActiveSubDocumentOfClassName:(NSString *)name;
{
  id current;
  NSEnumerator *e=[subDocActivationList reverseObjectEnumerator];
  current=[e nextObject];
  while (current=[e nextObject])
    if ([name isEqualToString:NSStringFromClass([current class])])
      return current;
  return nil;
}

- (void)removeDocumentFromActivationList:(NSDocument *)document;
{
  if ([subDocActivationList containsObject:document])
    [subDocActivationList removeObject:document];
}


- (void)windowDidBecomeKey:(NSNotification *)notification;
{
  id parent=[[subDocumentNode parentDocumentNode] document];
  if (parent && [parent isKindOfClass:[JGActivationSubDocument class]]) {
    [parent setActiveSubDocument:self];
  }
}

@end


@implementation JGActivationSubDocument (JgObjectCompatibility)
/*
+ (NSString *)getClassName;
{
  return NSStringFromClass([self class]);
}

- copyWithZone:(NSZone *)zone;
{
//  return [[[self class] allocWithZone:zone] init]; 
  return NSCopyObject(self,0,zone); // shallow copy
}

- jgCopyWithZone:(NSZone *)zone; // in case legacy code calls this method, we catch it here.
{
  return [self copyWithZone:zone];
}
*/
- (NSString *)name;
{
  return NSStringFromClass([self class]);
}

@end

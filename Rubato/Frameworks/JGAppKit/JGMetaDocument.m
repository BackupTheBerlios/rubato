#import "JGMetaDocument.h"

/*
@implementation DocumentControllerController
{
  NSMutableDictionary *documentControllers;
}
- init;
{
  documentControllers=[[NSMutableDictionary alloc] init];
  return self;
}
- (void)dealloc;
{
  [documentControllers release];
}
- (NSMutableDictionary *)documentControllers;
{
  return documentControllers;
}
@end

//?
@implementation LazyObject
{
  id object;
  id callbackId;
}
@end


@implementation JGMetaDocument
{
  NSMutableDictionary *documentInfo;
  NSMutableDictionary *documentControllerInfo;
  NSMutableDictionary *fileNames;
  NSMutableDictionary *documents;
  NSMutableDictionary *documentControllers;
}
//- (NSString *)fileNameForKey:(NSString *)key;
//- (NSDocumentController *)documentControllerForKey:(NSString *)key;
//- (NSDocument *)documentForKey:(NSString *)key;

- (NSDocumentController *)documentControllerForKey:(NSString *)key;
{
  [documentControllers setObject:controller forKey:key];
}
- (void)setDocumentController:(NSDocumentController *)controller forKey:(NSString *)key;
{
  [documentControllers setObject:controller forKey:key];
}

- (NSDocument *)documentControllerForKey:(NSString *)key;
{
  NSDocument *doc=[documentControllers objectForKey:key];
  if (!doc) {
    id info=[documentControllerInfo objectForKey:key];
    if (info) {
      doc=[self makeDocumentControllerWithInfo:info];
      if (doc)
        [documents setObject:doc forKey:key];
    }
  }
  return doc;
}
  
- (NSDocument *)documentForKey:(NSString *)key;
{
  NSDocument *doc=[documents objectForKey:key];
  if (!doc) {
    id info=[documentInfo objectForKey:key];
    if (info) {
      doc=[self makeDocumentWithInfo:info];
      if (doc)
        [documents setObject:doc forKey:key];
    }
  }
  return doc;
}
@end
*/

#import "PrediBaseDocumentBasics.h"
#import "RubatoController.h"

// UndoManager: this class only looks at the top level of persistDict (to be implemented)
@implementation PrediBaseDocumentBasics

- (NSArray *)toOneRelationshipKeys;
{
    static NSArray *keys=nil;
    if (!keys)
        keys=[[NSArray alloc] initWithObjects:@"persistDict",@"tmpDict",@"selected",nil];
    return keys;
}

    
/* standard object methods to be overridden */
- init
{
  [super init];

  persistDict=[[JGFileDictionary alloc] init];
  tmpDict=[[NSMutableDictionary alloc] init];

//  customObjectDictionary=[[NSMutableDictionary alloc] init];
//  predicateDictionary=[[NSMutableDictionary alloc] init];
//  weightDictionary=[[NSMutableDictionary alloc] init];
  selected=nil;
  return self;
}


- (void)dealloc {
  [persistDict release];
  [tmpDict release];
//  [customObjectDictionary release];
//  [predicateDictionary release];
//  [weightDictionary release];
  [super dealloc];
}

- (void)setPersistDict:(JGFileDictionary *)newDict;
{
    BOOL good=[newDict isKindOfClass:[JGFileDictionary class]];
    NSAssert(good,@"PredibaseDocumentBasics setPersistDict: newDict is not kindOfClass JGFileDictionary");
    if (good) {
        [newDict retain];
        [persistDict release];
        persistDict=newDict;
    }
}
- (JGFileDictionary *)persistDictDictWithKey:(NSString *)key create:(BOOL)yn;
{
    id ret=[persistDict objectForKey:key];
    if (yn && !ret) { // UndoManager!
         ret= [[[JGFileDictionary alloc] init] autorelease];
        [persistDict setObject:ret forKey:key];
    }
    return ret;
}
- (NSMutableDictionary *)tmpDictDictWithKey:(NSString *)key create:(BOOL)yn;
{
    id ret=[tmpDict objectForKey:key];
    if (yn && !ret) {
        ret= [[[NSMutableDictionary alloc] init] autorelease];
        [tmpDict setObject:ret forKey:key];
    }
    return ret;
}

// The resulting file structure is:
// File.rub
//   Predicates
//     Metro 1
//   Weights
//     Metro 1
- (JGFileDictionary *)predicateDictionary;
{
    return [self persistDictDictWithKey:@"Predicates" create:YES];
}
- (JGFileDictionary *)weightDictionary;
{
    return [self persistDictDictWithKey:@"Weights" create:YES];
}

- (NSMutableDictionary *)customObjectDictionary;
{
    return [self tmpDictDictWithKey:@"CustomObjects" create:YES];
}

// overridden in PrediBaseDocument (configurable)
- (id/* <Distributor> */)distributor;
{
  return [[NSApplication sharedApplication] delegate];
}

- (id)selected;
{
  return selected;
}

- (void)setSelected: aPredicate;
{
  [aPredicate retain];
  [selected release];
  selected=aPredicate;
}

// Rubette-Object management:
- (id)customObjectForKey:(NSString *)key;
{
  return [[self customObjectDictionary] objectForKey:key];
}

- (void)setCustomObject:(id)object forKey:key;
{ // UndoManager?
  [[self customObjectDictionary] setObject:object forKey:key];
}

- (void)removeCustomObjectForKey:(NSString *)key;
{// UndoManager!
  [[self customObjectDictionary] removeObjectForKey:key];
}

- (id)predicateForKey:(NSString *)key;
{
  return [[self predicateDictionary] objectForKey:key];
}
- (void)setPredicate:(id)object forKey:(NSString *)key;
{// UndoManager!
  [self willSetPredicate:object forKey:key];
  [[self predicateDictionary] setObject:object forKey:key];
  [self didSetPredicate:object forKey:key];
}
- (void)removePredicateForKey:(NSString *)key;
{// UndoManager!
  [[self predicateDictionary] removeObjectForKey:key];
}

- (id)weightForKey:(NSString *)key;
{// UndoManager!
  return [[self weightDictionary] objectForKey:key];
}
- (void)setWeight:(id)object forKey:(NSString *)key;
{// UndoManager!
  [[self weightDictionary] setObject:object forKey:key];
}
- (void)removeWeightForKey:(NSString *)key;
{// UndoManager!
  [[self weightDictionary] removeObjectForKey:key];
}

- (NSArray *)weightList;
{
  return [[self weightDictionary] allValues];
}

#define LOAD_HANDLER NSRunAlertPanel([localException name], \
                                        [localException reason],\
                                        @"", nil, nil);\
                     returnValue = nil;

/*
- (id)rootObjectForPrediBase;
{
  return [NSArray arrayWithObjects:predicateDictionary,weightDictionary,nil];
}

- (void)setPrediBaseFromRootObject:(id)root;
{
  predicateDictionary = [[root objectAtIndex:0] retain];
  weightDictionary = [[root objectAtIndex:1] retain];
}
*/

- (NSFileWrapper *)fileWrapperRepresentationOfType:(NSString *)type;
{
    NSFileWrapper *w;
//    NSLog(@"saving fileDictionary: %@",persistDict);
    w=[persistDict updatedDirectoryWrapper];
    return w;
}
- (BOOL)loadFileWrapperRepresentation:(NSFileWrapper *)wrapper ofType:(NSString *)type;
{
    if ([wrapper isDirectory]) {
        [persistDict release];
        persistDict=[[JGFileDictionary alloc] initWithDirectoryWrapper:wrapper fileWrapperCoder:self keyMapper:[[[JGFileDictionaryKeyMapper alloc] init] autorelease]];
//        NSLog(@"loaded fileDictionary: %@",fileDictionary);
        return (persistDict!=nil);
    }
    return NO;
}

// call backs from within persistDict methods
// put here for later fill ins, when using not NSArchiver.
// e.g. use [[self distributor] archiverForType:aType] later!
- (id)fileDictionary:(id)fileDict objectForFileWrapper:(NSFileWrapper *)fileWrapper;
{
    id ret=[fileDict fileDictionary:fileDict objectForFileWrapper:fileWrapper];
    return ret;
}
- (NSFileWrapper *)fileDictionary:(id)fileDict fileWrapperForObject:(id)obj fileKey:(NSString *)fileKey;
{
    NSFileWrapper *ret=[fileDict fileDictionary:fileDict fileWrapperForObject:obj fileKey:fileKey];
    return ret;
}

- (NSData *)dataRepresentationOfType:(NSString *)aType;
{
  NSData *data=nil;
  id returnValue = self; /* this variable is used in the load handler macro */
  id<CommonArchiverInterface> archiverClass=[[self distributor] archiverForType:aType];
  id root=[persistDict retain];//[[self rootObjectForPrediBase] retain];
  
  if (archiverClass && [aType hasPrefix:@"PrediBase"]) {
    NS_DURING
      data=[[archiverClass archivedDataWithRootObject:root] retain];
    NS_HANDLER
    LOAD_HANDLER  /* a load handler macro in macros.h */
    NS_ENDHANDLER /* end of handler */
    if (!returnValue)
      data=nil;
  }
  [root release];
  return [data autorelease];
}


- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type;
{
  id<CommonUnarchiverInterface> unarchiverClass=[[self distributor] unarchiverForType:type];
  if (unarchiverClass && [type hasPrefix:@"PrediBase"]) {
        id returnValue = self; /* this variable is used in the load handler macro */
        id root;
//        [predicateDictionary release]; 
//        [weightDictionary release];
//        predicateDictionary=nil;
//        weightDictionary=nil;
        NS_DURING
          root=[unarchiverClass unarchiveObjectWithData:data];
          [self setPersistDict:root];
//          [self setPrediBaseFromRootObject:root];
        NS_HANDLER
        LOAD_HANDLER  /* a load handler macro in macros.h */
//            [persistDict removeAllObjects];
//          predicateDictionary = [[NSMutableDictionary alloc] init];
//          weightDictionary = [[NSMutableDictionary alloc] init];
        NS_ENDHANDLER /* end of handler */
        if (returnValue) return YES;
        else return NO;
    }
    return NO;
}

// do this?
//  [NSNotification notificationWithName:@"PrediBaseWillSetPredicate" object:self
//                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:object,@"NewPredicate",key,@"Key"]];

- (void)willSetPredicate:(id)object forKey:(NSString *)key; // hook
{
}
- (void)didSetPredicate:(id)object forKey:(NSString *)key; // hook
{
}
@end

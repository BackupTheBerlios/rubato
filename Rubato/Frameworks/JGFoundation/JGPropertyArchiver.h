/* DTXDenotatorArchiver.h created by jg on Wed 16-Aug-2000 */

#import <Foundation/Foundation.h>

@interface JGPropertyArchiver : NSObject
{
  // steers processing
  BOOL addressAsString; /*" (YES) nameForObject: calls stringforObject: if YES "*/
  BOOL addReferencedObjects;  /*" unset this, if not interested in a Set of referenced objects and calling "*/
  BOOL reallyCreateRepresentation; /*" unset this, if only interested in referenced objects "*/
  BOOL returnReferences; /*" unset this, if you want the representation of referencedObjects returned instead of their address in method -representationForObject: "*/
  int maxArchivationDepth;    /*" stop archiving at this level, if not 0 "*/
  int maxRepresentationDepth; /*" 0 (default) means deliberately many set this to 1 to get a flat dictionary "*/
  
  // results
  NSMutableDictionary *archivedObjects; /*" keeps the representation of objects for address-Keys "*/
  NSMutableDictionary *referencedObjects;
  NSMutableArray *topObjects;
  int maxArchivedDepth;

  // used during processing
  int archivationDepth;
  NSMutableDictionary *representationReplacement;
  NSNumber *lastNumber; // fastenes numberForId, nameForId pairs
  id lastId;
}

- (id)init;
- (void)dealloc;

  /*" Access to Flags "*/
- (BOOL) addressAsString;
- (void) setAddressAsString:(BOOL)newAddressAsString;

- (BOOL) addReferencedObjects;
- (void) setAddReferencedObjects:(BOOL)newAddReferencedObjects;

- (BOOL) reallyCreateRepresentation;
- (void) setReallyCreateRepresentation:(BOOL)newReallyCreateRepresentation;

- (BOOL) returnReferences;
- (void) setReturnReferences:(BOOL)newReturnReferences;

- (int) maxArchivationDepth;
- (void) setMaxArchivationDepth:(int)newMaxArchivationDepth;

- (int) maxRepresentationDepth;
- (void) setMaxRepresentationDepth:(int)newMaxRepresentationDepth;


/*" Access to Results "*/
- (NSMutableDictionary *)referencedObjects;
- (NSMutableDictionary *)archivedObjects;
- (NSMutableArray *)topObjects;
- (int) maxArchivedDepth;

  /*" convenience Methods"*/
- (BOOL)containsObject:(id)obj;


/*" customizable behaviour by overwriting "*/
- (id)nameForObject:(id)obj;
- (NSString *)stringForObject:(id)obj;
- (id)idForObject:(id)obj;
- (id)objectForId:(id)identification;
- (NSString *)classKey;
- (NSString *)idKey;
- (id)classInfoForObject:(id)obj;

/*" must be overridden "*/
- (void)addToDictionary:(NSMutableDictionary *)dict representationForObject:(id)obj;

/*" Methods used in Building a representation of some objects. "*/
- (id)representationForObject:(id)obj;
- (id)representationForObject:(id)obj forceReference:(BOOL)forceReference;
- (void)addObject:(id)obj duplicates:(BOOL)duplicates;
- (void)declareRootObject:(id)obj;
- (void)addRootObject:(id)obj;
- (void)addNamesForReferencedObjects;

  /*" Derived Methods "*/
- (void)declareRootObjects:(NSArray *)objects;
- (void)addRootObjects:(NSArray *)objects;

@end

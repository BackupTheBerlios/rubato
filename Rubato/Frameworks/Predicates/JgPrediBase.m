/* JgPrediBase.m created by jg on Wed 23-Jun-1999 */

#import "JgPrediBase.h"
#import <Predicates/predikit.h>
#import <RubatoDeprecatedCommonKit/JGNXCompatibleUnarchiver.h>

// Warning: weightList is not in Predicate Format, but a RefCountList of Weights.
// Using JGNXCompatibleUnarchiver, it is o.k.
#define WEIGHTS

#ifdef WEIGHTS
#import <RubatoDeprecatedCommonKit/commonkit.h>
#endif

#define formsKey @"FormList"
#define predsKey @"PredicateList"
#define rubettesKey @"RubetteList"
#define weightsKey @"WeightList"
#define otherFormsKey @"ReferencedFormList"

@implementation JgPrediBase
- init;
{
  return [super init];
}

- (void)newPlist;
{
  if (plist) [plist release];
  plist=[NSMutableDictionary new];
}

- (void)releasePredLists;
{
  if(myFormList) [myFormList release];
  if(myPredicateList) [myPredicateList release];
  if(myRubetteList) [myRubetteList release];
  if(myWeightList) [myWeightList release];
  if(myOtherForms) [myOtherForms release];
  if(myAddresses) [myAddresses release];

  myFormList=nil;
  myPredicateList=nil;
  myRubetteList=nil;
  myWeightList=nil;
  myOtherForms=nil;
  myAddresses=nil;
}

- (int) readPlist:(NSString *)filename;
{
  if (plist) [plist release];
  plist=[NSMutableDictionary dictionaryWithContentsOfFile:filename];
  if (!plist) return 0;
  else return 1;
}

- (void)writePlist:(NSString *)filename;
{
  if (plist) [plist writeToFile:filename atomically:YES];
}

- (void)readPred:(NSString *)filename;
{
  NSUnarchiver *myUnarchiver;
  NSData *myData=[NSData dataWithContentsOfFile:filename];
  myUnarchiver= [[JGNXCompatibleUnarchiver alloc] initForReadingWithData:myData];
  [myUnarchiver decodeClassName:@"Object" asClassName:@"NSObject"];

  [self releasePredLists];
  myPredicateList=[[myUnarchiver decodeObject] retain];
  myFormList=[[myUnarchiver decodeObject] retain];
  myRubetteList=[[myUnarchiver decodeObject] retain];
#ifdef WEIGHTS
  myWeightList=[[myUnarchiver decodeObject] retain];
#else
  myWeightList=[[NSMutableArray alloc] init];
#endif

  [myUnarchiver release];
  [myData release];
}

- (void)writePred:(NSString *)filename;
{
  id myData;
  NSArray *a=[NSArray arrayWithObjects:myPredicateList,myFormList,myRubetteList,
#ifdef WEIGHTS
 myWeightList,
#endif
    nil];
  myData=[NSArchiver archivedDataWithRootObject:a];
  [myData writeToFile:filename atomically:YES];
}

- (void)plistToPreds;
{
  id pl;
  pl=[plist objectForKey:formsKey];
  [myFormList release]; myFormList=[GenericPredicate jgNewFromPropertyList:pl];
  pl=[plist objectForKey:predsKey];
  [myPredicateList release]; myPredicateList=[GenericPredicate jgNewFromPropertyList:pl];
  pl=[plist objectForKey:rubettesKey];
  [myRubetteList release]; myRubetteList=[GenericPredicate jgNewFromPropertyList:pl];
#ifdef WEIGHTS
  pl=[plist objectForKey:weightsKey];
  [myWeightList release];
//jg! myWeightList=[GenericPredicate jgNewFromPropertyList:pl];
  myWeightList=[[NSMutableArray alloc] init];
#endif
}

- (void)predsToPlist;
{
  dictstruct dicts;
  dicts.addresses=[[JGAddressDictionary alloc] init];
  dicts.forms=[NSMutableDictionary new];

  [self newPlist];
  if (myFormList) [plist setObject:[myFormList jgToPropertyList] forKey:formsKey];
  if (myPredicateList)
    [plist setObject:[myPredicateList jgToPropertyListWithDicts:&dicts] forKey:predsKey];
  if (myRubetteList) [plist setObject:[myRubetteList jgToPropertyList] forKey:rubettesKey];
#ifdef WEIGHTS
//jg!  if (myWeightList) [plist setObject:[myWeightList jgToPropertyList] forKey:weightsKey];
  if (myWeightList) [plist setObject:[NSMutableArray new] forKey:weightsKey];
#endif
  [plist setObject:dicts.forms forKey:otherFormsKey];
}

// to access the forms, with which the praedikates are created.
- (void)setFormManager:aManager;
{
  [GenericPredicate setFormManager:aManager];
}

- (id)predicateList;
{
  return myPredicateList;
}
- (id)formList;
{
  return myFormList;
}
- (id)rubetteList;
{
  return myRubetteList;
}
- (id)weigthList;
{
  return myWeightList;
}


@end

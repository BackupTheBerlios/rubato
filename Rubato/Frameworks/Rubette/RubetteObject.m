#import "RubetteObject.h"
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <RubatoDeprecatedCommonKit/JGList.h>
#import <Predicates/predikit.h>
//#import <JGFoundation/JGLogUnarchiver.h>

#import "RubetteDriver.h"
#import <Predicates/PrediBaseDocument.h>
#import <Predicates/FormManager.h>
#import <Rubato/RubatoController.h>
#import "Weight.subproj/Weight.h"

@implementation RubetteObject

+ (const char *)rubetteName;
{
    return "Default";
}

+ (const char *)rubetteVersion;
{
    return "1.0";
}

+ (spaceIndex) rubetteSpace;
{
    return 0;
}

// jg new 17.6.2002
- (spaceIndex) rubetteSpace;
{
  return [[extendedRubetteDriver class]rubetteSpace];
}

- (NSArray *)toOneRelationshipKeys;
{
    static NSArray *keys=nil;
    if (!keys)
        keys=[[NSArray alloc] initWithObjects:@"myRubetteData",@"foundPredicates",@"lastFoundPredicates",@"myWeight",nil];
    return keys;
}

- (id)init;
{
   [super init];
   myConverter = [[StringConverter alloc]init];
   myListForm=[CompoundForm listForm];
   myValueForm=[SimpleForm valueForm];

   myWeight = nil;
   foundPredicates=nil;
   lastFoundPredicates=nil;
   myWeight=nil;
   extendedRubetteDriver=nil;
   return self;
}

- (id)initWithExtendedRubetteDriver:(id<ExtendedRubetteDriver>)rubetteDriver;
{
  [self init];
  extendedRubetteDriver=[rubetteDriver retain];
  [self setFormsWithFormManager:[[rubetteDriver distributor] globalFormManager]];
  return self;
}
  
- (void)dealloc;
{
  [self setLastFoundPredicates:nil];
  [myConverter release];
  [extendedRubetteDriver release];
  [super dealloc];
}

- (void)setFormsWithFormManager:(id)gFormManager;
{
  /*
  myListForm = [[gFormManager formList] getFirstPredicateOfNameString:"RubetteValueListForm"];
  if (!myListForm) {
      myListForm = [[CompoundForm allocWithZone:[self zone]]init];
      [myListForm setTypeString:type_List];
      [myListForm setNameString:"RubetteValueListForm"];
      [myListForm setLocked:YES];
      [myListForm setAllowsToChangeName:YES];
      [myListForm setAllowsToChangeType:NO];
      [gFormManager addForm:myListForm];
  }

  myValueForm = [[gFormManager formList]  getFirstPredicateOfNameString:"RubetteValueForm"];
  if (!myValueForm) {
      myValueForm = [[SimpleForm allocWithZone:[self zone]]init];
      [myValueForm setTypeString:type_String];
      [myValueForm setNameString:"RubetteValueForm"];
      [myValueForm setLocked:YES];
      [myValueForm setAllowsToChangeName:YES];
      [myValueForm setAllowsToChangeType:YES];
      [gFormManager addForm:myValueForm];
  }
   */
}

- (id<ExtendedRubetteDriver>) extendedRubetteDriver
{
	return extendedRubetteDriver;
}

- (void) setExtendedRubetteDriver:(id<ExtendedRubetteDriver>)newExtendedRubetteDriver
{
	[newExtendedRubetteDriver retain];
	[extendedRubetteDriver release];
	extendedRubetteDriver = newExtendedRubetteDriver;
}

- (void)setInitialRubetteData;
{
  if (!myRubetteData) {
    myRubetteData=[[myListForm makePredicateFromZone:[self zone]]setNameString:[[extendedRubetteDriver rubetteKey] cString]];
    [self setRubetteData:myRubetteData];
  }
}

- (id)listForm;
{
  return myListForm; 
}
- (id)valueForm;
{
  return myValueForm;
}

- (id)rubetteData;
{
  return myRubetteData;
}
- (void)setRubetteData:(id)fp;
{
  [fp retain];
  [myRubetteData release];
  myRubetteData=fp;
}
- (id)foundPredicates;
{
  return foundPredicates;
}
- (void)setFoundPredicates:(id)fp;
{
  [fp retain];
  [foundPredicates release];
  foundPredicates=fp;
}
- (id)lastFoundPredicates;
{
  return lastFoundPredicates;
}
- (void)setLastFoundPredicates:(id)fp;
{
  [fp retain];
  [lastFoundPredicates release];
  lastFoundPredicates=fp;
}

- (id)weight;
{
  return myWeight;
}
- (void)setWeight:(id)weight;
{
  [weight retain];
  [myWeight release];
  myWeight=weight;
}

- (void)readCustomData;
{
}

- (void)writeCustomData;
{
}


- (void)newWeight;
{
  [self newWeightWithName:@"no name"];
}

- (void)newWeightWithName:(NSString *)name;
{
//    if (myWeight) [self writeWeight];
  Weight *newWeight;
    newWeight = [[Weight alloc] init]; // jgrelease
    [newWeight setSpaceTo:[self rubetteSpace]];
    [newWeight setRubetteName:[extendedRubetteDriver rubetteName]];
    [newWeight setNameString:[name cString]];
  [self setWeight:newWeight];
  [extendedRubetteDriver writeWeightParameters];
}

- (void)getWeightFromPrediBase;
{
  Weight *w=[[extendedRubetteDriver prediBase] weightForKey:[extendedRubetteDriver rubetteKey]];
  [self setWeight:w];
  if (w) {
    [extendedRubetteDriver readWeightParameters];
  }
}
- (void)setWeightToPrediBase;
{
  id w=[self weight];
  if (w)
    [[extendedRubetteDriver prediBase] setWeight:w forKey:[extendedRubetteDriver rubetteKey]];
  else
    [[extendedRubetteDriver prediBase] removeWeightForKey:[extendedRubetteDriver rubetteKey]];
}

/*
- (void)readWeightFromList:(NSMutableArray *)weightList;
{
    id weight;
    // only search for weight object if my weight it's not myWeight 
    if ([weightList indexOfObject:myWeight]==NSNotFound){
        int i, c = [weightList count];
        [myWeight release];
        myWeight = nil;

        [myConverter setStringValue:[extendedRubetteDriver rubetteKey]];
        for (i=0; i<c && !myWeight;i++) {
            weight = [weightList objectAtIndex:i];
            if ([myConverter isEqualTo:[weight rubetteName]])
                myWeight = [weight retain];
        }

        if (myWeight) {
            [self readWeightParameters];
        }
    }
}

- (void)writeWeightToList:(NSMutableArray *)weightList;
{
    if (myWeight) {
        id weight = nil;
      weightList = [[extendedRubetteDriver prediBase] weightList];
        // only replace or add weight if not available 
        if ([weightList indexOfObject:myWeight]==NSNotFound){
            int i, c = [weightList count];

          [myConverter setStringValue:[extendedRubetteDriver rubetteKey]];
            for (i=0; i<c && !weight;i++) {
                weight = [weightList objectAtIndex:i];
                if (![myConverter isEqualTo:[weight rubetteName]])
                    weight = nil;
            }
            if (weight)
                [weightList replaceObjectAtIndex:i-1 withObject:myWeight];
            else
                [weightList addObjectIfAbsent:myWeight];
        }
    }
    return self;
}
*/

- (void)readWeightParameters;
{
}

- (void)writeWeightParameters;
{
}

/*
- (void)setWeightFileName:(NSString *)fileName;
{
  [weightFileName release];
  weightFileName=[fileName copy];
}
*/

@end
#import <Predicates/PrediBaseDocument.h>
#import <Rubato/RubetteTypes.h>

#define WITHMODELOBJECT

// Model Classes for Rubettes might want to inherit from this class, but need not to.
// The Rubette-Driver knows how to get to these methods.
// This is espacially useful, if the Class has yet another inheritance-Relation.

#import "NibDrivenRubetteDriver.h"

@interface RubetteObject : NSObject
{
  id myListForm; // can be removed
  id myValueForm; // can be removed
  
  id	myRubetteData;
  id	foundPredicates;
  id	lastFoundPredicates;
  id	myWeight;

  id myConverter;
  id<ExtendedRubetteDriver> extendedRubetteDriver;

//  char* weightfile; //?
  unsigned long weightCount; //?
}
+ (const char *)rubetteName;
+ (const char *)rubetteVersion;
+ (spaceIndex) rubetteSpace;

- (id)init;
- (id)initWithExtendedRubetteDriver:(id<ExtendedRubetteDriver>)rubetteDriver;
- (void)dealloc;

- (id<ExtendedRubetteDriver>) extendedRubetteDriver;
- (void) setExtendedRubetteDriver:(id<ExtendedRubetteDriver>)newExtendedRubetteDriver;

- (void)setFormsWithFormManager:(id)gFormManager; // might be removed

- (id)listForm; // returns global form
- (id)valueForm; // returns global form

- (id)rubetteData;
- (void)setRubetteData:(id)fp;
- (id)foundPredicates;
- (void)setFoundPredicates:(id)fp;
- (id)lastFoundPredicates;
- (void)setLastFoundPredicates:(id)fp;
- (id)weight;
- (void)setWeight:(id)weight;

- (void)readCustomData;
- (void)writeCustomData;

- (void)newWeight;
- (void)newWeightWithName:(NSString *)name;
- (void)getWeightFromPrediBase;
- (void)setWeightToPrediBase;
//- (void)readWeightFromList:(NSMutableArray *)weightList;
//- (void)writeWeightToList:(NSMutableArray *)weightList;
- (void)readWeightParameters;
- (void)writeWeightParameters;

@end
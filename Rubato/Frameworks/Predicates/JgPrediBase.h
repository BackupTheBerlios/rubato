/* JgPrediBase.h created by jg on Wed 23-Jun-1999 */

#import <Foundation/Foundation.h>
#import <JGFoundation/JGAddressDictionary.h>

@interface JgPrediBase : NSObject
{
  id plist;
  id myPredicateList, myFormList, myRubetteList, myWeightList;

  // Forms, that do not occur in myFormList, but are used by Predicates
  NSMutableDictionary *myOtherForms; //  Key=LongInt Address, Val=Nummer

  // Addresses to avoid the duplicate naming of forms
  JGAddressDictionary *myAddresses;
}

- init;
- (int)readPlist:(NSString *)filename;
- (void)readPred:(NSString *)filename;
- (void)writePlist:(NSString *)filename;
- (void)writePred:(NSString *)filename;

- (void)plistToPreds;
- (void)predsToPlist;
- (void)setFormManager:aManager;
- (id)predicateList;
- (id)formList;
- (id)rubetteList;
- (id)weigthList;

@end

//  JGPredicateConverter.h
//  Copyright (c) 2002 by Joerg Garbers . All rights reserved.

#import <Foundation/Foundation.h>

@interface JGPredicateConverter : NSObject
{
  NSString *textIsOfType;
  id stdGivenNameOrNames;
  BOOL stdUseNames;
}
+ (id)predicateConverter;


- (id)predicateForList:(NSArray *)a withGivenNameOrNames:(id)nameOrNames;
- (id)listForPredicate:(id)predicate;
- (id)listForPredicate:(id)predicate useNames:(BOOL)useNames;
+ (id)predicateForList:(NSArray *)a;
+ (id)predicateForList:(NSArray *)a withGivenNameOrNames:(id)nameOrNames;
+ (id)listForPredicate:(id)predicate useNames:(BOOL)useNames;
@end

/*
 *  JGAccessorKeyValueMethods.h
 *  AndreasMeloProjects
 *
 *  Created by jg on Fri Aug 31 2001.
 *  Copyright (c) 2001 __CompanyName__. All rights reserved.
 *
 * state: untested
 *
 */

// merge the keys from super with those You get from FLEX_ACCESSORS

// heuristics
#define accessor_flex( type, var, setVar ) \
if (AttributeKeyKind==toOneRelationShipKey)  \
  [myKeys addObject:[NSString stringWithCString: #var]];
  
#define scalarAccessor_flex( type, var, setVar ) \
if (AttributeKeyKind==attributeKey) \
  [myKeys addObject:[NSString stringWithCString: #var]]; \

// defined behaviour
#define accessor_flex_key_addIf( var, info ) \
if (AttributeKeyKind==info.keyKind) { \
  [myKeys addObject:[NSString stringWithCString: #var]]; \
}

#define accessor_flex_info( type, var, setVar, info ) \
accessor_flex_key_addIf(var,info)

#define scalarAccessor_flex_info( type, var, setVar, info ) \
accessor_flex_key_addIf(var,info)

#define accessor_defineKeys \
  static NSArray *k; \
  if (!k) { \
    NSArray *s=[super attributeKeys]; \
    NSMutableArray *myKeys=[[NSMutableArray alloc] init]; \
    if (s) \
      [myKeys addObjectsFromArray:s]; \
FLEX_ACCESSORS \
    k=[myKeys copy]; \
    [myKeys release]; \
  } \
  return k; 

- (NSArray *)attributeKeys;
{
#define AttributeKeyKind attributeKey
accessor_defineKeys
}
- (NSArray *)toOneRelationshipKeys;
{
#define AttributeKeyKind toOneRelationshipKey
accessor_defineKeys
}
- (NSArray *)toManyRelationshipKeys;
{
#define AttributeKeyKind toManyRelationshipKey
accessor_defineKeys
}


//  JGPredicateConverter.m
//  Copyright (c) 2002 by Joerg Garbers . All rights reserved.

#import "JGPredicateConverter.h"
#import "SimplePredicate.h"
#import "CompoundPredicate.h"
#import "SimpleForm.h"
#import "CompoundForm.h"

#import <AppKit/NSPasteboard.h>

@interface JGRangeArray : NSArray
{
  NSArray *a;
  NSRange r;
}
- (id)initWithSuperArray:(NSArray *)s range:(NSRange)range;
+ (JGRangeArray *)rangeArrayWithSuperArray:(NSArray *)s range:(NSRange)range;
@end
@implementation JGRangeArray
- (id)initWithSuperArray:(NSArray *)s range:(NSRange)range;
{
  [super init];
  a=[s retain];
  r=range;
  return self;
}
+ (JGRangeArray *)rangeArrayWithSuperArray:(NSArray *)s range:(NSRange)range;
{
  id inst=[[JGRangeArray alloc] initWithSuperArray:s range:range];
  return [inst autorelease];
}
- (unsigned)count;
{
  return r.length;
}
- (id)objectAtIndex:(unsigned)idx;
{
  NSParameterAssert((idx<0) || idx>=r.length); 
  return [a objectAtIndex:idx+r.location];
}
@end

NSString *JGPropertyListPboardType=@"JGPropertyListPboardType"; // supported
NSString *JGXMLPropertyListPboardType=@"JGXMLPropertyListPboardType";
NSString *JGLispPboardType=@"JGLispPboardType";

@implementation JGPredicateConverter
+ (id)predicateConverter;
{
  static id pc=nil;
  if (!pc)
    pc=[[JGPredicateConverter alloc] init];
  return pc;
}
- (id)init;
{
  [super init];
  textIsOfType=[JGPropertyListPboardType retain];
  stdGivenNameOrNames=nil;
  stdUseNames=YES;
  return self;
}
- (void)dealloc;
{
  [textIsOfType release];
  [stdGivenNameOrNames release];
  [super dealloc];
}
- (NSString *)textIsOfType;
{
  return textIsOfType;
}
- (void)setTextIsOfType:(NSString *)newTextType;
{
  [newTextType retain];
  [textIsOfType release];
  textIsOfType=newTextType;
}


// Pasteboard conveniences
- (void)putPredicate:(id)pred toPasteboard:(NSPasteboard *)pboard;
{
  if (!pred)
    NSBeep();
  else {
    NSString *type=[NSString stringWithCString:PredFileType];
    NSArray *typeList = [NSArray arrayWithObjects:type,nil];
    NSData *dataBuffer=[NSArchiver archivedDataWithRootObject:pred];
    [pboard declareTypes:typeList owner:self];
    [pboard setData:dataBuffer forType:type];    
  }
}

- (void)putString:(NSString *)str toPasteboard:(NSPasteboard *)pboard;
{
  NSString *type=NSStringPboardType;
  NSArray *typeList = [NSArray arrayWithObjects:type,nil];
  [pboard declareTypes:typeList owner:self];
  [pboard setString:str forType:type];
}

- (void)convertArray:(NSArray *)a toPredicateInPasteboard:(NSPasteboard *)pboard;
{
  id predicate=[self predicateForList:a withGivenNameOrNames:nil];
  [self putPredicate:predicate toPasteboard:pboard];
}

- (id)convertFromPasteboard:(NSPasteboard *)pboard;
{
  id predicate=nil;
  id list=nil;
  NSData *dataBuffer;
  NSString *firstType,*predType=[NSString stringWithCString:PredFileType];
  firstType = [pboard availableTypeFromArray:[NSArray arrayWithObjects:predType,NSStringPboardType,nil]];
  if ([firstType isEqualToString:predType]) {
    if (dataBuffer = [pboard dataForType:firstType]) {
      predicate = [NSUnarchiver unarchiveObjectWithData:dataBuffer];
      list=[self listForPredicate:predicate];
    }
    return list;
  } else if ([firstType isEqualToString:NSStringPboardType]) {
    NSString *str=[pboard stringForType:firstType];
    if (str) {
      if ([textIsOfType isEqualToString:JGPropertyListPboardType]) {
        id plist=[str propertyList];
        predicate=[self predicateForList:plist withGivenNameOrNames:stdGivenNameOrNames];
      } else if ([textIsOfType isEqualToString:JGLispPboardType]) {
        //... FSLisp2PropertyList
      }
    }
    return predicate;
  }
  return nil;
}

- (void)putObject:(id)obj toPasteBoard:(NSPasteboard *)pboard;
{
  if ([obj isKindOfClass:[GenericPredicate class]]) {
    [self putPredicate:obj toPasteboard:pboard];
  } else if ([obj isKindOfClass:[NSArray class]]) {
    if ([textIsOfType isEqualToString:JGPropertyListPboardType]) {
      NSString *str=[obj description];
      [self putString:str toPasteboard:pboard];
    } else if ([textIsOfType isEqualToString:JGLispPboardType]) {
      //... FSLisp2PropertyList
    }
  }
}

- (id)convertObject:(id)obj;
{
  if ([obj isKindOfClass:[GenericPredicate class]]) {
    return [self listForPredicate:obj];
  } else if ([obj isKindOfClass:[NSArray class]]) {
    return [self predicateForList:obj withGivenNameOrNames:stdGivenNameOrNames];
  }
  return nil;
}

- (void)convertObject:(id)obj toPasteBoard:(NSPasteboard *)pboard;
{
  [self putObject:[self convertObject:obj] toPasteBoard:pboard];
}

- (BOOL)convertPasteboard;
{
  NSPasteboard *pboard = [NSPasteboard generalPasteboard];
  id result=[self convertFromPasteboard:pboard];
  [self convertObject:result toPasteBoard:pboard];
  return (result!=nil);
}

- (id)listForPredicate:(id)predicate;
{
  return [[self class] listForPredicate:predicate useNames:stdUseNames];
}
- (id)listForPredicate:(id)predicate useNames:(BOOL)useNames;
{
  return [[self class] listForPredicate:predicate useNames:useNames];
}

+ (id)listForPredicate:(id)predicate useNames:(BOOL)useNames;
{
  NSMutableArray *a=[NSMutableArray array];
  if (useNames && [predicate isKindOfClass:[GenericPredicate class]])
    [a addObject:[predicate name]];
  if ([predicate isKindOfClass:[SimplePredicate class]]) {
    [a addObject:[predicate stringValue]];
  } else if ([predicate isKindOfClass:[CompoundPredicate class]]) {
    NSEnumerator *e=[[predicate values] objectEnumerator];
    id item;
    while (item=[e nextObject])
      [a addObject:[self listForPredicate:item useNames:useNames]];
  } else {
    NSLog(@"Unexpected Object, which is not a SimplePredicate or CompoundPredicate.");
    return nil;
  }
  return a;
}

+ (id)predicateForList:(NSArray *)a;
{
  return [self predicateForList:a withGivenNameOrNames:nil];
}

- (id)predicateForList:(NSArray *)a withGivenNameOrNames:(id)nameOrNames;
{
  return [[self class] predicateForList:a withGivenNameOrNames:nameOrNames];
}

+ (id)predicateForList:(NSArray *)a withGivenNameOrNames:(id)nameOrNames;
{
  // (nameOrNames e1 e2 ...)
  // nameOrNames is name or (name entryNameOrNames1 entryNameOrNames2 ...)
  // if we run out of entryNameOrNames1 (for lists with unknown number of elements), reuse the last.
  
  NSString *name=nil;
  GenericPredicate *predicate;
  NSEnumerator *e,*entryNameEnumerator=nil;
  id item;
  int entryCount;
  id entryNameOrNames=nil;

  // accept nameOrNames in first slot or in input parameter.
  NSParameterAssert([a isKindOfClass:[NSArray class]]);
  e=[a objectEnumerator];
  if (!nameOrNames) {
    int c=[a count];
    if (!c) {
      NSLog(@"Could not create Predicate for List. List has no Name entry");
      return nil;
    }
    nameOrNames=[e nextObject];
    entryCount=c-1;
  } else {
    entryCount=[a count];
  }

  if ([nameOrNames isKindOfClass:[NSString class]]) {
    // nameOrNames is name
    name=nameOrNames;
  } else if ([nameOrNames isKindOfClass:[NSArray class]]) {
    // nameOrNames is (name entryNameOrNames1 entryNameOrNames2 ...)
    int nameOrNamesCount=[nameOrNames count];
    if (nameOrNamesCount<2) {
      NSLog(@"Could not create Predicate for List. Wrong type of first element.");
      return nil;      
    }
    entryNameEnumerator=[nameOrNames objectEnumerator];
    name=[entryNameEnumerator nextObject];
    entryNameOrNames=[entryNameEnumerator nextObject]; // the first entry name(s) of compound predicates
  }

  // check types
  if (![name isKindOfClass:[NSString class]]) {
    NSLog(@"Could not create Predicate for List. Wrong type of first element.");
    return nil;
  }
  
  item=[e nextObject];
  
  // SimplePredicate case
  // (Name String)
  if (!entryNameOrNames && (entryCount==1)) { 
    if ([item isKindOfClass:[NSString class]]) {
      predicate=[[SimplePredicate alloc] init];
      [predicate setForm:[SimpleForm valueForm]];
      [predicate setName:name];
      [(SimplePredicate *)predicate setStringValue:item];
      [predicate autorelease];
      return predicate;
    }
  }

  // CompoundPredicate case
  // (Name e1 e2..) or ((Name Name1 Name2 ...) e1 e2 ...) or ((Name Name1 .. Namej) e1 ...en) j<n
  predicate=[[CompoundPredicate alloc] init];
  [predicate setForm:[CompoundForm listForm]];
  [predicate setName:name];
  [predicate autorelease];
  
  while (item) {
    GenericPredicate *predItem=nil;    
    if ([item isKindOfClass:[NSString class]]) {
      if (![entryNameOrNames isKindOfClass:[NSString class]]) {
        NSLog(@"Could not create Predicate for List. Name for Elements is not a String.");
        return nil;
      }
      predItem=[[SimplePredicate alloc] init];
      [predItem setForm:[SimpleForm valueForm]];
      [predItem setName:entryNameOrNames];
      [(SimplePredicate *)predItem setStringValue:item];
      [predItem autorelease];
    }  else if ([item isKindOfClass:[NSArray class]]) {
      // entryNameOrNames can be nil, in which case the entry should contain its name.
      predItem=[self predicateForList:item withGivenNameOrNames:entryNameOrNames];
      if (!predItem)
        return nil;
    }  else {
      NSLog(@"Could not create Predicate for List. Unexpected element class.");
      return nil;
    }

    [predicate setValue:predItem]; // adds predItem to the compound predicate

    // next Loop
    item=[e nextObject];
    if (entryNameEnumerator) {
      // if we run out of entryNameOrNames-Elements, reuse the last.
      id nextEntryNameCandidate=[entryNameEnumerator nextObject];
      if (nextEntryNameCandidate)
        entryNameOrNames=nextEntryNameCandidate;
    }
  }
  return predicate;
}
@end

/* Hacks.m created by jg on Wed 23-Jun-1999 */
#import <Foundation/Foundation.h>
#import <JGFoundation/JGLogArchiver.h>
#import <JGFoundation/JGLogUnarchiver.h>
#import <Predicates/predikit.h>

void processPropertyList(id l,NSString *filename)
{
  NSMutableArray *a=[NSMutableArray new];
//  for (i=0; i<[l count]; i++) [a addObject:[[l objectAt:i] jgToPropertyList]];
  [a addObject:[l jgToPropertyList]]; // l is Predicate
  printf("PL: %s",[[a description] cString]);
  [a writeToFile:filename atomically:NO];
}

void readPropertyList(NSString *filename)
{
  NSMutableArray *a=[NSMutableArray arrayWithContentsOfFile:filename];
  id dict=[a objectAtIndex:0];
  id p=[GenericPredicate jgNewFromPropertyList:dict];
  processPropertyList(p,@"/tmp/rubtest1.plist");
}

id getObj()
{
  NSString *aString1, *aString2;
  NSArray *anarray;
  aString1=[NSString jgStringWithCString:"hallo"];
  aString2=[aString1 uppercaseString];
  anarray=[NSArray arrayWithObjects:aString1,aString2,nil];
  return anarray;
}
//   anObject=getObj();
//   [JGLogArchiver archiveRootObject:anObject toFile:@"test.pred"];


/*
1.Phase
 encodeObject:
 Class  NSConcreteArray
 encodeValueOfObjCType:
 Integer 2
 encodeObject:
 Class  NSInlineCString
 encodeObject:
 Class  NSInlineUnicodeString

2.Phase
 encodeObject:
 Class  NSConcreteArray
 encodeValueOfObjCType:
 Integer 2
 encodeObject:
 Class  NSInlineCString
 encodeObject:
 Class  NSInlineUnicodeString

 > Finished running 'ArchiverRepresentation'.
*/



void predarchiv()
{
  id aList;
  id aPred;
  id aType;
  printf("SimplePredicate Archivation\n");
  aPred=[SimplePredicate new];
  aType=[SimpleForm new];
  [aPred jgSetForm:aType];
   [JGLogArchiver archiveRootObject:aPred toFile:@"simple.pred"];
   printf("SimplePredicate UnArchivation\n");
   aList=[JGLogUnarchiver unarchiveObjectWithFile:@"simple.pred"];
}


void rubtest()
{
  id aList;
  id myArchiver;
  id myData;
  myData=[NSMutableData data];
  myArchiver= [[JGLogArchiver alloc] initForWritingWithMutableData:myData];
  [JGLogUnarchiver decodeClassName:@"Object" asClassName:@"NSObject"];
  [myArchiver encodeClassName:@"NSObject" intoClassName:@"Object"];

  printf("\n\nrubtest.pred Unarchivation\n");
  aList=[JGLogUnarchiver unarchiveObjectWithFile:@"rubtest.pred"];
  processPropertyList(aList,@"/tmp/rubtest.plist");
  readPropertyList(@"/tmp/rubtest.plist");
  // Warning: aList is no List, but CompoundPredicate.
  // perhaps related to error message:
  //  ArchiverRepresentation[1777] *** +[NSUnarchiver unarchiveObjectWithData:]: extra data discarded

/*
  printf("\n\nrubtest.pred Archivation\n");
  [myArchiver encodeRootObject:aList];
  [[myArchiver archiverData] writeToFile:@"rubtest.pred2" atomically:YES];
*/
}

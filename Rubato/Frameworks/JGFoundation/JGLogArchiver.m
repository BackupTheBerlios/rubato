/* JGLogArchiver.m created by jg on Thu 06-May-1999 */

#import "JGLogArchiver.h"
//#include <stdio.h>

@implementation JGLogArchiver:NSArchiver
{
}

- (void)encodeObject:(id)object
{
  printf("encodeObject:\n");
  printf("Klasse  %s\n",[NSStringFromClass([object class]) cString]);
  [super encodeObject:object];
}

/*
  i int
  d double
  c char * bzw. void *
*/
- (void)encodeValueOfObjCType:(const char*)typestr at:(void *)adress;
{
//  int count;
  printf("encodeValueOfObjCType:\n");
  switch (typestr[0]) {
    case '@' : printf("Klasse  %s\n",[NSStringFromClass([(NSObject *)adress class]) cString]); break;
    case 'c' : printf("Adresse %d\n als String %s\n",*((int *)adress),(char *)adress); break;
    case 'i' : printf("Integer %d\n",*((int *)adress)); break;
    case 'd' : printf("Double  %f\n",*((double *)adress)); break;
    case '{' : printf("Array start \n"); break;
    default  : printf("Unbekannt\n");
  }
  [super encodeValueOfObjCType:typestr at:adress];
}

@end

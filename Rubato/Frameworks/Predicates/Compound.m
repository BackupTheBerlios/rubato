/* Compound.m created by jg on Thu 24-Jun-1999 */

- (void) jgInfoToPropertyList:(NSMutableDictionary *)d withDicts:(dictstruct *)dicts;
{
  NSMutableArray *a=[NSMutableArray new];
  int count=[myList count];
  int i;

  for (i=0; i<count; i++) [a addObject:[[myList objectAt:i] jgToPropertyListWithDicts:dicts]];
  [d setObject:a forKey:ValsKey];
}


- (NSMutableDictionary *) jgToPropertyList;
{
  NSMutableArray *a=[NSMutableArray new];
  NSMutableDictionary *d=[super jgToPropertyList];
  int count=[myList count];
  int i;

  for (i=0; i<count; i++) [a addObject:[[myList objectAt:i] jgToPropertyList]];
  [d setObject:a forKey:ValsKey];
  return d;
}

- (void)jgInitFromPropertyList:(id) pl;
{
  int i;
  id elem;
  id vals=[pl objectForKey:ValsKey];
  [super jgInitFromPropertyList:pl];
  for (i=0; i<[vals count]; i++) {
    elem=[vals objectAtIndex:i];
    [myList addObject:[GenericPredicate jgNewFromPropertyList:elem]];
  }
} 


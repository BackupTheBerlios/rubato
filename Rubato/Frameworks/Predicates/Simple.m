/* Simple.m created by jg on Thu 24-Jun-1999 */
// jg:ToDo Still need support for... ?

- (void) jgInfoToPropertyList:(NSMutableDictionary *)d withDicts:(dictstruct *)dicts;
{
  // Simple forms sometimes did not have set this value!
  // reason in initWithCoder...! Is corrected now.
  if (myValue) {
    NSString *obj;
    if ([myValue respondsToSelector:@selector(stringValue)])
      obj=[myValue stringValue];
    else // jg: NSString   Watch for ModuleElements
      obj=myValue; 
    [d setObject:obj forKey:ValKey]; // Simple
  }
}

- (NSMutableDictionary *) jgToPropertyList
{
  NSMutableDictionary *d=[super jgToPropertyList];
  NSString *obj;
  if ([myValue respondsToSelector:@selector(stringValue)])
    obj=[myValue stringValue];
  else // jg: NSString   Watch for ModuleElements
    obj=myValue; 
  [d setObject:obj forKey:ValKey]; // Simple
  return d;
}

- (void)jgInitFromPropertyList:(id) pl;
{
  [super jgInitFromPropertyList:pl];
  myValue=[[pl objectForKey:ValKey] copy];
}


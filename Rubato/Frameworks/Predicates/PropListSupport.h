/* PropListSupport.h created by jg on Thu 24-Jun-1999 */

- (NSMutableDictionary *) jgToPropertyList;

// calls for noncyclic tree super, afterwards components
- (void)jgInitFromPropertyList:(id) pl;

// called by jgToPropertyListWithDicts does not call super, but components with
// jgToPropertyListWithDicts. Empty for abstract class GenericPredicate.
- (void)jgInfoToPropertyList:(NSMutableDictionary *)d withDicts:(dictstruct *)dicts;


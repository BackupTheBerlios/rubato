/* Ordering Protocol */

@protocol Ordering
- (int)compareTo:anObject;
- (BOOL)equalTo:anObject;
- (BOOL)largerThan:anObject; 
- (BOOL)smallerThan:anObject; 

/*logically redundant but not as methods */
- (BOOL)smallerEqualThan:anObject;
- (BOOL)largerEqualThan:anObject;
@end
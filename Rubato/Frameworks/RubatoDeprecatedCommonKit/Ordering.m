/* Ordering.m */

/* Default implementation for the Ordering Protocol */
- (int)compareTo:anObject;
{
    if ([self equalTo:anObject])
	return 0;
    else if ([self largerThan:anObject])
	return 1;
    else
	return -1;
}


- (BOOL)equalTo:anObject;
{
    if ([anObject isKindOfClass:[self class]]) {
	return [self isEqual:anObject]; /* this is the appKit euqality test */
    }
    return NO;
}

- (BOOL)largerThan:anObject;
{
    return [NSStringFromClass([self class]) compare:NSStringFromClass([anObject class])]>0;
}

- (BOOL)smallerThan:anObject; 
{
   return [NSStringFromClass([self class]) compare:NSStringFromClass([anObject class])]<0;

}

/*logically redundant but not as methods */
- (BOOL)smallerEqualThan:anObject;
{
    return [self equalTo:anObject] || [self smallerThan:anObject];
}

- (BOOL)largerEqualThan:anObject;
{
    return [self equalTo:anObject] || [self largerThan:anObject];
}


/* SpaceProtocolMethods.m */


/* This file may be imported by classes adopting the SpaceProtocol
 * protocol. It contains standard implementations for all methods declared
 * in the SpaceMethods protocol. These implementations assume the
 * class to declare a instance variable mySpace of the type spaceIndex.
 */
 
 
- setSpaceAt:(int)index to:(BOOL)flag;
{
    if (index<MAX_SPACE_DIMENSION) {
	if (flag)
	    mySpace = mySpace | 1 << index;
	else
	    mySpace = mySpace & ~(1 << index);
    }
    return self;
}

- (BOOL) spaceAt:(int)index;
{
    if (index<MAX_SPACE_DIMENSION)
	return mySpace & spaceOfIndex(index);
    else
	return NO;
}

- setSpaceTo:(spaceIndex)aSpace;
{
    mySpace = aSpace;
    return self;
}

- (spaceIndex) space;
{
    return mySpace;
}

- (BOOL) directionAt:(int)index;
{
    return [self spaceAt:index];
}

- (spaceIndex) direction;
{
    return mySpace;
}

- (int) dimension;
{
    int i;
    unsigned int d=0;
    for(i=0;i<MAX_SPACE_DIMENSION; i++){
	if(mySpace & 1<<i)
	    d++;
    }
    return d;
}

- (int) dimensionAtIndex:(int)index;
{/* this gives the dimension until the coordinate given by index */
    int i;
    int d=0;
    index = index<MAX_SPACE_DIMENSION ? index : MAX_SPACE_DIMENSION-1;
    for(i=0;i<=index; i++){
	if(mySpace & 1<<i)
	    d++;
    }
    return d;
}

- (int) dimensionOfIndex:(int)index;
{/* this gives the dimension OF the coordinate given by index */
    if ([self spaceAt:index])
	return [self dimensionAtIndex:index];
    return -1;
}

- (int) indexOfDimension:(int)dimension;
{
    int index;
    for (index=0; index<MAX_SPACE_DIMENSION && dimension; index++)
	if ([self spaceAt:index])
	    dimension--;
    return dimension ? -1 : index-1;
}


- (BOOL) isSubspaceFor:(spaceIndex) aSpace;
{
    return mySpace == (mySpace & aSpace);
}

- (BOOL) isSuperspaceFor:(spaceIndex) aSpace;
{
    return aSpace == (mySpace & aSpace);
}



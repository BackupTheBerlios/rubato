/* space.c */

/* Utility Functions and Macros for the manipulation of spaceIndex variables */

#import <objc/objc.h>
/*#import <AppKit/nextstd.h>*/
#import <Rubato/SpaceTypes.h>
#include "space.h"

#ifdef SPACE_NO_INLINE
spaceIndex spaceOfIndex(int I)
{ return 1<<I;}
BOOL spaceInSpace(spaceIndex A, spaceIndex B)
{ return (!(A & ~B) && (A & B));}
BOOL isSuperspace(spaceIndex A, spaceIndex B)
{ return (B == (A & B));}
BOOL isSubspace(spaceIndex A, spaceIndex B)
{ return (A == (A & B));}
BOOL isStrictSubspace(spaceIndex A, spaceIndex B)
{ return ((A == (A & B)) && ((A)!=(B)));}
BOOL isSubSubspace(spaceIndex A, spaceIndex B, spaceIndex C)
{ return ((A == (A & B)) && (B == (B & C)));}
#endif

int dimensionOfSpace(spaceIndex aSpace)
{
    int i;
    unsigned int d=0;
    for(i=0;i<MAX_SPACE_DIMENSION; i++){
	if(aSpace & 1<<i)
	    d++;
    }
    return d;
}

BOOL isSuperspaceFor(spaceIndex aSpace, spaceIndex bSpace)
{
    return aSpace == (aSpace & bSpace);
}

BOOL isSubspaceFor(spaceIndex aSpace, spaceIndex bSpace)
{
    return bSpace == (aSpace & bSpace);
}
/* space.h */
// jg:Inlines make problems on Mac OS X (24.10.2000)
// If fixed, set SPACE_NO_INLINE to YES if DEBUG, NO otherwise.
#define SPACE_NO_INLINE

/* Utility Functions and Macros for the manipulation of spaceIndex variables */

#ifdef SPACE_NO_INLINE
spaceIndex spaceOfIndex(int I);
BOOL spaceInSpace(spaceIndex A, spaceIndex B);
BOOL isSuperspace(spaceIndex A, spaceIndex B);
BOOL isSubspace(spaceIndex A, spaceIndex B);
BOOL isStrictSubspace(spaceIndex A, spaceIndex B);
BOOL isSubSubspace(spaceIndex A, spaceIndex B, spaceIndex C);
#else
inline extern spaceIndex spaceOfIndex(int I)
{ return 1<<I;}
inline extern BOOL spaceInSpace(spaceIndex A, spaceIndex B)
{ return (!(A & ~B) && (A & B));}
inline extern BOOL isSuperspace(spaceIndex A, spaceIndex B)
{ return (B == (A & B));}
inline extern BOOL isSubspace(spaceIndex A, spaceIndex B)
{ return (A == (A & B));}
inline extern BOOL isStrictSubspace(spaceIndex A, spaceIndex B)
{ return ((A == (A & B)) && ((A)!=(B)));}
inline extern BOOL isSubSubspace(spaceIndex A, spaceIndex B, spaceIndex C)
{ return ((A == (A & B)) && (B == (B & C)));}
#endif

int dimensionOfSpace(spaceIndex aSpace);
BOOL isSuperspaceFor(spaceIndex aSpace, spaceIndex bSpace);
BOOL isSubspaceFor(spaceIndex aSpace, spaceIndex bSpace);

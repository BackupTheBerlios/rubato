/* SpaceTypes.h */
/* the constant and type definitons for objects in spaces may be
 * changed herein according to the projects requirements.
 */

#define MAX_SPACE_DIMENSION 6
#define MAX_BASIS_DIMENSION 3
#define BASIS_SPACE 7
#define PIANOLA_SPACE 56
#define MAX_SPACE 63

typedef struct{
	double origin;
	double end;
}Space_Frame;
// jg: NSRect enthÙlt NSPoint origin; NSSize size;


typedef unsigned char spaceIndex;

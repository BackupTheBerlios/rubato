/* RubatoTypes.h */

//#import <objc/objc.h>
//#import <AppKit/event.h>
/*#import <AppKit/nextstd.h>*/
#import <Rubato/SpaceTypes.h>
#ifndef NO_NS
#import <Foundation/NSGeometry.h>
#else
typedef struct _NSPoint {
    float x;
    float y;
} NSPoint;
#endif

/* definition of globally used types */
typedef double cent;
typedef double hertz;
typedef hertz hz;
typedef double dB;
typedef double ms;
typedef int midiType;

typedef NSPoint shape[100];

/* symbolic type defs */
typedef double symEType;
typedef double symHType;
typedef double symLType;
typedef double symDType;
typedef double symGType;
typedef double symCType;

enum {indexE=0, indexH, indexL, indexD, indexG, indexC};

/* physical type defs */
typedef ms physEType;
typedef struct _physHType {
    hertz zero;
    cent  pitch;
    } physHType;
    
typedef struct _physLType {
    dB zero;
    dB level;
    } physLType;

typedef ms physDType;
typedef struct _physGType {
    cent  deltaPitch;
    shape polygon;
    } physGType;

typedef struct _physCType {
    dB	  deltaLevel;
    shape polygon;
    } physCType;

typedef struct _basicSpaceType {
    symEType	E;
    symHType	H;
    symLType	L;
    BOOL 	hasE;
    BOOL 	hasH;
    BOOL 	hasL;
} basicSpaceType;

typedef struct _pianolaSpaceType {
    symDType	D;
    symGType	G;
    symCType	C;
    BOOL 	hasD;
    BOOL 	hasG;
    BOOL 	hasC;
} pianolaSpaceType;

typedef struct _vibratoSpaceType {
    hz   vibFreq;
    cent vibPitch;
    dB   vibAmp;
    ms   vibDelay;
} vibratoSpaceType;

typedef struct _physicalSpaceType {
    physEType	e;
    physHType	h;
    physLType	l;
    physDType	d;
    physGType	g;
    physCType	c;
    BOOL 	hasE;
    BOOL 	hasH;
    BOOL 	hasL;
    BOOL 	hasD;
    BOOL 	hasG;
    BOOL 	hasC;
} physicalSpaceType;


typedef Space_Frame LPS_Frame;
    

typedef double symEvent[MAX_SPACE_DIMENSION];
typedef double physEvent[MAX_SPACE_DIMENSION];

/*Definition of performedEvent type*/
typedef struct{
    double symbEvent[MAX_SPACE_DIMENSION];//The symbolic event for given instrument
    double physEvent[MAX_SPACE_DIMENSION];//The associated physical event
}performedEvent;

// jg was midi, mid integrates better with OS X
#define MidiFileType "mid"
#define ScoreFileType "score"
#define StemmaFileType "stemma"

#define WeightFileType "weight"
#define OperatorFileType "operator"

#define ns_MidiFileType @"mid"
#define ns_ScoreFileType @"score"
#define ns_StemmaFileType @"stemma"

#define ns_WeightFileType @"weight"
#define ns_OperatorFileType @"operator"


#define strE "E"
#define strH "H"
#define strL "L"
#define strD "D"
#define strG "G"
#define strC "C"

#define E_space 1 /* E is position 1 */
#define H_space 2 /* H is position 10 */
#define L_space 4 /* L is position 100 */
#define D_space 8 /* D is position 1000 = 1<<3 = 8 */
#define G_space 16 /* G is position 10000 */
#define C_space 32 /* C is position 100000 */

#define ED_space 9 /* ED is position 1001 = 1<<3 | 1 = 9 */
#define EH_space 3 /* EH is position 11 = 1<<2 | 1 = 3 */


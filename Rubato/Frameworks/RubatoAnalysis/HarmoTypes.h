/* HarmoTypes.h */

#import <math.h>
// jg:Inlines make problems on Mac OS X (24.10.2000)
// If fixed, set HARMOTYPES_NO_INLINE to YES if DEBUG, NO otherwise.
#define HARMOTYPES_NO_INLINE

#define CHORDSEQ_DYN

#define PATHNUMBER 2 /*selection of number of best paths, presently, have only the best and the workpath */
#define MAX_TONALITY 12
#define MAX_FUNCTION 6
#define MAX_LOCUS 72
#define MAX_MODE 2
#define MAX_MODELESS_FUNCTION 3
#define EXPONENT 0.5

#define TONALITY_OF(index) (mod((index), locusCount) % tonalityCount)
#define FUNCTION_OF(index) (mod((index), locusCount) / tonalityCount)
//old usage: locusOf(index).RieTon and locusOf(index).RieVal;

#define PC_COUNT 12
#define FUNCTION_RANGE(a) (mod(a,functionCount))
#define TONALITY_RANGE(a) ((a)>=0 ? (a)%tonalityCount : (tonalityCount+(a)%tonalityCount)%tonalityCount)
#define MOD_PC(a) ((a)>=0 ? (a)%PC_COUNT : (PC_COUNT+(a)%PC_COUNT)%PC_COUNT)
// old usage: modTwelve

typedef struct{
	int RieVal;
	int RieTon;
	}RiemannLocus;

typedef struct{
	unsigned char length; /* number of thirds */
	unsigned short thirdBitList; /* bit representation of thirds: 1~4, 0~3 semitones */
	}thirdList;
	
int CardLimit(int);
// jg named harmo_round instead of round, because round is in conflict with MetroRubette.subproj::round().
#ifdef HARMOTYPES_NO_INLINE
int harmo_round(double x);
#else
inline extern int harmo_round(double x)
{
    return (x-floor(x) < 0.5) ?  floor(x) : ceil(x);
}
#endif

int mod(int, int);
unsigned char modTwelve(int);
int pitchClassTwelve(double, double, double);

const char* pitchClassName(int pitchClass);
const char* riemannFunctionName(int rieVal);

/* transformation of bit list */
// int bitComplement(int);
// int transpose(int, int);
RiemannLocus locusOf(int);

/* Noll-Functions */
/* procude a Vektor from  0 or 1 */
int *nollIndex(int *index, int *a);

/* Composition-Functions */
int *nollComp(int[], int, int, int, int);

/* i = row from 0 to 6, result is pointer with relative coordinates 0 and 1 */
int *nollMorpheme(int[], int, int, int);

int *majorCons(int[], int, int);

int *minorCons(int[], int, int);

int *majorDiss(int[], int, int);

int *minorDiss(int[], int, int);

/* BitSequence of the affine Values */
unsigned int affBits(unsigned int, unsigned int);

/* BitSequence of the Chord */
unsigned int nollClosure(unsigned int);

/* Chord-Weights from generic Weight RiemannWeight at Noll */
double riemann(int, int, unsigned short, double ***);

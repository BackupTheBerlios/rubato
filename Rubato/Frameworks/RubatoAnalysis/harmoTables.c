/*tables for harmoRubette */
#import <stdio.h>
#import <math.h>
#import <stdlib.h>
#import "HarmoTypes.h"


int CardLimit(int card)
{
    switch(card) {
	case 0:
	return  1;
	case 1:
	return  3;
	case 2:
	return  7;
	case 3:
	return  14;
	case 4:
	return  26;
	case 5:
	return  47;
	case 6:
	return  83;
	case 7:
	return  118;
	case 8:
	return  152;
	case 9:
	return  188;
	case 10:
	return  207;
	case 11:
	return  211;
	default:
	return 0;
    }
}
	
#ifdef HARMOTYPES_NO_INLINE
// #warning using non-inline definition of harmo_round()
int harmo_round(double x)  // runden
{
    return (x-floor(x) < 0.5) ?  floor(x) : ceil(x);
}
#else
#warning using inline definition of harmo_round()
// inline in HarmoTypes.h
#endif


int mod(int a,int n)
{
    if(n){
    n = n>0 ? n : -n;
    return a>=0 ? a%n : (n+(a%n))%n;
    }
    return a;
}

unsigned char modTwelve(int a)
{
    return a>=0 ? a%12 : (12+a%12)%12;
}

int pitchClassTwelve(double pitch, double ref, double unit)
{
  if(unit){
    return modTwelve(harmo_round((pitch - ref)/unit));
  } else
    return 0;
}

// jg: subst as instance method / usage as tonality names!
const char* pitchClassName(int pitchClass)
{
    switch (MOD_PC(pitchClass))
    {
	case 0:
	return "C";
	case 1:
	return "C#";
	case 2:
	return "D";
	case 3:
	return "D#";
	case 4:
	return "E";
	case 5:
	return "F";
	case 6:
	return "F#";
	case 7:
	return "G";
	case 8:
	return "G#";
	case 9:
	return "A";
	case 10:
	return "A#";
	case 11:
	return "B";
	default:
	return "-";
    }
}

// jg: subst as instance method
const char* riemannFunctionName(int rieVal)
{
    switch (rieVal)
    {
	case 0:
	return "T";
	case 1:
	return "D";
	case 2:
	return "S";
	case 3:
	return "t";
	case 4:
	return "d";
	case 5:
	return "s";
	default:
	return "-";
    }
}

/* transformation of bit list */
/*int bitComplement(int toneBits)
{
    return  ~toneBits & ~(~0<<12);
}*/

/*int transpose(int toneList,int shifter)
{
    int i, myShiftBits = 0;

    for(i=0; i<12; i++){
    if (toneList & 1<<i)
    myShiftBits = myShiftBits | 1<<modTwelve(i+shifter);
    }
    return myShiftBits;
}*/

// jg: see TONALITY_OF(index), FUNCTION_OF(index) in HarmoTypes.h for
//     a definition that repects locusCount, tonalityCount
RiemannLocus locusOf(int index)
{
    RiemannLocus retVal;
    retVal.RieVal = mod(index, MAX_LOCUS) / 12;
    retVal.RieTon = mod(index, MAX_LOCUS) % 12;
    return retVal;
}


/* Noll table */
int nollRow[43][2] = {
	{0,0},{0,1},{0,2},{0,3},{0,4},{0,5},{0,6},{0,7},{0,8},{0,9},{0,10},{0,11},
	{3,0},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{3,7},{3,8},{3,9},{3,10},{3,11},
	{8,0},{8,1},{8,2},{8,3},{8,4},{8,5},{8,6},{8,7},{8,8},{8,9},{8,10},{8,11},
	{9,0},{9,4},{9,8},
	{4,0},{4,3},{4,6},{4,9}
		    };

/* produces a Vector from 0 or 1 */
int *nollIndex(int *index, int *a)
{
    int i;

    for(i=0; i<43; i++)
	index[i] = (a[0] == nollRow[i][0] && a[1] == nollRow[i][1]) ? 1: 0; 
    return index;
}


/* Composition-Functions */
int *nollComp(int morpheme[2], int a0, int a1, int b0, int b1)
{
    morpheme[0] = modTwelve(a0*b0);
    morpheme[1] = modTwelve(a0*b1+a1);
    return morpheme;
}


/* i = row from 0 to 6, result is pointer with relative coordinates 0 and 1 */
int *nollMorpheme(int morpheme[2], int a, int b, int i)
{
    int v[2];
    switch(i){
	case 0:{
	morpheme[0] = 3;
	morpheme[1] = modTwelve(a);
	return  morpheme;
	}
	case 1:{
	return  nollComp(morpheme, 3,a,3,a);
	}
	case 2:{
	morpheme[0] = 8;
	morpheme[1] = modTwelve(b);
	return  morpheme;
	}
	case 3:{
	return  nollComp(morpheme, 8,b,8,b);
	}
	case 4:{
	return  nollComp(morpheme, 8,b,3,a);
	}
	case 5:{
	return  nollComp(morpheme, 3,a,8,b);
	}
	case 6:{
	nollComp(v,8,b,3,a);
	return   nollComp(morpheme,8,b,v[0],v[1]);
	}
	default:
	return  NULL;
	}
}



int *majorCons(int morpheme[2], int k, int i)
{
    return nollMorpheme(morpheme, modTwelve(5*(1-2*(5*k+4))),5*k+4,i);
}

int *minorCons(int morpheme[2], int k, int i)
{
    return nollMorpheme(morpheme, modTwelve(5*(11-2*(5*k+8))),5*k+8,i);
}

int *majorDiss(int morpheme[2], int k, int i)
{
    return nollMorpheme(morpheme, modTwelve(5*(10-2*(5*k+4))),5*k+4,i);
}

int *minorDiss(int morpheme[2], int k, int i)
{
    return nollMorpheme(morpheme, modTwelve(5*(2-2*(5*k+8))),5*k+8,i);
}

/* BitSequence of the affine Values */
unsigned int affBits(unsigned int classBits, unsigned int i)
{
    unsigned short result = 0;
    if(i<43){
	int j;
	for(j=0; j<12; j++){
	    if(classBits & 1<<j)
		result = result | 1<<modTwelve(nollRow[i][0]*j + nollRow[i][1]);
	}
    }
    return result;
}



/* BitSequence of the Chord */
unsigned int nollClosure(unsigned int classBits)
{
    int i;
    unsigned int closure = 0;
    classBits = ~classBits & 8191;  //~(~0<<12); /* complement of classBits */
    for(i=0; i<43; i++){
	if(!(classBits & affBits(classBits,i)))
	    closure = closure | 1<<i;
	}
    return closure;
}



/* Chord-Weights from generic Weight RiemannWeight at Noll */
double riemann(int function, int tonic, unsigned short classBits, double ***nollRiemannWeight)
{  
    int i;
    double result = 0;
    unsigned int closureBits = nollClosure(classBits);

    for(i=0; i<43; i++){
	if(closureBits & 1<<i)
	    result += nollRiemannWeight[function][tonic][i];
	}
    return result;
}


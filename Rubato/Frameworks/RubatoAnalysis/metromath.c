#include <stdio.h>
#include <math.h>
#include "metro.h"

#define max(A,B) ((A)>(B)?(A):(B))
#define min(A,B) ((A)<(B)?(A):(B))

// defined on OSX in AppKit.p and IEEE (math.h)
//#define INFINITY HUGE_VAL
//old: #define INFINITY strtod("+Infinity", (char **)NULL) /*infinity should be the largest double*/

int lcm(int a, int b)			/*kgV*/
	{
	int i;
	if(a*b)
	{	for(i = max(a,b);(i <= a*b) && (i%a != 0 || i%b != 0);i++)
		;
		return i;
	}
	else
		return 0;
	}
	
int LCM(int *o, int lgth)
	{
	int lc = *o, i;
	for(i = 0,lc; i < lgth; i++)
	lc = lcm(lc,*(o+i));
	return lc;
	}
	
int lcd(int a, int b)			/*ggT*/
	{
	int i;
	a = fabs(a);
	b = fabs(b);
	if(a*b)
	{	for(i = min(a,b);(1 <= i) && (a%i != 0 || b%i != 0);i--)
		;
		return i;
	}
	else
		return max(a,b);
	}
	
int LCD(int *o, int lgth)
	{
	int lc = *o, i;
	for(i = 0,lc; i < lgth;i++)
	lc = lcd(lc,*(o+i));
	return lc;
	}

int metro_round(double x)			/*runden*/
	{
	if(x-floor(x) < 0.5)
		return floor(x);
	else
		return ceil(x);
	}
	
double eval(RubatoFract x)			/*Evaluation  of symbolic Fractions*/	
	{
	if(x.isFraction && x.denominator)
		return x.numerator/x.denominator;
	else if (x.isFraction && !x.denominator)
            return HUGE_VAL;
	else
		return x.numerator;
	}

int gridOnset(double ori, RubatoFract msh, RubatoFract x)	/*Quantisation due to grid*/
	{
	if(msh.isFraction && msh.numerator)
		return metro_round((eval(x)-ori)*msh.denominator/msh.numerator);
	else if (!msh.numerator)
		return 0x7ffffff; // maximal integer (INFINITY)
	else
		return metro_round((eval(x)-ori)/msh.numerator);
	}

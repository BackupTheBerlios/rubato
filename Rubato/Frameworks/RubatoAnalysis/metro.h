/*metro.h*/
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
// NSGeometry (included in RubatoTypes.h) has Problems with pure C-Code.
// NO_NS removes some Definitions from RubatoTypes
// 10.12.99 not any more... hmm
//#define NO_NS
#import <Rubato/RubetteTypes.h>
//#undef NO_NS

typedef struct {
			RubatoFract *Fronsets;
			size_t length;
							} FractList;

typedef struct {
 			int n;
			int p;
							} loclim;
							
typedef struct {
			double param;
			double weight;
							} weightPoint;

typedef struct {
			weightPoint *wP;
			size_t length;
							} weightList;

typedef struct {
			double value;
			weightList wL;
							} scaList;
							
typedef struct {
			scaList *distributor;
			size_t length;
							} distributorList;

typedef struct {
			double origin;
			RubatoFract mesh;
							} grid;
							
typedef struct {
			FractList PRE;
			double DIS;
			grid GRD;
							} preDisGrid;



/*Extending a one-dimensional weightList by one weightPoint*/
weightList ExtWeightPoint(weightList,weightPoint);

/*Extending a weightList by another weightList*/
weightList ExtWeightList(weightList, weightList);

/*linear scaling of a scaList*/
weightList scale(scaList);

/*Uniting a distributorList*/
weightList UniDistributor(distributorList);

/*Mesh existence from index to the right wihin onset pointer*/
int PosExt(int *, int, int, int);

/*Mesh existence from index to the left wihin onset pointer*/
int NegExt(int *, int, int);

/*Maximal positive and negative multiplicities
for a mesh and index within onsets to define a local meter*/
loclim maxmeshlim(int *, int, int, int);

/*Return the really maximal local meters, else {-1,-1}*/
loclim maxlim(int *, int, int, int);

/*The weight of an index in onsets, as related to the lower limit length
of local meters and to a metrical profile*/
double weight(int *, int, int, int, double);

/*Make a scaList from a quantList, a value, a limit and a profile*/
scaList makescaList(quantList, double, int, double);

/*Member test for integer pointer List and integer x*/
BOOL ISMember(int *, int, int);

/*least common multiple of two integers*/
int lcm(int, int);

/*least common multiple of an integer pointer of given length*/
int LCM(int *, int);

/*largest common divisor of two integers*/
int lcd(int, int);

/*largest common divisor of an integer pointer of given length*/
int LCD(int *, int);

/*eliminates repetitions of onsets*/
quantList clean(quantList);

/*Make quantList out of FractList*/
quantList makequantList(FractList, double, RubatoFract, BOOL);

/*round a double to ceiling from floor-difference 0.5 on*/
// jg named metro_round instead of round, because round is in conflict with HarmoRubette.subproj::round().
int metro_round(double);

/*Evaluation of a Fract object*/
double eval(RubatoFract x);

/*Quantizing of one Fract point according to grid*/
int gridOnset(double, RubatoFract, RubatoFract);	

/*BOOLean decision for existence of is.Fraction elements in FractList*/
BOOL ISFr(FractList);













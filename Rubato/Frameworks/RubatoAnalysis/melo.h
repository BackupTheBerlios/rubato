/*melo.h*/
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#import <AppKit/AppKit.h>

#define max(A,B) ((A)>(B)?(A):(B))
#define min(A,B) ((A)<(B)?(A):(B))


#define DIASTEMATIC	1
#define ELASTIC		2
#define RIGID		3

#define IDENTITY		1
#define RETROGRADE		2
#define INVERSION		3
#define COUNTERPOINT	4

#define genMotifList(l) genMotifLayer(&genMotifList, l)

typedef struct {
			double para1;
			double para2;
							} M2D_Point;
							
typedef struct {
			M2D_Point *M2D_comp;
			size_t length;
			double presence;
			double content;
			double weight;
							} M2D_compList;
							
typedef struct {
			M2D_compList *M2D_powcom;
			size_t length;
							} M2D_powcomList;
																												
typedef struct {
			M2D_powcomList *layer;
			size_t length;
			double span;
			int card;
							} M2D_motifList;
																												
typedef struct {
			M2D_Point M2D_Pt;
			double weight;
							} M2D_weightPoint;
							
typedef struct {
			M2D_weightPoint *M2D_wP;
			size_t length;
							} M2D_weightList;

typedef struct {
			M2D_weightList *M2D_wList;
			size_t length;
							} M2D_weightDistributorList;
/* sign of difference a - b */
int sig(double, double);

/*Make a List out of one point*/
M2D_compList PtList(M2D_Point);

/*Prepend one motif if it is not the {NULL, 0}*/
M2D_powcomList preMotif(M2D_compList, M2D_powcomList);

/*Insert one 2D point into onset-ordered motif with span condition*/
M2D_compList insPoint(M2D_Point *, M2D_compList, double);

/*Rest of list*/
M2D_compList restList(M2D_compList);

/*Generate the list of all sub-melodies of list cL 
 *with determined cardinality and upper span limit 
 */
M2D_powcomList genPow(M2D_compList, M2D_motifList *, double, int);

/*Access layers of the genMotifList*/
M2D_powcomList genMotifLayer(M2D_motifList *, int);

/*Difference between two points*/
M2D_Point diff(M2D_Point, M2D_Point);

/*Sum of two points*/
M2D_Point add(M2D_Point, M2D_Point);

/*inversion of non-empty melody at pitch f*/
M2D_compList inversion(M2D_compList, double);

/*inversion of non-empty melody at initial sound event pitch*/
M2D_compList initinversion(M2D_compList);

/*retrograde of non-empty melody at time t*/
M2D_compList retrograde(M2D_compList, double);

/*retrograde of non-empty melody at middle time*/
M2D_compList midretrograde(M2D_compList);

/*Square 2-norm of one M2D-point*/
double M2D_ptNorm(M2D_Point);		

/*2-norm of one M2D-point*/
double M2D_ptsqrtNorm(M2D_Point);

/*Square averaged norm of a non-empty list of M2D-points*/	
double compNorm(M2D_compList);  

/*minimal distance shift vector for non-empty list cL*/
M2D_Point minDist(M2D_compList);

/*Count motifs containing a given motif within a list pL*/
int countSubmotifs(M2D_compList, M2D_powcomList);

/*Epsilon neighborhood of a motif1 within a given list of motifs having length of motif1*/
int EpsiCount(M2D_compList, M2D_powcomList, double, int, int);

/*Definition of membership number in list*/
int ptMemberNumber(int, M2D_Point, M2D_compList);

/*Definition of indexed membership in list*/
BOOL ptIndexMember(int, M2D_Point, M2D_compList);

/*Check whether every item of list cLL is contained in list cLM*/
BOOL compMember(M2D_compList, M2D_compList);

/*Gestalt of a motif of at least two points according to diastematic 
 *paradigm*/
 int *diaGestalt(M2D_compList);

/*Ratio of lengths between two successive difference vectors and angle of
 *difference vector in a motif of length at least 2
 */
M2D_compList elastGestalt(M2D_compList);

/*Preliminary function rigiDist, length of motif non-zero*/
double rigiDist(M2D_compList, M2D_compList);

/*Diastematic epsion neigborhood*/
BOOL diastemParadigm(M2D_compList, M2D_compList, double, int);

/*Elastic epsion neigborhood*/
BOOL elastParadigm(M2D_compList, M2D_compList, double, int);

/*Elastic epsion neigborhood*/
BOOL rigidParadigm(M2D_compList, M2D_compList, double, int);

/*Define BOOLean epsilon neighborhood relationship of two motifs
 *of equal length, relating to gestalt paradigm and (counterpoint sub)group.
 */ 
BOOL epsilonRelation(M2D_compList, M2D_compList, double, int, int);

/*The l_presence of a motif within list genMotifList(?) of motifs of lengths ?, suppose l is larger than length of motif*/
double l_presence(M2D_compList, M2D_motifList, double, int, int, int);
				
/*The l-content of a motif within a composition, l supposed smaller than length of motif*/
double l_content(M2D_compList, M2D_motifList, double, int, int, int);

/*Update presence, content and weight of a motif within a genMotifList*/
M2D_compList weightedMotif(M2D_compList, M2D_motifList, 
				double, int, int, int);

/*Update genMotifList*/
M2D_motifList weightedGenMotifList(M2D_motifList, double, int, int, int);

/*Merge a motif to a meloweightlist*/
M2D_weightList mergeMotif(M2D_weightList, M2D_compList); 

/*Merge a list of motifs to a meloweightlist*/
M2D_weightList mergeMeloWeightList(M2D_weightList, M2D_powcomList);

/*Default WeightList*/
M2D_weightList defaultList(M2D_compList);

/*The weightlist for one predicate composition and genMotifList(?)*/
M2D_weightList meloWeightList(M2D_compList, M2D_motifList, double, int, int, int);

/*Clean M2D_compList composition from repetitions*/
M2D_compList M2D_clean(M2D_compList);

/*Extending a two-dimensional, non-empty weightList by one weightPoint*/
M2D_weightList M2D_ExtWeightPoint(M2D_weightList, M2D_weightPoint);

/*Extending a two-dimensional M2D_weightList L1 by a M2D_weightList L2*/
M2D_weightList M2D_ExtWeightList(M2D_weightList, M2D_weightList);

/*Uniting a two-dimensional distributorWeightList LL*/
M2D_weightList M2D_UniDistributor(M2D_weightDistributorList);

/*Building the M2D_weightDistributorList from BigMeloList*/
M2D_weightDistributorList M2D_WeightDistributor(M2D_powcomList, double, int, int, int, double);

/*The final meloweight from a BigMeloList*/
M2D_weightList BigMeloWeightList(M2D_powcomList, double, int, int, int, double);



#include "melo.h"
    
M2D_compList meloList;	/*A "melody" predicate containing 
				 		 *double-parametrized 2D resp. onset-pitch points. 
						 *The list contains its points only once, and, 
				 		 *if possible, but not necessarily, ordered according to
				 		 *the lexicographic order of (onset,pitch).
						 */
M2D_powcomList BigMeloList; /*A list of "melody" predicates*/
double epsilon;			/*The neighborhood radius*/
int paradigm;			/*The integer representing one of the three types of shape and distance.
						 *1 = diastematic index, 2 = elastic, 3 = rigid.*/
int group;				/*Ond of the usual subgroups of the counterpoint group:
						 *'I' = identity, 
						 *'K' = <retrograde>, 
						 *'U' = <inversion>, 
						 *'KU' = full counterpoint group*/ 
int card;				/*The lower limit of cardinality of motifs to be considered, card= 2 is default*/
double span;			/*The upper limit of distance between first and last onset of a motif©s point*/




main()
	{
	BigMeloWeightList(BigMeloList,epsilon,paradigm,group,card,span); /*The new one for a list of melodies*/
	MeloWeightList(MeloList,epsilon,paradigm,group,card,span); /*The old (present...) one for a single melody*/
	}
	
	 

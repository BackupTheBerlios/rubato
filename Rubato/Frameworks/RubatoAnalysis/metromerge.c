/*metromerge.c*/
#include "metro.h"

/*Extending a one-dimensional weightList by one weightPoint*/
weightList ExtWeightPoint(weightList L, weightPoint P)
	{
			int i, j, t;
			for(i = 0;(P.param >= (L.wP+i)->param) && (i < L.length);i++)	
				;
				i -= 1;
			/* 
			 *This continues, until the onset
			 *of point P < onset of point i of L.
			 *Subtract 1: P >= i-th onset.  
			 */

			if(i < 0) /*First case: already Listpoint[0] is > P. P must now inserted before L */ 
				{
				L.wP = realloc(L.wP,sizeof(weightPoint)*(++L.length)); 
				for(j = L.length-1; 0 < j;j--)
					*(L.wP+j) = *(L.wP+j-1);
				*L.wP = P;
				}
			else /*Point P is above (<=) the i-th and below (<) the i+1-th Listpoint. 
				  *The i-th can also be the last one of L.
				  */
				{
				if(P.param == (L.wP+i)->param)	/*If P sits on top of the i-th Point, all weights are  added,
												 *List keeps its length.
												 */
					(L.wP+i)->weight += P.weight;
				
				else{	/*P sits between i. and i+1. Listpoint: enlarge List by 1, insert P.*/
					L.wP = realloc(L.wP,sizeof(weightPoint)*(++L.length)); 
					for(t = L.length-1; t >= i+2; t--)
						*(L.wP+t) = *(L.wP+t-1);
					*(L.wP+i+1) = P;
					}
				}
			return L;
	}


/*Extending a weightList L1 by a weightList L2*/
weightList ExtWeightList(weightList L1,weightList L2)
	{		
			weightList E = ExtWeightPoint(L1,*L2.wP);
			int i;
			for(i = 1;i < L2.length;i++)
				E = ExtWeightPoint(E,*(L2.wP+i));
			return E;
	}
		

/*linear scaling of a scaList*/
weightList scale(scaList SL)
	{
		int i;
		weightList L = SL.wL;
		for(i = 0;i < L.length;i++)
			(L.wP+i)->weight *= SL.value;
		return L;
	}
	
	
/*Uniting a distributorList LL*/
weightList UniDistributor(distributorList LL)
		{
			int i;
			scaList *D = LL.distributor;
			weightList UNION = scale(*D);
			for(i = 1;i < LL.length;i++)
				UNION = ExtWeightList(UNION,scale(*(D+i)));
			return UNION;
		}
	


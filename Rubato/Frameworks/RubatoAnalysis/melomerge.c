/*melomerge*/
#include "melo.h"



/*This one would consist in merging the data of a M2D_powcomList BigMeloList
 *in some way in order to get a global version of calculating meloweights.
 */

/*Extending a two-dimensional, non-empty weightList by one weightPoint*/
M2D_weightList M2D_ExtWeightPoint(M2D_weightList L, M2D_weightPoint P)
	{
	int i;
	for(i = 0; 
			(i < L.length) && 
			!(
				(((L.M2D_wP+i)->M2D_Pt).para1 == P.M2D_Pt.para1) && 
				(((L.M2D_wP+i)->M2D_Pt).para2 == P.M2D_Pt.para2)
			); 
		i++)
		;
	if(i < L.length)
		(L.M2D_wP+i)->weight += P.weight;
	
	else
	{
	L.M2D_wP = realloc(L.M2D_wP, ++L.length * sizeof(M2D_weightPoint));
	*(L.M2D_wP+L.length-1) = P;
	}
	
	return L;
	}



/*Extending a two-dimensional M2D_weightList L1 by a M2D_weightList L2*/
M2D_weightList M2D_ExtWeightList(M2D_weightList L1, M2D_weightList L2)
	{		
			M2D_weightList E = M2D_ExtWeightPoint(L1,*L2.M2D_wP);
			int i;
			for(i = 1;i < L2.length;i++)
				E = M2D_ExtWeightPoint(E,*(L2.M2D_wP+i));
			return E;
	}





/*Uniting a two-dimensional distributorWeightList LL*/
M2D_weightList M2D_UniDistributor(M2D_weightDistributorList LL)
		{
			int i;
			M2D_weightList UNION = *LL.M2D_wList;
			for(i = 1;i < LL.length;i++)
				UNION = M2D_ExtWeightList(UNION,*(LL.M2D_wList+i));
			return UNION;
		}
		
/*Building the M2D_weightDistributorList from BigMeloList*/
M2D_weightDistributorList M2D_WeightDistributor(M2D_powcomList BigMeloList,
							double epsilon, int paradigm, int group, int card, double span)
	{
	int i;
	M2D_weightList *X = calloc(BigMeloList.length,sizeof(M2D_weightList));
	M2D_weightDistributorList D = {X, BigMeloList.length};
	for(i = 0; i < BigMeloList.length; i++)
		; // jg:added semicolon. //*(D.M2D_wList+i) = meloWeightList(*(BigMeloList.M2D_powcom+i),epsilon,paradigm,group,card,span);
	return D;
	}

/*The final meloweight from a BigMeloList*/
M2D_weightList BigMeloWeightList(M2D_powcomList BigMeloList,
							double epsilon, int paradigm, int group, int card, double span)
	{
	return M2D_UniDistributor(M2D_WeightDistributor(BigMeloList,epsilon,paradigm,group,card,span));
	}




/*meloweight*/
#include "melo.h"


/*The l_presence of a motif within list genMotifList(?) of motifs of lengths ?, suppose ? is larger than length of motif*/
double l_presence(M2D_compList motif, M2D_motifList genMotifList,  
				double epsilon, int paradigm, int group, int l)
 	{
	int i, c = 0;	
	for(i = 0; i < (genMotifList(motif.length)).length; i++)
		{
		if(epsilonRelation(motif,(genMotifList(motif.length)).M2D_powcom[i],epsilon,paradigm,group)) 
		c += countSubmotifs((genMotifList(motif.length)).M2D_powcom[i],genMotifList(l));
		}
	return (double)c * pow(2.0,(double) motif.length - (double) l);
	}



/*The l-content of a motif within a composition, l supposed smaller than length of motif*/
double l_content(M2D_compList motif, M2D_motifList genMotifList, 
				double epsilon, int paradigm, int group, int l)
 	{
	int i, c = 0;
	for(i = 0; i < (genMotifList(l)).length; i++)
		{
		if(compMember((genMotifList(l)).M2D_powcom[i], motif)) 
		c += EpsiCount((genMotifList(l)).M2D_powcom[i], genMotifList(l),epsilon,paradigm,group);
		}
	return (double)c * pow(2.0,(double)l- (double) motif.length);
	}


/*Update presence, content and weight of a motif within a genMotifList*/
M2D_compList weightedMotif(M2D_compList motif, M2D_motifList genMotifList, 
				double epsilon, int paradigm, int group, int card)
 	{
	int l, m;
	double	p, c;
	p = c = (double)EpsiCount(motif,genMotifList(motif.length),epsilon,paradigm,group);	

	for(l = motif.length+1; l <= card; l++)
		p += l_presence(motif,genMotifList,epsilon,paradigm,group,l);

	motif.presence = p;	

	for(m = min((int)motif.length-1,card); m > 1; m--)
		c += l_content(motif,genMotifList,epsilon,paradigm,group,m);
	
	motif.content = c;

	motif.weight = p*c;

	return motif;
	}
	
/*Update genMotifList*/
M2D_motifList weightedGenMotifList(M2D_motifList genMotifList, 
				double epsilon, int paradigm, int group, int card)
	{
	int i,j;
	for(i = 2; i <= card; i ++) 
		{
		for(j = 0; j < genMotifList(i).length; j++)
			*(genMotifList(i).M2D_powcom+j) = 
			weightedMotif(*(genMotifList(i).M2D_powcom+j),genMotifList,epsilon,paradigm,group,card);
		}
	return genMotifList;
	}
	
	
/*Merge a motif to a meloweightlist*/
M2D_weightList mergeMotif(M2D_weightList L, M2D_compList Motif) 
	{
	int i,j;
	for(i = 0; i < Motif.length; i++)
		{
		for(j = 0; (j < L.length) && 
			!( 
			(((L.M2D_wP+j)->M2D_Pt).para1 == (Motif.M2D_comp+i)->para1) &&
			(((L.M2D_wP+j)->M2D_Pt).para2 == (Motif.M2D_comp+i)->para2)
			);
		 j++);
		(L.M2D_wP+j)->weight += Motif.weight;
		}
	return L;
	}
		

/*Merge a list of motifs to a meloweightlist*/
M2D_weightList mergeMeloWeightList(M2D_weightList L, M2D_powcomList MotifList)
	{
	int i;
	for(i = 0; i < MotifList.length; i++)
		L = mergeMotif(L, MotifList.M2D_powcom[i]);
	return L;
	}	

/*Default WeightList*/
M2D_weightList defaultList(M2D_compList Co)
	{
	int i;
	M2D_weightList L;
	Co = M2D_clean(Co); 
	L.length = Co.length;
	L.M2D_wP = calloc(Co.length,sizeof(M2D_weightPoint));
	for(i = 0; i < Co.length; i++)
		{
		(L.M2D_wP+i)->M2D_Pt = Co.M2D_comp[i];
		(L.M2D_wP+i)->weight = 0;
		}
	return L;
	}


/*The weightlist for one predicate composition and genMotifList(?)*/
M2D_weightList meloWeightList(M2D_compList Composition, M2D_motifList genMotifList, 
				double epsilon, int paradigm, int group, int card)
	{
	int l;
	M2D_weightList L = defaultList(Composition);
	for(l = 2; l <= card; l++)
			L = mergeMeloWeightList(L,genMotifList(l));
	
	return L;
	}
/*metroweight.c*/
#include "metro.h"

/*This functions decides upon mesh existence from index to the right wihin onset*/
int PosExt(int *onsets, int length, int index, int mesh)
	{
		int r,j;
		int *oi = onsets+index;
		if(mesh == 0)
			r = 1;
		else
			{
			for(j = 0;
				(((*(oi+j)-*oi) != mesh) || ((*(oi+j)-*oi) == 0)) && (j+index < length);
				j++)
				;
			r = ((index+j) < length);
			}
		return r;
	}
		
/*This functions decides upon mesh existence from index to the left wihin onset*/
int NegExt(int *onsets, int index, int mesh)
	{
		int r,j;
		int *oi = onsets+index;
		if(mesh == 0)
			r = 1;
		else
			{
			for (j = 0;
				(((*oi-*(oi-j)) != mesh) || ((*oi-*(oi-j)) == 0)) && (j <= index);
				j++)
				;
			r = (j <= index);
			}
		return r;
	}
	
	
/*Define maximal positive and negative multiplicities\
for a mesh and index within onsets to define a local meter*/
loclim maxmeshlim(int *onsets, int length, int index, int mesh)
 	{
		loclim point;
		int i,j;
		for(i = 0;PosExt(onsets,length,index,i*mesh);i++)
			;
		point.p = i-1;
		for(j = 0;NegExt(onsets,index,j*mesh);j++)
			;
		point.n = j-1;
		return point;
	}
	

/*Return the really maximal local meters, else {-1,-1}*/
loclim maxlim(int *onsets,int length,int index,int mesh)
	{
		int m;
		loclim k,l,t;
		for(m = 1; 
			(m < mesh)&&
			(
				mesh%m!=0 || 
				m*(k = maxmeshlim(onsets,length,index,m)).n <
				mesh*(l = maxmeshlim(onsets,length,index,mesh)).n ||
				m*k.p < mesh*l.p 
			);
			m++)
			;
		if (m == mesh)
		t = maxmeshlim(onsets,length,index,mesh);
		else 
		t.p = t.n = -1;
		return t;
	}

	

	

/*The weight of an index in onsets, as related to the lower limit length\
of local meters and to a metrical profile*/
double weight(int *onsets, int length, int index, int limit, double profile)
	{
		double w = 0; /*Initial weight*/
		int NP,m;
		loclim point;	
		for (m = 1;limit*m <= (*(onsets+length-1)-*onsets);m++)
			{
			point = maxlim(onsets,length,index,m);
			NP = point.n+point.p;
			if(NP < limit)
				;
			else
				w = w+pow(NP,profile);
			}
		return w;
	}
	
/*Make a scaList from a quantList, a value, a limit and a profile*/
scaList makescaList(quantList qL, double val, int limit, double profile)
	{
		int i;
		weightPoint *w = calloc(qL.length, sizeof(weightPoint));
		weightList mwL;
		scaList scL;
		mwL.wP = w;
		mwL.length = qL.length;
		scL.value = val;
		scL.wL = mwL;

		for(i=0;i < qL.length;i++)
			{
			(mwL.wP+i)->param = qL.origin + *(qL.onsets+i)*eval(qL.mesh);
			(mwL.wP+i)->weight = weight(qL.onsets,qL.length,i,limit,profile);
			}
		scL.wL = mwL;	

		return scL;
	}

/*metroquant.c*/
#include "metro.h"

/* Given a pointer to fractional onsets, 
 * together with an origin and a mesh, 
 * calculate the associated quantList.
 * We suppose that no infinite fraction 
 * (= zero denominator) is present, 
 * that the onsets are ordered according 
 * to their numeric order, ie. evaluating 
 * the fraction and that the mesh is finite 
 * and different from zero.
 */
 
/*The decision value for quantization: Automatic == YES is for ggt-kgV-Method*/

/*BOOLean decision for existence of !is.Fraction elements in pointer to Fract*/
BOOL ISFr(FractList frList)
	{
	int i;
	for(i=0;(i<frList.length)&&(frList.Fronsets+i)->isFraction;i++)
			;
	return i==frList.length;
	}
	
/*Member test for integer pointer List and integer x*/
BOOL ISMember(int *Lst, int limit, int x)
	{
	int i;
	for(i = 0; (i< limit) && (int)Lst[i] != x; i++)
	;
	return i < limit;
	}
	
	
quantList clean(quantList Q)
	{
	int i, j, m;
	quantList T;
	if(Q.length == 1)
		return Q;
	else if(ISMember(Q.onsets,Q.length-1,*(Q.onsets+Q.length-1)))
		{
		Q.length -= 1;
		return clean(Q);
		}
	else
		{
		m = *(Q.onsets+Q.length-1);
		Q.length -= 1;
		T = clean(Q);
		for(i = (int)T.length-1; (i >= 0) && m < *(T.onsets+i); i--)
		;
			for(j = T.length;  i+2 <= j; j--)
				*(T.onsets + j) = *(T.onsets + j - 1);
		*(T.onsets+i+1) = m;  

		T.length += 1;
		return T;
		}
	}
		
quantList makequantList(FractList frList, double ori, RubatoFract msh, BOOL Automatic)
	{
		int i;
		int *num = calloc(frList.length, sizeof(int));
		int *denom = calloc(frList.length, sizeof(int));
		int *oo = NULL;
		int *ons = NULL;
		quantList QL = {0,{1,0,0},oo,0};
		ons = num;
		
		/*denom = calloc(frList.length, sizeof(int));
		num   = calloc(frList.length, sizeof(int));*/
		for(i = 0;i < frList.length;i++)
			{
			*(denom+i) = (frList.Fronsets+i)->denominator;
			*(num+i) = (frList.Fronsets+i)->numerator;
			}

		if(	 !msh.isFraction ||						/*Double method*/
			 (msh.isFraction &&  ori) ||
			 (msh.isFraction && !ori && !ISFr(frList)) ||
			 (msh.isFraction && !ori &&  ISFr(frList) && !Automatic)
		  )	
			{
				for(i = 0;i < frList.length;i++)
					*(ons+i) = gridOnset(ori,msh,*(frList.Fronsets+i));
			}
			
		else	/*Fraction method for Automatic grid re-definition*/
			{
				for(i = 0;i < frList.length;i++)
					*(num+i) *= LCM(denom, frList.length)/(frList.Fronsets+i)->denominator;

				msh.numerator = LCD(num, frList.length);
				msh.denominator = LCM(denom, frList.length);

				for(i = 0;i < frList.length;i++)
					*(ons+i) = *(num+i)/LCD(num, frList.length);
			}
	

		QL.origin 	= ori;
		QL.mesh 	= msh;
		QL.onsets 	= ons;
		QL.length 	= frList.length;

		return clean(QL);
	}
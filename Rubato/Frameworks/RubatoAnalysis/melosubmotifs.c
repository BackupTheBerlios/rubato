/*melosubmotifs*/
#include "melo.h"

/*Make a motif out of one point*/
M2D_compList PtList(M2D_Point P)
	{
	M2D_compList L;
	L.M2D_comp = calloc(1,sizeof(M2D_Point)); 
	*L.M2D_comp = P;
	L.length = 1;
	L.presence = 0;
	L.content = 0;
	L.weight = 0;
	return L;
	}

/*Prepend one motif if it is not the {NULL, 0}*/
M2D_powcomList preMotif(M2D_compList mot, M2D_powcomList cL)
	{
	int i;
	M2D_powcomList dL;
	if(mot.length == 0)
	return cL;

	else if(cL.length == 0)
		{
		dL.M2D_powcom = calloc(1,sizeof(M2D_compList));
		dL.length = 1;		
		*dL.M2D_powcom = mot;
	return dL;
		}

	else
		{
		dL.length = cL.length+1;
		dL.M2D_powcom = realloc(cL.M2D_powcom, (cL.length+1)*sizeof(M2D_compList));
		for(i = dL.length-1; i >= 1; i--)
			*(dL.M2D_powcom+i) = *(dL.M2D_powcom+i-1);
		*dL.M2D_powcom = mot;
	return dL;
		}
	}
	


/*Insert one 2D point into onset-ordered motif with span condition*/
M2D_compList insPoint(M2D_Point *P, M2D_compList L, double span)
	{
	int i, t;
	M2D_compList LL= {NULL, 0};
	 
		for(i = 0;(i < L.length) && (P->para1 >= (L.M2D_comp+i)->para1);i++)	
			;
		/*i = first index with P.para1 < (L.M2D_comp+i)->para1*/

	if(	!L.length ||
		((max(P->para1,(L.M2D_comp+L.length-1)->para1) - 
		  min(P->para1,(L.M2D_comp)->para1)) > span) ||
		((i > 0) && (P->para1 == (L.M2D_comp + i-1)->para1))
	  )
		;/*Do nothing. The pathological cases: L empty or span violated or P is already in L*/
	
	else	/*P is a real candidate to be inserted after the ith entry within L*/
		{
		LL.length = L.length+1;
		LL.M2D_comp = calloc(LL.length,sizeof(M2D_Point)); 
		for(t = LL.length-1; t > i; t--)
			*(LL.M2D_comp+t) = *(L.M2D_comp+t-1); /* copy list from end to i+1-th position */
		*(LL.M2D_comp+i) = *P;
		for(t = 0; t < i; t++)
			*(LL.M2D_comp+t) = *(L.M2D_comp+t); /* copy list from 0 to i-1 */

		}
		return LL;
	}


/*Rest of list*/
M2D_compList restList(M2D_compList L)
	{
	if (!(L.length <= 1)) {
	    L.length = L.length-1;
	    L.M2D_comp = L.M2D_comp+1;	
	    }
	else
	    L = (M2D_compList){NULL, 0};
	    return L;
	}
	

/*Generate the list of all sub-melodies of list cL 
 *with determined cardinality and upper span limit 
 */
M2D_powcomList genPow(M2D_compList cL, M2D_motifList *genMotifList, double span, int card)
	{
	int i, j;
	M2D_powcomList TL, Temp = {NULL, 0};
	
	if(					/*pathological cases, return {NULL, 0}*/
		card <= 0 ||
		span < 0 ||
		cL.length == 0
	  )						
	return (M2D_powcomList){NULL, 0}; 


	if (!	(genMotifList->card >= card &&
		 genMotifList->span == span)
	) {
	
	    if (card == 1)	/*Non-pathological default: span >= 0, cL!={NULL, 0}*/
	    {
		Temp.M2D_powcom = calloc(cL.length,sizeof(M2D_compList));
		Temp.length = cL.length;
		
		for(i = 0; i < cL.length; i++)
		    *(Temp.M2D_powcom+i) = PtList(*(cL.M2D_comp+i));
	    }
    
	    else	/*Normal cases, i.e. card > 1, span >= 0, cL!={NULL, 0}*/
	    {
              if (genMotifList->span == span && genMotifList->card >= card) // guerino: code is garbage! this case is not possible (see above)! should be: genMotivList->card-1.
		    TL = genMotifLayer(genMotifList, card-1); /* we can just access the list */
		else
		    TL = genPow(cL, genMotifList,span,card-1);/* we have to calculate the next lower layer */
		
		for(i = TL.length-1; i >= 0; i--) {
		    for (j = cL.length-1; j >= 0; j--) {
			if (cL.M2D_comp[j].para1>TL.M2D_powcom[i].M2D_comp[TL.M2D_powcom[i].length-1].para1)
			    Temp = preMotif(insPoint(cL.M2D_comp+j,TL.M2D_powcom[i],span), Temp);				
		    }
		}
	    }
	    genMotifList->card = card;
	    genMotifList->span = span;
	    genMotifList->layer[card] = Temp;
	}		
	return genMotifList->layer[card]; 			
    }
	


/*Access layers of the genMotifList*/
M2D_powcomList genMotifLayer(M2D_motifList *mL, int l)
	{
	if(mL->layer && l<mL->length)
		return mL->layer[l];
	else
		return (M2D_powcomList){NULL,0};
			    
	}


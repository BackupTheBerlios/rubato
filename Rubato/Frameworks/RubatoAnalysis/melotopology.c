/*melotopology*/
#include "melo.h"


/*Square 2-norm of one M2D-point*/
double M2D_ptNorm(M2D_Point P)		
	{
	return pow(P.para1,2)+pow(P.para2,2);
	}
	
/*2-norm of one M2D-point*/
double M2D_ptsqrtNorm(M2D_Point P)		
	{
	return sqrt(M2D_ptNorm(P));
	}

/*Square averaged norm of a non-empty list of M2D-points*/	
double compNorm(M2D_compList cL)  
	{
	int i;
	double n = 0;
	for(i = 0; i < cL.length; i++)
		n += M2D_ptNorm(*(cL.M2D_comp+i));
	return n/cL.length;
	}
	
/*minimal distance shift vector for non-empty list cL*/
/*Nestke: neg. arithm. Mittel?*/
M2D_Point minDist(M2D_compList cL)
	{
	M2D_Point P = {0,0};
	int i;
	for(i =0; i < cL.length; i++)
		{
		P.para1 -= (cL.M2D_comp+i)->para1;	
		P.para2 -= (cL.M2D_comp+i)->para2;
		}
		P.para1 /= cL.length;	//jg:formatting?
		P.para2 /= cL.length;
	return P;
	}

/*Gestalt of a motif of at least two points according to diastematic 
 *paradigm*/
int *diaGestalt(M2D_compList cL)
	{
	int i;
	int *tmp = calloc(cL.length-1,sizeof(int));
	
	for(i = 0; i < cL.length-1; i++)
	*(tmp+i)=sig((cL.M2D_comp+i+1)->para2,(cL.M2D_comp+i)->para2); 

	return tmp;
	}

/*Ratio of lengths between two successive difference vectors and angle of
 *difference vector in a motif of cardinality at least 3
 */
/*Nestke:  Winkel zur E-Achse*/
M2D_compList elastGestalt(M2D_compList cL) 
	{
	int i;
	M2D_compList gestalt;
	
	gestalt.M2D_comp = calloc(cL.length-1, sizeof(M2D_Point));
	gestalt.length = cL.length-1;

	for(i=0; i < cL.length-2; i++) /*case of three successive points for length ratio*/
	{
	(gestalt.M2D_comp+i)->para1 = atan(
			diff(*(cL.M2D_comp+i+1),*(cL.M2D_comp+i)).para2/
			diff(*(cL.M2D_comp+i+1),*(cL.M2D_comp+i)).para1);
	(gestalt.M2D_comp+i)->para2 = M2D_ptsqrtNorm(diff(*(cL.M2D_comp+i+2),*(cL.M2D_comp+i+1)))/
							  M2D_ptsqrtNorm(diff(*(cL.M2D_comp+i+1),*(cL.M2D_comp+i)));
	}
	
	/*Last angle and concluding, negative symbolic ratio*/
	(gestalt.M2D_comp+cL.length-2)->para1 = atan(
			diff(*(cL.M2D_comp+cL.length-1),*(cL.M2D_comp+cL.length-2)).para2/
			diff(*(cL.M2D_comp+cL.length-1),*(cL.M2D_comp+cL.length-2)).para1);
	(gestalt.M2D_comp+cL.length-2)->para2 = -1;
	
	return gestalt;
	}
	 
	 
/*OLD Preliminary function rigiDist, length of motif non-zero
double rigiDist(M2D_compList motif1, M2D_compList motif2)
			{
			int i;
			double cN;
			M2D_Point m;
			M2D_compList temp;
			temp.M2D_comp = calloc(motif1.length, sizeof(M2D_Point));
			temp.length = motif1.length;
			for(i = 0; i < motif1.length; i++)
				*(temp.M2D_comp+i) = diff(*(motif2.M2D_comp+i),*(motif1.M2D_comp+i));
			m = minDist(temp);
			for(i = 0; i < motif1.length; i++)
				*(temp.M2D_comp+i) = add(*(temp.M2D_comp+i),m);
			cN = compNorm(temp);
			free(temp.M2D_comp);
			return cN;
			}
OLD*/

/*Preliminary function rigiDist, length of motif non-zero*/
double rigiDist(M2D_compList motif1, M2D_compList motif2)
			{
			int i;
			double 	cN = 0,
				diffi1,
				diffi2,
				r1 = 0,
				r2 = 0;

			for(i = 0; i < motif1.length; i++){
			    r1 -= (motif2.M2D_comp+i)->para1 - (motif1.M2D_comp+i)->para1;	
			    r2 -= (motif2.M2D_comp+i)->para2 - (motif1.M2D_comp+i)->para2;
			    }
			    r1 /= motif1.length;	
			    r2 /= motif1.length;

			for(i = 0; i < motif1.length; i++){
			    diffi1 = (motif2.M2D_comp+i)->para1 - (motif1.M2D_comp+i)->para1; 
			    diffi2 = (motif2.M2D_comp+i)->para2 - (motif1.M2D_comp+i)->para2; 
			    cN += pow(diffi1 + r1,2)+pow(diffi2 + r2,2);
			    }

			return cN;
			}


/*OLD Diastematic epsion neigborhood
BOOL diastemParadigm(M2D_compList motif1, M2D_compList motif2,
				double epsilon, int group)
		{
		BOOL ISEPSI = NO;
		int i; 
		double d = 0, e = 0, f = 0, g = 0;
		int *gestalt1 = diaGestalt(motif1);
		int *gestalt2 = diaGestalt(motif2);   
		switch(group)
		{
		case IDENTITY:
			{
			for(i = 0; i < (int)motif1.length-1; i++)
				d += pow(gestalt1[i] - gestalt2[i],2);
				ISEPSI = epsilon > d/motif1.length;
			}
			break;		

		case RETROGRADE:	
			{
			for(i = 0; i < (int)motif1.length-1; i++)
				{
				d += pow(gestalt1[i] - gestalt2[i],2);
				e += pow(*(gestalt1+motif1.length-i-2) + 
						 gestalt2[i],2);
				}
				ISEPSI = epsilon > min(d,e)/motif1.length;
			}
			break;		

		case INVERSION:	
			{
			for(i = 0; i < (int)motif1.length-1; i++)
				{
				d += pow(gestalt1[i] - gestalt2[i],2);
				e += pow(gestalt1[i] + 
						 gestalt2[i],2);
				}
				ISEPSI = epsilon > min(d,e)/motif1.length;
			}
			break;				

		case COUNTERPOINT:	
			{
			for(i = 0; i < motif1.length-1; i++)
				{
				d += pow(gestalt1[i] - gestalt2[i],2);
				e += pow(*(gestalt1+motif1.length-i-2) + 
						 gestalt2[i],2);
				f += pow(gestalt1[i] + 
						 gestalt2[i],2);
				g += pow(*(gestalt1+motif1.length-i-2) - 
						 gestalt2[i],2);
				}						 
				ISEPSI = epsilon > min(min(d,e),min(f,g))/motif1.length;
			}
			break;		
		}
		free(gestalt1);
		free(gestalt2);

		return ISEPSI;
		}
OLD*/
		
/*Diastematic epsion neigborhood*/
BOOL diastemParadigm(M2D_compList motif1, M2D_compList motif2,
				double epsilon, int group)
		{
		BOOL ISEPSI = NO;
		int i; 
		double d = 0, e = 0, f = 0, g = 0;

		switch(group)
		{
		case IDENTITY:
			{
			for(i = 0; i < (int)motif1.length-1; i++){
			    d += 
			    pow(sig((motif1.M2D_comp+i+1)->para2,(motif1.M2D_comp+i)->para2)-
				sig((motif2.M2D_comp+i+1)->para2,(motif2.M2D_comp+i)->para2)
				,2);
				}
				ISEPSI = epsilon > d/(double)motif1.length;
			}
			break;		

		case RETROGRADE:	
			{
			for(i = 0; i < (int)motif1.length-1; i++){
			    d += 
			    pow(sig((motif1.M2D_comp+i+1)->para2,(motif1.M2D_comp+i)->para2)-
				sig((motif2.M2D_comp+i+1)->para2,(motif2.M2D_comp+i)->para2)
				,2);
			    e += 
			    pow(sig(	(motif1.M2D_comp+(motif1.length-i-2)+1)->para2,
			    		(motif1.M2D_comp+(motif1.length-i-2))->para2)+
				sig((motif2.M2D_comp+i+1)->para2,(motif2.M2D_comp+i)->para2)
				,2);
				}
				ISEPSI = epsilon > min(d,e)/(double)motif1.length;
			}
			break;		

		case INVERSION:	
			{
			for(i = 0; i < (int)motif1.length-1; i++){
			    d += 
			    pow(sig((motif1.M2D_comp+i+1)->para2,(motif1.M2D_comp+i)->para2)-
				sig((motif2.M2D_comp+i+1)->para2,(motif2.M2D_comp+i)->para2)
				,2);
			    e += 
			    pow(sig((motif1.M2D_comp+i+1)->para2,(motif1.M2D_comp+i)->para2)+
				sig((motif2.M2D_comp+i+1)->para2,(motif2.M2D_comp+i)->para2)
				,2);
				}
				ISEPSI = epsilon > min(d,e)/(double)motif1.length;
			}
			break;				

		case COUNTERPOINT:	
			{
			for(i = 0; i < motif1.length-1; i++){
			    d += 
			    pow(sig((motif1.M2D_comp+i+1)->para2,(motif1.M2D_comp+i)->para2)-
				sig((motif2.M2D_comp+i+1)->para2,(motif2.M2D_comp+i)->para2)
				,2);
			    e += 
			    pow(sig(	(motif1.M2D_comp+(motif1.length-i-2)+1)->para2,
			    		(motif1.M2D_comp+(motif1.length-i-2))->para2)+
				sig((motif2.M2D_comp+i+1)->para2,(motif2.M2D_comp+i)->para2)
				,2);
				f += 
			    pow(sig((motif1.M2D_comp+i+1)->para2,(motif1.M2D_comp+i)->para2)+
				sig((motif2.M2D_comp+i+1)->para2,(motif2.M2D_comp+i)->para2)
				,2);
				g += 
			    pow(sig(	(motif1.M2D_comp+(motif1.length-i-2)+1)->para2,
			    		(motif1.M2D_comp+(motif1.length-i-2))->para2)-
				sig((motif2.M2D_comp+i+1)->para2,(motif2.M2D_comp+i)->para2)
				,2);
				}						 
				ISEPSI = epsilon > min(min(d,e),min(f,g))/(double)motif1.length;
			}
			break;		
		}

		return ISEPSI;
		}

		
/*Elastic epsion neigborhood*/
BOOL elastParadigm(M2D_compList motif1, M2D_compList motif2,
				double epsilon, int group)
	{
	BOOL ISEPSI = NO;
	int l = motif1.length-1, i;

		switch(group)
		{
		case IDENTITY:
			{
			M2D_compList 	gestalt1 = elastGestalt(motif1), 
					gestalt2 = elastGestalt(motif2);

			for(i = 0; i < l; i++)
				gestalt1.M2D_comp[i]=diff(gestalt1.M2D_comp[i], gestalt2.M2D_comp[i]);
			ISEPSI = (epsilon > compNorm(gestalt1));

			free(gestalt1.M2D_comp);
			free(gestalt2.M2D_comp);
			
			}
			break;		
		
		
		case RETROGRADE:	
			{
			M2D_compList 	gestalt1 = elastGestalt(motif1),
					gestalt2 = elastGestalt(motif2),
					retromotif = midretrograde(motif1),
					gestalt3 = elastGestalt(retromotif);
			
			 
			for(i = 0; i < l; i++)
				{
				gestalt1.M2D_comp[i] = diff(gestalt1.M2D_comp[i],
										   		gestalt2.M2D_comp[i]);
				gestalt3.M2D_comp[i] = diff(gestalt3.M2D_comp[i],
							 					gestalt2.M2D_comp[i]);
				}
			ISEPSI = (epsilon > min(compNorm(gestalt1), compNorm(gestalt3)));

			free(gestalt1.M2D_comp);
			free(gestalt2.M2D_comp);
			free(gestalt3.M2D_comp);
			free(retromotif.M2D_comp);

			}
			break;		
		

		case INVERSION:	
			{
			M2D_compList 	gestalt1 = elastGestalt(motif1), 
					gestalt2 = elastGestalt(motif2),
					inversion = initinversion(motif1), 
					gestalt4 = elastGestalt(inversion);

			for(i = 0; i < l; i++)
				{
				gestalt1.M2D_comp[i] = diff(gestalt1.M2D_comp[i],
												gestalt2.M2D_comp[i]);
				gestalt4.M2D_comp[i] = diff(gestalt4.M2D_comp[i],
												gestalt2.M2D_comp[i]);
				}
			
			ISEPSI = (epsilon > min(compNorm(gestalt1), compNorm(gestalt4)));

			free(gestalt1.M2D_comp);
			free(gestalt2.M2D_comp);
			free(gestalt4.M2D_comp);
			free(inversion.M2D_comp);

			}
			break;		
		

		case COUNTERPOINT:	
			{
			M2D_compList 	gestalt1 = elastGestalt(motif1), 
							gestalt2 = elastGestalt(motif2),
							retromotif = midretrograde(motif1),
							inversion = initinversion(motif1), 
							retrinversion = initinversion(retromotif), 
							gestalt3 = elastGestalt(retromotif),
							gestalt4 = elastGestalt(inversion),
							gestalt5 = elastGestalt(retrinversion);

			for(i = 0; i < l; i++)
				{
				gestalt1.M2D_comp[i] = diff(gestalt1.M2D_comp[i],
										  		gestalt2.M2D_comp[i]);
				gestalt3.M2D_comp[i] = diff(gestalt3.M2D_comp[i],
							 					gestalt2.M2D_comp[i]);
				gestalt4.M2D_comp[i] = diff(gestalt4.M2D_comp[i],
												gestalt2.M2D_comp[i]);
				gestalt5.M2D_comp[i] = diff(gestalt5.M2D_comp[i],
												gestalt2.M2D_comp[i]);
				}
			
			ISEPSI = (epsilon > min(min(compNorm(gestalt1), compNorm(gestalt3)),
								 min(compNorm(gestalt4), compNorm(gestalt5))));

			free(gestalt1.M2D_comp);
			free(gestalt2.M2D_comp);
			free(gestalt3.M2D_comp);
			free(gestalt4.M2D_comp);
			free(gestalt5.M2D_comp);
			free(retromotif.M2D_comp);
			free(inversion.M2D_comp);
			free(retrinversion.M2D_comp);
			}
			break;		
		}

			return ISEPSI;		
		}

/*Rigid epsion neigborhood*/
BOOL rigidParadigm(M2D_compList motif1, M2D_compList motif2,
				double epsilon, int group)
		{
		BOOL ISEPSI = NO;

		switch(group)
		{
		case IDENTITY:
			{
			ISEPSI = epsilon > rigiDist(motif1,motif2);
			}
			break;		

		
		case RETROGRADE:	
			{
			M2D_compList 	retromotif = midretrograde(motif1);

			ISEPSI = epsilon > min(rigiDist(motif1,motif2),
					 			 rigiDist(retromotif,motif2));

			free(retromotif.M2D_comp);

			}
			break;		


		case INVERSION:	
			{
			M2D_compList 	inversion = initinversion(motif1);
			 
			ISEPSI = epsilon > 
				min(rigiDist(motif1,motif2),
					rigiDist(inversion,motif2));

			free(inversion.M2D_comp);
			}
			break;		


		case COUNTERPOINT:	
			{
			M2D_compList 	retromotif = midretrograde(motif1),
							inversion = initinversion(motif1),
							retrinversion = initinversion(retromotif);
			ISEPSI = epsilon > 
				min(
					min(rigiDist(motif1,motif2),
						rigiDist(midretrograde(motif1),motif2)),
					min(rigiDist(initinversion(motif1),motif2),
						rigiDist(initinversion(midretrograde(motif1)),motif2))
					);

			free(retrinversion.M2D_comp);
			free(inversion.M2D_comp);
			free(retromotif.M2D_comp);
			}
			break;		
		}

	return ISEPSI;
	}

/*Define BOOLean epsilon neighborhood relationship of two motifs
 *of equal length, relating to gestalt paradigm and (counterpoint sub)group.
 */ 
BOOL epsilonRelation(M2D_compList motif1, M2D_compList motif2,
				double epsilon, int paradigm, int group)
 	{
	switch(paradigm)
		{
		case DIASTEMATIC:
		return diastemParadigm(motif1,motif2,epsilon,group);
		break;

		case ELASTIC: 
		return elastParadigm(motif1,motif2,epsilon,group);
		break;

		case RIGID: 
		return rigidParadigm(motif1,motif2,epsilon,group);
		break;
		}
		return NO;
	}
	

/*Epsilon neighborhood of a motif1 within a given list of motifs having length of motif1*/
int EpsiCount(M2D_compList motif1, M2D_powcomList pL, 
					double epsilon, int paradigm, int group)
	{
	int i, c = 0;
	for(i = 0; i < pL.length; i++)
		{
		c += (int) epsilonRelation(motif1, pL.M2D_powcom[i], epsilon, paradigm, group);
		}
	return c;
	}
	
/*Count motifs containing a given motif within a list pL*/
int countSubmotifs(M2D_compList motif1, M2D_powcomList pL)
	{
	int i, c = 0;
		for(i = 0; i < pL.length; i++)
		c += (int) compMember(motif1,pL.M2D_powcom[i]);
	return c;
	}


	


/*melomath*/
#include "melo.h"

int sig(double a, double b)
	{
	if(a > b)
	return 1;
	else if ( b > a)
	return -1;
	else
	return 0;
	}

M2D_Point diff(M2D_Point P, M2D_Point Q)
	{
	P.para1 -= Q.para1;
	P.para2 -= Q.para2;
	
	return P;
	}
	
M2D_Point add(M2D_Point P, M2D_Point Q)
	{
	P.para1 += Q.para1;
	P.para2 += Q.para2;
	
	return P;
	}
	
/*inversion of non-empty melody at pitch f*/
M2D_compList inversion(M2D_compList cL, double f)
	{
	int i;
	M2D_compList IL;
	IL.M2D_comp = calloc(cL.length,sizeof(M2D_Point));
	IL.length = cL.length;
	for(i = 0; i < cL.length; i++){
		(IL.M2D_comp+i)->para1 = (cL.M2D_comp+i)->para1; 
		(IL.M2D_comp+i)->para2 = 2*f - (cL.M2D_comp+i)->para2; 
		}
	return IL;	
	}

/*inversion of non-empty melody at initial sound event pitch*/
M2D_compList initinversion(M2D_compList cL)
	{
	return inversion(cL, cL.M2D_comp->para2);
	}
	
/*retrograde of non-empty melody at time t*/
M2D_compList retrograde(M2D_compList cL, double t)
	{
	int i;
	M2D_compList IL;
	IL.M2D_comp = calloc(cL.length,sizeof(M2D_Point));
	IL.length = cL.length;
	for(i = 0; i < cL.length; i++){
		(IL.M2D_comp+i)->para1 = 2*t - (cL.M2D_comp+cL.length-1-i)->para1; 
		(IL.M2D_comp+i)->para2 = (cL.M2D_comp+cL.length-1-i)->para2;
		} 
	return IL;	
	}
	
/*retrograde of non-empty melody at end time*/
M2D_compList midretrograde(M2D_compList cL)
	{
	return retrograde(cL,(cL.M2D_comp+cL.length-1)->para1);
	}
	

/*Definition of membership number in list*/
int ptMemberNumber(int index, M2D_Point P, M2D_compList cL)
	{
	int i;

	if(index >= 0 && index < cL.length)
	{
	for(i = index; i < cL.length && 
				!((P.para1 == cL.M2D_comp[i].para1) && 
			   	  (P.para2 == cL.M2D_comp[i].para2)); i++);
	return i;
	}
	
	else
	return -1;
	}
		 

/*Definition of indexed membership in list*/
BOOL ptIndexMember(int index, M2D_Point P, M2D_compList cL)
	{
	return (index <= ptMemberNumber(index,P,cL) &&
				 	 ptMemberNumber(index,P,cL) < cL.length);
	}


/*Check whether every item of list cLL is contained in list cLM*/
BOOL compMember(M2D_compList cLL, M2D_compList cLM)
	{
	int i, index;

	if(!cLL.length)
		return 1;

	else if(!cLM.length)
		return 0;
	
	else
		{
		for(i = index = 0; (i < cLL.length) && ptIndexMember(index,cLL.M2D_comp[i],cLM);i++)
			index = 1+ptMemberNumber(index,cLL.M2D_comp[i],cLM);

		return i == cLL.length;
		}
	}
	

/*Clean M2D_compList composition from repetitions*/
M2D_compList M2D_clean(M2D_compList composition)
	{
	M2D_compList T;
	if(composition.length <= 1)
		return composition;
	else 
		{
		--composition.length;
		T = M2D_clean(composition);
		if(ptIndexMember(0,*(composition.M2D_comp+composition.length),T))
			return T;
		else
			{
			T.length +=1;
			*(T.M2D_comp+T.length-1) = *(composition.M2D_comp+composition.length);
			return T;
			}
		}
	}
  
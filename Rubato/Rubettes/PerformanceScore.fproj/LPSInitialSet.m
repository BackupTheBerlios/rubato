/* LPSInitialSet.m */

#import "LPSInitialSet.h"
#import "LocalPerformanceScore.h"
#import <Rubette/space.h>

/* here is a C-array for ordering of the 64 hierarchy spaces */
static const int hierarchySpaceOrder[Hierarchy_Size] = {
//0-dim:
/* ord[0] = */ 0,
//1-dim:
/* ord[1] = */ 1,	/*000001*/
/* ord[2] = */ 2,	/*000010*/
/* ord[3] = */ 4,	/*000100*/
/* ord[4] = */ 8,	/*001000*/
/* ord[5] = */ 16,	/*010000*/
/* ord[6] = */ 32,	/*100000*/
//2-dim:
/* ord[7] = */ 3,	/*000011*/
/* ord[8] = */ 5,	/*000101*/
/* ord[9] = */ 6,	/*000110*/
/* ord[10] = */ 9,	/*001001*/
/* ord[11] = */ 10,	/*001010*/
/* ord[12] = */ 12,	/*001100*/
/* ord[13] = */ 17,	/*010001*/
/* ord[14] = */ 18,	/*010010*/
/* ord[15] = */ 20,	/*010100*/
/* ord[16] = */ 24,	/*011000*/
/* ord[17] = */ 33,	/*100001*/
/* ord[18] = */ 34,	/*100010*/
/* ord[19] = */ 36,	/*100100*/
/* ord[20] = */ 40,	/*101000*/
/* ord[21] = */ 48,	/*110000*/
//3-dim:
/* ord[22] = */ 7,	/*000111*/
/* ord[23] = */ 11,	/*001011*/
/* ord[24] = */ 13,	/*001101*/
/* ord[25] = */ 14,	/*001110*/
/* ord[26] = */ 19,	/*010011*/
/* ord[27] = */ 21,	/*010101*/
/* ord[28] = */ 22,	/*010110*/
/* ord[29] = */ 25,	/*011001*/
/* ord[30] = */ 26,	/*011010*/
/* ord[31] = */ 28,	/*011100*/
/* ord[32] = */ 35,	/*100011*/
/* ord[33] = */ 37,	/*100101*/
/* ord[34] = */ 38,	/*100110*/
/* ord[35] = */ 41,	/*101001*/
/* ord[36] = */ 42,	/*101010*/
/* ord[37] = */ 44,	/*101100*/
/* ord[38] = */ 49,	/*110001*/
/* ord[39] = */ 50,	/*110010*/
/* ord[40] = */ 52,	/*110100*/
/* ord[41] = */ 56,	/*111000*/
//4-dim:
/* ord[42] = */ 15,	/*001111*/
/* ord[43] = */ 23,	/*010111*/
/* ord[44] = */ 27,	/*011011*/
/* ord[45] = */ 29,	/*011101*/
/* ord[46] = */ 30,	/*011110*/
/* ord[47] = */ 39,	/*100111*/
/* ord[48] = */ 43,	/*101011*/
/* ord[49] = */ 45,	/*101101*/
/* ord[50] = */ 46,	/*101110*/
/* ord[51] = */ 51,	/*110011*/
/* ord[52] = */ 53,	/*110101*/
/* ord[53] = */ 54,	/*110110*/
/* ord[54] = */ 57,	/*111001*/
/* ord[55] = */ 58,	/*111010*/
/* ord[56] = */ 60,	/*111100*/
//5-dim:
/* ord[57] = */ 31,	/*011111*/
/* ord[58] = */ 47,	/*101111*/
/* ord[59] = */ 55,	/*110111*/
/* ord[60] = */ 59,	/*111011*/
/* ord[61] = */ 61,	/*111101*/
/* ord[62] = */ 62,	/*111110*/
//6-dim:
/* ord[63] = */ 63};	/*111111*/

@implementation LPSInitialSet

/* class methods specialized creation of initialSets */

+ newBPSetForLPS:anLPS atIndex:(int)basis;
{
    id bpInitialSet = nil;
    if(0<=basis && basis <MAX_BASIS_DIMENSION){

	int pianola = basis + MAX_BASIS_DIMENSION;
	spaceIndex BPspace = (spaceOfIndex(basis)) | (spaceOfIndex(pianola));
	double  a = [anLPS frameAt:basis]->origin,
		b = [anLPS frameAt:basis]->end,
		c = [anLPS frameAt:pianola]->origin,
		d = [anLPS frameAt:pianola]->end;
	id	horizontalSimplex = [[Simplex alloc]initWithSpace:BPspace andDimension:1],
	    	verticalSimplex = [[Simplex alloc]initWithSpace:BPspace andDimension:1],
	    	horizontalInitialSet = nil,
	    	verticalInitialSet = nil;

	/* define the horizontal (basis) simplex */
	    [[[[horizontalSimplex setDoubleValue:a ofPointAt:0 atIndex:basis]
				setDoubleValue:c ofPointAt:0 atIndex:pianola]
				setDoubleValue:b ofPointAt:1 atIndex:basis]
				setDoubleValue:c ofPointAt:1 atIndex:pianola];
	
	/* define the vertical (pianola) simplex */
	    [[[[verticalSimplex setDoubleValue:a ofPointAt:0 atIndex:basis]
				setDoubleValue:c ofPointAt:0 atIndex:pianola]
				setDoubleValue:a ofPointAt:1 atIndex:basis]
				setDoubleValue:c + MAX(b-a,d-c) ofPointAt:1 atIndex:pianola];
	
	/* insert the horizontal simplex */
	    horizontalInitialSet = [[[LPSInitialSet alloc]init] setSimplex:horizontalSimplex];

	/* make the vertical initialSet of the vertical simplex */
	    verticalInitialSet = [[[LPSInitialSet alloc]init] setSimplex:verticalSimplex];

	/* make list of the two initial simplexes */
	    bpInitialSet = [horizontalInitialSet makeListWith:verticalInitialSet];
    }
    return bpInitialSet; 
}


+ newBPListForLPS:anLPS withSpace:(spaceIndex)basisSpace;
{
    id list = nil;
    int i,j;
    if(spaceInSpace(basisSpace, BASIS_SPACE)){ /* assure that only EHL is concerned */
	for(i = 0; i<MAX_BASIS_DIMENSION && !(basisSpace & spaceOfIndex(i)); i++);
	list = [self newBPSetForLPS:anLPS atIndex:i];
	for(j = i+1; j<MAX_BASIS_DIMENSION; j++){
	    if(basisSpace & spaceOfIndex(j)){
		id part = [self newBPSetForLPS:anLPS atIndex:j];
		list = [list makeListWith:part];
	    }
	}
    }
    return list;
}

	

/* a wall system, returns a list initial with the walls AS initial simplices */
+ newWallSystemForLPS:anLPS inSpace:(spaceIndex)aSpace;
{
    int i, dim = dimensionOfSpace(aSpace);
    id wallSystem = [[self newWallForLPS:anLPS inSpace:aSpace at:1] wrapSelfInList];

    for(i=2;i<=dim; i++)
	wallSystem = [wallSystem makeListWith:[self newWallForLPS:anLPS inSpace:aSpace at:i]];
    return wallSystem;  
}

/* construction of the ith initial wall Simplex  */
+ newWallForLPS:anLPS inSpace:(spaceIndex)aSpace at:(int)index;
{
    int j, k, dim = dimensionOfSpace(aSpace),
    	expDim = (int)pow(2,dim-1);
    id result = nil;
    
    if(1<=index && index<=dim){
	/* define the simplex template */
	int indexMask = pow(2, index-1)-1;
	id theSimplex = [[Simplex alloc]initWithSpace:aSpace andDimension:expDim-1];
	double kVal = [anLPS frameAt:[theSimplex indexOfDimension:index]]->origin; 
    
	/* update points */
	for(j=0; j<expDim; j++){
	    for(k=0; k<dim; k++){
		int k_index = [theSimplex indexOfDimension:k+1];
		double newVal = kVal;
		    if((k+1) != index)
		    newVal = (((2*((~indexMask)&j)+(indexMask&j)) & (1<<k)) ?  [anLPS frameAt:k_index]->end : 
					    [anLPS frameAt:k_index]->origin);
						
		[theSimplex setDoubleValue:newVal ofPointAt:j atIndex:k_index];
		}
	
	
	    }
	    /* make an initial simplex set from the simplex */
	    result = [[[self alloc]init]setSimplex:theSimplex];
	}
    return result;
}

/* definition of the default initial set with respect to the **mother©s hierarchy** 
 * suppose we are given the ordering array ord[] for the 64 hierarchy spaces*/
+ newDefaultInitialSetForLPS:anLPS;
{
    id defaultSet = nil;
    if([anLPS mother]){
	int i;
	defaultSet = [[[self alloc]init]convertToInitialList];

	for(i=1; i<Hierarchy_Size; i++){
	    /* check the role of hierarchySpaceOrder[i], the space where we construct a system of walls */
	    if([[anLPS mother] hierarchyAt:hierarchySpaceOrder[i]] && ![[anLPS mother] hasReducibleSpace:hierarchySpaceOrder[i]])
		defaultSet = [defaultSet makeListWith:[self newWallSystemForLPS:[anLPS mother] inSpace:hierarchySpaceOrder[i]]];
	    }
    }
    return defaultSet;
}



/* standard object methods to be overridden */
- init;
{
    [super init];
    myLPS = nil;
    return self;
}

- (void)dealloc;
{
    myLPS = nil;
    return [super dealloc];
}

- copyWithZone:(NSZone*)zone;
{
    LPSInitialSet *myCopy= [super copyWithZone:zone];
    myCopy->myLPS = nil;
    return myCopy;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    myLPS = [[[aDecoder decodeObject] retain] ref];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeConditionalObject:myLPS];

}


- setOwnerLPS:aLPS;
{
    if (!myLPS && [aLPS isKindOfClass:[LocalPerformanceScore class]]) {
	myLPS = aLPS;
	return self;
    }
    return nil;
}

- ownerLPS;
{
    return myLPS;
}

@end



/* PrimaVista.m */

#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubato/RubatoTypes.h>
#import <Rubette/MatrixEvent.h>
#import <Rubette/Weight.h>

#import "PrimaVista.h"
#import "PrimaVistaPreferences.h"


@implementation PrimaVista

- init;
{
    [super init];
    makeArtiSpikes = NO;
    makeArtiDuration = NO;
    return self;
}

- (void)dealloc;
{
    [myAbsDynList release]; myAbsDynList = nil;
    [myRelDynList release]; myRelDynList = nil;
    [myAbsTpoList release]; myAbsTpoList = nil;
    [myRelTpoList release]; myRelTpoList = nil;
    [myArtiList release]; myArtiList = nil;
    return [self release];
}

- setMakeArtiSpikes:(BOOL)flag;
{
    makeArtiSpikes = flag;
    return self;
}

- (BOOL) makeArtiSpikes;
{
    return makeArtiSpikes;
}

- takeMakeArtiSpikesFrom:sender;
{
    if ([sender respondsToSelector:@selector(intValue)])
	[self setMakeArtiSpikes:[sender intValue]];
    return self;
}

- setMakeArtiDuration:(BOOL)flag;
{
    makeArtiDuration = flag;
    return self;
}

- (BOOL) makeArtiDuration;
{
    return makeArtiDuration;
}

- takeMakeArtiDurationFrom:sender;
{
    if ([sender respondsToSelector:@selector(intValue)])
	[self setMakeArtiDuration:[sender intValue]];
    return self;
}

- setAbsDynEventList:anEventList;
{
    [myAbsDynList release];
    myAbsDynList = [anEventList ref];
    myDynIsClean = NO;
    return self;
}

- setRelDynEventList:anEventList;
{
    [myRelDynList release];
    myRelDynList = [anEventList ref];
    myDynIsClean = NO;
    return self;
}

- setAbsTpoEventList:anEventList;
{
    [myAbsTpoList release];
    myAbsTpoList = [anEventList ref];
    myTpoIsClean = NO;
    return self;
}

- setRelTpoEventList:anEventList;
{
    [myRelTpoList release];
    myRelTpoList = [anEventList ref];
    myTpoIsClean = NO;
    return self;
}

- setArtiEventList:anEventList;
{
    [myArtiList release];
    myArtiList = [anEventList ref];
    myArtIsClean = NO;
    return self;
}


- (int)successorIn:anObject forOnset:(double)onset;
{
    int i=NSNotFound, c = [anObject count];
if ([anObject isKindOfClass:[JgList class]] || [anObject isKindOfClass:[OrderedList class]])
	for(i=0; i<c && [[anObject objectAt:i] doubleValueAtIndex:indexE]<=onset; i++);
    if ([anObject isKindOfClass:[Weight class]])
	for(i=0; i<c && [[anObject eventAt:i] doubleValueAtIndex:indexE]<=onset; i++);
    return i;
}

- (int)predecessorIn:anObject forOnset:(double)onset;
{
    return [self successorIn:anObject forOnset:onset]-1;
}

- (double)predecessorOnsetIn:anObject forOnset:(double)onset;
{
    if ([anObject isKindOfClass:[Weight class]])
	return [[anObject eventAt:[self predecessorIn:anObject forOnset:onset]] doubleValueAtIndex:indexE];
if ([anObject isKindOfClass:[JgList class]] || [anObject isKindOfClass:[OrderedList class]])
	return [[anObject objectAt:[self predecessorIn:anObject forOnset:onset]] doubleValueAtIndex:indexE];
    return 0.0;
}

- (double)predecessorValueIn:anObject forOnset:(double)onset;
{
    if ([anObject isKindOfClass:[Weight class]])
	return [[anObject eventAt:[self predecessorIn:anObject forOnset:onset]] doubleValue];
if ([anObject isKindOfClass:[JgList class]] || [anObject isKindOfClass:[OrderedList class]])
	return [[anObject objectAt:[self predecessorIn:anObject forOnset:onset]] doubleValue];
    return 0.0;
}


/* eliminates all multiple onsets and too small durations */
- sortAndCleanPVList:aList;
{

    int i, c = [aList count];
    [aList sort];
    for(i=c-1; 0<i; i--){
	id evti = [aList objectAt:i];
	if(([evti doubleValueAtIndex:indexE] == [[aList objectAt:i-1] doubleValueAtIndex:indexE]) ||
	    ([evti spaceAt:indexD] && ([evti doubleValueAtIndex:indexD]<2*EPSILON))) 
	    [[aList removeObjectAt:i] release];
    }
    return aList;
}

/* at the end, this method inserts the absolute events to keep values constant  
 * for successive absolute events at an index, without intermediate relative events 
 */
- cleanPVRelList:relList withAbsList:absList;
{
    int i, cabs, crel;
    id newEvent;

    [self sortAndCleanPVList:absList];
    [self sortAndCleanPVList:relList];
    /* from its initialization, absList has at least ONE !! element */
    cabs = [absList count];
    crel = [relList count];

    for(i=0; i<crel; i++){
	id obi = [relList objectAt:i];
	double 	ONi = [obi doubleValueAtIndex:indexE],
		OFFi = ONi+[obi doubleValueAtIndex:indexD],
		ONiplus, OFFsucc, 
		succ = [self successorIn:absList forOnset:ONi];  

	if(i<crel-1){
	    ONiplus = [[relList objectAt:i+1] doubleValueAtIndex:indexE];
	    if(ONiplus<OFFi)
		OFFi = ONiplus;
	    }
	if(succ<cabs){
		OFFsucc = [[absList objectAt:succ] doubleValueAtIndex:indexE];
		if(OFFsucc<OFFi)
	    OFFi = OFFsucc;
	    }
	    
	[obi setDoubleValue:OFFi-ONi atIndex:indexD];
    [relList sort];
    }
    
    /*NEW END OF METHOD*/
    for(i=cabs-2; 0<=i; i--){
    if([self isIsolatedFrom:relList inAbsList:absList atIndex:i]){
	double succONsi = [[absList objectAt:i+1] doubleValueAtIndex:indexE]; 

	newEvent = [[MatrixEvent alloc] initWithSpace:indexE andValue:succONsi-EPSILON]; 

	[newEvent setDoubleValue:[[absList objectAt:i] doubleValue]];
	[absList addObject:newEvent];
        [absList sort];
	}  
    }
    return self;
}



- cleanPVDynamics;
{
    if(!myDynIsClean)
	[self cleanPVRelList:myRelDynList withAbsList:myAbsDynList];
    myDynIsClean = YES;
    return self;
}


- cleanPVAgogics;
{
    if(!myTpoIsClean)
	[self cleanPVRelList:myRelTpoList withAbsList:myAbsTpoList];
    myTpoIsClean = YES;
    return self;
}


- cleanPVArticulation;
{
    if(!myArtIsClean)
	[self cleanPVRelList:myArtiList withAbsList:nil]; /* this adjusts the durations */
    myArtIsClean = YES;
    return self;
}
 
- (int)separatorIndex:relList:absList;
{
    double firstAbsOnset = [[absList objectAt:0] doubleValueAtIndex:indexE];
    int j, crel = [relList count];
    for(j=0; j<crel && [[relList objectAt:j] doubleValueAtIndex:indexE]<firstAbsOnset; j++);
    return j;
}

/* this one also includes the relative events before the first absolute event */
- makeDynWeight;
{
    int i, j, cabs, crel;
    id firstAbsEvt, firstWeight;
    double firstAbsOnset, firstAbsDynamics, firstDynVal;
    [self cleanPVDynamics];
    j = [self separatorIndex:myRelDynList:myAbsDynList];
    cabs = [myAbsDynList count];
    crel = [myRelDynList count];
    firstAbsEvt = [myAbsDynList objectAt:0];
    firstAbsOnset = [firstAbsEvt doubleValueAtIndex:indexE];
    firstAbsDynamics = [firstAbsEvt doubleValue];
		
    [myDynWeight release]; myDynWeight = nil;
    myDynWeight = [[[[Weight alloc]init]sort]ref];
    [myDynWeight setNameString:DYN_WEIGHT_NAME];
    [myDynWeight setSpaceTo:E_space];
    
    /* Add the Weight's Parameters */
    for (i=0; i<RELDYN_RANGE; i++)
	[myDynWeight setParameter:[myPrefs relDynParaValueNameAt:i] toDoubleValue:[myPrefs relDynValueAt:i]];
    for (i=0; i<ABSDYN_RANGE; i++)
	[myDynWeight setParameter:[myPrefs absDynParaValueNameAt:i] toDoubleValue:[myPrefs absDynValueAt:i]];

    firstDynVal = [myPrefs absDynValueAt:firstAbsDynamics];

    /* first, add absolute weights, this list is already ordered by onsets */
    for(i=0; i<cabs; i++){
	id obi = [myAbsDynList objectAt:i];
	[myDynWeight 	addWeight:[myPrefs absDynValueAt:[obi doubleValue]] 
			at:[obi doubleValueAtIndex:indexE]   :0.0 : 0.0 :0.0 :0.0 :0.0];
	}
	
    /* now, calculate the weights of the first j events backwards */
    if(j>0){ /* start downwards recursion at last relative event before first absolute event */ 
	id obj = [myRelDynList objectAt:j-1];
	double	valj = dynAdjust(   firstDynVal, 
				    [myPrefs relDynTolerance], 
				    1/[myPrefs relDynValueAt:[obj doubleValue]],/*go backwards!*/
				    firstDynVal),
		ONj = [obj doubleValueAtIndex:indexE], 
		OFFj = ONj+[obj doubleValueAtIndex:indexD];
	if(OFFj<firstAbsOnset)
		[myDynWeight	addWeight:firstDynVal 
			    	at:OFFj   :0.0 : 0.0 :0.0 :0.0 :0.0];

		[myDynWeight	addWeight:valj 
				at:ONj   :0.0 : 0.0 :0.0 :0.0 :0.0];

	}

    for(i=j-2; 0<=i; i--){
	id obi = [myRelDynList objectAt:i];
	double 	ONi = [obi doubleValueAtIndex:indexE],
		OFFi = ONi+[obi doubleValueAtIndex:indexD],
		firstON, firstWeightValue, onval;
		 
		firstWeight = [myDynWeight eventAt:0]; /* the momently first weight */
	 	firstON = [firstWeight doubleValueAtIndex:indexE];
	 	firstWeightValue = [myDynWeight weightAt:0];
	    	onval = dynAdjust(  firstDynVal, 
				    [myPrefs relDynTolerance], 
				    1/[myPrefs relDynValueAt:[obi doubleValue]],
				    firstWeightValue);

	if(OFFi<firstON)
		[myDynWeight	addWeight:firstWeightValue 
			    	at:OFFi   :0.0 : 0.0 :0.0 :0.0 :0.0];

	[myDynWeight	addWeight:onval 
			at:ONi   :0.0 : 0.0 :0.0 :0.0 :0.0];
	}
    
    	    
    /* second, insert relative weights after the first absolute event and order by onsets */
    for(i=j; i<crel; i++){
	id obi = [myRelDynList objectAt:i];
	double 	ONsi = [obi doubleValueAtIndex:indexE],
		OFFi = ONsi+[obi doubleValueAtIndex:indexD],
		vali = [obi doubleValue];
	int 	absSuccessor = [self successorIn:myAbsDynList forOnset:ONsi],
		absPredecessor = absSuccessor-1;
	id	predEvent = [myAbsDynList objectAt:absPredecessor];

	double 	preval = [self predecessorValueIn:myDynWeight forOnset:ONsi],
		preONs = [self predecessorOnsetIn:myDynWeight forOnset:ONsi],
		succONs = [[myAbsDynList objectAt:absSuccessor] doubleValueAtIndex:indexE];

	if(preONs < ONsi)/* for == nothing to do! */
	    [myDynWeight addWeight:preval at:ONsi   :0.0 : 0.0 :0.0 :0.0 :0.0];

	if(absSuccessor == cabs || OFFi < succONs){
	    /* relative event ends before next abs event if any */
	    double offval = dynAdjust(  [myPrefs absDynValueAt:[predEvent doubleValue]], 
					[myPrefs relDynTolerance], 
					[myPrefs relDynValueAt:vali], 
					preval);
	    [myDynWeight addWeight:offval at:OFFi   :0.0 : 0.0 :0.0 :0.0 :0.0];

	    if(absSuccessor<cabs){
		if(i == crel-1)
			[myDynWeight addWeight:offval at:succONs-EPSILON   :0.0 : 0.0 :0.0 :0.0 :0.0];
		else{
		    id obiPlus = [myRelDynList objectAt:i+1];
		    if(succONs<=[obiPlus doubleValueAtIndex:indexE]) 
			[myDynWeight addWeight:offval at:succONs-EPSILON   :0.0 : 0.0 :0.0 :0.0 :0.0];
		    }
		}
	    }
	    
	else{/* this is the delicate case: OFFi stays on successor abs event */
	    id succEvent = [myAbsDynList objectAt:absSuccessor];
	    double  abSuccVal = [succEvent doubleValue],
		    predVal = [predEvent doubleValue],
		    offval = dynAdjust( [myPrefs absDynValueAt:predVal], 
					[myPrefs relDynTolerance], 
					[myPrefs relDynValueAt:vali], 
					preval);
	    if((abSuccVal>=predVal && vali<PV_cresc) ||(abSuccVal<=predVal && vali>PV_dim))
		[myDynWeight addWeight:offval at:OFFi-EPSILON   :0.0 : 0.0 :0.0 :0.0 :0.0];
	    }
    }	
    return myDynWeight;
}

- makeTpoWeight;
{
    int i, cabs, crel;
    
    [self cleanPVAgogics];
    cabs = [myAbsTpoList count];
    crel = [myRelTpoList count];
    
    [myTpoWeight release]; myTpoWeight = nil;
    myTpoWeight = [[[[Weight alloc]init]sort]ref];
    [myTpoWeight setNameString:TPO_WEIGHT_NAME];
    [myTpoWeight setSpaceTo:E_space];
    
    /* Add the Weight's Parameters */
    for (i=0; i<RELTPO_RANGE; i++)
	[myTpoWeight setParameter:[myPrefs relTpoParaValueNameAt:i] toDoubleValue:[myPrefs relTpoValueAt:i]];
	
    /* first, add absolute weights, this list is already ordered by onsets */
    for(i=0; i<cabs; i++){
	id obi = [myAbsTpoList objectAt:i];
	[myTpoWeight 	addWeight:[obi doubleValue] 
	    		at:[obi doubleValueAtIndex:indexE]   :0.0 : 0.0 :0.0 :0.0 :0.0];
	}
	
    /* second, insert relative weights and order by onsets */
    for(i=0; i<crel; i++){
	id obi = [myRelTpoList objectAt:i];
	double 	ONsi = [obi doubleValueAtIndex:indexE],
		OFFi = ONsi+[obi doubleValueAtIndex:indexD],
		vali = [obi doubleValue];
	
	int 	absSuccessor = [self successorIn:myAbsTpoList forOnset:ONsi];

	double 	preval = [self predecessorValueIn:myTpoWeight forOnset:ONsi],
		preONs = [self predecessorOnsetIn:myTpoWeight forOnset:ONsi],
		succONs = [[myAbsTpoList objectAt:absSuccessor] doubleValueAtIndex:indexE];

	if(preONs < ONsi) /* for == nothing to do! */
	    [myTpoWeight addWeight:preval at:ONsi   :0.0 : 0.0 :0.0 :0.0 :0.0];

	if(absSuccessor == cabs || OFFi < succONs){
	    /* relative event ends before next abs event if any */
	    double  offval = [myPrefs relTpoValueAt:((((int)vali) != PV_fermata) ? vali: PV_fermatashift)]*preval;
	    [myTpoWeight addWeight:offval at:OFFi   :0.0 : 0.0 :0.0 :0.0 :0.0];

	    if(absSuccessor<cabs){
		if(i == crel-1)
			[myTpoWeight addWeight:offval at:succONs-EPSILON   :0.0 : 0.0 :0.0 :0.0 :0.0];
		else{
		    id obiPlus = [myRelTpoList objectAt:i+1];
		    if(succONs<=[obiPlus doubleValueAtIndex:indexE]) 
			[myTpoWeight addWeight:offval at:succONs-EPSILON   :0.0 : 0.0 :0.0 :0.0 :0.0];
		    }
		}
	    }
	    
	else {/* this is the delicate case: OFFi stays on successor abs event */
	    id succEvent = [myAbsTpoList objectAt:absSuccessor];
	    double  abSuccVal = [succEvent doubleValue];
		    
	    if(vali != PV_fermata && ((abSuccVal>=preval && vali<PV_accel) || (abSuccVal<=preval && vali>PV_ritard)))		
		[myTpoWeight addWeight:[myPrefs relTpoValueAt:vali]*preval at:OFFi-EPSILON   :0.0 : 0.0 :0.0 :0.0 :0.0];
	    }
	    
	if(vali == PV_fermata){ /* for the fermata, add down interval */
	    [myTpoWeight addWeight:preval*[myPrefs relTpoValueAt:PV_fermata] 
			 at:ONsi+[myPrefs relTpoValueAt:PV_fermatadelay]*(OFFi-ONsi)   :0.0 : 0.0 :0.0 :0.0 :0.0];
	    [myTpoWeight addWeight:preval*[myPrefs relTpoValueAt:PV_fermata] 
			 at:ONsi+(1-[myPrefs relTpoValueAt:PV_fermatadelay])*(OFFi-EPSILON-ONsi)   :0.0 : 0.0 :0.0 :0.0 :0.0];
	    }
	    
    }	
    return myTpoWeight;
}

- makeArtiWeight;
{
    int i, crel;
    
    crel = [myArtiList count];
    
    [myArtiWeight release]; myArtiWeight = nil;
    myArtiWeight = [[[[Weight alloc]init]sort]ref];
    [myArtiWeight setNameString:ARTI_WEIGHT_NAME];
    [myArtiWeight setSpaceTo:EH_space];
    
    /* Add the Weight's Parameters */
    for (i=0; i<ARTI_RANGE; i++)
	[myArtiWeight setParameter:[myPrefs artiParaValueNameAt:i] toDoubleValue:[myPrefs artiValueAt:i]];
	
    /* make relative weights and order by onsets */
    for(i=0; i<crel; i++){
	id obi = [myArtiList objectAt:i];
	double 	ON_E = [obi doubleValueAtIndex:indexE],
		OFFE = makeArtiDuration ? ON_E+[obi doubleValueAtIndex:indexD] : ON_E,
		ON_H = [obi doubleValueAtIndex:indexH],
		OFFH = makeArtiDuration ? ON_H+[obi doubleValueAtIndex:indexG] : ON_H,
		vali = ((int)[obi doubleValue])!=NSNotFound ? [myPrefs artiValueAt:[obi doubleValue]] : 1.0;
	[myArtiWeight addWeight:vali 	at:ON_E 	  :ON_H : 0.0 :0.0 :0.0 :0.0];
	if (makeArtiDuration) 
	    [myArtiWeight addWeight:vali at:OFFE 	  :OFFH : 0.0 :0.0 :0.0 :0.0];
	
	if (makeArtiSpikes) {
	    [myArtiWeight addWeight:1.0 at:ON_E-EPSILON :ON_H : 0.0 :0.0 :0.0 :0.0];
	    [myArtiWeight addWeight:1.0 at:ON_E   	:ON_H-EPSILON : 0.0 :0.0 :0.0 :0.0];
	    [myArtiWeight addWeight:1.0 at:ON_E   	:ON_H+EPSILON : 0.0 :0.0 :0.0 :0.0];
	    [myArtiWeight addWeight:1.0 at:OFFE+EPSILON :OFFH : 0.0 :0.0 :0.0 :0.0];
	    if (makeArtiDuration) {
		[myArtiWeight addWeight:1.0 at:OFFE   	:OFFH-EPSILON : 0.0 :0.0 :0.0 :0.0];
		[myArtiWeight addWeight:1.0 at:OFFE   	:OFFH+EPSILON : 0.0 :0.0 :0.0 :0.0];
	    }
	}
    }
    return myArtiWeight;
}    

/* auxiliary method to find pairs of successive absolute events at an index, without intermediate relative events */ 
- (BOOL)isIsolatedFrom:relList inAbsList:absList atIndex:(int)index;
{
    int isol = NO;
    if(0<=index && index<[absList count]-1){
	double 	ONindex = [[absList objectAt:index] doubleValueAtIndex:indexE],
		ONsuccindex = [[absList objectAt:index+1] doubleValueAtIndex:indexE]; 
	int 	preIndex = [self predecessorIn:relList forOnset:ONsuccindex];
	if(preIndex<0) /* relList empty or to the right of Onsuccindex */ 
	    isol = YES;
	else
	    isol = [self predecessorOnsetIn:relList forOnset:ONsuccindex]<=ONindex;
	}
    return isol;
}

@end

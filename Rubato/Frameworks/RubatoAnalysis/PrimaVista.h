/* PrimaVista.h */

#import <Foundation/NSObject.h>
#import <RubatoDeprecatedCommonKit/commonkit.h>
    		
@interface PrimaVista:JgObject
{
    id	myAbsDynList; /* list of absolute dynamics events in E space, abs. dynamics on doublevalues*/
    id	myRelDynList; /* list of relative dynamics events in ED space, rel. dynamics on doublevalues*/
    //id myPtDynList; list of point dynamics events in E space, pt. dynamics on doublevalues
    id	myAbsTpoList; /* list of absolute tempo events in E space, abs. tempo on doublevalues*/
    id	myRelTpoList; /* list of relative tempo events in ED space, rel. tempi on doublevalues*/
    id	myArtiList; /* list of articulation events in E space, articulation on doublevalues*/
    id	myPrefs;

    BOOL myDynIsClean;
    BOOL myTpoIsClean;
    BOOL myArtIsClean;
    BOOL makeArtiSpikes;
    BOOL makeArtiDuration;

    id	myDynWeight; /* these weights live all in E space */
    id	myTpoWeight;
    id	myArtiWeight;
}

- init;
- (void)dealloc;

- setMakeArtiSpikes:(BOOL)flag;
- (BOOL) makeArtiSpikes;
- takeMakeArtiSpikesFrom:sender;
- setMakeArtiDuration:(BOOL)flag;
- (BOOL) makeArtiDuration;
- takeMakeArtiDurationFrom:sender;

/* Adding predicate values to PrimaVista event lists */
- setAbsDynEventList:anEventList;
- setRelDynEventList:anEventList;
- setAbsTpoEventList:anEventList;
- setRelTpoEventList:anEventList;
- setArtiEventList:anEventList;


- (int)successorIn:anObject forOnset:(double)onset;
- (int)predecessorIn:anObject forOnset:(double)onset;
- (double)predecessorOnsetIn:anObject forOnset:(double)onset;
- (double)predecessorValueIn:anObject forOnset:(double)onset;

/* auxiliary method to find pairs of successive absolute events at an index, without intermediate relative events */ 
- (BOOL)isIsolatedFrom:relList inAbsList:absList atIndex:(int)index;

/* eliminates all multiple onsets or vanishing durations */
- sortAndCleanPVList:aList;

- cleanPVRelList:relList withAbsList:absList;
- cleanPVDynamics;
- cleanPVAgogics;
- cleanPVArticulation;
- (int)separatorIndex:relList:absList;

- makeDynWeight;
- makeTpoWeight;
- makeArtiWeight;

@end

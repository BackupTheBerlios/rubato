#import "ChordSequence.h"
#import "Chord.h"
//#import <mathmatrixkit/mathmatrixkit.h>
#import <Rubato/RubatoTypes.h>
//#import <Rubato/MatrixEvent.h>
#import <Rubette/Weight.h>
#import <RubatoDeprecatedCommonKit/ProgressPanel.h>
#import <RubatoDeprecatedCommonKit/JgOwner.h>

#import <FScript/FScript.h>

//#define VAL_MAX_TONALITY MAX_TONALITY
//#define VAL_MAX_FUNCTION MAX_FUNCTION
//#define VAL_MAX_LOCUS MAX_LOCUS
#define VAL_MAX_TONALITY tonalityCount
#define VAL_MAX_FUNCTION functionCount
#define VAL_MAX_LOCUS locusCount

/* some global variables/initialisation tables of this class */
/* function values of chromatic scale tones */
double funScale[6][12] =    {
			    /*C,  C#,  D,   D#,  E,   F,   F#,  G,   G#,  A,   A#,  B*/
	/*major*/	    {1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0}, /* T functions of C,C#,D,d# etc. */
			    {0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0}, /* D functions of C,C#,D,d# etc. */
			    {1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0}, /* S functions of C,C#,D,d# etc. */
				
	/*harmonic minor*/  {1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0}, /* t functions of C,C#,D,d# etc. */
			    {0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0}, /* d functions of C,C#,D,d# etc. */
			    {1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0}  /* s functions of C,C#,D,d# etc. */
			    };

double funDist[3][3] =  {
			{ 0.0, 1.0, 0.5}, /* tonic -> tonic, dominant, subdominant */
			{-0.2, 1.0, 0.8}, /* dominant -> tonic, dominant, subdominant */
			{-0.5, 0.2, 1.0}  /* subdominant -> tonic, dominant, subdominant */
			};
 		
double modeDist[2][2] = {
			{0.0, 2.0}, /* major -> major, minor */
			{1.5, 0.0}  /* minor -> major, minor */
			};

double tonalityDist[2][7] = {
			    {0.0,2.0,4.0,6.0,8.0,10.0,12.0}, /* fourths: 0,1,2,3,4,5,6 */
			    {0.0,2.0,4.0,6.0,8.0,10.0,12.0}  /* fifths: 0,1,2,3,4,5,6 */
			    };
			    
/* Noll default table */
double nollProfile[8][7] =  {	{4.1,1.7,3.7,1.3,0.7,0.5,1.1},  /* TON */
				{4.1,1.7,3.7,1.3,0.7,0.5,1.1},  /* DOM */
				{4.1,1.7,3.7,1.3,0.7,0.5,1.1},  /* SUB */
				{4.1,1.7,3.7,1.3,0.5,0.7,1.1},  /* ton */
				{4.1,1.7,3.7,1.3,0.5,0.7,1.1},  /* dom */
				{4.1,1.7,3.7,1.3,0.5,0.7,1.1},  /* sub */
				{4.1,1.7,3.7,1.3,0.7,0.5,1.1},  /* DOMdiss */
				{4.1,1.7,3.7,1.3,0.5,0.7,1.1}}; /* subDiss */


@implementation ChordSequence

+ (void)initialize;
{
    [super initialize];
    if (self == [ChordSequence class]) {
	[ChordSequence setVersion:2];
    }
}


- (void)deallocHarmoSpace;
{
#ifdef  CHORDSEQ_DYN
  if (myFunctionScale)
    free(myFunctionScale);
  myFunctionScale=NULL;
  if (myUseFunctionList)
    free(myUseFunctionList);
  myUseFunctionList=NULL;
  if (myDistanceMatrix)
    free(myDistanceMatrix);
  myDistanceMatrix=NULL;
#endif
}

- (void)deallocModalitySpace;
{
#ifdef  CHORDSEQ_DYN
  if (myModelessFunctionDist)
    free(myModelessFunctionDist);
  myModelessFunctionDist=NULL;
  if (myModeDist)
    free(myModeDist);
  myModeDist=NULL;
#endif
}

#define MALLOC2(carr,N,M,type) carr=malloc((N)*sizeof(type *)+(N)*(M)*sizeof(type)); \
{ int carri; for (carri=0;carri<N;carri++) carr[carri]=((type *)(carr+(N)))+carri*(M);}

#define MALLOC3(carr,N,M,P,type) carr=malloc((N)*sizeof(type **)+(N)*(M)*sizeof(type *) +(N)*(M)*(P)*sizeof(type)); \
{ int i,j; \
  type **pi=(type **)(carr+(N)); \
  type *pj=(type *)(pi+(N*M)) ; \
  for (i=0;i<N;i++) { \
    carr[i]=pi+i*(M); \
    for (j=0;j<M;j++) \
      carr[i][j]=pj +i*(M)*(P) + j*P; \
  }}


- (void)allocFunctionScale:(double **)otherFunctionScale useFunctionList:(BOOL *)otherUseFunctionList distanceMatrix:(double **)otherDistanceMatrix doInit:(BOOL)doInit;
{
  [self deallocHarmoSpace];
#ifdef  CHORDSEQ_DYN
  MALLOC2(myFunctionScale,VAL_MAX_FUNCTION,pcCount,double);
  myUseFunctionList=malloc(VAL_MAX_LOCUS*sizeof(BOOL));
  MALLOC2(myDistanceMatrix,VAL_MAX_LOCUS,VAL_MAX_LOCUS,double);
#endif
  if (doInit) {
    int i,j;
    for(i=0; i<VAL_MAX_FUNCTION; i++) {
      for(j=0; j<pcCount; j++) {
        myFunctionScale[i][j]=(otherFunctionScale ? otherFunctionScale[i][j] : 0.0);
      }
    }
    for(i=0; i<VAL_MAX_LOCUS; i++) {
      myUseFunctionList[i]=(otherUseFunctionList ? otherUseFunctionList[i] : YES);
      for(j=0; j<VAL_MAX_LOCUS; j++) {
        myDistanceMatrix[i][j]=(otherDistanceMatrix ? otherDistanceMatrix[i][j] : 0.0);
      }
    }
  }
}

- (void)allocModelessFunctionDist:(double **)otherModelessFunctionDist doInit:(BOOL)doInit;
{
#ifdef  CHORDSEQ_DYN
  if (myModelessFunctionDist)
    free(myModelessFunctionDist);
  MALLOC2(myModelessFunctionDist,modelessFunctionCount,modelessFunctionCount,double);
#endif
  if (doInit) {
    int i,j;
    for(i=0; i<modelessFunctionCount; i++) {
      for(j=0; j<modelessFunctionCount; j++) {
        myModelessFunctionDist[i][j]=(otherModelessFunctionDist ? otherModelessFunctionDist[i][j] : 0.0);
      }
    }
  }
}
- (void)allocModeDist:(double **)otherModeDist doInit:(BOOL)doInit;
{
#ifdef  CHORDSEQ_DYN
  if (myModeDist)
    free(myModeDist);
  MALLOC2(myModeDist,modeCount,modeCount,double);
#endif
  if (doInit) {
    int i,j;
    for(i=0; i<modeCount; i++) {
      for(j=0; j<modeCount; j++) {
        myModeDist[i][j]=(otherModeDist ? otherModeDist[i][j] : 0.0);
      }
    }
  }
}

- (void)allocModelessFunctionDist:(double **)otherModelessFunctionDist modeDist:(double **)otherModeDist doInit:(BOOL)doInit;
{
  [self allocModelessFunctionDist:otherModelessFunctionDist doInit:doInit];
  [self allocModeDist:otherModeDist doInit:doInit];
}

- (void)allocNollMatrix:(double ***)otherNollMatrix doInit:(BOOL)doInit;
{
#ifdef  CHORDSEQ_DYN
  if (myNollMatrix)
    free(myNollMatrix);
  MALLOC3(myNollMatrix,8,12,43,double);
#endif
}
- init;
{
    [super init];

    // pure c arrays
#ifdef  CHORDSEQ_DYN
    myFunctionScale=NULL;
    myUseFunctionList=NULL;
    myDistanceMatrix=NULL;
    myModelessFunctionDist=NULL;
    myModeDist=NULL;
    functionCount=0;
    tonalityCount=0;
    locusCount=0;
    modeCount=0;
    modelessFunctionCount=0;
#else
    functionCount=MAX_FUNCTION;
    tonalityCount=MAX_TONALITY;
    locusCount=functionCount*tonalityCount;
    modeCount=MAX_MODE;
    modelessFunctionCount=MAX_MODELESS_FUNCTION; 
#endif
    pcCount=12;
    harmonicProfile=NULL;
    fsBlocks=[[NSMutableDictionary alloc] init];
    myChords = [[[OrderedList alloc]init]ref];
    [self allocNollMatrix:NULL doInit:NO];
    [self resetToDefaultValues]; // initilizes tonalityCount,...
    [self invalidate];

  calcBestPathSelector=@selector(viterbiCalcBestPathUseLevelMatrix);
  return self;
}

- (void)dealloc;
{
    /* do NXReference houskeeping */
  
    [myChords release]; myChords = nil;
    
    [viterbiContext release];

    // pure c arrays
#ifdef CHORDSEQ_DYN
    if (myNollMatrix)
      free(myNollMatrix);
#endif
    if (harmonicProfile)
      free(harmonicProfile);
    [self deallocHarmoSpace];
    [self deallocModalitySpace];
    [fsBlocks release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone;
{
  NSAssert(NO,@"WeightWatcher copyWithZone: not expected/implemented!");
//    [self allocFunctionScale:NULL useFunctionList:NULL distanceMatrix:NULL doInit:YES];
  return JGSHALLOWCOPY;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{ // NEWHARMO add fsBlocks?
    int i, j, classVersion = [aDecoder versionForClassName:NSStringFromClass([ChordSequence class])];
//    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    [self allocNollMatrix:NULL doInit:NO];

    if (classVersion<2) {
      tonalityCount=MAX_TONALITY;
      functionCount=MAX_FUNCTION;
      modeCount=2;
      modelessFunctionCount=3;
    } else {
      [aDecoder decodeValueOfObjCType:"i" at:&functionCount];
      [aDecoder decodeValueOfObjCType:"i" at:&tonalityCount];
      [aDecoder decodeValueOfObjCType:"i" at:&modeCount];
      [aDecoder decodeValueOfObjCType:"i" at:&modelessFunctionCount];
    }
    locusCount=VAL_MAX_FUNCTION*VAL_MAX_TONALITY;
    [self allocFunctionScale:NULL useFunctionList:NULL distanceMatrix:NULL doInit:NO];
    [self allocModelessFunctionDist:NULL modeDist:NULL doInit:NO];

    myChords = [[[aDecoder decodeObject] retain] ref];
    
    /* read Riemann Function Values */
    for(i=0;i<VAL_MAX_LOCUS;i++) {
	[aDecoder decodeValueOfObjCType:"d" at:&myFunctionScale[i/tonalityCount][i%tonalityCount]];
	[aDecoder decodeValueOfObjCType:"c" at:&myUseFunctionList[i]];
    }
    for(i=0;i<modelessFunctionCount*modelessFunctionCount;i++)
	[aDecoder decodeValueOfObjCType:"d" at:&myModelessFunctionDist[i/modelessFunctionCount][i%modelessFunctionCount]];

    /* read Tonlity Values */
    for(i=0;i<modeCount*modeCount;i++)
	[aDecoder decodeValueOfObjCType:"d" at:&myModeDist[i/modeCount][i%modeCount]];

    for(i=0;i<14;i++)
	[aDecoder decodeValueOfObjCType:"d" at:&myTonalityDist[i/7][i%7]];
    
    for(i=0;i<VAL_MAX_LOCUS*VAL_MAX_LOCUS;i++)
	[aDecoder decodeValueOfObjCType:"d" at:&myDistanceMatrix[i/VAL_MAX_LOCUS][i%VAL_MAX_LOCUS]];
	
    [aDecoder decodeValueOfObjCType:"d" at:&myPitchReference];
    [aDecoder decodeValueOfObjCType:"d" at:&mySemitoneUnit];
    [aDecoder decodeValueOfObjCType:"d" at:&myGlobalLevel];
    [aDecoder decodeValueOfObjCType:"d" at:&myLocalLevel];
    [aDecoder decodeValueOfObjCType:"d" at:&myWeightProfile];
    [aDecoder decodeValueOfObjCType:"d" at:&myTransitionProfile];
    [aDecoder decodeValueOfObjCType:"d" at:&myStartWeight];
    [aDecoder decodeValueOfObjCType:"d" at:&myEndWeight];
    [aDecoder decodeValueOfObjCType:"d" at:&myGlobalSlope];
    [aDecoder decodeValueOfObjCType:"d" at:&myIntraProfile];
    
    [aDecoder decodeValueOfObjCType:"i" at:&myCausalDepth];
    [aDecoder decodeValueOfObjCType:"i" at:&myFinalDepth];
    
    [aDecoder decodeValueOfObjCType:"c" at:&isRiemannCalculated];
    [aDecoder decodeValueOfObjCType:"c" at:&isLevelCalculated];
    [aDecoder decodeValueOfObjCType:"c" at:&isDistanceCalculated];
    [aDecoder decodeValueOfObjCType:"c" at:&isBestPathCalculated];
    
    if (classVersion) {
	[aDecoder decodeValueOfObjCType:"i" at:&myMethod];
	for(i=0;i<56;i++)
	    [aDecoder decodeValueOfObjCType:"d" at:&myNollProfile[i/7][i%7]];
	for(i=0;i<96;i++)
	    for (j=0; j<43; j++)
		[aDecoder decodeValueOfObjCType:"d" at:&myNollMatrix[i/12][i%12][j]];
    } else {
	myMethod = MAZZOLA;
	for(i=0;i<56;i++)
	    myNollProfile[i/7][i%7] = nollProfile[i/7][i%7];
    }
	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{ // NEWHARMO add fsBlocks?
    int i, j;
//    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */

  if ([aCoder versionForClassName:@"ChordSequence"]>=2) {
    [aCoder encodeValueOfObjCType:"i" at:&functionCount];
    [aCoder encodeValueOfObjCType:"i" at:&tonalityCount];
    [aCoder encodeValueOfObjCType:"i" at:&modeCount];
    [aCoder encodeValueOfObjCType:"i" at:&modelessFunctionCount];
  }

  [aCoder encodeObject:myChords];
    
    /* write Riemann Function Values */
    for(i=0;i<VAL_MAX_LOCUS;i++) {
	[aCoder encodeValueOfObjCType:"d" at:&myFunctionScale[i/pcCount][i%VAL_MAX_TONALITY]];
	[aCoder encodeValueOfObjCType:"c" at:&myUseFunctionList[i]];
    }
    for(i=0;i<modelessFunctionCount*modelessFunctionCount;i++)
	[aCoder encodeValueOfObjCType:"d" at:&myModelessFunctionDist[i/modelessFunctionCount][i%modelessFunctionCount]];


    /* write Tonlity Values */
    for(i=0;i<modeCount*modeCount;i++)
	[aCoder encodeValueOfObjCType:"d" at:&myModeDist[i/modeCount][i%modeCount]];

    for(i=0;i<14;i++)
	[aCoder encodeValueOfObjCType:"d" at:&myTonalityDist[i/7][i%7]];
    
    for(i=0;i<VAL_MAX_LOCUS*VAL_MAX_LOCUS;i++)
	[aCoder encodeValueOfObjCType:"d" at:&myDistanceMatrix[i/VAL_MAX_LOCUS][i%VAL_MAX_LOCUS]];
	
    [aCoder encodeValueOfObjCType:"d" at:&myPitchReference];
    [aCoder encodeValueOfObjCType:"d" at:&mySemitoneUnit];
    [aCoder encodeValueOfObjCType:"d" at:&myGlobalLevel];
    [aCoder encodeValueOfObjCType:"d" at:&myLocalLevel];
    [aCoder encodeValueOfObjCType:"d" at:&myWeightProfile];
    [aCoder encodeValueOfObjCType:"d" at:&myTransitionProfile];
    [aCoder encodeValueOfObjCType:"d" at:&myStartWeight];
    [aCoder encodeValueOfObjCType:"d" at:&myEndWeight];
    [aCoder encodeValueOfObjCType:"d" at:&myGlobalSlope];
    [aCoder encodeValueOfObjCType:"d" at:&myIntraProfile];
    
    [aCoder encodeValueOfObjCType:"i" at:&myCausalDepth];
    [aCoder encodeValueOfObjCType:"i" at:&myFinalDepth];
    
    [aCoder encodeValueOfObjCType:"c" at:&isRiemannCalculated];
    [aCoder encodeValueOfObjCType:"c" at:&isLevelCalculated];
    [aCoder encodeValueOfObjCType:"c" at:&isDistanceCalculated];
    [aCoder encodeValueOfObjCType:"c" at:&isBestPathCalculated];
    
    [aCoder encodeValueOfObjCType:"i" at:&myMethod];
    for(i=0;i<56;i++)
	[aCoder encodeValueOfObjCType:"d" at:&myNollProfile[i/7][i%7]];
    for(i=0;i<96;i++)
	for (j=0; j<43; j++)
	    [aCoder encodeValueOfObjCType:"d" at:&myNollMatrix[i/12][i%12][j]];
}

- (id)viterbiContext;
{
  return viterbiContext;
}

- (void)setViterbiContext:(id)newViterbi;
{
  [newViterbi retain];
  [viterbiContext release];
  viterbiContext=newViterbi;
}


- resetToDefaultValues;
{
    [self resetGeneralDefaultValues];
    [self resetRiemannDefaultValues];
    [self resetTonalityDefaultValues];
    [self resetWeightDefaultValues];
    [self resetNollDefaultValues];
    [self resetMethod];
    return self;
}

- resetGeneralDefaultValues;
{
    myPitchReference = 60.0;
    mySemitoneUnit = 1.0;
    myLocalLevel = 0.0;
    myGlobalLevel = 0.0;
    myCausalDepth = 1; // was 2 (takes too long)
    myFinalDepth = 0;  // was 2 (takes too long)
    myGlobalSlope = 0.0;
    [self invalidate];
    return self;
}


- resetRiemannDefaultValues;
{
    int i;

  tonalityCount=MAX_TONALITY;
  functionCount=MAX_FUNCTION;
  locusCount=VAL_MAX_FUNCTION*VAL_MAX_TONALITY;
  modelessFunctionCount=MAX_MODELESS_FUNCTION;

  [self allocFunctionScale:NULL useFunctionList:NULL distanceMatrix:NULL doInit:YES];
  [self allocModelessFunctionDist:NO doInit:NO];

  for(i=0;i<VAL_MAX_LOCUS;i++) {
	myFunctionScale[i/pcCount][i%VAL_MAX_TONALITY] = funScale[i/pcCount][i%VAL_MAX_TONALITY];
	myUseFunctionList[i] = YES;
    }

    for(i=0;i<modelessFunctionCount*modelessFunctionCount;i++)
	myModelessFunctionDist[i/modelessFunctionCount][i%modelessFunctionCount] = funDist[i/modelessFunctionCount][i%modelessFunctionCount];
    
    [self invalidate];
    return self;
}

- resetTonalityDefaultValues;
{
    int i;

    modeCount=MAX_MODE;
    [self allocModeDist:NULL doInit:NO];
    for(i=0;i<modeCount*modeCount;i++)
	myModeDist[i/modeCount][i%modeCount] = modeDist[i/modeCount][i%modeCount];

    for(i=0;i<14;i++)
	myTonalityDist[i/7][i%7] = tonalityDist[i/7][i%7];

    [self invalidate];
    return self;
}

- resetWeightDefaultValues;
{
    myWeightProfile = 10.0;
    myTransitionProfile = 1.0;
    myStartWeight = 1.0;
    myEndWeight = 1.0;
    myIntraProfile = 0.5;
    isDistanceCalculated = NO;
    isBestPathCalculated = NO;
    return self;
}

- resetNollDefaultValues;
{
    int i;

    for(i=0;i<56;i++)
	myNollProfile[i/7][i%7] = nollProfile[i/7][i%7];

    isRiemannCalculated = NO;
    isLevelCalculated = NO;  
    isDistanceCalculated = NO;
    return self;
}

- resetMethod;
{
    myMethod = MAZZOLA;
    isRiemannCalculated = NO;
    isLevelCalculated = NO;  
    isDistanceCalculated = NO;
    return self;
}


/* suppose that a canonically ordered list anEventList built from EH-MatrixEvents is deduced from the predicate */
- generateChordsFromEHList:anEventList;
{
    int c = [anEventList count];
//    [anEventList ref];
    
    if(c){
	int i;
	id toneAti, chord;
    
	[anEventList sort];
	
	[myChords freeObjects];
	for(i=0; i<c; i++){ /*make chord list */
	    toneAti = [anEventList objectAt:i]; /*make chord list */
	    [toneAti setDoubleValue:0.0]; /* necessary for later weights are 0 by default */
	    if(!i || [toneAti doubleValueAtIndex:indexE] > [[anEventList objectAt:i-1] doubleValueAtIndex:indexE]){
		chord = [[[Chord alloc]initOwner:self] addToneEvent:toneAti];
		[myChords addObject: chord];
	    }
	    else {
		[[myChords lastObject] addToneEvent:toneAti];/* adds only if absent */
	    }
	}
	[self invalidate];
	[myChords sort];
    }
//    [anEventList release];
  [self setViterbiContext:nil];
    return self;
}

/* suppose that anEventList built from EHD-MatrixEvents is deduced from the predicate */
- generateChordsFromEHDList:anEventList;
{
    id list = nil;
    int c = [anEventList count];
//    [anEventList ref];
    [anEventList sort];
    
    if(c){
	int i, j, k, lc, sup, inf;
	double ONi, OFFi, ONj, OFFj, pitchi, iD, maxD = 0.0;
	id 	evti, toneAti, toneAtj;
	
	list = [[OrderedList alloc] init];
    
	/* get maximal duration */
	for(i=0; i<c;i++){
	    iD = [[anEventList objectAt:i] doubleValueAtIndex:indexD];
	    maxD = maxD < iD ? iD : maxD;
	}

        toneAtj = [[[[anEventList objectAt:0] setSpaceTo:EH_space]retain] autorelease];
	for(i=0; i<c; i++){
	    evti = [anEventList objectAt:i];
	    ONi = [evti doubleValueAtIndex:indexE];
	    OFFi = ONi+[evti doubleValueAtIndex:indexD];
            toneAti = [[[evti clone] autorelease] setSpaceTo:EH_space];
	    pitchi = [evti doubleValueAtIndex:indexH];
	    lc = [list count];
	    for (k=0; k<lc && ![[list objectAt:k]equalTo:toneAti]; k++);
	    if (k==lc) [list addObject:toneAti];

	    /* limits for search */
	    /* for(sup = c-1; OFFi<=[[anEventList objectAt:sup] doubleValueAtIndex:indexE]; sup--); */
	    /*  replace by faster version starting from evti */
	    for(sup = i; sup<c && OFFi>=[[anEventList objectAt:sup] doubleValueAtIndex:indexE]; sup++);
	    /* finds the index of last event with onset at most OFFi-ONi (i.e. Durationi) behind evti */
	    
	    /* for(inf = 0; ONi>=maxD+[[anEventList objectAt:inf] doubleValueAtIndex:indexE]; inf++); */
	    /*  replace by faster version starting from evti */
	    for(inf = i; inf>0 && ONi<maxD+[[anEventList objectAt:inf] doubleValueAtIndex:indexE]; inf--);
	    /* finds the index of the first event that is at most maxD before evti */

	    /* insert all succeeding chords within duration of evti */
	    for(j=i+1; 	j<=sup;j++){ 
		ONj = [[anEventList objectAt:j] doubleValueAtIndex:indexE];
		if(ONi<ONj && ONj<OFFi){
		    [toneAtj setDoubleValue:ONj atIndex:indexE];
                    [toneAtj setDoubleValue:pitchi atIndex:indexH];
    
		    lc = [list count];
		    /* check whether there is already an equal one */
		    for (k=0; k<lc && ![[list objectAt:k]equalTo:toneAtj]; k++);
		    /* insert if sole event with that coordinates */
                    if (k==lc) {
                      id clone=[toneAtj clone];
                      [list addObject:clone];
                      [clone release];
                    }
		}
	    }


	    /* insert events produced by off's from preceding chords which happen within duration of evti  */
	    for(j=inf; 	j<=sup; j++){
		ONj = [[anEventList objectAt:j] doubleValueAtIndex:indexE];
		OFFj = ONj+[[anEventList objectAt:j] doubleValueAtIndex:indexD];
		if(ONi<OFFj && OFFj<OFFi){
		    [toneAtj setDoubleValue:OFFj atIndex:indexE];
                    [toneAtj setDoubleValue:pitchi atIndex:indexH];
		    lc = [list count];
		    for (k=0; k<lc && ![[list objectAt:k]equalTo:toneAtj]; k++);
                    if (k==lc) {
                      id clone=[toneAtj clone];
			[list addObject:clone];
                        [clone release];
                    }
		}
	    }
	    //[toneAti release]; 
            toneAti = nil;
	}
	//[toneAtj release]; 
        toneAtj = nil;
    }
    [self generateChordsFromEHList:[list sort]];
//    [anEventList release];
    return self;
}

- installThirdStreams;
{
    int i, c = [myChords count];
    for(i=0; i<c; i++)
	[[myChords objectAt:i] calcThirdStreamList];
    [self invalidate];
    return self;
}


- (unsigned int)count;
{
    return [myChords count];
}

- chordAt:(int)index;
{
    return [myChords objectAt:index];
}

- (double)onsetAt:(int)index;
{
    return [[self chordAt:index] onset];
}


/* read and write of instance variables */
/* Riemann and level data */
- (double)scaleValueAt:(int)function:(int)tone;
{
    
    function = mod(function, VAL_MAX_FUNCTION);
    tone = mod(tone, pcCount);
    return myFunctionScale[function][tone];
}

- setScaleValue:(double)value at:(int)function:(int)tone;
{
    if([self scaleValueAt:function:tone] != value){
	function = mod(function, VAL_MAX_FUNCTION);
	tone = mod(tone, pcCount);
	myFunctionScale[function][tone]=value;
	[self invalidate];
    }
    return self;
}

- (const double**)functionScale;
{
    return (const double**)myFunctionScale;
}


- (double)pitchReference;
{
    return myPitchReference;
}

- setPitchReference:(double)aDouble;
{
    if (aDouble!=myPitchReference) {
	myPitchReference = aDouble;
	[self invalidate];
    }
    return self;
}

- (double)semitoneUnit;
{
    return mySemitoneUnit; 
}

- setSemitoneUnit:(double)aDouble;
{
    if(aDouble && aDouble!=mySemitoneUnit) {
	mySemitoneUnit = fabs(aDouble);
	[self invalidate];
    }  
    return self;
}

- (double)localLevel;
{
    return myLocalLevel;
}

- setLocalLevel:(double)level;
{
    (level = fabs(level));
    if(level>=0 && level <=100 && (myLocalLevel != level)){
	myLocalLevel = level;
	isLevelCalculated = NO;  
	isBestPathCalculated = NO;
    }
    return self;
}

- (double)globalLevel;
{
    return myGlobalLevel;
}

- setGlobalLevel:(double)level;
{
    (level = fabs(level));
    if(level>=0 && level <=100 && (myGlobalLevel != level)){
	myGlobalLevel = level;
	isLevelCalculated = NO;
	isBestPathCalculated = NO;
    }
    return self;
}


- (BOOL)useFunctionAtLocus:(int)locus;
{
    if (locus<VAL_MAX_LOCUS)
	return myUseFunctionList[locus];
    return NO;
}

- setUseFunction:(BOOL)flag atLocus:(int)locus;
{
    if (locus<VAL_MAX_LOCUS) {
	if (myUseFunctionList[locus]!=flag) {
	    myUseFunctionList[locus] = flag;
	    isLevelCalculated = NO; 
	    isBestPathCalculated = NO;
	}
    }
    return self;
}


- invalidate;
{
    isRiemannCalculated = NO;
    isLevelCalculated = NO;
    isDistanceCalculated = NO;
    isBestPathCalculated = NO;
    [self invalidateChords];
    return self;
}

- invalidateChords;
{
  [myChords makeObjectsPerformSelector:@selector(invalidate)];
    return self;
}

- invalidateWeights;
{
    [myChords makeObjectsPerformSelector:@selector(invalidateWeight)];
    return self;
}

#define NUMBER(i) [NSClassFromString(@"Number") numberWithDouble:(double)(i)]
/* generating the Riemann logic background if necessary */
- generateRiemannLogic;
{
  int i, j, c = [myChords count];

  if(!isRiemannCalculated){
    // NEWHARMO
    Block *block=[fsBlocks objectForKey:@"HarmonicProfileValueForFunction:tonic:pc:"];
    int i,j,k;
    int sumCount;
    NSArray *tonalityToPitchClassMapping;
    int *tonalityMapping;
    if (harmonicProfile)
      free(harmonicProfile);
    if (useMorphology) {
      sumCount=144;
    } else
      sumCount=pcCount;
    MALLOC3(harmonicProfile,functionCount,tonalityCount,sumCount,double);

    tonalityToPitchClassMapping=[harmoSpace objectForKey:@"TonalityToPitchClassMapping"];
    NSParameterAssert(!tonalityToPitchClassMapping || (tonalityCount==[tonalityToPitchClassMapping count]));
    if (!tonalityToPitchClassMapping && (pcCount!=tonalityCount)) {
      NSLog(@"Warning: pcCount!=tonalityCount and there is no TonalityToPitchClassMapping installed");
      NSBeep();
    }
    tonalityMapping=malloc(tonalityCount*sizeof(int));
    for (j=0; j<tonalityCount; j++) {
      if (tonalityToPitchClassMapping) {
        int tonalityToPitchClassValue;
        id tonalityToPitchClassEntry=[tonalityToPitchClassMapping objectAtIndex:j];
        if ([tonalityToPitchClassEntry respondsToSelector:@selector(intValue)]) {
          tonalityToPitchClassValue=[tonalityToPitchClassEntry intValue];
        } else if ([tonalityToPitchClassEntry respondsToSelector:@selector(doubleValue)]) {
          double dval=[tonalityToPitchClassEntry doubleValue];
          tonalityToPitchClassValue=(int)dval;
        } else {
          NSAssert(NO,@"Some entries of TonalityToPitchClassMapping are no numbers");
          tonalityToPitchClassValue=j;
        }
        NSParameterAssert((tonalityToPitchClassValue>=0) && (tonalityToPitchClassValue<pcCount));
        tonalityMapping[j]=tonalityToPitchClassValue;
      } else {
        tonalityMapping[j]=j;
      }
    }

    for (i=0; i<functionCount; i++) {
      for (j=0; j<tonalityCount; j++) {
        for (k=0; k<sumCount; k++) {
          double val;
          if (block) {
            id blockVal=[block value:NUMBER(i) value:NUMBER(j) value:NUMBER(k)];
            if ([blockVal respondsToSelector:@selector(doubleValue)])
              val=[blockVal doubleValue];
            else
              val=0.0;
          } else {
            val=myFunctionScale[i][(pcCount+k-tonalityMapping[j]) % pcCount]; // tonalityCount must be pcCount
          } // if
          harmonicProfile[i][j][k]=val;
        } // for k
      } // for j
    } // for i
    free(tonalityMapping); tonalityMapping=NULL;
    [self calcNollMatrix];
    for(i=0; i<c; i++)
      [[myChords objectAt:i] calcRiemannMatrix];
    isRiemannCalculated = YES;
  }
  if(!isLevelCalculated){
    double gLevel = 0.0, lLevel =0.0;
    id iChord;
    for (i=0; i<c;i++) {
	     lLevel = [[myChords objectAt:i] maxRiemannValue];
	     gLevel = lLevel>gLevel ? lLevel : gLevel;
    }
    gLevel = (myGlobalLevel/100)*gLevel;
    for(i=0; i<c; i++) {
      iChord = [myChords objectAt:i];
      lLevel = [iChord maxRiemannValue];
      lLevel = (myLocalLevel/100)*lLevel;
      [iChord calcLevelMatrixWithLevel:(gLevel>lLevel ? gLevel : lLevel)];
      for (j=0; j<VAL_MAX_LOCUS; j++)
        if (!myUseFunctionList[j])
          [iChord restrictLevelMatrixAtLocus:j];
    }
    isLevelCalculated = YES;
  }
  if(!isDistanceCalculated){
    NSArray *distanceMatrix=[harmoSpace objectForKey:@"DistanceMatrix"];
    if (distanceMatrix) {
      // skip calculation, use external Setting
      NSParameterAssert([distanceMatrix count]==VAL_MAX_LOCUS);
      for(i=0;i<VAL_MAX_LOCUS;i++) {
        NSArray *distanceVector=[distanceMatrix objectAtIndex:i];
        NSParameterAssert([distanceVector count]==VAL_MAX_LOCUS);
        for(j=0;j<VAL_MAX_LOCUS;j++)
          myDistanceMatrix[i][j]=[[distanceVector objectAtIndex:j] doubleValue];
      }
    } else {
      for(i=0;i<VAL_MAX_LOCUS;i++){
        for(j=0;j<VAL_MAX_LOCUS;j++)
          myDistanceMatrix[i][j] = [self calcDistanceFrom:i to:j];
      }
    }
    isDistanceCalculated = YES;
  }
  return self;
}

- (BOOL)isRiemannLogicOK;
{
    return isRiemannCalculated && isLevelCalculated && isDistanceCalculated;
}


- (double)functionDistanceFrom:(int)startFunction to:(int)targetFunction;
{
    startFunction = mod(startFunction,modelessFunctionCount);
    targetFunction = mod(targetFunction,modelessFunctionCount);
    return myModelessFunctionDist[startFunction][targetFunction];
}

- setFunctionDistance:(double)dist from:(int)startFunction to:(int)targetFunction;
{
    startFunction = mod(startFunction,modelessFunctionCount);
    targetFunction = mod(targetFunction,modelessFunctionCount);
    if (myModelessFunctionDist[startFunction][targetFunction] != dist) {
	myModelessFunctionDist[startFunction][targetFunction] = dist;
	[self invalidate];
    }
    return self;
}

- (double)modeDistanceFrom:(int)startMode to:(int)targetMode;
{
    startMode = mod(startMode,modeCount);
    targetMode = mod(targetMode,modeCount);
    return myModeDist[startMode][targetMode];
}

- setModeDistance:(double)dist from:(int)startMode to:(int)targetMode;
{
    startMode = mod(startMode,modeCount);
    targetMode = mod(targetMode,modeCount);
    if (myModeDist[startMode][targetMode] != dist) {
	myModeDist[startMode][targetMode] = dist;
	[self invalidate];
    }
    return self;
}

- (double)tonalityDistanceAt:(int)intervalRow:(int)tonalityCol;
{
    intervalRow = mod(intervalRow,2);
    tonalityCol = mod(tonalityCol,7);
    return myTonalityDist[intervalRow][tonalityCol];
}

- setTonalityDistance:(double)dist at:(int)intervalRow:(int)tonalityCol;
{
    intervalRow = mod(intervalRow,2);
    tonalityCol = mod(tonalityCol,7);
    if (myTonalityDist[intervalRow][tonalityCol] != dist) {
	myTonalityDist[intervalRow][tonalityCol] = dist;
	[self invalidate];
    }
    return self;
}

- (double)nollProfileAt:(int)row :(int)col;
{
    row = mod(row,8);
    col = mod(col,7);
    return myNollProfile[row][col];
}


- setNollProfile:(double)prof at:(int)row:(int)col;
{
    row = mod(row,8);
    col = mod(col,7);
    if (myNollProfile[row][col] != prof) {
	myNollProfile[row][col] = prof;
	[self calcNollMatrix];
	[self invalidate];
    }
    return self;
}

// jg? NEWHARMO unchanged?
- (double)tonalityDistanceFrom:(int)startTonality to:(int)targetTonality;
{
    int diff = modTwelve(targetTonality-startTonality);

    if(diff<=6)
	return myTonalityDist[0][diff];
    else
	return myTonalityDist[1][12-diff];
}

// jg? NEWHARMO unchanged?
- setTonalityDistance:(double)dist from:(int)startTonality to:(int)targetTonality;
{
    int diff = modTwelve(targetTonality-startTonality);

    if(diff<=6)
	myTonalityDist[0][diff] = dist;	
    else
	myTonalityDist[1][12-diff] = dist;

    [self invalidate];
    return self;
}

- (int)causalDepth;
{
    return myCausalDepth;
}

- setCausalDepth:(int)chordCard;
{
    if (chordCard != myCausalDepth) {
	myCausalDepth = chordCard;
	[self invalidate];
    }
    return self;
}


- (int)finalDepth;
{
    return myFinalDepth;
}

- setFinalDepth:(int)chordCard;
{
    if (chordCard != myFinalDepth) {
	myFinalDepth = chordCard;
	[self invalidate];
    }
    return self;
}


- (double)weightProfile;
{
    return myWeightProfile;
}

- setWeightProfile:(double)weightProfile;
{
    if (myWeightProfile != weightProfile) {
	myWeightProfile = weightProfile;
	[self invalidateWeights];
    }
    return self;
}

- (double)transitionProfile;
{
    return myTransitionProfile;
}

- setTransitionProfile:(double)transitionProfile;
{
    if (myTransitionProfile != transitionProfile) {
	myTransitionProfile = transitionProfile;
	[self invalidate];
    }
    return self;
}

- (double)globalSlope;
{
   return myGlobalSlope;
}

- setGlobalSlope:(double)slope;
{
    if (myGlobalSlope!=slope) {
	myGlobalSlope = slope;
	[self invalidateWeights];
    }
    return self;
}

- (double)intraProfile;
{
   return myIntraProfile;
}

- setIntraProfile:(double)intraProfile;
{
    intraProfile = fabs(intraProfile);
    if(1>intraProfile && intraProfile!=myIntraProfile && intraProfile!=0.0) {
	myIntraProfile = intraProfile;
	[self invalidateWeights];
    }
    return self;
}

- (int)method;
{
    return myMethod;
}

- setMethod:(int)aMethod;
{
    if (aMethod != myMethod && aMethod>0) {
	myMethod = aMethod;
	[self invalidate];
    }
    return self;
}


- (int)locusStartAt:(int)sequenceIndex;
{
    sequenceIndex = mod(sequenceIndex,[myChords count]);
    return [[myChords objectAt:sequenceIndex] supportStart];
}

- setWorkPathToSupportStartAround:(int)sequenceIndex;
{
    int i, mi, ma, c = [myChords count];
    sequenceIndex = mod(sequenceIndex,c);
    mi = MIN(c-1, sequenceIndex+myFinalDepth);
    ma = MAX(0, sequenceIndex-myCausalDepth);

    for(i = ma; i<= mi;i++){
	[[myChords objectAt:i] resetWorkLocusToSupportStart];
	}

    return self;
}

- resetWorkPathToSupportStart;
{
    int i, c = [myChords count];
    for(i=0; i<c;i++)
	[[myChords objectAt:i] resetWorkLocusToSupportStart];

    return self;
}

- (int)workLocusAt:(int)sequenceIndex;
{
    if (sequenceIndex<[myChords count])
	return [[myChords objectAt:sequenceIndex] workLocus];
    return VAL_MAX_LOCUS;
}

/* distance calculation between two points in function-mode-tonality 3x2x12 space */
- (double)calcDistanceFrom:	(int)startFunction:(int)startMode:(int)startTonality to:
				(int)targetFunction:(int)targetMode:(int)targetTonality;
{
    int row=0, col=0;
    targetTonality = TONALITY_RANGE(targetTonality);

    startMode = mod(startMode,modeCount);
    targetMode = mod(targetMode,modeCount);
    startFunction = mod(startFunction,modelessFunctionCount);
    targetFunction = mod(targetFunction,modelessFunctionCount);

    for (col=0; col<7; col++) {
	if (TONALITY_RANGE(startTonality + col*5) == targetTonality) {
	    row = 0;
	    break;
	}
	if (TONALITY_RANGE(startTonality + col*7) == targetTonality) {
	    row = 1;
	    break;
	}
    }
    
	
    return  (myModelessFunctionDist[startFunction][targetFunction]+ 
	    myModeDist[startMode][targetMode]+  
	    myTonalityDist[row][col])*myTransitionProfile; 
}

/* distance calculation between two points in Riemann-Locus space */
- (double)calcDistanceFrom:(int)startLocus to:(int)targetLocus;
{
    return [self calcDistanceFrom:mod(FUNCTION_OF(startLocus),modelessFunctionCount)
                                 :(FUNCTION_OF(startLocus)<modelessFunctionCount ? 0 : 1)
                                 : TONALITY_OF(startLocus)
                               to: mod(FUNCTION_OF(targetLocus),modelessFunctionCount)
                                 :(FUNCTION_OF(targetLocus) <modelessFunctionCount ? 0 : 1)
                                 :TONALITY_OF(targetLocus)];
}

- (double)distanceFrom:(int) startLocus to:(int)targetLocus;
{
    if (!isDistanceCalculated) 
	[self generateRiemannLogic];
    return myDistanceMatrix[startLocus][targetLocus];
}		



- (int)firstIndex;
{
    int i, c = [myChords count];
    for(i=0; i<c && [[myChords objectAt:i] supportStart]==VAL_MAX_LOCUS; i++);
    return i;
}


- (int)lastIndex;
{
    int i, c = [myChords count];
    for(i=c-1; i>=0 && [[myChords objectAt:i] supportStart]==VAL_MAX_LOCUS; i--);
    return i;
}


/* weight of chord at sequenceIndex on path of index = pathNumber and myCausalDepth, myFinalDepth*/
- (double)pathWeightDifferenceAround:(int)sequenceIndex:(int)diffIndex;
/* logarithmic version */
{
    int i, t, k = 1, l = 1, c = [myChords count], mi, ma;
    double startOneWeight = 0.0, startTwoWeight = 0.0, leviOne, leviTwo;
    id iChord, kChord, lChord; 
    if(0<=diffIndex){
	iChord = [myChords objectAt:diffIndex];
	mi = MIN(MIN(c-1, sequenceIndex+myFinalDepth),[self lastIndex]);
	ma = MAX(MAX(0, sequenceIndex-myCausalDepth),[self firstIndex]);
	/* by choice of diffIndex we "know" that the following two levels are non-vanishing! */
	startOneWeight = log([iChord levelAtPath:PATHNUMBER])*myWeightProfile;
	startTwoWeight = log([iChord levelAtPath:PATHNUMBER-1])*myWeightProfile;
	for(t=diffIndex-1; ma<=t && ![[myChords objectAt:t] levelAtPath:PATHNUMBER]; t--);
	if(ma<=t){
	    kChord = [myChords objectAt:t];
	    startOneWeight -= myDistanceMatrix[[kChord locusOfPath:PATHNUMBER]][[iChord locusOfPath:PATHNUMBER]];	    
	    startTwoWeight -= myDistanceMatrix[[kChord locusOfPath:PATHNUMBER]][[iChord locusOfPath:PATHNUMBER-1]];	 
	    }   

	for(i=diffIndex+1; i<=mi; i++){
	    iChord= [myChords objectAt:i];
	    leviOne=[iChord levelAtPath:PATHNUMBER];
	    leviTwo=[iChord levelAtPath:PATHNUMBER-1];
	    if(leviOne){ 
		kChord = [myChords objectAt:i-k]; 
		startOneWeight += log(leviOne)*myWeightProfile-
			    myDistanceMatrix[[kChord locusOfPath:PATHNUMBER]][[iChord locusOfPath:PATHNUMBER]];				
		k = 1;
		}
	    if(leviTwo){ 
		lChord = [myChords objectAt:i-l]; 
		startTwoWeight += log(leviTwo)*myWeightProfile-
			    myDistanceMatrix[[lChord locusOfPath:PATHNUMBER-1]][[iChord locusOfPath:PATHNUMBER-1]];				
		l = 1;
		}
		/* if a weight is zero, neglect it! */
	    if(!leviOne)
		k +=1;
	    if(!leviTwo)
		l +=1;
	}
    }
    return startOneWeight-startTwoWeight;
}


/* produces the next working path, copies the old one to the PATHNUMBER-1 path 
 * and returns non-negative index of local increase or -1 if it©s a maximal path 
 */
- (int)increaseIndexAround:(int)sequenceIndex;
{
    int i, inc = -1, c = [myChords count];
    sequenceIndex = mod(sequenceIndex,c);
    if(VAL_MAX_LOCUS!=[[myChords objectAt:sequenceIndex] supportStart]){
	int last = MIN(c-1, sequenceIndex+myFinalDepth),
	    first = MAX(0, sequenceIndex-myCausalDepth);
    
	/* find first non maximal position */
	for(i=last; i>=first && [[myChords objectAt:i] maxWorkSupportIndex];i--);
	    
	if(i >= first){
	    int j;
	    id obi = [myChords objectAt:i];
	    [obi retainWorkLocus];
	    [obi setWorkLocus:[obi nextSupportIndexTo:[obi workLocus]]];
	    /* set all the following workloci to start support */
	    for(j = i+1; j<=last; j++){
		[[myChords objectAt:j] retainWorkLocus];
		[[myChords objectAt:j] resetWorkLocusToSupportStart];
		}
	    inc = i;
	}
    }
    return inc;
}

/* the locus ranking for the chord at sequenceIndex */
- calcBestPathAt:(int)sequenceIndex;
{
    int inc, bestLocus;
    double val = 0.0, valmax = 0.0;
    id iChord;
    [self invalidateWeights];
    iChord = [myChords objectAt:sequenceIndex];
    if([iChord supportStart]<VAL_MAX_LOCUS){
	/* reset the relevant work path data after working on them */
	[self setWorkPathToSupportStartAround:sequenceIndex];
	bestLocus = [iChord workLocus]; 
	while(0<=(inc=[self increaseIndexAround:sequenceIndex])){
	    val += [self pathWeightDifferenceAround:sequenceIndex:inc];	    
	    if(val>valmax){
		valmax = val;
		bestLocus = [iChord workLocus]; 
	    }
	}
	/* this adapts the object 0-path-locus at sequenceIndex */
	[iChord setRiemannLocusOf:0 to:bestLocus];
	}
    return self;
}

- (SEL)calcBestPathSelector;
{
  return calcBestPathSelector;
}
- (void)setCalcBestPathSelector:(SEL)sel;
{
  calcBestPathSelector=sel;
}

/* this one performs all the preceding index-specific tasks */
- calcBestPath;
{
    if (!isBestPathCalculated) {
      if (calcBestPathSelector) {
        [self performSelector:calcBestPathSelector]; // jg substitute
      } else {
        id progressPanel; // element in ow
	JgOwner *ow=[[JgOwner alloc] init];
	int i, c = [myChords count];
//jg old:        progressPanel = [NSBundle loadNibNamed:@"JgProgress.nib" owner:self];
        [NSBundle loadNibNamed:@"Progress.nib" owner:ow]; // ow.property=Progress-Panel
	progressPanel=[ow property];	

        [[progressPanel progressView] setDoubleValue:0.0];
	[progressPanel setIncrement:1.0];
	[[progressPanel progressView]setMaxValue:(double)c];
	[progressPanel setTitle:@"Path Calculation Progress"];
	[progressPanel setString:@""];
	[progressPanel makeKeyAndOrderFront:nil];
	[progressPanel display];
	    
	for(i=0; i<c; i++) {
	    NSEvent *theEvent = [[NSApplication sharedApplication] nextEventMatchingMask:(int)NSKeyDownMask untilDate:[NSDate dateWithTimeIntervalSinceNow:0.0] inMode:NSEventTrackingRunLoopMode dequeue:YES];
            if (theEvent && [theEvent modifierFlags] & NSCommandKeyMask && [[theEvent charactersIgnoringModifiers] isEqualToString:@"."])
		break;
		
            [progressPanel setString:[NSString stringWithFormat:@"Calculating path at\n chord %d of %d", i+1, c]];
	    [self calcBestPathAt:i];
            [progressPanel increment:self];
	}
        [progressPanel close];

        [progressPanel release]; progressPanel = nil;
        [ow release];
        isBestPathCalculated = i==c;
      }
    
	if (isBestPathCalculated) {
	    [self bestPathWeight];
	    myStartWeight = [self bestPathWeightAt:[self firstIndex]];
	    myEndWeight = [self bestPathWeightAt:[self lastIndex]];
	}
    
    }
    return self;
}

- (BOOL)isBestPathCalculated;
{
    return isBestPathCalculated;
}

/* weight calculations for best path, should be preceeded by the calcBestPath method! */
- (double)bestPathWeightAt:(int)sequenceIndex;
{
    return [[myChords objectAt:sequenceIndex] bestWeight];
}

/* global weight calculations for best path, should be incorporated into calcBestPath method! */
- bestPathWeight;
{
    int i, j, 
    	c = [myChords count],
	ma = [self firstIndex];
	
    double  jWeight, iWeight, value, 
	    r = 1.0;
	
    id iChord, jChord;
    
    for(j=0;j<c;j++){
	jChord = [myChords objectAt:j];
	jWeight = [jChord levelAtPath:0];
    
	if(jWeight==0.0)
	    [jChord setBestWeight:0.0];

	else if(j==ma){
	    [jChord setBestWeight:pow(jWeight,myWeightProfile/(double)c)];
	    r++;
	    }
	    
	else{	
	    for(i=j-1; i>=ma && !(iWeight = [[myChords objectAt:i] levelAtPath:0]); i--);

	    iChord = [myChords objectAt:i];
	    value = log([iChord bestWeight])*(double)c*r/(r+1);

	    value += (log(jWeight)*myWeightProfile - 
			myDistanceMatrix[[iChord locusOfPath:0]][[jChord locusOfPath:0]])/(r+1);
	    
	    [jChord setBestWeight:exp(value/((double)c))];
	    r++;
	    }
     }
    return self;
}



- (double)firstWeight;
{
    int i, c = [myChords count];
    double weight = 0.0;
    for(i=0; i<c && [[myChords objectAt:i] supportStart]==VAL_MAX_LOCUS; i++);
    if(i<c)
    weight = [[myChords objectAt:i] levelAtPath:0];
    return weight;
}

- (double)lastWeight;
{
    int i, c = [myChords count];
    double weight = 0.0;
    for(i=c-1; i>=0 && [[myChords objectAt:i] supportStart]==VAL_MAX_LOCUS; i--);
    if(i>=0)
    weight = [[myChords objectAt:i] levelAtPath:0];
    return weight;
}

- (double)normalizeFactorAt:(int)sequenceIndex;
{
    double norm = 1.0;
    sequenceIndex = mod(sequenceIndex,[myChords count]);
    if([self locusStartAt:sequenceIndex]!=VAL_MAX_LOCUS && myStartWeight && myEndWeight){
	/* second condition only for security reasons */
	int fI = (double)[self firstIndex],
	lI = (double)[self lastIndex];
	if(fI == lI) /* only one weight non-vanishing */
	    norm = 1/myStartWeight;
	else {
	    double slopeFactor = exp(myGlobalSlope)-1,
	    startOnset = [self onsetAt:fI],
	    lastOnset = [self onsetAt:lI],
	    sequenceOnset = [self onsetAt:sequenceIndex],
	    onsetRange = lastOnset - startOnset,
	    deltaOnset = sequenceOnset - startOnset;

	    slopeFactor = onsetRange + deltaOnset*slopeFactor;
	    norm = slopeFactor/(onsetRange*myStartWeight + deltaOnset*(myEndWeight-myStartWeight));
	}
    }
    return norm; 	
}


/* this is the weight of chord at sequenceIndex */
- (double)normalizedbestPathWeightAt:(int)sequenceIndex;
{
    sequenceIndex = mod(sequenceIndex,[myChords count]);

    if([self locusStartAt:sequenceIndex]!=VAL_MAX_LOCUS)
	return [self normalizeFactorAt:sequenceIndex]*[self bestPathWeightAt:sequenceIndex];

    return 0.0;
}

- (double)relativeWeightAt:(int)sequenceIndex:(int)toneIndex;
{
    id indexChord = [myChords objectAt:sequenceIndex];
    if([indexChord supportStart]!=VAL_MAX_LOCUS){
	int bestLocus = [indexChord locusOfPath:0];
	
	return [self normalizedbestPathWeightAt:sequenceIndex]*
	    [indexChord relativeWeightOfTone:toneIndex 
			atLocus:bestLocus];
    }
    return 0.0;
}

/* perhaps the following three methods superfluous by the fourth! 
- weightedChordAt:(int)sequenceIndex;
{
    id indexChord = [myChords objectAt:sequenceIndex];
    int c = [indexChord pitchCount];

    for(i=0;i<c;i++)
	[[indexChord toneEventAt:i] setDoubleValue:[self relativeWeightAt:sequenceIndex:i]];
    return self;
}

- weightedChordSequence;
{
    int i, c = [myChords count];

    for(i=0; i<c; i++)
	[self weightedChordAt:i];
    return self;
}

- harmoWeightList;
{
    int i, c = [myChords count];
    id theList = [[myChords objectAt:0] toneList]; 
    for(i=1; i<c; i++)
	[theList appendList:[[myChords objectAt:i] toneList];
    return theList;
}
*/


/* this makes the harmoweight list at once, without first makein the weighted chords */
- addHarmoWeightsToWeight:aWeight;
{
    int i, j, c = [myChords count];
    for(i=0; i<c; i++){
	id iChord = [myChords objectAt:i];
	int pc = [iChord pitchCount];

	for(j=0;j<pc;j++)
	    [aWeight addWeight:[self relativeWeightAt:i:j] at:[iChord onset]:[iChord pitchList][j]:0:0:0:0];

	}
    return self;
}

- (BOOL)isWeightCalculated;
{
    int i, c = [myChords count];
    for (i=0; i<c && [[myChords objectAt:i]isWeightCalculated]; i++);
    return isBestPathCalculated && i==c;
}

    
/* estimate calculation amount */
- (double)approxCalculations;
{
    int i, j, sC, c = [myChords count];
    double amounti = 1, sum = 0.0;
    for(i=0; i<c; i++){
	int mi = MIN(c-1, i+myFinalDepth),
	    ma = MAX(0, i-myCausalDepth);
    
	for(j = ma, amounti=1; j<=mi; j++){
	    id chordj = [myChords objectAt:j];
	    if(sC = [chordj supportCard])
		amounti *= sC;
	}
	sum += amounti;
    }
    return sum;
}

/* Noll Methoden */
/* Methode för die Berechnung der Koeffizienten der Noll-Matrix; j++ = Zeile 1...8; k++ = Spalte 1...12 */
- (double *)profTable:(double *)table at:(int)j:(int)k;
{
    int i,t, indexArray[7][43], m[2];
    double temp;
 
    switch(j){
	case 0:{ /*TON*/
	    for (t=0; t<7; t++)
		nollIndex(indexArray[t], majorCons(m,k,t));
	    
	    for(i=0;i<43;i++){
		for(t=0,temp = 0; t<7; t++)
		    temp += myNollProfile[j][t]*indexArray[t][i];
	    
		table[i]= temp;
	    }
	    return table;
	}
    
	case 1:{ /*DOM*/
	    for (t=0; t<7; t++)
		nollIndex(indexArray[t], majorCons(m,k+1,t));
	    
	    for(i=0;i<43;i++){
		for(t=0,temp = 0; t<7; t++)
		    temp += myNollProfile[j][t]*indexArray[t][i];
	    
		table[i]= temp;
	    }
	    return table;
	}
    
	case 2:{ /*SUB*/
	    for (t=0; t<7; t++)
		nollIndex(indexArray[t], majorCons(m,k+11,t));
	    
	    for(i=0;i<43;i++){
		for(t=0,temp = 0; t<7; t++)
		    temp += myNollProfile[j][t]*indexArray[t][i];
	    
		table[i]= temp;
	    }
	    return table;
	}
    
	case 3:{ /*ton*/
	    for (t=0; t<7; t++)
		nollIndex(indexArray[t], minorCons(m,k+1,t));
	    
	    for(i=0;i<43;i++){
		for(t=0,temp = 0; t<7; t++)
		    temp += myNollProfile[j][t]*indexArray[t][i];
	    
		table[i]= temp;
	    }
	    return table;
	}
    
	case 4:{ /*dom*/
	    for (t=0; t<7; t++)
		nollIndex(indexArray[t], minorCons(m,k+2,t));
	    
	    for(i=0;i<43;i++){
		for(t=0,temp = 0; t<7; t++)
		    temp += myNollProfile[j][t]*indexArray[t][i];
	    
		table[i]= temp;
	    }
	    return table;
	}
    
	case 5:{ /*sub*/
	    for (t=0; t<7; t++)
		nollIndex(indexArray[t], minorCons(m,k,t));
	    
	    for(i=0;i<43;i++){
		for(t=0,temp = 0; t<7; t++)
		    temp += myNollProfile[j][t]*indexArray[t][i];
	    
		table[i]= temp;
	    }
	    return table;
	}    
    
	case 6:{ /*DOMdiss*/
	    for (t=0; t<7; t++)
		nollIndex(indexArray[t], majorDiss(m,k+1,t));
	    
	    for(i=0;i<43;i++){
		for(t=0,temp = 0; t<7; t++)
		    temp += myNollProfile[j][t]*indexArray[t][i];
	    
		table[i]= temp;
	    }
	    return table;
	}
    
	case 7:{ /*subDiss*/
	    for (t=0; t<7; t++)
		nollIndex(indexArray[t], minorDiss(m,k,t));
	    
	    for(i=0;i<43;i++){
		for(t=0,temp = 0; t<7; t++)
		    temp += myNollProfile[j][t]*indexArray[t][i];
	    
		table[i]= temp;
	    }
	    return table;
	}
	
	default:
	    break;
    }
    return NULL; 

}

/* Berechnungsmethode der nollWeight 3D-Matrix 12 x 8 x 43 */
- calcNollMatrix;
{
    int j,k;
    for(j=0; j<8; j++){
	for(k=0; k<12; k++)
	    [self profTable:myNollMatrix[j][k] at:j:k];
	}
    return self;
}

- (double ***)nollMatrix;
{
    return (double ***)myNollMatrix;
}

- (NSDictionary *)harmoSpace;
{
  return harmoSpace;
}

- (void)setHarmoSpace:(NSDictionary *)dict;
{
//  int newFunctionCount=functionCount;
//  int newTonalityCount=tonalityCount;
  id entry;
  [dict retain];
  [harmoSpace release];
  harmoSpace=dict;
  entry=[dict objectForKey:@"Functions"];
  if (entry) 
    functionCount=[entry count];
  entry=[dict objectForKey:@"Tonalities"];
  if (entry)
    tonalityCount=[entry count];
  entry=[dict objectForKey:@"Modes"];
  if (entry)
    modeCount=[entry count];
  entry=[dict objectForKey:@"ModelessFunctions"];
  if (entry)
    modelessFunctionCount=[entry count];
  entry=[dict objectForKey:@"Pitches"];
  if (entry)
    pcCount=[entry count];

  locusCount=tonalityCount*functionCount;
  entry=[dict objectForKey:@"Loci"];
  if (entry)
    NSAssert([entry count]==locusCount,@"ChordSequence -setHarmoSpace: number of Loci entries does not reflect tonalityCount*functionCount");
  [self allocFunctionScale:NULL useFunctionList:NULL distanceMatrix:NULL doInit:YES]; // need all three?
  [self allocModelessFunctionDist:NULL modeDist:NULL doInit:YES];
//  - (void)allocNollMatrix:(double ***)otherNollMatrix doInit:(BOOL)doInit;
  [self invalidate];
}


- (NSMutableDictionary *)fsBlocks;
{
  return fsBlocks;
}

- (int)locusCount;
{
  return locusCount;
}
- (int)tonalityCount;
{
  return tonalityCount;
}
- (int)functionCount;
{
  return functionCount;
}
- (int)modeCount;
{
  return modeCount;
}
- (int)modelessFunctionCount;
{
  return modelessFunctionCount;
}
- (int)pcCount;
{
  return pcCount;
}
@end

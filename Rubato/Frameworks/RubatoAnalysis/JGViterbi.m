#import "JGViterbi.h"
#import <Foundation/NSDebug.h>

// Constants N and L must be defined in the context of the macro expansion
// () are very important! eg. psi_at(t+1,path[t+1])
#define a_at(i,j) a[(i)*N+(j)] 

#define b_at(j,v) b[(j)*L+(v)]

#define psi_at(t,i) psi[(t)*N+(i)]

static BOOL dontFreeJGViterbi=YES;

void *viterbiCalloc(size_t nmemb, size_t size) {
  void *result=calloc(nmemb,size);
  static int action=1;
  if (!result) {
    if (action&1)
      NSLog(@"viterbiCalloc Could not allocate %d times %d bytes",nmemb,size);
    if (action&2)
      abort();
  }
  return result;
}
                  
@interface JGViterbi (private)
- (void)printOb:(NSString *)location;
@end
@implementation JGViterbi
- (id)init; 
{ 
  [super init];
  T=N=L=0;
  ob=NULL;
  a=b=pi=NULL;
  sf=NULL;
  path=NULL;
  P=0;
  d_prev=d_next=NULL;
  psi=NULL;
  customFactors=NULL;
  nextT=0;
  return self;
}
- (void)dealloc;
{
  [self viterbiDeallocation];
  [super dealloc];
}
- (void)viterbiAllocateDelta;
  /*" call this before viterbiAllocation to keep delta values (consumes T*N doubles) "*/
{ 
  int t;
  delta=viterbiCalloc(T,sizeof(double *));
  for (t=0;t<T;t++)
    delta[t]=viterbiCalloc(N,sizeof(double));
}

- (void)viterbiAllocation;
{
  if (!delta) {
    d_prev=viterbiCalloc(N,sizeof(double));
    d_next=viterbiCalloc(N,sizeof(double));    
  }
  psi=viterbiCalloc(T*N,sizeof(int));
    // not deallocated:
  path=viterbiCalloc(T,sizeof(int));
}
- (void)viterbiDeallocation;
{
  if (dontFreeJGViterbi) return;
  if (!delta) {
    if (d_prev) free(d_prev);
    if (d_next) free(d_next); 
  } else {
    int t;
    for (t=0;t<T;t++)
      free(delta[t]);
    free(delta);
    delta=NULL;
  }
  d_prev=NULL;
  d_next=NULL;
  if (psi) free(psi); psi=NULL;
}

- (void)viterbiAllocateCustomFactorsForT:(int)t;
{
  NSParameterAssert(t<T);
  if (customFactors) {
    customFactors[t]=viterbiCalloc(N,sizeof(double));
  }
}
- (void)viterbiDeallocateCustomFactorsForT:(int)t;
{
  NSParameterAssert(t<T);
  if (customFactors && customFactors[t]) {
    free(customFactors[t]);
    customFactors[t]=NULL;
  }
}

- (void)viterbiAllocateModelUsePi:(BOOL)usePi useSF:(BOOL)useSF useCustomFactors:(BOOL)useCF;
{
  ob =viterbiCalloc(T,sizeof(int));
  a =viterbiCalloc(N*N,sizeof(double));
  b =viterbiCalloc(N*L,sizeof(double));
  if (usePi)
    pi=viterbiCalloc(N,sizeof(double));
  if (useSF)
    sf=viterbiCalloc(N,sizeof(char));
  if (useCF)
    customFactors=viterbiCalloc(T,sizeof(double *));
}


- (void)viterbiDeallocateModelAndPath:(BOOL)deallocPath;
{
  if (dontFreeJGViterbi) return;
  if (ob) free(ob); ob=NULL;
  if (a) free(a); a=NULL;
  if (b) free(b); b=NULL;
  if (pi) free(pi); pi=NULL;
  if (sf) free(sf); sf=NULL;
  if (customFactors) free(customFactors); customFactors=NULL; // who releases the elements?
  if (deallocPath && path) {
    free(path);
    path=NULL;
  }
}

// special cases of isNormalizedBuffer...
- (void)normalizeB;
{
  int j,l;
  for (j=0;j<N;j++) {
    double sum=0.0;
    for (l=0;l<L;l++)
      sum+=b_at(j,l);
    for (l=0;l<L;l++)
      b_at(j,l)/=sum;
  }
}
- (void)normalizeBInL:(int)l;
{
  int j;
  double sum=0.0;
  for (j=0;j<N;j++) 
    sum+=b_at(j,l);
  for (j=0;j<N;j++) 
    b_at(j,l)/=sum;
}

- (void)normalizeA;
{
  int i,j;
  for (i=0;i<N;i++) {
    double sum=0.0;
    for (j=0;j<N;j++)
      sum+=a_at(i,j);
    for (j=0;j<N;j++)
      a_at(i,j)/=sum;
  }
}

- (BOOL)isNormalizedBuffer:(double *)buf length:(int)l tolerance:(double)tol normalizeIfNeeded:(BOOL)normalizeIfNeeded;
{
  int i;
  double sum=0.0;
  BOOL isNormalized;
  for (i=0;i<l;i++)
    sum+=buf[i];
  isNormalized=((sum-tol<1.0) && (sum+tol>1.0));
  if (!isNormalized && normalizeIfNeeded)
    for (i=0;i<l;i++)
      buf[i]/=sum;
  return isNormalized;
}

- (BOOL)isNormalizedWithTolerance:(double)tol;
{
  int i;
  if (a)
    for (i=0;i<N;i++)
      if (![self isNormalizedBuffer:a+i*N length:N tolerance:tol normalizeIfNeeded:NO])
        return NO;
  if (b)
    for (i=0;i<N;i++)
      if (![self isNormalizedBuffer:b+i*L length:L tolerance:tol normalizeIfNeeded:NO])
        return NO;
  if (pi)
    if (![self isNormalizedBuffer:pi length:N tolerance:tol normalizeIfNeeded:NO])
      return NO;
  return YES;
}

- (void)viterbiAlgorithm;
{
  static BOOL doPrint=NO;
  [self printOb:@"viterbiAlgorithm 1"];
  if (nextT==0)
    [self viterbiInitialization];
  [self printOb:@"viterbiAlgorithm 2"];
  if (nextT<T)
    [self viterbiRecursion];
  [self printOb:@"viterbiAlgorithm 3"];
  if (nextT==T)
    [self viterbiRecursion];  
  [self viterbiTermination];
  [self printOb:@"viterbiAlgorithm 4"];
  //  [self viterbiDeallocation];
  if (doPrint)
    NSLog([self description]);
}  
  
- (void)viterbiInitialization;
{
  int i;
  double initialProb=1.0/(double)N; // default, if pi is not set
  double *customFactorsT=(customFactors?customFactors[0]:NULL);
  if (delta)
    d_next=delta[0];
  if (T<=0)
    return;
  for (i=0;i<N;i++) {
    if (pi) 
      initialProb=pi[i];
    if (customFactorsT)
      d_next[i]=customFactorsT[i]*initialProb*b_at(i,ob[0]);
    else
      d_next[i]=initialProb*b_at(i,ob[0]);      
    psi_at(0,i)=0; // t==0
  }
  nextT=1;
}

- (void)viterbiRecursion;
{
  int i,j,t;

  for (t=nextT; t<T; t++) {
    double *customFactorsT=(customFactors?customFactors[t]:NULL);
    if (delta) {
      d_next=delta[t];
      d_prev=delta[t-1];
    } else {
      double *d_swap;
      d_swap=d_prev;
      d_prev=d_next;
      d_next=d_swap;      
    }

//    NSLog(@"viterbiRecursion t=%d",t);
    for (j=0; j<N; j++) {
      int argmax=0;
      double max=d_prev[0]*a_at(0,j);
      for (i=1; i<N; i++) {
        double val;
          val=d_prev[i]*a_at(i,j);
        if (val > max) {
          argmax=i;
          max=val;
        }
      } // for i
      if (customFactorsT)
        d_next[j]=customFactorsT[j]*max*b_at(j,ob[t]);
      else
        d_next[j]=max*b_at(j,ob[t]);
      psi_at(t,j)=argmax;
    } // for j
  } // for t
  nextT=T;
}
/* old, wrong?
for (j=0; j<N; j++) {
  int argmax=0;
  double max=d_prev[0]*a_at(0,j);
  for (i=1; i<N; i++) {
    double val;
    if (customFactorsT)
      val=customFactorsT[i]*d_prev[i]*a_at(i,j);
    else
      val=d_prev[i]*a_at(i,j);
    if (val > max) {
      argmax=i;
      max=val;
    }
  } // for i
  d_next[j]=max*b_at(j,ob[t]);
  psi_at(t,j)=argmax;
*/  
- (void)viterbiTermination;
{
  int i,t;
  BOOL maxIsSet=NO;
  double max=0.0;
  int argmax=0;
  for (i=0;i<N;i++) {
    if (!sf || sf[i]) {
      double val=d_next[i];
      if (!maxIsSet || (val>max)) {
        maxIsSet=YES;
        argmax=i;
        max=val;
      } 
    }
  }
  NSParameterAssert(maxIsSet);
  P=max;
  // Recovering the state sequence
  path[T-1]=argmax;
  for (t=T-2;t>=0;t--) {
    path[t]=psi_at(t+1,path[t+1]);
  }
}

- (double *)deltaAtT:(int)t;
{
  if (t<nextT) {
    if (delta)
      return delta[t];
    else if (nextT==T-1)
      return d_next;
    else if (nextT==T-2)
      return d_prev;
  } 
  return NULL;
}

- (void)testViterbi; // not complete
{
  // set counts
  N=3; // states
  T=15; // events
  L=3; // symbols + 0 -

  [self viterbiAllocation];
  [self viterbiAllocateModelUsePi:NO useSF:NO useCustomFactors:NO];

  // set ob
  ob[0]=0;
  ob[1]=1;
  ob[2]=0;
  ob[3]=0;
  ob[4]=0;
  ob[5]=0;
  ob[6]=1;
  ob[7]=1;
  ob[8]=2;
  ob[9]=1;
  ob[10]=2;
  ob[11]=2;
  ob[12]=0;
  ob[13]=2;
  ob[14]=2;
  
  // set b(j,v)
  b_at(0,0)=0.7;
  b_at(0,1)=0.2;
  b_at(0,2)=0.1;
  b_at(1,0)=0.1;
  b_at(1,1)=0.8;
  b_at(1,2)=0.1;
  b_at(2,0)=0.1;
  b_at(2,1)=0.2;
  b_at(2,2)=0.7;
  
  // set a
  a_at(0,0)=0.8;
  a_at(0,1)=0.2;
  a_at(0,2)=0.0;
  a_at(1,0)=0.0;
  a_at(1,1)=0.7;
  a_at(1,2)=0.3;
  a_at(2,0)=0.2;
  a_at(2,1)=0.0;
  a_at(2,2)=0.8;
  
  [self viterbiAlgorithm];
  NSLog([self description]);
}
+ (void)testViterbi;
{
  JGViterbi *vit=[[[JGViterbi alloc] init] autorelease];
  [vit testViterbi];
}

- (void)printOb:(NSString *)location;
{
  static BOOL doIt=NO;
  if (doIt) {
    int t;
    NSMutableString *str=[NSMutableString string];
    [str appendFormat:@"%@ obs:",location];
    for (t=0;(t<T);t++)
      [str appendFormat:@" %d",ob[t]];
    NSLog(str);
  }
}

- (NSString *)description;
{
  NSMutableString *str=[NSMutableString string];
  int i,j,l,t;
  static int maxLength=10;
  [str appendFormat:@"Viterbi: N=%d L=%d T=%d",N,L,T];
  if (ob) {
    [str appendString:@"\nobs:"];
    for (t=0;((t<T) && (t<maxLength));t++)
      [str appendFormat:@" %d",ob[t]];
  }
  if (path) {
    [str appendString:@"\npath:"];
    for (t=0;((t<T) && (t<maxLength));t++)
      [str appendFormat:@" %d",path[t]];
  }
  if (a) {
    [str appendString:@"\na:"];
    for (i=0;((i<N) && (i<maxLength));i++) {
      [str appendFormat:@"\ni=%d: ",i];
      for (j=0;((j<N) && (j<maxLength));j++)
        [str appendFormat:@" %f",a_at(i,j)];
    }
  }
  if (b) {
    [str appendString:@"\nb:"];
    for (i=0;((i<N) && (i<maxLength));i++) {
      [str appendFormat:@"\ni=%d: ",i];
      for (l=0;((l<L) && (l<maxLength));l++)
        [str appendFormat:@" %f",b_at(i,l)];
    }
  }
  if (psi) {
    [str appendString:@"\npsi(t,j):"];
    for (j=0;((j<N) && (j<maxLength));j++) {
      [str appendFormat:@"\nj=%d: ",j];
      for (t=0;((t<T) && (t<maxLength));t++)
        [str appendFormat:@" %d",psi_at(t,j)];
    }
  }
  return str;
}
@end

@implementation JGViterbiContext
- (id)init;
{
  [super init];
  viterbi=[[JGViterbi alloc] init];
  symbols=[[NSMutableDictionary alloc] init];
  processedSymbols=[[NSMutableSet alloc] init];
//  observationSequence=[[NSMutableArray alloc] init];
  useLevelMatrix=YES;
  nextObservationPosition=0;
  return self;
}
- (void)dealloc;
{
  [viterbi release];
  [symbols release];
  [processedSymbols release];
//  [observationSequence release];
  [super dealloc];
}
@end



NSString *JGViterbiDictionary=@"JGViterbiDictionary";
NSString *JGViterbiSymbols=@"JGViterbiSymbols";
NSString *JGViterbiSymbolList=@"JGViterbiSymbolList";
NSString *JGViterbiSequence=@"JGViterbiSequence";
NSString *JGViterbiMatrix=@"JGViterbiMatrix";
NSString *JGChordLevelMatrix=@"JGChordLevelMatrix";

@implementation ChordSequence (JGViterbi)
- (void)viterbiCalcBestPathUseRiemannMatrix;
{// level matrix does not include restrictions on tonality
  [self viterbiCalcBestPathUseLevelMatrix:NO];
}
- (void)viterbiCalcBestPathUseLevelMatrix;
{// level matrix includes restrictions on tonality
  [self viterbiCalcBestPathUseLevelMatrix:YES];
}

- (void)viterbiCalcBestPathUseLevelMatrix:(BOOL)useLevelMatrix;
{
  static double tol=0.1;
  static BOOL shouldBeNormalized=NO; // not necessary/not reasonable for b.
  
  BOOL doOwnVit=(viterbiContext==nil);
  JGViterbi *vit;
  JGViterbiContext *vitCont=viterbiContext;
  if (doOwnVit)
    vit=[self makeViterbiUseLevelMatrix:useLevelMatrix]; // includes autorelease
  else 
    vit=vitCont->viterbi; // the object, who sets viterbiAnalysis in self must keep it in sync with self!
  
  if (shouldBeNormalized && ![vit isNormalizedWithTolerance:tol]) {
    // this block is for debugging only
    static double tol=-2.0; // useful for breakpoints
    BOOL success;
    if (NSDebugEnabled) NSLog(@"assertion failed in -viterbiCalcBestPathUseLevelMatrix: vit is not normalized");
    while (tol>-1.0)
      success=[vit isNormalizedWithTolerance:tol]; // debug helper: try different values for tol here.
  }
  [vit printOb:@"viterbiCalcBestPathUseLevelMatrix"];
  [vit viterbiAlgorithm];
  [self setBestPathFromViterbi:vit];
  [vit printOb:@"viterbiCalcBestPathUseLevelMatrix"];
  if (doOwnVit)
    [vit viterbiDeallocateModelAndPath:YES];
  isBestPathCalculated=YES;
}


- (id)makeViterbiUseLevelMatrix:(BOOL)useLevelMatrix;
{
  JGViterbiContext *context=[self makeViterbiContextUseLevelMatrix:useLevelMatrix];
  JGViterbi *vit=context->viterbi;
  [self addProbabilitiesToViterbiContext:context];
  [[vit retain] autorelease];
  return vit;
}

- (id)makeViterbiContextUseLevelMatrix:(BOOL)useLevelMatrix;
{
  JGViterbiContext *context=[[[JGViterbiContext alloc] init] autorelease];
  NSMutableDictionary *symbols=context->symbols;
  JGViterbi *vit=context->viterbi;
  context->useLevelMatrix=useLevelMatrix;

  // set counts
  vit->N=MAX_FUNCTION*MAX_TONALITY;
  vit->T=[myChords count];
  // collect the symbols (for the number L)
  [myChords makeObjectsPerformSelector:@selector(addSymbolsToViterbiSymbols:) withObject:symbols];
  vit->L=[symbols count];
  [vit viterbiAllocation];
  [vit viterbiAllocateModelUsePi:NO useSF:NO useCustomFactors:YES];
  return context;
}

- (void)addProbabilitiesToViterbiContext:(JGViterbiContext *)context;
{  // set b
  static BOOL doNormalizeB=NO; //
  [myChords makeObjectsPerformSelector:@selector(addValuesToViterbiContext:) withObject:context];
  [context->viterbi printOb:@"makeViterbiUseLevelMatrix"];
  if (doNormalizeB)
    [context->viterbi normalizeB];
  // set a
  [self addValuesToViterbi:context->viterbi];
}

- (void)addValuesToViterbi:(JGViterbi *)viterbi;
{
  static int printTable=0;
  int i,j;
  double *a=viterbi->a;
  int N=viterbi->N;
  double *w=viterbiCalloc(MAX_LOCUS,sizeof(double));
  static BOOL printDistMatrix=NO;
  if (printDistMatrix) {
    NSMutableString *str=[NSMutableString string];
    for(i=0; i<MAX_LOCUS; i++) {
      [str appendFormat:@"\ni=%d",i];
      for (j=0;j<MAX_LOCUS;j++)
        [str appendFormat:@" %f",myDistanceMatrix[i][j]];
    }
   NSLog(str);
//  NSLog([viterbi description]);
  }

  for(i=0; i<MAX_LOCUS; i++) { // MAX_LOCUS==72==N
    double distSum=0.0;
    double wSum=0.0;
    double defaultVal=1.0/(double)MAX_LOCUS;
    static double expScaling=-1.0; // should later be adjustable by user in preferences
    static BOOL useOld=NO;
    if (useOld) {
      for(j=0; j<MAX_LOCUS; j++)
        distSum+=myDistanceMatrix[i][j];
      if (distSum>0.0)
        for(j=0; j<MAX_LOCUS; j++)
          w[j]=1.0-myDistanceMatrix[i][j]/distSum;
      else
        for(j=0; j<MAX_LOCUS; j++)
          w[j]=defaultVal;      
    } else { // accept negative values 
      for(j=0; j<MAX_LOCUS; j++)
        w[j]=exp(expScaling*myDistanceMatrix[i][j]);
    }
    // calculate probability (sum over all transitions is one)
    for(j=0; j<MAX_LOCUS; j++)  // (can be omitted: scaling is not relevant for the best path algorithm, but for P)
      wSum+=w[j];
    if (wSum>0.0)
      for(j=0; j<MAX_LOCUS; j++)
        a_at(i,j)=w[j]/wSum;
    else
      for(j=0; j<MAX_LOCUS; j++)
        a_at(i,j)=defaultVal;      
  }
  if (printTable){
    NSMutableString *str=[NSMutableString string];
//    [str appendFormat:@"distSum=%f wSum=%f",distSum,wSum];    
    [str appendFormat:@"\tT\tD\tS\tt\td\ts\tT\tD\tS\tt\td\ts\n"];
    for(j=0; j<MAX_LOCUS; j++) {
      for(i=0; i<6; i++) {
        [str appendFormat:@"\t%f",myDistanceMatrix[i*12][j]];
      }
      for(i=0; i<6; i++) {
        [str appendFormat:@"\t%f",a_at(i*12,j)];
      }
      [str appendString:@"\n"];
    }
    NSLog(str);
  }
  free(w);
}
- (void)setBestPathFromViterbi:(JGViterbi *)viterbi;
{
  int *path=viterbi->path;
  int i,c;
  c=[myChords count];
  for (i=0;i<c;i++) {
    int idx=path[i];
    Chord *chord=[myChords objectAtIndex:i];
    [chord setLocusOfPath:0 toIndex:idx];
  }
}
@end

@implementation Chord (JGViterbi)
- (void)addSymbolsToViterbiSymbols:(NSMutableDictionary *)symbols;
{
  // sets viterbi->L, viterbi->b and helper variables of p.
//  NSMutableDictionary *symbols=[p objectForKey:JGViterbiSymbols];
  NSNumber *symbol=[NSNumber numberWithShort:myPitchClasses]; // the produced symbol
  NSNumber *symbolNrObj;
  int symbolNr;

  symbolNrObj=[symbols objectForKey:symbol]; 
  if (!symbolNrObj) {
    symbolNr=[symbols count];
    symbolNrObj=[NSNumber numberWithInt:symbolNr];
    [symbols setObject:symbolNrObj forKey:symbol];
  }
}

- (void)addValuesToViterbiContext:(JGViterbiContext *)context;
{ // adds to b and ob, modifies nextObservationPosition
  
  NSNumber *symbol=[NSNumber numberWithShort:myPitchClasses]; // the produced symbol
  NSNumber *symbolNrObj=[context->symbols objectForKey:symbol];
  int symbolNr=[symbolNrObj intValue];
  JGViterbi *viterbi=context->viterbi;
  double *b=viterbi->b;
  int L=viterbi->L;
  int *observations=viterbi->ob;
  static BOOL showLog=NO;
  if (showLog)
    NSLog(@"chord nr=%d symbolNr=%d obsNr=%d ", [myOwnerSequence->myChords indexOfObject:self], symbolNr,context->nextObservationPosition);

  observations[context->nextObservationPosition]=symbolNr;
  context->nextObservationPosition++;
      
  // Two Chords with the same myPitchClasses should have the same riemannMatrix and must (!) have
  // the same probability distribution, otherwise Viterbi will not work.
  // So if b[j,v] is already defined for all j given a symbol (v is the number of the symbol)
  // we can skip the production of b.
  if (!context->processedSymbols || ![context->processedSymbols containsObject:symbol]) {
    double **pointer;//[][MAX_TONALITY];
    int i,j,state;
    static BOOL usePointer=NO;

    [context->processedSymbols addObject:symbol];
    if (usePointer) {
      if (context->useLevelMatrix)
        pointer=(double **)myLevelMatrix;
      else
        pointer=(double **)myRiemannMatrix;      
    }
    state=0;
    // semantics of index state in b_at(state,symbolNr):
    // first the tonality changes, then the function. (same as i in myDistanceMatrix[i][j])
    for(i=0; i<MAX_FUNCTION; i++) {
      for(j=0; j<MAX_TONALITY; j++) {
        double val;
        if (usePointer)
          val=pointer[i][j];
        else if (context->useLevelMatrix)
          val=myLevelMatrix[i][j];
        else
          val=myRiemannMatrix[i][j];
        b_at(state,symbolNr)=val;
        state++;
      }
    }
    // b is eventually normalized in symbolNr later. (see makeViterbiUseLevelMatrix)
  }
}
@end

/*- (void)addSymbolsToViterbi:(JGViterbi *)viterbi parameters:(id)p;
{
  // sets viterbi->L, viterbi->b and helper variables of p.
  NSMutableSet *symbols=[p objectForKey:JGViterbiSymbols];
  NSMutableArray *symbolList=[p objectForKey:JGViterbiSymbols]; // the observed symbols
  NSMutableArray *symbolNrSequence=[p objectForKey:JGViterbiSequence]; // the observation sequence O // needed?
  NSString *varName=[p objectForKey:JGViterbiMatrix];
  BOOL occoured;
  NSNumber *symbolNrObj;
  int symbolNr;
  id storedMatrix;
  double *b=viterbi->b;
  NSNumber *symbol=[NSNumber numberWithShort:myPitchClasses]; // the produced symbol

  occoured=[symbols containsObject:symbol]; // the state output probability distribution b(j) for all j. b[j,v]
  if (occoured) {
    symbolNr=[symbolList indexOfObject:storedMatrix];
  } else {
    [symbols addObject:symbol];
    [symbolList addObject:symbol];
    symbolNr=[symbolList count];
    viterbi->L=symbolNr+1;
  }
  [symbolNrSequence addObject:[NSNumber numberWithInt:symbolNr]]; // is this necessary/useful?
}
*/

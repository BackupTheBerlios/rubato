#import "ChordSequence.h"
#import "Chord.h"

@class JGViterbi;


// This class implements the Viterbi algorithm for Hidden Markov Models (HMM).
// The model is given through
// - S: a set of states, represented as indices, -> N
// - A: a set of state transition probabilities, -> a, N
// - B: a set of state output probabilities      -> b, N, L
// - Pi:an initial state distribution            -> pi
// The application of the model is given though
// - O: an observation sequence in time          -> T, L (symbols represented as indices)
// - SF: a set of allowed final states           -> sf
// The result of the algorithm is
// - thepath that has the highest probability    -> path, T, N
//   within the model to produce O.
// - its probability                             -> P

// Discussion: pi and sf can be expressed in terms of customFactors!
//             we leave them in here, because of reference to the standard algorithm (witout customFactors)
@interface JGViterbi : NSObject
{
 @public
  // given, not freed
  int T,N,L;  // number of observations (O), states (S) and generated symbols
  int *ob;    // ob[t]  : observation sequence, values are symbolNrs
  double *a;  // a[i,j] : transition probability from state i to state j
  double *b;  // b[j,v] : probability of generating symbol v in state j
  double *pi; // pi[i]  : initial probability of state i (optional, default:1/N)
  char *sf;   // sf[i]  : final states characteristic array (bool values) (optional, default:1)
    // return values, created and to be freed by the user
  int *path;     // path[t]   : state of the best path at observation time t
  double P;   // probability of the best path
  double **customFactors; // customFactors[t][i] customFactors[t] might be NULL
  int nextT;  // nextT allows viterbiAlgorithm to reuse a previously archieved calculation state.
              // (e.g.: when customFactors changes at t, nextT should be set to min(t,nextT)
 @private
     // algorithm variables, freed upon dealloc.
  double **delta; // delta[t][i] : if not NULL keeps the delta values
  double *d_prev,*d_next;  // d[j]: delta_t-1(j) and delta_t(j) 
  int *psi;  // psi[t,j] : 
}
- (void)viterbiAllocateDelta;
- (void)viterbiAllocation;
- (void)viterbiDeallocation;

- (void)viterbiAllocateCustomFactorsForT:(int)t;
- (void)viterbiDeallocateCustomFactorsForT:(int)t;

- (void)viterbiAllocateModelUsePi:(BOOL)usePi useSF:(BOOL)useSF useCustomFactors:(BOOL)useCF;
- (void)viterbiDeallocateModelAndPath:(BOOL)deallocPath;

// make sum of probabilities to 1.0
- (void)normalizeB; // sum above b[i,l] (i const)
- (void)normalizeA; // sum above a[i,j] (i const)
- (BOOL)isNormalizedBuffer:(double *)buf length:(int)l tolerance:(double)tol normalizeIfNeeded:(BOOL)normalizeIfNeeded;
- (BOOL)isNormalizedWithTolerance:(double)tol;

- (void)viterbiAlgorithm;
// consists of:
- (void)viterbiInitialization;
- (void)viterbiRecursion;
- (void)viterbiTermination;

- (double *)deltaAtT:(int)t;
@end

@interface JGViterbiContext : NSObject
{
  @public
  JGViterbi *viterbi;
  NSMutableDictionary *symbols;
  NSMutableSet *processedSymbols;
//  NSMutableArray *observationSequence;
  BOOL useLevelMatrix;
  int nextObservationPosition;
}
@end

@interface ChordSequence (JGViterbi)
- (void)viterbiCalcBestPathUseRiemannMatrix;
- (void)viterbiCalcBestPathUseLevelMatrix;
- (void)viterbiCalcBestPathUseLevelMatrix:(BOOL)useLevelMatrix;
// consists of:
- (id)makeViterbiUseLevelMatrix:(BOOL)useLevelMatrix; // consists of the following two
- (id)makeViterbiContextUseLevelMatrix:(BOOL)useLevelMatrix;
- (void)addProbabilitiesToViterbiContext:(JGViterbiContext *)context;
- (void)addValuesToViterbi:(JGViterbi *)viterbi;
- (void)setBestPathFromViterbi:(JGViterbi *)viterbi;
@end

@interface Chord (JGViterbi)
- (void)addSymbolsToViterbiSymbols:(NSMutableDictionary *)symbols;
- (void)addValuesToViterbiContext:(JGViterbiContext *)context;
@end

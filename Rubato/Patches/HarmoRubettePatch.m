//
//  HarmoRubettePatch.m
//  Rubato
//
//  Created by Joerg Garbers on Wed Oct 09 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "Chord.h"
#import "ChordSequence.h"
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import <Rubette/MatrixEvent.h>

#import "ThirdStream.h"
#import <FScript/FScript.h>
#define ClassArray NSClassFromString(@"Array")
#define ClassNumber NSClassFromString(@"Number")

#define EH_space 3

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

#define NUMBER(i) [NSClassFromString(@"Number") numberWithDouble:(double)(i)]


//#define VAL_MAX_TONALITY MAX_TONALITY
//#define VAL_MAX_FUNCTION MAX_FUNCTION
//#define VAL_MAX_LOCUS MAX_LOCUS
#define VAL_MAX_TONALITY tonalityCount
#define VAL_MAX_FUNCTION functionCount
#define VAL_MAX_LOCUS locusCount

@implementation ChordSequence (Patch)

// copied to ChordSequence
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
    for(i=0;i<VAL_MAX_LOCUS;i++){
      for(j=0;j<VAL_MAX_LOCUS;j++)
        myDistanceMatrix[i][j] = [self calcDistanceFrom:i to:j];
    }
    isDistanceCalculated = YES;
  }
  return self;
}
@end

@implementation Chord (Patch)

// copied to Main Rubaton
- (double)calcRiemannValueAtFunction:(int)function andTonic:(int)tonic;
{
  NSString *blockKey=@"Chord:calcRiemannValueAtFunction:andTonic:";
  Block *block=[[myOwnerSequence fsBlocks] objectForKey:blockKey];
  if ((function>MAX_FUNCTION) || (tonic>MAX_TONALITY)) {
    static int c=0;
    c++; // set breakpoint here
  }

  if (block) {
    id blockVal=[block value:self value:[ClassNumber numberWithDouble:(double)function] value:[ClassNumber numberWithDouble:(double)tonic]];
    if ([blockVal respondsToSelector:@selector(doubleValue)])
      return [blockVal doubleValue];
    else {
      NSLog(@"Block %@ did not return a Number value",blockKey);
      return 0.0;
    }
  } else {
    int method=[myOwnerSequence method];
    switch(method) {
      case MAZZOLA: {
        int j, c = [myThirdStreamList count]; /* c is always positive */
        double val = 0.0;
        for(j=0; j<c; j++) {
          /* add all thirdstream contributions */
          // add flag for NEWHARMO (useThirdStream/useChord)
          val += [[myThirdStreamList objectAt:j] riemannWeightWithFunctionScale:
#ifndef CHORDSEQ_DYN
            (void *)
#endif
                                     [myOwnerSequence functionScale] atFunction:FUNCTION_RANGE(function) andTonic:tonic];
        }
        /* take average */
        return    val / (double)c;
      }
      case NOLL: return [self calcNollRiemannValueAtFunction:function andTonic:tonic
                                                                    genericWeight:[myOwnerSequence nollMatrix]];
        // NEWHARMO
      case DIRECT_HARMO:
      case THIRDCHAIN_HARMO: {
        int i,c=0;
        int summandCount=0;
        int j;
        double val = 0.0;
        int pcCount;
        int pitchClasses;
        int useMorphology=(myOwnerSequence->useMorphology);
        BOOL useThirdChainFlag=(method==THIRDCHAIN_HARMO);
        int summationFormulaNumber=(myOwnerSequence->summationFormulaNumber);
        Block *summationFormulaBlock;
        id NumberClass=nil;
        if (summationFormulaNumber==3) {
          NSString *sBlockKey=@"ChordSummationFormulaBlock:";
          NumberClass=NSClassFromString(@"Number");
          summationFormulaBlock=[[myOwnerSequence fsBlocks] objectForKey:sBlockKey];
          NSParameterAssert(summationFormulaBlock!=nil);
        }

        if (useMorphology>0) {
          pcCount=144;
        } else
          pcCount=myOwnerSequence->pcCount; // normally 12
        if (useThirdChainFlag) {
          c=[myThirdStreamList count];
        } else {
          c=1;
          pitchClasses=myPitchClasses;
        }
        for (j=0;j<c;j++) {
          double *pitchFactors;
          if (useThirdChainFlag) {
            pitchClasses=[[myThirdStreamList objectAtIndex:j] pitchClasses];
          }
          if (useMorphology==1) {
            pitchFactors=[self closureNumbersForPitchClasses:pitchClasses];
          } else if (useMorphology==2) {
            pitchFactors=[self injectionNumbersForPitchClasses:pitchClasses];
          }
          for (i=0;i<pcCount;i++) {
            if (pitchClasses & 1<<i) {// see hasPitchClass
              double lookup=(myOwnerSequence->harmonicProfile)[function][tonic][i];
              double product;
              summandCount++;
              if (useMorphology>0) {
                product=lookup*pitchFactors[i];
              } else {
                product=lookup;
              }
              if (summationFormulaNumber==2) { // exp
                product=exp(product);
              } else if (summationFormulaNumber==0) { // exp (classic)
                if (product!=0.0)
                  product=exp(product);
              } else if (summationFormulaNumber==3) { // FScript code
                product=[[summationFormulaBlock value:[NumberClass numberWithDouble:product]] doubleValue];
              }
              val+=product;
            }
          }
        }
        return val/=(double)summandCount;
      }
    }
    return 0.0;
  }
}

@end

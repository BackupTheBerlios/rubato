
#import <RubatoDeprecatedCommonKit/commonkit.h>
#import "HarmoTypes.h"

@interface ThirdStream:JgRefCountObject
{
    thirdList *myThirdList; /* pointer to bit sequence for major and minor third sequence, 
    			1~major, 0~minor, sequence starts from the right! Everything is fixed within
			thirdList theBigThirdList[211] on HarmoTypes.h*/
    unsigned char myBasis; /* a one-bit position (0 to 11) for the basis tone where the thirds start from */
}

- init;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- setThirdList:(int)thirdListIndex;
- (int)basis;
- setBasis:(int)aBasis;
- (int)top;
- (size_t)length;
- (unsigned short)thirdBitList;
- (int)pitchClasses;
- (int)pitchClassAt:(int)index;
#ifdef CHORDSEQ_DYN
- (double)riemannWeightWithFunctionScale:(const double **)functionScale atFunction:(int)function andTonic:(int)tonic;
#else
- (double)riemannWeightWithFunctionScale:(const double [6][12])functionScale atFunction:(int)function andTonic:(int)tonic;
#endif
@end
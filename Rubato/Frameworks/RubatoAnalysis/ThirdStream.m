#import "ThirdStream.h"
#import <RubatoDeprecatedCommonKit/commonkit.h>

/* from presto©s third chain list; using bit.c in /gbm/CSB 
for transforming 3&4 chains into bit repres */
/* a "global" class variable */

thirdList theBigThirdList[211] = 
{
    /*length 0 */
	{0,0}, 
    
    /*length 1 */
	{1,0},{1,1},
    
    /*length 2 */
	{2,0},{2,1},{2,2},{2,3},
    
    /*length 3 */
	{3,0},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},
    
    /*length 4 */
	{4,1},{4,2},{4,3},{4,4},{4,5},{4,6},{4,8},
	{4,9},{4,10},{4,11},{4,12},{4,13},
    
    /*length 5 */
	{5,2},{5,3},{5,4},{5,5},{5,6},{5,8},{5,9},
	{5,10},{5,11},{5,12},{5,13},{5,17},{5,18},
	{5,19},{5,20},{5,21},{5,22},{5,24},{5,25},
	{5,26},{5,27},
    
    /*length 6 */
	{6,4},{6,5},{6,6},{6,8},{6,9},{6,10},{6,11},
	{6,12},{6,17},{6,17},{6,18},{6,19},{6,20},
	{6,21},{6,22},{6,24},{6,25},{6,26},{6,27},
	{6,34},{6,35},{6,36},{6,37},{6,38},{6,40},
	{6,41},{6,42},{6,43},{6,44},{6,45},{6,49},
	{6,50},{6,51},{6,52},{6,53},{6,54},
    
    /*length 7 */
	{7,8},{7,9},{7,10},{7,12},{7,17},{7,18},{7,20},
	{7,24},{7,27},{7,34},{7,36},{7,40},{7,43},{7,45},
	{7,51},{7,53},{7,54},{7,68},{7,72},{7,75},{7,77},
	{7,83},{7,85},{7,86},{7,89},{7,90},{7,91},{7,99},
	{7,101},{7,102},{7,105},{7,106},{7,107},{7,108},
	{7,109},
    
    /*length 8 */
	{8,17},{8,18},{8,20},{8,24},{8,34},{8,36},{8,40},
	{8,54},{8,68},{8,72},{8,86},{8,90},{8,102},{8,106},
	{8,107},{8,108},{8,109},{8,136},{8,137},{8,145},
	{8,155},{8,171},{8,173},{8,179},{8,181},{8,182},
	{8,203},{8,205},{8,211},{8,213},{8,214},{8,217},
	{8,218},{8,219},
    
    /*length 9 */
	{9,34},{9,36},{9,40},{9,68},{9,72},{9,108},{9,109},
	{9,136},{9,137},{9,145},{9,173},{9,181},{9,205},
	{9,213},{9,214},{9,217},{9,218},{9,219},{9,273},
	{9,274},{9,290},{9,310},{9,342},{9,346},{9,347},
	{9,358},{9,362},{9,363},{9,364},{9,365},{9,411},
	{9,427},{9,429},{9,435},{9,437},{9,438},
    
    /*length 10 */
	{10,68},{10,72},{10,136},{10,137},{10,145},
	{10,217},{10,218},{10,273},{10,274},{10,290},
	{10,346},{10,546},{10,548},{10,580},{10,620},
	{10,731},{10,859},{10,875},{10,877},
    
    /*length 11 */
	{11,136},{11,1161},{11,1241},{11,1755}
};

@implementation ThirdStream

- init;
{
    [super init];
    myThirdList = theBigThirdList; /* the address of theBigThirdList */
    myBasis = 0;

    return self;
}

- (id)copyWithZone:(NSZone *)zone;
{
  NSAssert(NO,@"WeightWatcher copyWithZone: not expected/implemented!");
  return JGSHALLOWCOPY;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    int index;
//    [super initWithCoder:aDecoder];
    /* class-specific code goes here */
    [aDecoder decodeValueOfObjCType:"i" at:&index];
    [aDecoder decodeValueOfObjCType:"C" at:&myBasis];
    [self setThirdList:index];
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    int index;
//    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */

    index = myThirdList-theBigThirdList;
    [aCoder encodeValueOfObjCType:"i" at:&index];
    [aCoder encodeValueOfObjCType:"C" at:&myBasis];
}

- setThirdList:(int)thirdListIndex;
{
    myThirdList = theBigThirdList+mod(thirdListIndex, 211);
    return self;
}


- (int)basis;
{
    return myBasis;
}


- setBasis:(int)aBasis;
{
    myBasis = modTwelve(aBasis);
    return self;
}

- (int)top;
{
    int i, top = myBasis;
    
    for(i=0; i<myThirdList->length; i++){
	top = (myThirdList->thirdBitList & 1<<i) ? top+4 : top+3;
    }
    return 1 << modTwelve(top); 
}


- (size_t)length;
{
    return myThirdList->length;
}

- (unsigned short)thirdBitList;
{
    return myThirdList->thirdBitList;
}

- (unsigned short)pitchClasses;
{
    int i, toneList, tonei;
    toneList = 1 << modTwelve(myBasis);
    tonei = myBasis;
    
    for(i=0; i<myThirdList->length; i++){
	tonei = (myThirdList->thirdBitList & 1<<i) ? tonei+4 : tonei+3;
	toneList = toneList | 1 << modTwelve(tonei); 
	}

    return toneList; 
}


- (int)pitchClassAt:(int)index;
{
    int i, tonei = myBasis;
    index = mod(index, myThirdList->length+1);
    for(i=0; i<index; i++){
	tonei = (myThirdList->thirdBitList & 1<<i) ? tonei+4 : tonei+3;
    }
    /* this returns myBasis for index = 0 */
    return modTwelve(tonei);
}


- (double)riemannWeightWithFunctionScale:(const double [6][12])functionScale atFunction:(int)function andTonic:(int)tonic;
/*
{
    int i, tonei;
    double valuei = 0.0, circle;
    function = mod(function,6);
    tonei = modTwelve(myBasis-tonic);
    valuei = functionScale[function][tonei];

    if(myThirdList->length){
	for(i=0; i<myThirdList->length-1; i++){
	    tonei = (myThirdList->thirdBitList & 1<<i) ? modTwelve(tonei+4) : modTwelve(tonei+3);
	    valuei += 2*(functionScale[function][tonei]);
	}
	tonei = (myThirdList->thirdBitList & 1<<i) ? modTwelve(tonei +4) : modTwelve(tonei +3);
	valuei += functionScale[function][tonei];
	valuei /= (double)2*myThirdList->length;
    }
    return valuei; 
}
*/
{
    int i, tonei;
    double valuei = 0.0, fui;
    function = mod(function,6);
    tonei = modTwelve(myBasis-tonic);
    if(fui=functionScale[function][tonei])
    valuei = exp(fui*EXPONENT);

    if(myThirdList->length){
	for(i=0; i<myThirdList->length; i++){
	    tonei = (myThirdList->thirdBitList & 1<<i) ? modTwelve(tonei+4) : modTwelve(tonei+3);
	    if(fui=functionScale[function][tonei])
	    valuei += exp(fui*EXPONENT);
	}
    }
    return valuei; 
}

@end

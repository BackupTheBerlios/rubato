/* CommonTypes.h */
//#import <objc/objc.h>           /* Contains nil, etc. */
#import <Foundation/Foundation.h>

typedef struct _Fract {
	double numerator;
	unsigned long denominator;
	BOOL isFraction;
} RubatoFract;

// als Compilerdirektive -Dselfvoid=id
// typedef id selfvoid; //jg zum entstauben.

#define nilVal 0
#define nilStr "NIL"
#define trueStr "TRUE"
#define falseStr "FALSE"
#define nilFract (RubatoFract){0,0,0}

#define ns_nilStr @"NIL"
#define ns_trueStr @"TRUE"
#define ns_falseStr @"FALSE"

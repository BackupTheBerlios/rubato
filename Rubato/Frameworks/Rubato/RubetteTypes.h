/* RubetteTypes.h */

//#import <appkit/appkit.h>
#import <RubatoDeprecatedCommonKit/CommonTypes.h>
#import <Rubato/PredicateTypes.h>

#import "RubatoTypes.h"

/* type definitions for Rubette data exchange */
typedef struct _quantList {
	double origin;
	RubatoFract mesh;
	int *onsets;
	size_t length;
} quantList;

#if 0
typedef struct _weightPoint {
	double *param;
	double weight;
} weightPoint;

typedef struct _weightList {
	int dimension;
	weightPoint *wP;
	size_t length;
} weightList;
#endif

#define RubetteFileType "rubette"
#define ns_RubetteFileType @"rubette"
#define BundleFileType "bundle"
#define ns_BundleFileType @"bundle"

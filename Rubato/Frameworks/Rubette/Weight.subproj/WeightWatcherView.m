/* WeightWatcherView.m */

#ifdef WITH_PS
#import <AppKit/psops.h>
#endif
#import <AppKit/NSApplication.h>

#import "WeightWatcherView.h"
#import "MatrixEvent.h"
//jg#import "LocalPerformanceScore.h"
#import "Weight.h"
#import "WeightWatcher.h"

@implementation WeightWatcherView


- initWithFrame:(NSRect)frameRect;
{
    [super initWithFrame:frameRect];
    return self;
}

- (void)dealloc;
{
  [myWeightWatcher release];
    [super dealloc];
}

- (void)displayWeightWatcher:aWeightWatcher;
{
    if (aWeightWatcher != myWeightWatcher) {
      [aWeightWatcher retain];
      [myWeightWatcher release];
      myWeightWatcher = aWeightWatcher;
      [theWeight release];
      theWeight=[myWeightWatcher retain];
    }
    [self display];
}

- (void)setCustomValues;
{
    double iBaryWeight, iTolerance;//, width=0.0, height=0.0, weight=1.0;
    int i, c;
    BOOL isYinit = NO, isProduct = [myWeightWatcher isProduct];

    c = [myWeightWatcher count];
    for (i=0; i<c; i++) {
	id aWeight = [myWeightWatcher weightObjectAt:i];
	iBaryWeight = [myWeightWatcher baryWeightAt:i];
	iTolerance = [myWeightWatcher toleranceAt:i];
	if (i>0) {
	    /* these variables are used for speed only */
	    double newMinX = [aWeight minCoordinate:0]-iTolerance,
		   newMaxX = [aWeight maxCoordinate:0]+iTolerance,
		   newMinY = [aWeight minCoordinate:1]-iTolerance,
		   newMaxY = [aWeight maxCoordinate:1]+iTolerance;
	    minX = MIN(newMinX, minX);
	    maxX = MAX(newMaxX, maxX);
	    if ([aWeight dimension]>1) {
		if (!isYinit) {
		    minY = [aWeight minCoordinate:1]-iTolerance;
		    maxY = [aWeight maxCoordinate:1]+iTolerance;
		    isYinit = YES;
		} else {
		    minY = MIN(newMinY, minY);
		    maxY = MAX(newMaxY, maxY);
		}
	    }
	    if (isProduct) {
		maxWeight *= [myWeightWatcher highNormAt:i]*iBaryWeight;
		minWeight *= [myWeightWatcher lowNormAt:i]*iBaryWeight;
	    } else {
		maxWeight += [myWeightWatcher highNormAt:i]*iBaryWeight;
		minWeight += [myWeightWatcher lowNormAt:i]*iBaryWeight;
	    }
	} else {
	    minX = [aWeight minCoordinate:0]-iTolerance;
	    maxX = [aWeight maxCoordinate:0]+iTolerance;
	    if ([aWeight dimension]>1) {
		minY = [aWeight minCoordinate:1]-iTolerance;
		maxY = [aWeight maxCoordinate:1]+iTolerance;
		isYinit = YES;
	    }
	    maxWeight = [myWeightWatcher highNormAt:i]*iBaryWeight;
	    minWeight = [myWeightWatcher lowNormAt:i]*iBaryWeight;
	}
    }	

  if (isProduct) {
      meanLevel = 1.0;
      for (i=0; i<c; i++)
          meanLevel *= [[myWeightWatcher weightObjectAt:i] meanNormalizedWeight]*[myWeightWatcher baryWeightAt:i];
  } else {
      meanLevel = 0.0;
      for (i=0; i<c; i++)
          meanLevel += [[myWeightWatcher weightObjectAt:i] meanNormalizedWeight]*[myWeightWatcher baryWeightAt:i];
  }
  // meanLevel shift by (-minWeight + wOffset) done in drawRect; 
}

- (double)weightValueAtEvent:(id)event;
{
  return [myWeightWatcher weightSumAt:event];
}


- (void)customDrawDim1;
{
  int i,j,d;
  int c=[myWeightWatcher count];
  id iWeight, jEvent;
  for (i=0; i<c; i++) {
      iWeight = [myWeightWatcher weightObjectAt:i];
      d=[iWeight count];
      for (j=0; j<d; j++) {
        double x,y;
          jEvent = [iWeight eventAt:j];
          x = ([jEvent doubleValueAt:0]-minX);
          y = ([myWeightWatcher weightSumAt:jEvent]-minWeight+wOffset);
          [self drawCircleAtX:x Y:y];
      }
  }
}

- (void)customDrawDim2;
{
  int i,j,d;
  int c=[myWeightWatcher count];
  id iWeight, jEvent;
  for (i=0; i<c; i++) {
      iWeight = [myWeightWatcher weightObjectAt:i];
      d=[iWeight count];
      for (j=0; j<d; j++) {
         jEvent = [iWeight eventAt:j];
          if ([jEvent space]==[myWeightWatcher space]) {
            [self drawCircleAtX:([jEvent doubleValueAt:0]-minX)
                              Y:([jEvent doubleValueAt:1]-minY)
                      fillColor:1 - ([myWeightWatcher weightSumAt:jEvent] - minWeight)*weightScaleFactor];
          }
      }
  }
}
@end

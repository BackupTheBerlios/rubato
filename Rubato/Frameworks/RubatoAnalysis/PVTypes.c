/* PVTypes.c */

#import <math.h>
#import "PVTypes.h"

double dynAdjust(double reference, double tolerance, double increase, double x)
{
    double result = reference, low, high;
    tolerance = reference-tolerance>= EPSILON ? tolerance : reference-EPSILON;
    if(tolerance && (low = reference-tolerance)<x && (high = reference+tolerance)>x){
	increase = fabs(increase);
	result = -((high*low - high*increase*low + high*increase*x - low*x)/
	    	(-high + increase*low + x - increase*x));
	    }
    return result;
}

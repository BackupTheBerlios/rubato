/* splines.c */

/*C-Routines for splines*/

#import <stdio.h>
#import <math.h>
#import "splines.h"
#define MAX 10 /* maximal number of admitted parameters, presently, we have 6 */

/*Splinefunction for:
start x,
end y,
startField Zx,
endField Zy,
startTime tx,
endTime ty,
time t
*/

double spline(double x, double Zx, double tx, double y, double Zy, double ty, double t)
{
    if(ty-tx){
	return
	pow(t,3)*((Zx+Zy)/pow(ty-tx,2) - 2*(y-x)/pow(ty-tx,3))+
	pow(t,2)*(3*(y-x)/pow(ty-tx,2) - (2*Zx+Zy)/(ty-tx))+
	t*Zx+
	x;
	    }
    else
	return x;
}


/* maxNorm, the maximal absolute value of a double pointer of given length for Runge-Kutta-Fehlberg ODE */
double maxNorm(unsigned int length, double *vector)
{
	int i;
	double abs, norm = fabs(*vector);
	for(i=1; i<length; i++)
	    norm = norm > (abs=fabs(vector[i])) ? norm : abs;
	return norm;
}



/*One cubic unit with P smaller than Q abscisse*/
double cube(double P1, double P2, double Q1, double Q2, double x)
{
    if( P1 - x >= 0)
	    return P2;
    
    else if(x - Q1 >= 0)
	    return Q2;
    
    else
	    return P2 + 
	    pow((x- P1),2) * 3 * (Q2 - P2)/pow((Q1 - P1),2) -
	    pow((x- P1),3) * 2 * (Q2 - P2)/pow((Q1 - P1),3);
}
	
/*Derivation of cube*/
double Dcube(double P1, double P2, double Q1, double Q2, double x)
{
    if((P1 - x >= 0) || (x - Q1 >= 0))
	    return 0;
    
    else
	    return (6 * ((x- P1) * (Q2 - P2)/pow((Q1 - P1),2) -
	    pow((x- P1),2) * (Q2 - P2)/pow((Q1 - P1),3)));
}

/*integration on reciprocal of line segment*/
double reciproc(double a, double b, double u, double v)
{
    if(v*u){
	if(v-u) 
    return (b-a)*(log(fabs(v/u)))/(v-u);
	else
    return (b-a)/u;
    }

    else
    return 1;
} 

/* support function between a and b and division number div */
double support(double a, double b, int div, double x)
{
    double step;

    if(a-b && div){
	step = (b-a)/fabs((double)div);

	if(x<a+step)
    return cube(a, 0, a+step, 1,x);
	else if(x<=b-step)
    return 1.0;
	else
    return cube(b-step, 1, b, 0, x);
    }
    
    else return 0;
}


/* 1D support between a and b and tolerance (a<b, tolerance >0) */

double tol1Dsupport(double deformation, double a, double b, double tolerance, double argument)
{
    if(a<b && tolerance){
	if(argument>a && argument<b)
	    return deformation;
	if(argument<=a)
	    return cube(a-(fabs(tolerance)/1000),0,a,1,argument)*deformation;
	
	if(argument>=b)
	    return cube(b,1,b+(fabs(tolerance)/1000),0,argument)*deformation;
    }
    return 0.0;
}

#if 0
{
    if(a<b && tolerance){
	    tolerance = fabs(tolerance);
	    deformation = fabs(deformation);
	if((argument<=(a-tolerance)) || (argument>=(b+tolerance)))
	    return 0.0;
	if(argument<=a)
	    //return (argument-(a-tolerance)) * (1.0/tolerance);  /* linear function */
	    return cube(a-tolerance,0.0,a,1.0,argument) / exp(2.0*deformation*(argument-(a-tolerance))/tolerance);
	if(argument<=b)
	    return 1.0;
	else
	    //return ((b+tolerance)-argument) * (1.0/tolerance); /* linear function */
	    return cube(b,1.0,b+tolerance,0.0,argument) / exp(2.0*deformation*((b+tolerance)-argument)/tolerance);
	}
    return 0.0;
} 
#endif

/* 2D support between a and b (1st axis) c and d (2nd axis) tolerance (a<b, c<d, tolerance >0) */

double tol2Dsupport(double deformation, double a, double b, double c, double d, double tolerance, double xArgument, double yArgument)
{
    return tol1Dsupport(deformation,a,b,tolerance,xArgument)*
	   tol1Dsupport(deformation,c,d,tolerance,yArgument);
}


/* 1D deformation function, centered around 0 and channeled through a support*/
double supported1DDeform(	double x, double deformation, 
			double a, double b, 
			double tolerance, double argument)
{
    return deform(x, tol1Dsupport(deformation,a,b,tolerance,argument));
}


/* 2D deformation function, centered around 0 and channeled through a support*/
double supported2DDeform(	double x, double deformation, 
			double a, double b, double c, double d, 
			double tolerance, double xArgument, double yArgument)
{
    return deform(x, tol2Dsupport(deformation, a,b,c,d,tolerance,xArgument,yArgument));
}


/* deformation function, centered around 0 */
double deform(double x, double deformation)
{
    if(deformation)
    return x/(exp(2.0*deformation) + x - exp(2.0*deformation)*x);
    else 
    return x;
}

/* derivation of deformation function */
double derDeform(double x, double deformation)
{
    if(deformation)
    return  exp(2*deformation)/pow(-exp(2*deformation)-x+exp(2*deformation)*x,2);

    else
    return 1;
}
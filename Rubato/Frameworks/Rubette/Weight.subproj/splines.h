/* splines.h */

/*C-Routines for splines*/

double spline(double x, double Zx, double tx, double y, double Zy, double ty, double t);

/* maxNorm, the maximal absolute value of a double pointer of given length for Runge-Kutta-Fehlberg ODE */
double maxNorm(unsigned int length, double *vector);

/*One cubic unit with P smaller than Q abscisse*/
double cube(double P1, double P2, double Q1, double Q2, double x);

/*Derivation of cube*/
double Dcube(double P1, double P2, double Q1, double Q2, double x);

/*integration on reciprocal of line segment*/
double reciproc(double a, double b, double u, double v);

/* support function between a and b and division number div */
double support(double a, double b, int div, double x);

/* 1D support between a and b and tolerance (a<b, tolerance >0) */

double tol1Dsupport(double deformation, double a, double b, double tolerance, double argument); 

/* 2D support between a and b (1st axis) c and d (2nd axis) tolerance (a<b, c<d, tolerance >0) */

double tol2Dsupport(double deformation, double a, double b, double c, double d, double tolerance, double xArgument, double yArgument);

/* 1D deformation function, centered around 0 and channeled through a support*/
double supported1DDeform(	double x, double deformation, 
			double a, double b, 
			double tolerance, double argument);

/* 2D deformation function, centered around 0 and channeled through a support*/
double supported2DDeform(	double x, double deformation, 
			double a, double b, double c, double d, 
			double tolerance, double xArgument, double yArgument);



/* deformation function */
double deform(double x, double deformation);

/* derivation of deformation function */
double derDeform(double x, double deformation);
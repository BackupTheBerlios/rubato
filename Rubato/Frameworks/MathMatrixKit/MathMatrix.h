/*MathMatrix.h*/

#import <RubatoDeprecatedCommonKit/JGList.h>
#import <math.h>

#import <RubatoDeprecatedCommonKit/commonkit.h>

#define NEWRETAINSCHEME [MathMatrix newRetainScheme]

#define NullMatrix nil /* 0x0 matrix with nil coefficients and 0 value, should be the default matrix */

#define EMANCIPATED_MATRIX_MAXRETAINCOUNT 1
#define EMANCIPATED_COEFFICIENT_MAXRETAINCOUNT 1
// a coefficient gets allocated, then added to an array (results in retainCount=2). If you do not want to keep a reference of the coefficient as an identity of its own, not just as a coefficient, you should release it (the super matrix still retains it.

@interface MathMatrix:JgRefCountObject <Ordering>
{
    unsigned int myRows;
    unsigned int myCols;
    double myValue;
    RefCountList *myCoefficients;
    Class myCoeffClass;
    BOOL isTransposed;
    BOOL isRegular;
}
+ (BOOL)newRetainScheme; // used for conversion to new programming paradigma

/* standard class methods to be overridden */
+ (void)initialize;

/* special class methods */

/* standard object methods to be overridden */
- init;
- initRows:(int)rowCount Cols:(int)colCount andValue:(double)value withCoefficients:(BOOL)cFlag;
- initIdentityMatrixOfWidth:(int)width;
- initElementaryMatrixWithRows:(int)rowCount Cols:(int)colCount andValue:(double)value at:(int)row:(int)col;
- (void)dealloc;
- (id)copyWithZone:(NSZone*)zone;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (BOOL)isEqual:anObject;
- (unsigned int)hash;

/* special Matrix copying */
- (id)clone;
- (id)cloneFromZone:(NSZone*)zone;
- (selfvoid)setToMatrix:aMatrix;
- (selfvoid)setToCopyOfMatrix:aMatrix;
- (selfvoid)setToEmptyCopyOfMatrix:aMatrix;

/* Matrix conversion and maintenance */
- (selfvoid)convertToRealMatrix;
- (selfvoid)convertToIdentityMatrixOfWidth:(int)width;
- (selfvoid)convertToElementaryMatrixWithValue:(double)value at:(int)row:(int)col;

- (BOOL)isEmancipatedWithMaxRetainCount:(unsigned int)maxRetainCount;
- (BOOL)isEmancipated;
- (BOOL)isEmancipatedCoefficient;
- (id)emancipateWithMaxRetainCount:(unsigned int)maxRetainCount;
- (id)emancipate;

- (BOOL)isCalculated;
- (selfvoid)calculate;

- (selfvoid)undo;

/* general Matrix behaviour */
/* Acces to matrix coefficient values */
- (selfvoid)setCoeffClass:classId;
- coeffClass;

// jg in union with NSString and NSCell return the following 3 methods void
- (void)setDoubleValue:(double)aDouble;
- (void)setDoubleValue:(double)value at:(int)row:(int)col;
- (void)setDoubleValue:(double)value at:(unsigned int)index;
- (double) doubleValue;
- (double) doubleValueAt:(int)row :(int)col;
- (NSNumber *) numberAt:(int)row :(int)col;
- (double) doubleValueAt:(unsigned int)index;
- (double *)doubleValuePtr:(int *)length;
- (void)takeDoubleValueFrom:(id)sender;

- (unsigned int)rows;
- (selfvoid)setRows:(unsigned int)newRows;
- (unsigned int)columns;
- (selfvoid)setColumns:(unsigned int)newCols;
- (BOOL) hasCoefficients;
- (NSMutableArray *)coefficients;
- (BOOL) hasCoefficients;
- (unsigned int)indexAt:(int)row :(int)col;
- (int)rowOfIndex:(unsigned int)index;
- (int)colOfIndex:(unsigned int)index;
- (unsigned int)transIndex:(unsigned int)index;
- (selfvoid)getRow:(int *)row andCol:(int *)col ofIndex:(unsigned int)index;

- (void)getNumberOfRows:(int *)rowCount columns:(int *)colCount;
- (id)matrixAt:(int)row :(int)col;
- (id)matrixAt:(unsigned int)index;
- (selfvoid)getRow:(int *)row andCol:(int *)col ofMatrix:aMatrix;
- (BOOL)putMatrix:newMatrix at:(int)row :(int)col;
- (BOOL)putMatrix:newMatrix at:(unsigned int)index;
- (BOOL)replaceMatrixAt:(int)row :(int)col with:newMatrix;
- (BOOL)replaceMatrixAt:(unsigned int)index with:newMatrix;


- (void)addRow;
- (void)insertRow:(int)row;
- (BOOL)insertRow:aRow at:(int)row;
- (BOOL)removeRowAt:(int)row;
- (selfvoid)modifyRowsTo:(int)row;

- (selfvoid)transpose; /* exchange row and column positions */
- (BOOL) isTransposed;

- (void)addColumn;
- (void)insertColumn:(int)col;
- (selfvoid)insertCol:aColumn at:(int)col;
- (selfvoid)removeColAt:(int)col;
- (selfvoid)modifyColsTo:(int)col;

- (const char*)rowSelectorFrom:(int)low to:(int)high;
- (const char*)colSelectorFrom:(int)low to:(int)high;

// the following methods create new matrices, but do not autorelease them. Is this desired ???jg
- (id)subMatrixOfRowSel:(const char*)rowSelector andColSel:(const char*)colSelector asCopy:(BOOL)flag;
- (id)subMatrixFrom:(int)fromRow:(int)fromCol to:(int)toRow:(int)toCol asCopy:(BOOL)flag;
- (id)rowMatrixAt:(int)fromRow asCopy:(BOOL)flag;
- (id)colMatrixAt:(int)fromCol asCopy:(BOOL)flag;
- (id)minorMatrixAt:(int)row:(int)col asCopy:(BOOL)flag; /* Attention: is a transposed construction! */
- (id)minorMatrixAt:(unsigned int)index asCopy:(BOOL)flag;

/*
- blockMatrixRowSel:(const char*)rowSelector andColSel:(const char*)colSelector asCopy:(BOOL)flag;
*/

- (double)determinant;
- (double)minorAt:(int)row:(int)col;
- (double)minorAt:(unsigned int)index;

/* Matrix Operations via Methods */
  // the following methods create new matrices, but do not autorelease them. Is this desired ???jg no, see uses within these methods
- (id)scaleWith:(double)scalar;
- (id)sumWith:aMatrix;
- (id)differenceTo:aMatrix;
- (id)productWith:aMatrix;
- (id)powerOfExponent:(int)exp;
- (id)taylorOfExponent:(int)exp;

- (int)rank;

- (id)adjoint;
- (id)inverse;
- (id)affineDifference;
- (id)quadraticForm;

/* emancipative Matrix Operation Methods */
- XresultClass;
- xResultForMatrix:(id)matrix;
- XscaleWith:(double)scalar;
- XsumWith:aMatrix;
- XdifferenceTo:aMatrix;
- XproductWith:aMatrix;
- XpowerOfExponent:(int)exp;
- XtaylorOfExponent:(int)exp;

- Xadjoint;
- Xinverse;
- XaffineDifference;
- XquadraticForm;


/* surface and deep calculation methods */
- (double)euclideanValue; /* Euclidean length of a MathMatrix class instance */
- (double)stripEuclideanValue; /* Euclidean length of a stripped MathMatrix class instance */
- (double)valueSum;
- (double)stripValueSum;
- (BOOL)isPositive;
- (BOOL)stripIsPositive;
- (BOOL)isZero;
- (BOOL)stripIsZero;

/*
- (double)trace;

- exponentialOfLength:(int)exp asCopy:(BOOL)flag;
- rowBasisAsCopy:(BOOL)flag;
- colBasisAsCopy:(BOOL)flag;
*/

/* Regularity check */
- (BOOL)isRegular;

/* Two criteria for numericity */
- (BOOL)isNumeric;
- (BOOL)hasNumericFormat;

/* The Prﬁt-’-Porter Methods: isWellDressed, dress, undress, strip */
- (BOOL)isWellDressed;
- (id)undress;
- (id)strip;
/* The Emancipated Prﬁt-’-Porter Methods */
- (id)Xundress;
- (id)Xstrip;


/* Ordering protocol methods */
- (int)compareTo:anObject;
- (BOOL)equalTo:anObject;
- (BOOL)largerThan:anObject; 
- (BOOL)smallerThan:anObject; 

/*logically redundant but not as methods */
- (BOOL)smallerEqualThan:anObject;
- (BOOL)largerEqualThan:anObject;
@end

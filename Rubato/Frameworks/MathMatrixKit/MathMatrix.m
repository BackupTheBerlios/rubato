/* MathMatrix.m */

#import "MathMatrix.h"

#import "AdjointMatrix.h"
#import "AffineDifferenceMatrix.h"
#import "InverseMatrix.h"
#import "PowerMatrix.h"
#import "ProductMatrix.h"
#import "ScaleMatrix.h"
#import "StripMatrix.h"
#import "SumMatrix.h"
#import "TaylorMatrix.h"
#import "UndressMatrix.h"

#define max(A,B) ((A)>(B)?(A):(B))

@implementation MathMatrix

+ (BOOL)newRetainScheme;
{
  static BOOL b=YES;
  return b;
}

#define MAX_EMANCIREFCOUNT INIT_REFCOUNT+2

/* standard class methods to be overridden */
+ (void)initialize;
{
    [super initialize];
    if (self == [MathMatrix class]) {
	[MathMatrix setVersion:2];
    }
}

- (NSArray *)attributeKeys;
{
    static NSArray *keys=nil;
    if (!keys)
        keys=[[NSArray alloc] initWithObjects:@"rows",@"columns",@"isTransposed",@"isRegular",@"doubleValue",nil];
    return keys;
}
- (NSArray *)toManyRelationshipKeys;
{
    static NSArray *keys=nil;
    if (!keys)
        keys=[[NSArray alloc] initWithObjects:@"coefficients",nil];
    return keys;
}

/* special class methods */
/* standard object methods to be overridden */
- init;
{
    [super init];
    /* class-specific initialization goes here */
    myRows = 1;
    myCols = 1;
    myValue = 1.0;
    myCoefficients = nil;
    myCoeffClass = [MathMatrix class];
    isTransposed = NO;
    isRegular = YES;
    return self;
}

- initRows:(int)rowCount Cols:(int)colCount andValue:(double)value withCoefficients:(BOOL)cFlag;
{
    [self init];
    myRows = rowCount>0 ? rowCount : myRows;
    myCols = colCount>0 ? colCount : myCols;
    myValue = value;
    if (cFlag) {
	[self convertToRealMatrix];
    }
    return self;
}

- initIdentityMatrixOfWidth:(int)width;
{
    int i;
    [self initRows:width Cols:width andValue:0.0 withCoefficients:YES];
    myValue = 1.0;
    for(i=1; i<=width; i++)
	[[self matrixAt:i:i] setDoubleValue:1.0];
    return self;
}

- initElementaryMatrixWithRows:(int)rowCount Cols:(int)colCount andValue:(double)value at:(int)row:(int)col 
{
    [self initRows:rowCount Cols:colCount andValue:0.0 withCoefficients:YES];
    [[self matrixAt:row:col] setDoubleValue:value];
    myValue = value;
    return self;
}

- (void)dealloc;
{
    /* do NXReference houskeeping */
    [myCoefficients release]; // jg removed freeObjects, so myCoefficients can survive this dealloc
    [super dealloc];
}

- copyWithZone:(NSZone*)zone;
/*" Copy depths is 2: NSCopyObject plus a shallow mutableCopy of the coefficient array. "*/
{
    MathMatrix *myCopy = JGSHALLOWCOPY; // == NSCopyObject(self,0,zone); // shallow copy
    myCopy->myCoefficients = [myCoefficients mutableCopyWithZone:zone]; // jgrelease was:[[myCoefficients jgCopyWithZone:zone]ref]; //jg here should not be called ref (see below)
    myCopy->myValue = myValue;
    return myCopy;
}



- (id)initWithCoder:(NSCoder *)aDecoder
{
    int classVersion;
//    [super initWithCoder:aDecoder];
    
    /* class-specific code goes here */
    classVersion = [aDecoder versionForClassName:NSStringFromClass([MathMatrix class])];

    if (!classVersion) {
	[aDecoder decodeValuesOfObjCTypes:"IIdc", &myRows, &myCols, &myValue, &isTransposed];
	myCoefficients = [[aDecoder decodeObject] retain];
	isRegular = YES;
	myCoeffClass = [MathMatrix class];
    } else {
	[aDecoder decodeValuesOfObjCTypes:"IIdcc#", &myRows, &myCols, &myValue,  &isTransposed, &isRegular, &myCoeffClass];
	myCoefficients = [[aDecoder decodeObject] retain];
    }
    
    if (classVersion < 2 && [myCoefficients count]){
	id coefficients = myCoefficients;
        myCoefficients = [[RefCountList allocWithZone:(NSZone*)[self zone]]initCount:[coefficients count]]; // jgrefcount?
	[myCoefficients appendList:coefficients];
	[coefficients release];
    } else {
      if(![myCoefficients count]) {
          [myCoefficients release];
          myCoefficients = nil;
        }
	/* delete unused coefficient lists */
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
//    [super encodeWithCoder:aCoder];
    /* class-specific archiving code goes here */
    [aCoder encodeValuesOfObjCTypes:"IIdcc#", &myRows, &myCols, &myValue,  &isTransposed, &isRegular, &myCoeffClass];
    [aCoder encodeObject:myCoefficients];
}

- (BOOL)isEqual:anObject
{
    if (anObject!=self) {
	if ([anObject isKindOfClass:[self class]]) {
	    if (([self hasCoefficients]==[anObject hasCoefficients]) && (myValue==[anObject doubleValue])) {
		if ([self hasCoefficients] && (myRows*myCols==[anObject rows]*[anObject columns])) {
		    /* both have coefficients, check all of them */
		    int i;
		    for (i=0; i<myRows*myCols && [[self matrixAt:i] isEqual:[anObject matrixAt:i]]; i++);
		    return (i==myRows*myCols);
		}
		/* both have no coefficients and values are the same */
		return YES;
	    }
	}
	return NO;
    }
    return YES;
}

- (unsigned int)hash;
{
    unsigned int *valPtr;
    int i, c = [myCoefficients count];
    unsigned long long int hashVal = c;
    
    if (c) {
	for (i=0; i<c; i++)
	    hashVal += [[myCoefficients objectAt:i]hash];
    }
    
    valPtr = (unsigned int*)&myValue;
    hashVal += (valPtr[0] + valPtr[1]);
    hashVal = hashVal > UINT_MAX ? hashVal % UINT_MAX : hashVal;
    
    return hashVal;
}


/* special Matrix copying and conversion */
- clone;
{
    return [self cloneFromZone:[self zone]];
}


- cloneFromZone:(NSZone*)zone;
/*" Defined with a call to [self copyWithZone], so that all subclasses get their own version of cloneFromZone.
CopyWithZone is a shallow copy, whereas cloneFromZone is defined recursively "*/
{
    unsigned int index;
    MathMatrix *myCopy = [self copyWithZone:zone]; 
    
    if ([self hasCoefficients]) {
	id coeffCopy = myCopy->myCoefficients;
	[coeffCopy freeObjects];
	for (index=0; index<myCols*myRows; index++) {
          id coeffClone=[[myCoefficients objectAt:index]cloneFromZone:zone];
	    [coeffCopy addObject:coeffClone];
            [coeffClone release];
	}
    }
    return myCopy;
}

- (void)setCoefficients:(NSMutableArray *)coefficients;
{
  [coefficients retain];
  [myCoefficients release];
  myCoefficients=coefficients;
}

- (selfvoid)setToMatrix:aMatrix;
/*" copies the coefficients "*/
{
    [self setToEmptyCopyOfMatrix:aMatrix];
    if ([aMatrix hasCoefficients]) {
	[self setCoefficients:[[aMatrix coefficients] mutableCopyWithZone:[self zone]]]; // jgrefcount
    }
}

- (selfvoid)setToCopyOfMatrix:aMatrix;
/*" clones the coefficients "*/
{
    int i;
    [self setToEmptyCopyOfMatrix:aMatrix];
    if ([aMatrix hasCoefficients]) {
        if (!myCoefficients){// || [myCoefficients capacity]>([aMatrix rows]*[aMatrix columns])) {
	    [self setCoefficients:[[RefCountList allocWithZone:[self zone]]initCount:[aMatrix rows]*[aMatrix columns]]]; // jgrefcount
	}
	for(i = 0; i < myRows*myCols &&
	    [myCoefficients nx_addObject:[[aMatrix matrixAt:i]clone]]; i++);
    }
}

- (selfvoid)setToEmptyCopyOfMatrix:aMatrix;
{
    if ([aMatrix isKindOfClass:[MathMatrix class]]) {
	[myCoefficients freeObjects];
	isTransposed = [aMatrix isTransposed];
	myRows = [aMatrix rows];
	myCols = [aMatrix columns];
	myValue = [aMatrix doubleValue];
    }
}

/* Matrix conversion and maintenance */
- (selfvoid)convertToRealMatrix;
/*" sets all coefficients to newly created objects of myCoeffClass with value myValue "*/
{
    if (![self hasCoefficients]) {
	unsigned int i;
	[self setCoefficients:[[RefCountList allocWithZone:[self zone]]initCount:myCols*myRows]]; // jgrefcount
	for (i=0; i<myCols*myRows;i++) {
            id tmp=[[myCoeffClass alloc]init];
            [tmp setDoubleValue:myValue];
	    [myCoefficients addObject:tmp];
            [tmp release]; // jgrelease
	}
    }
}

- (selfvoid)convertToIdentityMatrixOfWidth:(int)width;
  /*" Makes self the identity Matrix of width width. "*/
{
    int i;
    width = width > 0 ? width : width*-1;
    [self setRows:width]; 
    [self setColumns:width];
    [myCoefficients freeObjects];
/*    if ([myCoefficients capacity]>(width*width)+4) {
	// accept extra capacity of 4 Objects 
	[myCoefficients nxrelease];
	myCoefficients = [[RefCountList allocWithZone:[self zone]]initCount:width*width]; // jgrefcount
    }
*/
    myValue = 0.0;
    [self convertToRealMatrix];
    myValue = 1.0;
    for(i=1; i<=width; i++)
	[[self matrixAt:i:i] setDoubleValue:1.0];
}

- (selfvoid)convertToElementaryMatrixWithValue:(double)value at:(int)row:(int)col;
/*" a Matrix with one nontrivial coefficient "*/
{
    [myCoefficients freeObjects];
  /*
    if ([myCoefficients capacity]>(myRows*myCols)+4) {
	// accept extra capacity of 4 Objects 
	[myCoefficients nxrelease];
	myCoefficients = [[RefCountList allocWithZone:[self zone]]initCount:myRows*myCols]; // jgrefcount
    }
   */
    myValue = 0.0;
    [self convertToRealMatrix];
    myValue = value;
    [[self matrixAt:row:col] setDoubleValue:value];
}


- (BOOL)isEmancipatedWithMaxRetainCount:(unsigned int)maxRetainCount;
{
    unsigned int i;
    if (myCoefficients) {
	for (i=0; i<myRows*myCols && [[myCoefficients objectAt:i]isEmancipatedCoefficient]; i++);
      return (i==myRows*myCols) && ([self retainCount] <= maxRetainCount);
    } else
      return [self retainCount] <= maxRetainCount;
}
- (BOOL)isEmancipatedCoefficient;
{
  return [self isEmancipatedWithMaxRetainCount:EMANCIPATED_COEFFICIENT_MAXRETAINCOUNT];
}
- (BOOL)isEmancipated;
{
  return [self isEmancipatedWithMaxRetainCount:EMANCIPATED_MATRIX_MAXRETAINCOUNT];
}

- (id)emancipate;
{
  id ret=[self emancipateWithMaxRetainCount:EMANCIPATED_MATRIX_MAXRETAINCOUNT];
  return ret;
}
  
- (id)emancipateWithMaxRetainCount:(unsigned int)maxRetainCount;
/*" Returns an object, which is a fully emancipated version of self, that means, having minimal retain count. The returned object is either a modified self or a newly created object, in that case, the user has to take care of the disposal of it."*/
{
  if (![self isEmancipatedWithMaxRetainCount:maxRetainCount]) {
    if ([self retainCount] <= maxRetainCount) { 
	    unsigned int i;
	    for (i=0; i<myRows*myCols ; i++) {
              id objectAtI=[myCoefficients objectAt:i];
              id emancipated = [objectAtI emancipateWithMaxRetainCount:EMANCIPATED_COEFFICIENT_MAXRETAINCOUNT];
              if (emancipated!=objectAtI)
//#ifdef RETAINCOUNTMINUS1
//#warning Compiler option RETAINCOUNTMINUS1 defined.
//                  [[myCoefficients replaceObjectAt:i with:emancipated] release];
//#else
//#warning Compiler option RETAINCOUNTMINUS1 not defined.
                  [myCoefficients replaceObjectAt:i with:emancipated];// jgrelease was:[[myCoefficients replaceObjectAt:i with:emancipated] release];
//#endif
	    }
	} else {
          id returnval;
//#ifdef RETAINCOUNTMINUS1
//#warning Compiler option RETAINCOUNTMINUS1 defined.
//            returnval= [[[self copy]ref] emancipate];
//#else
//#warning Compiler option RETAINCOUNTMINUS1 not defined.
            // warning: copy makes a retainCount of 1. ref makes 1+1 -> infinitive loop
            // hmm, if you look at copy, emancipate should not be necessary any more!
          returnval= [[self copy] emancipateWithMaxRetainCount:maxRetainCount]; // jgrelease was: [[[self copy]ref] emancipate];
//#endif
          if (NEWRETAINSCHEME) [returnval autorelease];
          else ;//[self release]; // safer not to release self!
          return returnval;
	}
    }
    if (NEWRETAINSCHEME)  [[self retain] autorelease]; // makes sure, it will exist. Drawback: next call to emancipate will copy again.
    return self;
}

- (BOOL)isCalculated;
{
    if ([self hasCoefficients]) {
	unsigned int i;
	for (i=0; i<myRows*myCols && [[myCoefficients objectAt:i] isCalculated]; i++)
	    ;
	return i==myRows*myCols;
    }
    return YES;
}

- (selfvoid)calculate;
/*" to be overridden "*/
{
}


- (selfvoid)undo;
  /*" to be overridden "*/
{
}

/* general Matrix behaviour */
/* Acces to matrix coefficient values */
- (selfvoid)setCoeffClass:classId;
{
    if (![myCoefficients count])
    /* can't check a classObject for isKindOf: */
	myCoeffClass = classId;
}

- coeffClass;
{
    return myCoeffClass;
}


- (void)setDoubleValue:(double)aDouble;
{
    myValue = aDouble;
}

- (void)setDoubleValue:(double)value at:(int)row:(int)col;
{
    if([self hasCoefficients])
	[[self matrixAt:row:col] setDoubleValue:value];
    else
	[self setDoubleValue:value];
}

- (void)setDoubleValue:(double)value at:(unsigned int)index;
{
    if([self hasCoefficients])
	[[self matrixAt:index] setDoubleValue:value];
    else
	[self setDoubleValue:value];
}

- (double) doubleValue;
{
    return myValue;
}

- (void)takeDoubleValueFrom:(id)sender;
{
    if ([sender respondsToSelector:@selector(doubleValue)])
	myValue = [sender doubleValue];
}

- (double) doubleValueAt:(int)row :(int)col;
{
    id matrix = [self matrixAt:row :col];
    return matrix ? [matrix doubleValue] : 0.0;
}

- (NSNumber *) numberAt:(int)row :(int)col;
{
  return [NSNumber numberWithDouble:[self doubleValueAt:row :col]];
}

- (double) doubleValueAt:(unsigned int)index;
{
    id matrix = [self matrixAt:index];
    return matrix ? [matrix doubleValue] : 0.0;
}

- (double *)doubleValuePtr:(int *)length;
  /*" creates and returns a c-array of double. returns its length in (int *)lenght. "*/
{
    int i, c;
    double *pointer;
    c = [myCoefficients count];
    pointer = calloc(c, sizeof(double));
    for(i=0; i<c; i++)
	pointer[i] = [self doubleValueAt:i];

    *length = c;
    return pointer;
}

- (unsigned int)rows;
{
    if (isTransposed)
	return myCols;
    else
	return myRows;
}

- (void)setRows:(unsigned int)newRows;
{
    return [self modifyRowsTo:newRows];
}


- (unsigned int)columns;
{
    if (isTransposed)
	return myRows;
    else
	return myCols;
}

- (selfvoid)setColumns:(unsigned int)newCols;
{
    return [self modifyColsTo:newCols];
}


- (NSMutableArray *)coefficients;
{
    return myCoefficients;
}

- (BOOL) hasCoefficients;
{
    return [myCoefficients count]==myRows*myCols;
}

- (unsigned int)indexAt:(int)row :(int)col; 
{
    row--;
    col--;
    if (row>=0 && row<[self rows] && col>=0 && col<[self columns]) {
	if (isTransposed)
	    return col*myCols + row;
	else
	    return row*myCols + col;
    } else
	return NSNotFound;
}

- (int)rowOfIndex:(unsigned int)index;
{
    if (index < myRows*myCols) {
	if (isTransposed) 
	    return (index % myCols)+1;
	else
	    return (index / myCols)+1;
    } else
	return NSNotFound;
}

- (int)colOfIndex:(unsigned int)index;
{
    if (index < myRows*myCols)
	if (isTransposed) 
	    return (index / myCols)+1;
	else
	    return (index % myCols)+1;
    else
	return NSNotFound;
}

- (unsigned int)index:(unsigned int)index;
{
    if (index < myRows*myCols)
	if (isTransposed) 
	    return [self transIndex:index];
	else
	    return index;
    else
	return NSNotFound;
}

- (unsigned int)transIndex:(unsigned int)index;
{
    if (index < myRows*myCols)
	if (isTransposed) 
	    return (index % myRows)*myCols + index / myRows;
	else
	    return (index % myCols)*myRows + index / myCols;
    else
	return NSNotFound;
}


- (selfvoid)getRow:(int *)row andCol:(int *)col ofIndex:(unsigned int)index;
{
    *row = [self rowOfIndex:index];
    *col = [self colOfIndex:index];
}

- (void)getNumberOfRows:(int *)rowCount columns:(int *)colCount;
{
    *rowCount = (int)[self rows];
    *colCount = (int)[self columns];
}

- matrixAt:(int)row :(int)col;
{
    return [myCoefficients objectAt:[self indexAt:row:col]];
}

- matrixAt:(unsigned int)index;
{
    return [myCoefficients objectAt:[self index:index]];
}

- (selfvoid)getRow:(int *)row andCol:(int *)col ofMatrix:aMatrix;
{
    unsigned int index;
    index = [myCoefficients indexOfObject:aMatrix];
    if (index == NSNotFound) {
	*row = NSNotFound;
	*col = NSNotFound;
    } else {
	*row = [self rowOfIndex:index];
	*col = [self colOfIndex:index];
    }
}

- (BOOL)putMatrix:newMatrix at:(int)row :(int)col;
{
    if (![newMatrix isKindOfClass:myCoeffClass]) 
	return NO;
    [self convertToRealMatrix];
    [myCoefficients replaceObjectAt:[self indexAt:row:col] with:newMatrix];
    return YES;
}

- (BOOL)putMatrix:newMatrix at:(unsigned int)index;
{
    if (![newMatrix isKindOfClass:myCoeffClass]) 
	return NO;
    [self convertToRealMatrix];
    [myCoefficients replaceObjectAt:[self index:index] with:newMatrix];
    return YES;
}

- (BOOL)replaceMatrixAt:(int)row :(int)col with:newMatrix;
{
    if (![newMatrix isKindOfClass:myCoeffClass]) 
	return NO;
    [self convertToRealMatrix];
    [myCoefficients replaceObjectAt:[self indexAt:row:col] with:newMatrix];//jgrelease? without release!
    return YES;
}

- (BOOL)replaceMatrixAt:(unsigned int)index with:newMatrix;
{
    if (![newMatrix isKindOfClass:myCoeffClass]) 
	return NO;
    [self convertToRealMatrix];
    [myCoefficients replaceObjectAt:[self index:index] with:newMatrix];//jgrelease? without release!
    return YES;
}



- (void)addRow;
{
    [self insertRow:[self rows]+1];
}

- (void)insertRow:(int)row;	/* the new row comes exactly at row-index row, the rest is shifted */ 
{
    id aRow = [[myCoeffClass alloc]initRows:1 Cols:[self columns] andValue:1.0 withCoefficients:YES];
    [self insertRow:aRow at:row];
    [aRow release];
}

- (BOOL)insertRow:aRow at:(int)row;
{
    row--;
    if (0<=row && row<=[self rows] && [aRow hasCoefficients] && [aRow columns]==[self columns]) {
	unsigned int i, cols = [self columns];
	/* whichever they are, the count of cols remains constant throughout this method.
	 * change the count of myRows, myCols resp. now. In case of a normal, i.e. untransposed, 
	 * matrix, it doesn't matter. In the case of a transposed matrix, the changed number of
	 * columns is needed for proper index calculation!
	 */
	isTransposed ? myCols++ : myRows++;
	if (myCoefficients) {
	    for (i=0; i<cols; i++) 
		[myCoefficients insertObject:[aRow matrixAt:1:i+1] at: [self index:(row*cols)+i]];
	}
	return YES;
    }
    else
	return NO;
}

- (BOOL)removeRowAt:(int)row;
{
    row--;
    if (0<=row && row<[self rows] && [self rows]>1) {
	int i;
	if ([self hasCoefficients]) {
	    for (i=[self columns]-1; i>=0; i--) {
		[myCoefficients removeObjectAt:[self index:(row*[self columns])+i]];
	    }
	}
	isTransposed ? myCols-- : myRows--;
	return YES;
    }
    else
	return NO;
}

- (selfvoid)modifyRowsTo:(int)row;
{
    int i;
    
    if ([self hasCoefficients]) {
	if(row >= [self rows])
	    for(i = row-[self rows]; i>0; i--)
		[self addRow];
	else if(row)
	    for(i = [self rows]-row; i>0; i--)
		[self removeRowAt:[self rows]];
    } else
	isTransposed ? (myCols=row) : (myRows=row);
}

- (selfvoid)transpose;
{
    isTransposed = !isTransposed;
}
	

- (BOOL) isTransposed;
{
    return isTransposed;
}


- (void)addColumn;
{
    [self insertColumn:[self columns]+1];
}

- (void)insertColumn:(int)col;
{
    [self transpose];
    [self insertRow:col];
    [self transpose];
}

- (selfvoid)insertCol:aColumn at:(int)col;
{
    [self transpose];
    [aColumn transpose];
    [self insertRow:aColumn at:col];
    [aColumn transpose];
    return [self transpose];
}

- (selfvoid)removeColAt:(int)col;
{
    [self transpose];
    [self removeRowAt:col];
    return [self transpose];
}

- (selfvoid)modifyColsTo:(int)col;
{
    [self transpose];
    [self modifyRowsTo:col];
    return [self transpose];
}

- (const char*)rowSelectorFrom:(int)low to:(int)high;
/*" For printable representation: the row names as a c-string"*/
{
    if(1<=low && high-low>=0) {
	int i;
	char *rS =malloc(high);
	for(i = 0; i<high; i++)
	    rS[i] = (i+1>=low && i+1<=high && i+1<=[self rows])+'0';
	rS[high] = '\0';
	return rS;
    } else
	return (const char*)nil;	
}

- (const char*)colSelectorFrom:(int)low to:(int)high;
{
    if(1<=low && high-low>=0) {
	int i;
	char *cS =malloc(high);
	for(i = 0; i<high; i++)
	    cS[i] = (i+1>=low && i+1<=high && i+1<=[self columns])+'0';
	cS[high] = '\0';
	return cS;
    } else
	return (const char*)nil;	
}

- subMatrixOfRowSel:(const char*)rowSelector andColSel:(const char*)colSelector asCopy:(BOOL)flag;
{
    int row, col, rLen = 0, cLen = 0;
    id subMatrix = nil;
    if (rowSelector && colSelector) {
	rLen = strlen(rowSelector);
	cLen = strlen(colSelector);

	if (flag)
	    subMatrix = [self clone];
	else
	    subMatrix = [self copy];
	
	for (col=[subMatrix columns]; col>0; col--){
	    if ((cLen < col) || colSelector[col-1]=='0')
		[subMatrix removeColAt:col];
	}
	for (row=[subMatrix rows]; row>0; row--){
	    if ((rLen < row) || rowSelector[row-1]=='0')
		[subMatrix removeRowAt:row];
	}

    }
    if (NEWRETAINSCHEME) [subMatrix autorelease];
    return subMatrix;
}

- subMatrixFrom:(int)fromRow:(int)fromCol to:(int)toRow:(int)toCol asCopy:(BOOL)flag;
/*" if flag is YES, clone is used "*/
{
    id subMatrix = nil;
    int row;
    if (fromRow>0 && myRows>=toRow && fromCol>0 && myCols>=toCol && toRow-fromRow>=0 && toCol-fromCol>=0) {
	if (flag)
	    subMatrix = [self clone];
	else
	    subMatrix = [self copy];
	
	/* first remove the rows */
	for (row=myRows; row>toRow; row--)
	    [subMatrix removeRowAt:row];
	for (row=fromRow-1; row>0; row--)
	    [subMatrix removeRowAt:row];
	    
	/* now transpose and remove the colmns */
	[subMatrix transpose];
	
	for (row=myCols; row>toCol; row--)
	    [subMatrix removeRowAt:row];
	for (row=fromCol-1; row>0; row--)
	    [subMatrix removeRowAt:row];
	    
	[subMatrix transpose];
	
	
    }
    if (NEWRETAINSCHEME)
      [subMatrix autorelease];
    return subMatrix;
}

- rowMatrixAt:(int)fromRow asCopy:(BOOL)flag;
{
    return [self subMatrixFrom:fromRow:1 to:fromRow :myCols asCopy:(BOOL)flag];
}


- colMatrixAt:(int)fromCol asCopy:(BOOL)flag;
{
    return [self subMatrixFrom:1:fromCol to:myRows :fromCol asCopy:(BOOL)flag];
}


- minorMatrixAt:(int)row:(int)col asCopy:(BOOL)flag; /* Attention: is a transposed construction! */
{
  if (1<=row && 1<=col && row<=[self rows] && col<=[self columns] && myRows*myCols>1) {
    id copy;
    if (flag)
        copy=[self clone];
    else
        copy=[self copy];
    [copy removeRowAt:col];
    [copy removeColAt:row];
    if (NEWRETAINSCHEME) [copy autorelease];
    return copy;
  } else
	return NullMatrix;
}

- minorMatrixAt:(unsigned int)index asCopy:(BOOL)flag;
{
    return [self minorMatrixAt:[self rowOfIndex:index]:[self colOfIndex:index] asCopy:flag];
}


- (double) determinant;
{
    int i;
    double det = 0.0;
    if ([self isCalculated]) {
	id strippedMatrix = [self strip]; // jgrefcount?
	//[self ref];
	/* increment our myRefCount for savety. If myRefCount == 0 we 
	 * would be freed, when the stripedMatrix is freed.
	 */
	
	if([strippedMatrix rows] - [strippedMatrix columns])
	    det = 0.0;
    
	else if(!myCoefficients && myRows==1)
	    det = myValue;
    
	else if(!myCoefficients)
	    det = 0.0;
    
	else if([self isNumeric]) {/*automatically not a number now!*/
	    for(i = 1, det = 0; i <= myRows; i++) {
		det += [self minorAt:1:i] *[[self matrixAt:i:1] doubleValue];
	    }
	}
	else if([strippedMatrix isNumeric])
	    det = [strippedMatrix determinant];
    
	else
	    det = 0.0;
        if (!NEWRETAINSCHEME)	[strippedMatrix release];
	//[self deRef];/* decrement myRefCount. Parallel to increment above. */
    }
    return det;
}

- (double)minorAt:(int)row:(int)col;
{
    double minorDet = 1.0;
    id minorMatrix;
    minorMatrix = [self minorMatrixAt:row:col asCopy:NO]; // jg: removed retain
    if (minorMatrix)
	minorDet = [minorMatrix determinant]*pow(-1, row+col);
    if (!NEWRETAINSCHEME)    [minorMatrix release];
    return minorDet;
}

- (double)minorAt:(unsigned int)index;
{
    return [self minorAt:[self rowOfIndex:index]:[self colOfIndex:index]];
}

- (int)rank;
{
    int i, r, rk = -1;
    if ([self isCalculated]) {
	id aMatrix = nil;
	//[self ref];
	if([self isNumeric]){
	    if([self rows]>[self columns]){
		for(i = 1; i <= [self rows]; i++) {
		    aMatrix = [self copy]; // jg was: [[self copy]ref];
		    if ([aMatrix removeRowAt:i]) {
			r = [aMatrix rank];
		    } else
			r = 0; /* is that correct ? */
		    rk = max(rk,r);
		    [aMatrix release];  // jg new version
		}
	    } else if([self rows]<[self columns]) {
                [self transpose];
		rk = [self rank];
		[self transpose];
    
	    } else if([self determinant])
		rk = [self rows];
		
	    else{
		for(i = 1; i <= [self rows]; i++) {
		    aMatrix = [self copy]; // jg was: [[self copy]ref];
		    if ([aMatrix removeRowAt:i]) {
			r = [aMatrix rank];
		    } else
			r = 0; /* is that correct ? */
		    rk = max(rk,r);
                    [aMatrix release];  // jg new version
		}
	    }
	}
	else {
	    aMatrix = [self strip]; // jg was: [[self strip] ref]
	    if([aMatrix isNumeric]) 
		rk = [aMatrix rank];
            if (!NEWRETAINSCHEME) [aMatrix release];      // jg new version. In the old code at this place nxrelease should have been standing.
	}
	//[self deRef];
    }
    return rk;
}

/* Matrix Operations via Methods */

- scaleWith:(double)scalar;
{
  id ret=[[ScaleMatrix allocWithZone:[self zone]]initWithOperands:self:nil];
  [ret setScalar:scalar];
  [ret calculate];
  if (NEWRETAINSCHEME) [ret autorelease];
  return ret;
}

- sumWith:aMatrix;
{
  id ret= [[SumMatrix allocWithZone:[self zone]]initWithOperands:self:aMatrix];
  [ret calculate];
  if (NEWRETAINSCHEME) [ret autorelease];
  return ret;
}

- differenceTo:aMatrix;
{ id scaleMatrix=[aMatrix scaleWith: -1];
  id ret=[self sumWith: scaleMatrix];
  if (!NEWRETAINSCHEME)  [scaleMatrix release];
  return ret;
}

- productWith:aMatrix;
{
  id ret=  [[ProductMatrix allocWithZone:[self zone]]initWithOperands:self:aMatrix];
  [ret calculate];
  if (NEWRETAINSCHEME) [ret autorelease];
  return ret;
}

- powerOfExponent:(int)exp;
{

  id ret=  [[PowerMatrix allocWithZone:[self zone]]initWithOperands:self:nil];
  [ret setExponent:exp];
  [ret calculate];
  if (NEWRETAINSCHEME) [ret autorelease];
  return ret;
}


- taylorOfExponent:(int)exp;
{

  id ret=  [[TaylorMatrix allocWithZone:[self zone]]initWithOperands:self:nil];
  [ret setExponent:exp];
  [ret calculate];
  if (NEWRETAINSCHEME) [ret autorelease];
  return ret;
}


- adjoint;
{
  id ret= [[AdjointMatrix allocWithZone:[self zone]]initWithOperand:self];
  [ret calculate];
  if (NEWRETAINSCHEME) [ret autorelease];
  return ret;
}

- inverse;
{
  id ret= [[InverseMatrix allocWithZone:[self zone]]initWithOperand:self];
  [ret calculate];
  if (NEWRETAINSCHEME) [ret autorelease];
  return ret;
}

- affineDifference;
{
  id ret= [[AffineDifferenceMatrix allocWithZone:[self zone]]initWithOperand:self];
  [ret calculate];
  if (NEWRETAINSCHEME) [ret autorelease];
  return ret;
}

- quadraticForm;
{
    //if(isRegular && [self isNumeric])
  id cp,strip1,strip2,ret;
  cp=[self copy];
  strip1=[cp strip];
  [cp release];
  strip2=[self strip];
  [strip1 transpose];
  ret= [strip1 productWith: [self strip]];
  if (NEWRETAINSCHEME)
    ; // [ret autorelease];
  else {
    [strip1 release];
    [strip2 release];
  }
  return ret;
}

/* emancipative Matrix Operation Methods */
- XresultClass;
{
    return [MathMatrix class];
}

- xResultForMatrix:(id)matrix;
/*" This method is the replacement of all the X... methods below. Just call 
    [self xResultForMatrix:[self <createNewMatrix1Here>]].
    It creates a new Object of class XresultClass, sets the values to an emancipated version of matrix1,
    returns it and releases matrix1. The user is responsible to release the returned object.
    The methods below are not removed, because they are partially overridden in MatrixEvent.m.
"*/
{
  id new = nil, result = nil;

  result = [matrix emancipate];
  if ([result isCalculated]) {
      new = [[[self XresultClass] alloc]init];
      [new setToEmptyCopyOfMatrix:self];
      [new setToMatrix:result];
  }
  if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
  return new;
}


- XscaleWith:(double)scalar;
{
    id new = nil, result = nil;

    //[self ref]; // Just in case...
    result = [[self scaleWith:scalar]emancipate];
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToEmptyCopyOfMatrix:self];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];

    return new;
}

- XsumWith:aMatrix;
{
    id new = nil, result = nil;

    //[self ref]; // Just in case...
    [aMatrix ref]; // Just in case...
    result = [[self sumWith:aMatrix]emancipate];
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToEmptyCopyOfMatrix:self];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];
    [aMatrix deRef];

    return new;
}

- XdifferenceTo:aMatrix;
{
    id new = nil, result = nil;

    //[self ref]; // Just in case...
    [aMatrix ref]; // Just in case...
    result = [[self differenceTo:aMatrix]emancipate];
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToEmptyCopyOfMatrix:self];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];
    [aMatrix deRef];

    return new;
}

- XproductWith:aMatrix;
{
    id new = nil, result = nil;

    //[self ref]; // Just in case...
    [aMatrix ref]; // Just in case...
    result = [[self productWith:aMatrix]emancipate];
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToEmptyCopyOfMatrix:self];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];
    [aMatrix deRef];

    return new;
}

- XpowerOfExponent:(int)exp;
{
    id new = nil, result = nil;

    //[self ref]; // Just in case...
    result = [[self powerOfExponent:exp]emancipate];
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToEmptyCopyOfMatrix:self];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];

    return new;
}

- XtaylorOfExponent:(int)exp;
{
    id new = nil, result = nil;

    //[self ref]; // Just in case...
    result = [[self taylorOfExponent:exp]emancipate];
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToEmptyCopyOfMatrix:self];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];

    return new;
}


- Xadjoint;
{
    id new = nil, result = nil;

    //[self ref]; // Just in case...
    result = [[self adjoint]emancipate];
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToEmptyCopyOfMatrix:self];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];

    return new;
}

- Xinverse;
{
    id new = nil, result = nil;

    //[self ref]; // Just in case...
    result = [[self inverse]emancipate];
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToEmptyCopyOfMatrix:self];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];

    return new;
}

- XaffineDifference;
{
    id new = nil, result = nil;

    //[self ref]; // Just in case...
    result = [[self affineDifference]emancipate];
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToEmptyCopyOfMatrix:self];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];

    return new;
}

- XquadraticForm;
{
    id new = nil, result = nil;

    //[self ref]; // Just in case...
    result = [[self quadraticForm]emancipate];
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToEmptyCopyOfMatrix:self];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];

    return new;
}


- (double)euclideanValue; /* Euclidean length of a MathMatrix class instance */
{
    int i;
    double eucl = 0;
    if(myCoefficients){
	for(i=0; i<myRows*myCols;i++)
	    eucl += [self doubleValueAt:i]*[self doubleValueAt:i];
    }
    else
	eucl = [self doubleValue]*[self doubleValue];

    return eucl;
}


- (double)stripEuclideanValue; /* Euclidean length of a stripped MathMatrix class instance */
{
    int i;
    double eucl = 0;
    if(myCoefficients){
	for(i=0; i<myRows*myCols;i++)
	    eucl += [[self matrixAt:i]stripEuclideanValue]*[[self matrixAt:i]stripEuclideanValue];
    }
    else
	eucl = [self doubleValue]*[self doubleValue];

    return eucl;
}


- (double)valueSum;
{
    int i;
    double valsum = 0.0;
    
    if(myCoefficients){
	for(i = 0; i<myRows*myCols; i++)
	    valsum += [self doubleValueAt:i];
	return valsum;
    }
    return myValue;
}

- (double)stripValueSum;
{
    int i;
    double valsum = 0.0;
    
    if(myCoefficients){
	for(i = 0; i<myRows*myCols; i++)
	    valsum += [[self matrixAt:i]stripValueSum];
	return valsum;
    }
    return myValue;
}

- (BOOL)isPositive;
{
    int i;
    if(myCoefficients){
	for(i=0;i<myRows*myCols && [self doubleValueAt:i]>=0; i++);
    	return i == myRows*myCols;
    }
    return myValue>=0;
}

- (BOOL)stripIsPositive;
{
    int i;
    if(myCoefficients){
	for(i=0;i<myRows*myCols && [[self matrixAt:i]stripIsPositive]; i++);
    	return i == myRows*myCols;
    }
    return myValue>=0;
}

- (BOOL)isZero;
{
    int i;
    for(i=0; i<myRows*myCols && ![self doubleValueAt:i]; i++);
    return i==myRows*myCols;
}
    
- (BOOL)stripIsZero;
{
    int i;
    for(i=0; i<myRows*myCols && [[self matrixAt:i]stripIsZero]; i++);
    return i==myRows*myCols;
}
    
/* Regularity check */
- (BOOL)isRegular;
{
    return isRegular;
}

/* Check methods for numericity */

- (BOOL)isNumeric;
{
    int i;
    if([self hasCoefficients]) {
	for(i = 0; (i < myRows*myCols) &&
		    [[myCoefficients objectAt:i] rows] == 1 && 
		    [[myCoefficients objectAt:i] columns] == 1 && 
		    ![[myCoefficients objectAt:i] hasCoefficients]; i++); 
	    ;
	return  i == myRows*myCols;
    
    } else if(myRows ==1 && myCols == 1)
	return YES; /*numbers are numeric*/
    
    else
	return NO; /*constant non-numbers are not numeric*/
} 

- (BOOL)hasNumericFormat;
{
    int i;
    if([self hasCoefficients]) {
	for(i = 0; (i < myRows*myCols) &&
		    [[myCoefficients objectAt:i] rows] == 1 && 
		    [[myCoefficients objectAt:i] columns] == 1 ; i++); 
	    ;
	return  i == myRows*myCols;
    } else if(myRows ==1 && myCols == 1)
	return YES; /*numbers are numeric*/
    
    else
	return NO; /*constant non-numbers are not numeric*/
} 


/* The PrÞt-Õ-Porter Methods: isWellDressed, dress, undress, strip */
// jg: Guerino said, this possibly is not correct!
- (BOOL)isWellDressed;
{
    /* This method tests all the coefficients rows and columns for compatibility.
     * If any of the coeffs doesn't fit, the test is stopped and NO returned.
     */
    int index, cols = [self columns];
    if ([self hasCoefficients]) {
	for (index=1; 
		(index < myRows*myCols)
		&&
		([[myCoefficients objectAt:[self index:index]]columns]==
		    [[myCoefficients objectAt:[self index:cols * (index/cols)]]columns])
		&&
		([[myCoefficients objectAt:[self index:index]]rows] ==
		    [[myCoefficients objectAt:[self index:index%cols]]rows]); 
	    index++);
	if (index < myRows*myCols)
	    return NO;
	
    }
    return YES;
}

- undress;
{
  id ret=[[UndressMatrix allocWithZone:[self zone]]initWithOperand:self];
  [ret calculate];
  if (NEWRETAINSCHEME) [ret autorelease];
  return ret;
}

- strip;
{
  id ret=[[StripMatrix allocWithZone:[self zone]]initWithOperand:self];
  [ret calculate];
  if (NEWRETAINSCHEME) [ret autorelease];
  return ret;
}

/* The Emancipated PrÞt-Õ-Porter Methods */
- Xundress;
{
    id new = nil, result = nil;

    //[self ref]; // Just in case...
    result = [[self undress]emancipate];
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToEmptyCopyOfMatrix:self];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];

    return new;
}

- Xstrip;
{
    id new = nil, result = nil;

    //[self ref]; // Just in case...
    result = [[self strip]emancipate];
    if ([result isCalculated]) {
	new = [[[self XresultClass] alloc]init];
	[new setToEmptyCopyOfMatrix:self];
	[new setToMatrix:result];
    }
    if (!NEWRETAINSCHEME) [result release]; else [new autorelease];
    //[self deRef];

    return new;
}


/* Implementation of Ordering protocol */
- (int)compareTo:anObject;
{
    if ([self equalTo:anObject])
	return 0;
    else if ([self largerThan:anObject])
	return 1;
    else
	return -1;
}


- (BOOL)equalTo:anObject;
{
    return [self isEqual:anObject];
}


- (BOOL)largerThan:anObject; 
{
    if ([anObject isKindOfClass:[self class]]) {
	if (myCoefficients && [anObject hasCoefficients]) {
	    if (myRows*myCols==[anObject rows]*[anObject columns]) {
		int i;
		for (i=0; i<myRows*myCols && [[self matrixAt:i] largerThan:[anObject matrixAt:i]]; i++);
		return i==myRows*myCols;
	    }
	}
	else if (!myCoefficients && ![anObject hasCoefficients]) 
	    return myValue>[anObject doubleValue];
    }
   return [NSStringFromClass([self class]) compare:NSStringFromClass([anObject class])]>0;
}


- (BOOL)smallerThan:anObject; 
{
    if ([anObject isKindOfClass:[self class]]) {
	if (myCoefficients && [anObject hasCoefficients]) {
	    if (myRows*myCols==[anObject rows]*[anObject columns]) {
		int i;
		for (i=0; i<myRows*myCols && [[self matrixAt:i] smallerThan:[anObject matrixAt:i]]; i++);
		return i==myRows*myCols;
	    }
	}
	else if (!myCoefficients && ![anObject hasCoefficients]) 
	    return myValue<[anObject doubleValue];
    }
return [NSStringFromClass([self class]) compare:NSStringFromClass([anObject class])]<0;
}


- (BOOL)smallerEqualThan:anObject;
{
    if ([anObject isKindOfClass:[self class]]) {
	if (myCoefficients && [anObject hasCoefficients]) {
	    if (myRows*myCols==[anObject rows]*[anObject columns]) {
		int i;
		for (i=0; i<myRows*myCols && [[self matrixAt:i] smallerEqualThan:[anObject matrixAt:i]]; i++);
		return i==myRows*myCols;
	    }
	}
	else if (!myCoefficients && ![anObject hasCoefficients]) 
	    return myValue<=[anObject doubleValue];
    }
    return self <= anObject;
}


- (BOOL)largerEqualThan:anObject;
{
    if ([anObject isKindOfClass:[self class]]) {
	if (myCoefficients && [anObject hasCoefficients]) {
	    if (myRows==[anObject rows] && myCols==[anObject columns]) {
		int i;
		for (i=0; i<myRows*myCols && [[self matrixAt:i] largerEqualThan:[anObject matrixAt:i]]; i++);
		return i==myRows*myCols;
	    }
	}
	else if (!myCoefficients && ![anObject hasCoefficients]) 
	    return myValue>=[anObject doubleValue];
    }
    return self >= anObject;
}


@end

Files in the main directory do not depend on those in the AppKit and Weight subproject and might be linked only against Foundation

Matix identities:
Two matrices are called independent, if they do not share any modifyable object, e.g. a Matrix as a coefficient. This can be archieved by cloning an object (creating a new one) or emancipating it (converting it to an object that doesnt share).
Two matrices might share the same coefficients, but one may be the transposed Matrix. This can be archieved by copying a Matrix shallow by -copy. In this case, you may not modify the coefficients, since this would affect the other copy.
Methods that effect the instances of myCoefficients and should only be used in contexts, where it is clear that you do not effect foreign objects:
emancipate, putMatrix und replaceMatrix, insertRow, removeRow,insertCol,removecol, modifyRowsTo
caution: used in doUndress, doStrip, doAffineDifference on self!
shiftBy

braucht man die emancipate-Funktionalitaeten wirklich, oder reicht es, wenn man clone effizient macht, d.h. myCoefficients isa NSArray und copy=retain und clone?

You will not find autorelease with Matrix. emancipate relies on this. So the user is responsible for releasing Matrices she got with the methods below (special case emancipate*.
irregular transformation of self
- (id)emancipateWithMaxRetainCount:(unsigned int)maxRetainCount;
- (id)emancipate;

irregular creation of objects (not autoreleased):

- (id)cloneFromZone:(NSZone*)zone; // o.k.

// the following methods create new matrices, but do not autorelease them. Is this desired ???jg
// we might want to add "Matrix" to the methods in block 2-4 (->adjointMatrix) etc.
- (id)subMatrixOfRowSel:(const char*)rowSelector andColSel:(const char*)colSelector asCopy:(BOOL)flag;
- (id)subMatrixFrom:(int)fromRow:(int)fromCol to:(int)toRow:(int)toCol asCopy:(BOOL)flag;
- (id)rowMatrixAt:(int)fromRow asCopy:(BOOL)flag;
- (id)colMatrixAt:(int)fromCol asCopy:(BOOL)flag;
- (id)minorMatrixAt:(int)row:(int)col asCopy:(BOOL)flag; /* Attention: is a transposed construction! */
- (id)minorMatrixAt:(unsigned int)index asCopy:(BOOL)flag;

- (id)scaleWith:(double)scalar;
- (id)sumWith:aMatrix;
- (id)differenceTo:aMatrix;
- (id)productWith:aMatrix;
- (id)powerOfExponent:(int)exp;
- (id)taylorOfExponent:(int)exp;

- (id)adjoint;
- (id)inverse;
- (id)affineDifference;
- (id)quadraticForm;

- (id)undress;
- (id)strip;


MatrixEvent create new Objects:
- projectTo:(spaceIndex)aSpace;
- injectInto:(spaceIndex)aSpace;
- parajectTo:(spaceIndex)aSpace;
- alterateAt:(int)basisIndex :(int)pianolaIndex;
- alterate;


/* JGLogUnarchiver.h created by jg on Fri 14-May-1999 */

#import <Foundation/Foundation.h>
#import "JGAddressDictionary.h"

@interface JGLogUnarchiver : NSUnarchiver
{
  JGAddressDictionary *addresses;
  NSMutableDictionary *classes;  // for the DTD.
  NSMutableString *xmlchildren;  // go empty into decodeObject, leave filled.
  NSMutableString *subelements;
  BOOL printinfo;
  BOOL makexml;
  int indent;
  int maxElementLength; // Maximal length of element-definition in characters.
  int maxxmlchildrenlength; // Maximal length of elements
  BOOL includeOtherUnArchiver; // see initForReadingWithData:parent:
  JGLogUnarchiver *parent;
}
+ (id)unarchiveObjectWithData:(NSData *)idata parent:(NSCoder *)parent;
- (id)initForReadingWithData:(NSData *)idata parent:(JGLogUnarchiver *)parent;
- (id)init;
- (id)initForReadingWithData:(NSData *)idata;
- (void) initWithParent:(JGLogUnarchiver *)aParent; // dont call directly but only from other inits.

- (id)decodeObject;
//- (id)handleObjectWith:(int)kind objCType:(const char*)valueType at:(void *)thedata;
- (void)decodeValueOfObjCType:(const char *)valueType at:(void *)data;
- (void)decodeSimpleValueOfObjCType:(const char *)valueType at:(void *)thedata; // no decoding, just XML-Output sideeffects
- (void)decodeValuesOfObjCTypes:(const char *)types, ...;
- (void)decodeArrayOfObjCType:(const char *)itemType count:(unsigned int)count at:(void *)address;

- (void)setMakexml:(BOOL)val; // call before Unarchiving
- (void)setPrintinfo:(BOOL)val; // call before Unarchiving
- (NSMutableString *)getXMLEncoding; // call after Unarchiving

// for internal use:
- (void)writeXML;
- (void)addElement:(NSString *)anElement withSubElements:(NSString *)sub;
- (NSMutableString *)structureForElement:(NSString *)element invalidAlternatives:(BOOL)yn;
- (NSMutableString *)elements;
- (NSMutableString *)internalDTD;

@end

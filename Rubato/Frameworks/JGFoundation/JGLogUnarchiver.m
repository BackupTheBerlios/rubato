/* JGLogUnarchiver.m created by jg on Fri 14-May-1999 */

#import "JGLogUnarchiver.h"
int writtenArchiverNr;  // is connected to /tmp/JGLogUnarchiver/archivernr.xml

typedef struct _previousInfo {
  NSMutableString *olderBrothers;
  NSMutableString *prevElements;
} previousInfo;

void space(int n)
{
  int i;
  for (i=0;i<n;i++) printf("   ");
}

/* classes:
  key: encoded Classes;
  value: NSMutableDictionary
         key: aClassSequence as String "X,Y,Z"
         value:@""
  Reason: all valid sequences are collected, but duplicates removed.
*/

@implementation JGLogUnarchiver
- init;
{
  [super init];
  [self initWithParent:nil];
  return self;
}

- (void) initWithParent:(JGLogUnarchiver *)aParent;
{
  parent=aParent;
  classes=[[NSMutableDictionary alloc] init];
  xmlchildren=[[NSMutableString alloc]init];
  subelements=[[NSMutableString alloc]init];

  if (parent) {
    addresses=parent->addresses; [addresses retain];
    printinfo=parent->printinfo;
    makexml=parent->makexml;
    includeOtherUnArchiver=parent->includeOtherUnArchiver;
    indent=parent->indent; // this behaviour could also be simulated while inserting in parent.
    maxElementLength=parent->maxElementLength;
    maxxmlchildrenlength=parent->maxxmlchildrenlength;
  } else {
    addresses=[[JGAddressDictionary alloc] init];
#ifdef DEBUG
    printinfo=NO;
    makexml=YES;
    includeOtherUnArchiver=YES;
#else
    printinfo=NO;
    makexml=NO;
    includeOtherUnArchiver=NO;
#endif
    indent=1;
    maxElementLength=100;
    maxxmlchildrenlength=10000;
  }
}

- (id)initForReadingWithData:(NSData *)idata;
{
  [super initForReadingWithData:idata];
  [self initWithParent:nil];
  return self;
}

// share anything with parent, so parent is able to include Children of new Unarchiver
- (id)initForReadingWithData:(NSData *)idata parent:(JGLogUnarchiver *)aParent;
{
  [super initForReadingWithData:idata];
  [self initWithParent:aParent];
  return self;
}

+ (id)unarchiveObjectWithData:(NSData *)idata parent:(NSCoder *)aparent;
{
  id obj;
  JGLogUnarchiver *u;
  JGLogUnarchiver *setParent;
  if ([aparent isKindOfClass:[self class]]&&(((JGLogUnarchiver *)aparent)->includeOtherUnArchiver)) 
    setParent=(JGLogUnarchiver *)aparent;
  else setParent=nil; 
  if (setParent) 
    [setParent->xmlchildren appendString:@"  <!-- Begin read with another Unarchiver -->\n"];

  u=[[JGLogUnarchiver alloc] initForReadingWithData:idata parent:setParent];
  obj=[[u decodeObject] retain];
  [u release];
  [obj autorelease];
  if (setParent)
    [setParent->xmlchildren appendString:@"  <!-- End   read with another Unarchiver -->\n"]; 
  return obj;
}

- (void)dealloc;
{
  if (makexml) {
    [self writeXML];
    if (parent) {  // Copy structure, subelementes and elementdefinitions to parent
      NSEnumerator *e1,*e2;
      NSString *key,*sequence;
      NSMutableDictionary *sequences;
      [((JGLogUnarchiver *)parent)->xmlchildren appendString:xmlchildren];
      if (([((JGLogUnarchiver *)parent)->subelements length]>0) && ([subelements length]>0)) 
        [((JGLogUnarchiver *)parent)->subelements appendString:@", "];
      [((JGLogUnarchiver *)parent)->subelements appendString:subelements];
      e1=[classes keyEnumerator];
      while ((key=[e1 nextObject])) {
        sequences=[classes objectForKey:key];
        e2=[sequences keyEnumerator];
        while ((sequence=[e2 nextObject])) {
           [parent addElement:key withSubElements:sequence];
        }
      }
    }
  }
  [addresses release];
  [classes release];
  [xmlchildren release];
  [subelements release];
  [super dealloc];
}


- (void)writeXML;
{
  NSMutableString *s=[[NSMutableString alloc]init];

  [s appendString:[self internalDTD]];
  [s appendFormat:@"<JGLogUnarchiverResult>\n%@</JGLogUnarchiverResult>\n",xmlchildren];
  [[NSFileManager defaultManager] createDirectoryAtPath:@"/tmp/JGLogUnarchiverResult" attributes:nil];
  [s writeToFile:[NSString stringWithFormat:@"/tmp/JGLogUnarchiverResult/%d.xml",++writtenArchiverNr]
                  atomically:NO];
}

- (void)setMakexml:(BOOL)val; // call before Unarchiving
{
  makexml=val;
}
- (void)setPrintinfo:(BOOL)val; // call before Unarchiving
{
  printinfo=val;
}
- (NSMutableString *)getXMLEncoding; // call after Unarchiving
{
  return xmlchildren;
}

- (void)addElement:(NSString *)anElement withSubElements:(NSString *)sub;
{
  NSMutableDictionary *subs=[classes objectForKey:anElement];
  if (!subs)
    subs=[NSMutableDictionary new];
  [subs setObject:@"" forKey:sub];    
  [classes setObject:subs forKey:anElement];
}

// Warning: ((a,b,c)|(a,d)) is not allowed in XML (Parser fast but stupid)
// instead use ANY. Exception here: ((nil)|(class))
// for more intelligent pattern recognition, I do not have time now. (perhaps included in xml4j ?).
- (NSMutableString *)structureForElement:(NSString *)element invalidAlternatives:(BOOL)yn;
{
  NSMutableString *s=[NSMutableString new];
  NSMutableDictionary *structures=[classes objectForKey:element];
  NSEnumerator *e=[structures keyEnumerator];
  NSString *key=[e nextObject];
  if ([structures objectForKey:@""])
    printf("structureForElement:leerer key enthalten\n");
  if (!key || (([structures count]==1)&&[structures objectForKey:@""])) 
    [s appendString:@"EMPTY"]; // I think this case I have excluded below (with xmlchildrenlenght)
  else {
    if (!yn && (  ([structures count]>2) || 
                  (([structures count]==2) && ![structures objectForKey:@"nil"]) ||
                  [structures objectForKey:@""]  )) // "" also excluded, isnt it?
      [s appendString:@"ANY"];
    else {
      // warning: empty Elements () are not removed yet!
      if ([structures count]==1)
        [s appendFormat:@"(%@)",key];
      else {        
        [s appendFormat:@"((%@)",key];
        while ((key=[e nextObject]) && ([s length]<=maxElementLength))
          [s appendFormat:@" | (%@)",key];
        [s appendString:@")"];
        if ([s length]>=maxElementLength) [s setString:@"ANY"];
      }
    }
  }
  [s autorelease];
  return s;
}


- (NSMutableString *)elements;
{
  NSMutableString *s=[[NSMutableString alloc] init];
  NSEnumerator *e;
  NSString *aclass;
  [s appendFormat:@"<!ELEMENT Reference EMPTY >\n<!ATTLIST Reference Nr CDATA #IMPLIED>\n"];
  [s appendFormat:@"<!ELEMENT children_too_long_warning EMPTY >\n"];
  [s appendFormat:@"<!ELEMENT nil EMPTY >\n"];
/*
  [s appendFormat:@"<!ELEMENT array ANY >\n<!ATTLIST array ObjCEncoding CDATA #IMPLIED Address CDATA #IMPLIED Nr CDATA #IMPLIED  Value CDATA #IMPLIED >\n"];
  [s appendFormat:@"<!ELEMENT struct ANY >\n<!ATTLIST struct ObjCEncoding CDATA #IMPLIED Address CDATA #IMPLIED Nr CDATA #IMPLIED  Value CDATA #IMPLIED >\n"];
  [s appendFormat:@"<!ELEMENT ObjCValues ANY >\n<!ATTLIST ObjCValues ObjCEncoding CDATA #IMPLIED Address CDATA #IMPLIED Nr CDATA #IMPLIED  Value CDATA #IMPLIED >\n"];
*/

  [s appendFormat:@"<!ELEMENT INTEGER (#PCDATA) >\n<!ATTLIST INTEGER ObjCEncoding CDATA #IMPLIED Address CDATA #IMPLIED >\n"];
  [s appendFormat:@"<!ELEMENT FLOAT (#PCDATA) >\n<!ATTLIST FLOAT ObjCEncoding CDATA #IMPLIED Address CDATA #IMPLIED >\n"];
  [s appendFormat:@"<!ELEMENT STRING (#PCDATA) >\n<!ATTLIST STRING ObjCEncoding CDATA #IMPLIED Address CDATA #IMPLIED >\n"];
//  [s appendFormat:@"<!ELEMENT charPointer EMPTY >\n<!ATTLIST charPointer ObjCEncoding CDATA #IMPLIED Address CDATA #IMPLIED >\n"];
  [s appendFormat:@"<!ELEMENT other EMPTY >\n<!ATTLIST other Type CDATA #IMPLIED Address CDATA #IMPLIED Value CDATA #IMPLIED >\n"];

  [s appendString:@"\n"];
  e=[classes keyEnumerator];
  while ((aclass= [e nextObject])) {
    [s appendFormat:@"<!ELEMENT %@ %@ >\n",aclass,[self structureForElement:aclass invalidAlternatives:NO]];
  }
  [s appendString:@"\n"];
  e=[classes keyEnumerator];
  while ((aclass= [e nextObject])) {
    [s appendFormat:@"<!ATTLIST %@ ObjCEncoding CDATA #IMPLIED Address CDATA #IMPLIED Nr CDATA #IMPLIED >\n",aclass];
  }
  [s autorelease];
  return s;
}

- (NSMutableString *)internalDTD;
{
  NSMutableString *s=[[NSMutableString alloc] init];
  [s appendFormat:@"<?xml version=\"1.0\" standalone=\"yes\"?>\n<!DOCTYPE JGLogUnarchiverResult [\n"];
  [s appendFormat:@"<!ELEMENT JGLogUnarchiverResult ANY >\n%@]>\n",[self elements]];
  [s autorelease];
  return s;
}

- (void)decodeStructured1:(previousInfo *)previous structure:(NSString *)structure;
{
  if (printinfo && structure) {
    space(indent);
    printf("<decode%s/>\n",[structure cString]);
  }
  if (makexml) {
    previous->olderBrothers=xmlchildren;
    previous->prevElements=subelements;
    xmlchildren=[NSMutableString new];
    subelements=[NSMutableString new];
  }
  indent++;
}

// type=NULL bedeutet: Objekt!
- (void)decodeStructured2:(previousInfo *)previous structure:(NSString *)structure
                             tag:(NSString *)tag  address:(void *)obj objCType:(const char *)type
                           visualFormatation:(BOOL)visual;
{
  NSString *typeInfo=nil;
  int i;
  indent--;

  if (printinfo) {
    space(indent);
    if (tag) 
      if (!type) typeInfo=[NSString stringWithFormat:@" Type=\"%@\"", tag];
    else
      typeInfo=@""; 
    printf("<endDecode%s%s Address=\"0x%x\"/>\n",[structure cString], [typeInfo cString], (int)obj);
  }
  if (makexml) { 
// Warning: if a structure includes itself, isOld can be true for this structure
// anyway the structure and their subelements must be output.
// on the other hand then the structure should not be output if its subelements is empty.
    BOOL isOld=NO;
    int xmlchildrenlength=[xmlchildren length];
//    NSString *aname;
    NSString *subel;
    NSString *Nr=nil;
    NSMutableString *prepend=[[NSMutableString alloc] init];
    for (i=0;i<indent;i++) [prepend appendString:@"  "];
    if (obj) {
      subel=tag;
      [prepend appendFormat:@"<%@", tag];
      if (type) [prepend appendFormat:@" ObjCEncoding=\"%s\"",type];
      if (obj!=(void *)1) { // 1 means: not a real Address, but a Structure or decodeObjectsWithObjCValues
        [prepend appendFormat:@" Address=\"0x%x\"", obj];
        isOld=[addresses containsAddress:obj];
        if (!isOld)
          [addresses insertAddress:obj withName:@""];
        Nr=[addresses getNumberStringForAddress:obj]; 
        [prepend appendFormat:@" Nr=\"%@\"",Nr];
      }
      if (xmlchildrenlength==0) {
        [prepend appendFormat:@" ><Reference Nr=\"%@\"/></%@>\n",Nr,tag];
        [self addElement:tag withSubElements:@"Reference"];
      } else {
        [self addElement:tag withSubElements:subelements];
        [prepend appendString:@">"];
        if (maxxmlchildrenlength && (xmlchildrenlength>maxxmlchildrenlength)) {
          [xmlchildren setString:@"<children_too_long_warning/>"];
          [self addElement:tag withSubElements:@"children_too_long_warning"];
          [prepend appendFormat:@" %@\n",xmlchildren];
        } else {
          if (visual) [prepend appendFormat:@"\n"];
          [prepend appendFormat:@"%@",xmlchildren];
        }
        if (visual) {
          for (i=0;i<indent;i++) [prepend appendString:@"  "];
          [prepend appendFormat:@" "];
        }
        [prepend appendFormat:@"</%@>\n",tag];
      }
 
      [subelements release];
      subelements=previous->prevElements;

    } else {
      subel=@"nil";
      [prepend appendFormat:@"<nil/>\n"];
    }
      if ([subelements length]>0)
        [subelements appendString:@", "];
      [subelements appendString:subel];
    [previous->olderBrothers appendFormat:@"%@",prepend];
    xmlchildren=previous->olderBrothers;
  }  // end if makexml
}


- (id)decodeObject;
{
 id obj;
 previousInfo pi;
 NSString *structure=@"Object";
 NSString *tag;
 if (printinfo || makexml) [self decodeStructured1:&pi structure:structure];

 obj=[super decodeObject];

 if (printinfo || makexml) {
   if (obj) 
     tag=NSStringFromClass([(id)obj class]);
   else
     tag=@"nil";
   [self decodeStructured2:&pi structure:structure tag:tag address:obj objCType:NULL visualFormatation:YES];
 } 
 return obj;
}


#define decodeHandleTag(character,ObjCType,Tag,Formatter) case character: tag=Tag; [valStr appendFormat:Formatter,*(ObjCType *)thedata]; break;

- (void)decodeValueOfObjCType:(const char *)valueType at:(void *)thedata;
{
  previousInfo pi;
  NSString *structure=nil;
  if (printinfo || makexml) {
    switch(*valueType) {
      case '{': structure=@"struct"; break;
      case '[': structure=@"array"; break;
      case '@': structure=@"id"; break; // static, or id.  thedata==id*
      default: structure=nil;
    }
    if (structure) [self decodeStructured1:&pi structure:structure];
    else if (printinfo) {
      space(indent);
      printf("<decodeObjC Type=\"%s\" Address=\"0x%x\"",valueType,(int)thedata);
      if (*valueType=='@') printf("/>\n");
    }
  }

  [super decodeValueOfObjCType:valueType at:thedata];

  // if @ then {if !nil then decodeObject} else *thedata==nil!
  if (printinfo || makexml) 
   if (structure) {
     if (*valueType=='@') {
       id obj=*(id *)thedata;
       if (obj) {
         Class theclass=[obj class];
         if (theclass) 
           structure=NSStringFromClass(theclass);
         else
           structure=@"NoNSObject";
       }
       if ([structure isEqualToString:@"NSInlineCString"]) {
          [xmlchildren appendString:obj];
          [subelements appendString:@"#PCDATA"];
          [self decodeStructured2:&pi structure:structure tag:structure address:obj
                         objCType:valueType visualFormatation:NO];
       } else
         [self decodeStructured2:&pi structure:structure tag:structure address:obj
                      objCType:valueType visualFormatation:YES];
     } else  // not '@'
     [self decodeStructured2:&pi structure:structure tag:structure address:thedata
                    objCType:valueType visualFormatation:YES];
   } else { // if ((*valueType!='@') || !(*(id *)thedata))   // no structure.
     [self decodeSimpleValueOfObjCType:valueType at:thedata];
   }
}

- (void)decodeSimpleValueOfObjCType:(const char *)valueType at:(void *)thedata;
{
    int i;
    NSString *tag;
    NSMutableString *valStr=[NSMutableString new];
    switch(*valueType) {
decodeHandleTag('c',char,@"INTEGER",@"%d")
decodeHandleTag('i',int,@"INTEGER",@"%d")
decodeHandleTag('s',short,@"INTEGER",@"%d")
decodeHandleTag('l',long,@"INTEGER",@"%d")
decodeHandleTag('q',long long,@"INTEGER",@"%d")
decodeHandleTag('C',unsigned char,@"INTEGER",@"%d")
decodeHandleTag('I',unsigned long,@"INTEGER",@"%d")
decodeHandleTag('S',unsigned short,@"INTEGER",@"%d")
decodeHandleTag('Q',unsigned long long,@"INTEGER",@"%d")
decodeHandleTag('f',float,@"FLOAT",@"%f")
decodeHandleTag('d',double,@"FLOAT",@"%f")
      case 'v': tag=@"void";
              [valStr appendFormat:@"void"]; break;
      case '*': tag=@"STRING"; // thedata is the address of a char *, that means char ** (see String)
                [valStr appendFormat:@"%s",*(char **)thedata]; break;
      case '@': tag=@"nil";  
                [valStr appendFormat:@"nil"]; break;
      default: tag=@"other"; break;    
    }
    if (printinfo) {
      printf(" ObjCEncoding=\"%s\" Value=\"%s\"/>\n", [tag cString], [valStr cString]);
    }
    if (makexml) {
      for (i=0;i<indent;i++) [xmlchildren appendString:@"  "];
      if ([subelements length]>0)
        [subelements appendString:@", "];
      [subelements appendString:tag];
      if (([valStr length]>0) || (*valueType=='*')) // 
        [xmlchildren appendFormat:@"<%@ ObjCEncoding=\"%s\" Address=\"0x%x\">%@</%@>\n",
                               tag,valueType,thedata,valStr,tag];
//      else if (([valStr length]>0) || (*valueType=='*'))
//        [xmlchildren appendFormat:@"<%@ ObjCEncoding=\"%s\" Address=\"0x%x\" Value=\"%@\"/>\n",
//                             tag,valueType,thedata,valStr];
      else 
        [xmlchildren appendFormat:@"<%@ ObjCEncoding=\"%s\" Address=\"0x%x\"/>\n",
                             tag,valueType,thedata];
    }
    [valStr release];
}

// jg: dont know, if this works with structs and arrays. But they also dont occour in Rubato.
// vor.
- (void)decodeValuesOfObjCTypes:(const char *)types, ...;
{
  int i;
  size_t count=strlen(types);
  va_list pvar;
  void *address, *firstaddress=NULL;
  const char *typeP;
  char type[2]; 
  void *a[10]; // jg: sufficient fuer Rubato now.
  previousInfo pi;
  NSString *structure=@"ObjCValues";
  if (printinfo || makexml) {
    type[1]=0;
    [self decodeStructured1:&pi structure:structure];
  }

  if (count>10) printf("JGLogUnarchiver: decodeValuesOfObjCTypes >10 args Error!\n");
  va_start(pvar,types); // initilised to ...
  for (i=0,typeP=types; *typeP; typeP++,i++) { // do we have to separate the single characters from the string?
    address=va_arg(pvar,void *);
    if (!firstaddress) firstaddress=address;
    a[i]=address;
//    type[0]=*typeP;
// this does not work, because the decoder finds types-Sequence and not the single types.
//    [self decodeValueOfObjCType:type at:address]; 
  }
  va_end(pvar);

//  [super decodeValuesOfObjCTypes:types,pvar];  // does not work either
// insted the following workaourd: (dont know, if you can forward ellipses in whole.
  switch (count) {
  case 0:[super decodeValuesOfObjCTypes:types]; break;
  case 1:[super decodeValuesOfObjCTypes:types,a[0]]; break;
  case 2:[super decodeValuesOfObjCTypes:types,a[0],a[1]]; break;
  case 3:[super decodeValuesOfObjCTypes:types,a[0],a[1],a[2]]; break;
  case 4:[super decodeValuesOfObjCTypes:types,a[0],a[1],a[2],a[3]]; break;
  case 5:[super decodeValuesOfObjCTypes:types,a[0],a[1],a[2],a[3],a[4]]; break;
  case 6:[super decodeValuesOfObjCTypes:types,a[0],a[1],a[2],a[3],a[4],a[5]]; break;
  case 7:[super decodeValuesOfObjCTypes:types,a[0],a[1],a[2],a[3],a[4],a[5],a[6]]; break;
  case 8:[super decodeValuesOfObjCTypes:types,a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7]]; break;
  case 9:[super decodeValuesOfObjCTypes:types,a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8]]; break;
  case 10:[super decodeValuesOfObjCTypes:types,a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9]]; break;
  }

  if (printinfo || makexml) {
    for (i=0,typeP=types; *typeP; typeP++,i++)  {
      type[0]=*typeP;
      [self decodeSimpleValueOfObjCType:type at:a[i]];
    }
    [self decodeStructured2:&pi structure:structure tag:structure address:(void *)1
                   objCType:types visualFormatation:YES];
  }
}

- (void)decodeArrayOfObjCType:(const char *)itemType count:(unsigned int)count at:(void *)address;
{
  previousInfo pi;
  NSString *structure=@"array";
  if (printinfo || makexml) {
    [self decodeStructured1:&pi structure:structure];
  }

  [super decodeArrayOfObjCType:itemType count:count at:address];

  if (printinfo || makexml)
    [self decodeStructured2:&pi structure:structure tag:structure address:address
                   objCType:itemType visualFormatation:YES];
}


@end

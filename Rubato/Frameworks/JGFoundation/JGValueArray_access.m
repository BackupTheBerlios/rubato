//  JGValueArray_init.m Copyright (c) 2002 Joerg Garbers.
//  This software is open source. See the license.

+ (id)arrayWithArray:(NSArray *)array;
{
  NSParameterAssert([array count]>0);
  return [self arrayWithArray:array prototype:[array objectAtIndex:0]];
}

- (void)dealloc;
{
  [data release];
  free(objCType);
  [super dealloc];
}
- (BOOL)castValue;
{
  return castValue;
}
- (void)setCastValue:(BOOL)newCastValue;
{
  castValue=newCastValue;
}
- (unsigned int)elementSize;
{
  return size;
}
- (NSString *)elementType;
{
  return [NSString stringWithCString:objCType];
}
- (unsigned)count;
{
  return count;
}

- (id)objectAtIndex:(unsigned)idx;
{
  NSNumber *number;
  NSParameterAssert([self count]>idx);
  if (returnType==0) 
    return [[[NSValue alloc] initWithBytes:VALPOINTER objCType:objCType] autorelease];
//  NSLog(@"objectAtIndex as int:%d",*(int *)VALPOINTER);
#undef NC    
#define NC(character,method,typ) case character: number=[NSNumber method:*(typ *)VALPOINTER]; break;
  switch(objCType[0]) {
    NC('c',numberWithChar,char);
    NC('C',numberWithUnsignedChar,unsigned char);
    NC('i',numberWithInt,int);
    NC('I',numberWithUnsignedInt,unsigned int);
    NC('s',numberWithShort,short);
    NC('S',numberWithUnsignedShort,unsigned short);
    NC('l',numberWithLong,long);
    NC('L',numberWithUnsignedLong,unsigned long);
    NC('q',numberWithLongLong,long long);
    NC('Q',numberWithUnsignedLongLong,unsigned long long);
    NC('f',numberWithFloat,float);
    NC('d',numberWithDouble,double);
//    NC('Q',numberWithBool,BOOL);
    default: NSAssert1(0,@"JGNumberArray unmatched char %c",objCType[0]); return nil;
  }
  if (returnType==1)
    return number;
  else if (returnType==2)
    return [NumberClass numberWithDouble:[number doubleValue]];
  return nil; // should not be reached !
}


//  JGValueArray_init.m Copyright (c) 2002 Joerg Garbers.
//  This software is open source. See the license.

  [super init];
  castValue=YES;
  returnType=newReturnType;
  size=[JGValueArray sizeForObjCType:newObjCType];
  dataOffset=offset;
  count=newCount;
  NSParameterAssert([newData length]>=dataOffset+count*size);
  data=[newData retain];
  objCType=malloc(strlen(newObjCType)+1);
  strcpy(objCType,newObjCType);
  return self; 

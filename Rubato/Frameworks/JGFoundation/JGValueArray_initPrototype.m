//  JGValueArray_initPrototype.m Copyright (c) 2002 Joerg Garbers.
//  This software is open source. See the license.

  const char *newObjCType;
  unsigned int newReturnType;
  if ([prototype isKindOfClass:[NSString class]]) {
    prototype=[JGValueArray numberWithElementType:prototype];
  } 
  if ([prototype isKindOfClass:NumberClass]) {
    newObjCType=@encode(double);
    newReturnType=2;
  } else if ([prototype isKindOfClass:[NSNumber class]]) {
    newObjCType=[prototype objCType];
    newReturnType=1;
  } else if ([prototype isKindOfClass:[NSValue class]]) {
    newObjCType=[prototype objCType];
    newReturnType=0;
  } else
    NSAssert(0,@"JGValueArray error: Wrong Prototype instance");

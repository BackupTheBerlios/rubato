/*
 *  JGClassRefMacros.h
 *  JGMacros/Misc
 *
 *  Created by Joerg Garbers on Mon Jun 03 2002.
 *  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
 *
 */

// className is not a String, but #className is.

#define JG_UNCHECKED_CLASS_REF(className) NSClassFromString([NSString stringWithCString: #className])

// throw exception or Log?
#define JG_CHECKED_CLASS_REF(className) \
  (JG_UNCHECKED_CLASS_REF(className) \
   ? JG_UNCHECKED_CLASS_REF(className) \
   : [NSString stringWithFormat: @"Warning: Class %s expected to exist, but is not linked", #className] )

// example: [myObject JG_CLASS_REF_METHOD(MyOtherClass)] -> [myObject MyOtherClass]
#define JG_CLASS_REF_METHOD(className) className

// defines a class or instance method with name JG_CLASS_REF_METHOD(className) 
#define JG_CLASS_REF_METHOD_DEFINITION(sign,className) \
  sign (id) JG_CLASS_REF_METHOD(className) \
{  \
  id cls=NSClassFromString(str); \
  NSParameterassert(cls!=nil); \
  return cls; \
}

// Standard behaviour, modifiable by compile option JG_LINK_CHECK_CLASS_REF
#ifdef JG_LINK_CHECK_CLASS_REF
#define JG_CLASS_REF(className) className
#else
#define JG_CLASS_REF(className) JG_UNCHECKED_CLASS_REF(className)
#endif
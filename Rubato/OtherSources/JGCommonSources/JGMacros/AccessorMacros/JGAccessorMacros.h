/*
 *  JGAccessorMacros.h
 *  AddOnServices
 *
 *  Created by jg on Thu Aug 16 2001. (learned from Marcel Weihers MPWFoundation)
 *  Copyright (c) 2001 __CompanyName__. All rights reserved.
 *
 * #import (without definition of accessor_flex and scalarAccessor_flex)
 * #include "..." redifines accessor_flex and scalarAccessor_flex
 *            and evaluates JG_FLEX_ACCESSORS
#import "JGAccessorMacros.h"
#include "JGAccessorMacros_ivar.h"
#include "JGAccessorMacros_h.h"
#include "JGAccessorMacros_init.h"
#include "JGAccessorMacros_dealloc.h"
#include "JGAccessorMacros_initWithCoder.h"
#include "JGAccessorMacros_encodeWithCoder.h"
#include "JGAccessorMacros_m.h"
 */

#define	setAccessor( type, var, setVar ) \
-(void)setVar:(type)newVar { \
    if ( newVar!=var) {  \
        if ( newVar!=(id)self ) \
            [newVar retain]; \
        if ( var && var!=(id)self) \
            [var release]; \
        var = newVar; \
	} \
} \

#define readAccessor( type, var )\
-(type)var {	return var; }

#define accessor( type, var, setVar ) \
readAccessor(type,var)\
setAccessor(type,var,setVar)

#define	accessor_h( type,var,setVar ) -(void)setVar:(type)newVar; \
-(type)var;

#define scalarAccessor( scalarType, var, setVar ) \
-(void)setVar:(scalarType)newVar {	var=newVar;	} \
-(scalarType)var {	return var;	} 
#define scalarAccessor_h( scalarType, var, setVar ) \
-(void)setVar:(scalarType)newVar; \
-(scalarType)var;

#define intAccessor( var, setVar )	scalarAccessor( int, var, setVar )
#define intAccessor_h( var, setVar )	scalarAccessor_h( int, var, setVar )
#define floatAccessor(var,setVar )  scalarAccessor( float, var, setVar )
#define floatAccessor_h(var,setVar )  scalarAccessor_h( float, var, setVar )
#define boolAccessor(var,setVar )  scalarAccessor( BOOL, var, setVar )
#define boolAccessor_h(var,setVar )  scalarAccessor_h( BOOL, var, setVar )

#define accessor_ivar( type, var, setVar ) type var;
#define scalarAccessor_ivar( type, var, setVar ) type var;

#define accessor_init( type, var, setVar ) var=(type)0;
#define scalarAccessor_init( type, var, setVar ) var=(type)0;

#define accessor_dealloc( type, var, setVar ) [var release];
#define scalarAccessor_dealloc( type, var, setVar ) 

#define accessor_initWithCoder( type, var, setVar ) var=[[coder decodeObject] retain];
#define scalarAccessor_initWithCoder( type, var, setVar ) [coder decodeValueOfObjCType:@encode(type) at:&var];

#define accessor_encodeWithCoder( type, var, setVar ) [coder encodeObject:var];
#define scalarAccessor_encodeWithCoder( type, var, setVar ) [coder encodeValueOfObjCType:@encode(type) at:&var];

#define accessor_initWithCoder_info( type, var, setVar, info ) \
if ((info).transient!=0) { \
  accessor_init(type,var,setVar) \
} else { \
  accessor_initWithCoder(type,var,setVar) \
}
#define scalarAccessor_initWithCoder_info( type, var, setVar, info ) \
if ((info).transient!=0) { \
  scalarAccessor_init(type,var,setVar) \
} else { \
  scalarAccessor_initWithCoder(type,var,setVar) \
}

#define accessor_encodeWithCoder_info( type, var, setVar, info ) \
if (((info).transient==0)) { \
  accessor_encodeWithCoder(type,var,setVar) \
}
#define scalarAccessor_encodeWithCoder_info( type, var, setVar, info ) \
if (((info).transient==0)) { \
  scalarAccessor_encodeWithCoder(type,var,setVar) \
}

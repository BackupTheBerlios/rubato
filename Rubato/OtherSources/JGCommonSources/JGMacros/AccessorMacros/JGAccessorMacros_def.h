/*
 *  JGAccessorMacros_def.h
 *  AndreasMeloProjects
 *
 *  Created by jg on Wed Aug 29 2001.
 *  Copyright (c) 2001 __CompanyName__. All rights reserved.
 *
 * #import "JGAccessorMacros.h" first (without definition of accessor_flex and scalarAccessor_flex)
 * then #define (in that order) and #include "JGAccessorMacros_def.h"
 * ACCESSOR_ivar ACCESSOR_h ACCESSOR_init ACCESSOR_dealloc ACCESSOR_m 
 * Later #defines will precede earlier.
 * ACCESSOR_ivar_only will #undef all ACCESSOR_... 
 * ACCESSOR_ivar_only will #define ACCESSOR_ivar and #undef all others. 
 * for copy and paste:
#import "JGAccessorMacros.h"
#define ACCESSOR_
#include "JGAccessorMacros_def.h"
 */


#if defined(ACCESSOR_clear) || defined(ACCESSOR_ivar_only)
#undef ACCESSOR_clear
#undef ACCESSOR_ivar_only
#undef ACCESSOR_ivar
#undef ACCESSOR_h
#undef ACCESSOR_init
#undef ACCESSOR_dealloc
#undef ACCESSOR_m
#endif

#ifdef ACCESSOR_ivar_only
#define ACCESSOR_ivar
#endif

#if defined(ACCESSOR_ivar) || defined(ACCESSOR_h) || defined(ACCESSOR_init) || defined(ACCESSOR_dealloc) || defined(ACCESSOR_m)
#undef accessor_flex
#undef scalarAccessor_flex
#endif

#if defined(ACCESSOR_m)
#define accessor_flex( type, var, setVar ) accessor(type,var,setVar)
#define scalarAccessor_flex( type, var, setVar ) scalarAccessor(type,var,setVar)
#elif defined(ACCESSOR_dealloc)
#define accessor_flex( type, var, setVar ) accessor_dealloc(type,var,setVar)
#define scalarAccessor_flex( type, var, setVar ) scalarAccessor_dealloc(type,var,setVar)
#elif defined(ACCESSOR_init)
#define accessor_flex( type, var, setVar ) accessor_init(type,var,setVar)
#define scalarAccessor_flex( type, var, setVar ) scalarAccessor_init(type,var,setVar)
#elif defined(ACCESSOR_h)
#define accessor_flex( type, var, setVar ) accessor_h(type,var,setVar)
#define scalarAccessor_flex( type, var, setVar ) scalarAccessor_h(type,var,setVar)
#elif defined(ACCESSOR_ivar)
#define accessor_flex( type, var, setVar ) accessor_ivar(type,var,setVar)
#define scalarAccessor_flex( type, var, setVar ) scalarAccessor_ivar(type,var,setVar)
#endif

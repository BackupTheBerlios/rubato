/*
 *  JGNextAccessorMacros.h
 *  AndreasMeloProjects
 *
 *  Created by jg on Mon Aug 27 2001.
 *  Copyright (c) 2001 __CompanyName__. All rights reserved.
 *
 * this seems to be too complicated. better use JGAccessorMacros_ivar.h, ...
 *
 * the following features are not so clear.
 * ACCESSOR_iterate will #define ACCESSOR_ivar and #undef all others. 
 * ACCESSOR_next will define next ACCESSOR_... in chain. 
 *   (Automatically set by ACCESSOR_iterate and FLEX_ACCESSORS)
 * Special feature: #define FLEX_ACCESSORS accessor_flex(...) \ ...
 *   this will #define ACCESSOR_ivar on the first run and defines ACCESSOR_next.
 *   Besides, at the end of this file FLEX_ACCESSORS is evaluated
 */

#if defined(ACCESSOR_ivar) || defined(ACCESSOR_h) || defined(ACCESSOR_init) || defined(ACCESSOR_dealloc) || defined(ACCESSOR_m)

#if defined(ACCESSOR_m)
#warning JGAccessorMacros_next.h: ACCESSOR_m is the last macro defined. No next accessor macros!
#elif defined(ACCESSOR_dealloc)
#define ACCESSOR_m
#elif defined(ACCESSOR_init)
#define ACCESSOR_dealloc
#elif defined(ACCESSOR_h)
#define ACCESSOR_init
#elif defined(ACCESSOR_ivar)
#define ACCESSOR_h
#endif

#elif defined(FLEX_ACCESSORS)
#define ACCESSOR_ivar
#endif

#include "JGAccessorMacros_def.h"

#ifdef FLEX_ACCESSORS
FLEX_ACCESSORS
#endif

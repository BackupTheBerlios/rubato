/*
 *  JGAccessorMacros_initWithCoder.h
 *  AndreasMeloProjects
 *
 *  Created by jg on Fri Aug 31 2001.
 *  Copyright (c) 2001 __CompanyName__. All rights reserved.
 *
 */

#include "JGAccessorMacrosFlexBegin.h"

#define accessor_flex( type, var, setVar ) accessor_initWithCoder(type,var,setVar)
#define scalarAccessor_flex( type, var, setVar ) scalarAccessor_initWithCoder(type,var,setVar)

#undef accessor_flex_info
#undef scalarAccessor_flex_info

#define accessor_flex_info( type, var, setVar, info ) accessor_initWithCoder_info(type,var,setVar,info)
#define scalarAccessor_flex_info( type, var, setVar, info ) scalarAccessor_initWithCoder_info(type,var,setVar,info)

#include "JGAccessorMacrosFlexEnd.h"



/*
 *  JGAccessorMacros_ivar.h
 *  AndreasMeloProjects
 *
 *  Created by jg on Wed Aug 29 2001.
 *  Copyright (c) 2001 __CompanyName__. All rights reserved.
 *
 */

#include "JGAccessorMacrosFlexBegin.h"

#define accessor_flex( type, var, setVar ) accessor_ivar(type,var,setVar)
#define scalarAccessor_flex( type, var, setVar ) scalarAccessor_ivar(type,var,setVar)

#include "JGAccessorMacrosFlexEnd.h"


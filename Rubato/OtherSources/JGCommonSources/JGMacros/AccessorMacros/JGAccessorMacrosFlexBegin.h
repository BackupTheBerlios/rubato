/*
 *  JGAccessorMacrosFlexBegin.h
 *  AndreasMeloProjects
 *
 *  Created by jg on Fri Aug 31 2001.
 *  Copyright (c) 2001 __CompanyName__. All rights reserved.
 *
 */

#undef accessor_flex_info
#undef scalarAccessor_flex_info

#define accessor_flex_info( type, var, setVar, info ) \
accessor_flex(type,var,setVar)
#define scalarAccessor_flex_info( type, var, setVar, info ) \
scalarAccessor_flex(type,var,setVar)

#undef accessor_flex
#undef scalarAccessor_flex

/*
 *  JGAccessorMacrosEncodeMethods.h.h
 *  AndreasMeloProjects
 *
 *  Created by jg on Fri Aug 31 2001.
 *  Copyright (c) 2001 __CompanyName__. All rights reserved.
 *
 */

- (id)initWithCoder:(NSCoder *)coder;
{
  if ([super respondsToSelector:@selector(initWithCoder:)])
    [super initWithCoder:coder];
  else
    [super init];
#include "JGAccessorMacros_initWithCoder.h"
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
  if ([super respondsToSelector:@selector(encodeWithCoder:)])
    [super encodeWithCoder:coder];
#include "JGAccessorMacros_encodeWithCoder.h"
}

//
//  RubatoAppPatch.m
//  Rubato
//
//  Created by Joerg Garbers on Thu Oct 03 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "RubatoAppPatch.h"

#import "JGTitledScrollView.h"
@implementation JGTitledScrollView (Patch)
+ (void)initialize;
{
  NSLog(@"Patch loaded JGTitledScrollView (Patch)");
}
@end
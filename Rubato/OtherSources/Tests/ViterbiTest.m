//
//  ViterbiTest.m
//  RubatoFrameworks
//
//  Created by Joerg Garbers on Sat Jul 06 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

//#import <RubatoAnalysis/JGViterbi.h>
@interface JGViterbi;
+ (void)testViterbi;
@end
int main(int argc, char *argv[])
{
  [[NSAutoreleasePool alloc] init];
  [JGViterbi testViterbi];
  [NSAutoreleasePool release];
  return 0;
}
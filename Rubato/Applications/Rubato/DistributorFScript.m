//
//  DistributorFScript.m
//  RubatoFrameworks
//
//  Created by jg on Wed Dec 05 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "DistributorFScript.h"
#import <AppKit/AppKit.h>
#import <FScript/System.h>
#import <FScript/FSServicesProvider.h>
#import <FScript/FSInterpreter.h>

@protocol InterpreterProviderDistributor
-(id)interpreter;
@end

@implementation Distributor (FScript)
- (id)interpreterView;
{
    if (!interpreterView) {
      id interpreter,servicesProvider;
      [NSBundle loadNibNamed:@"FScript.nib" owner:self];
//      [self loadNibNamed:@"FScript.nib" forClass:[Distributor class]];
      interpreter=[interpreterView interpreter];
      [interpreter setObject:self forIdentifier:@"distributor"];
      [interpreter setShouldJournal:NO];
      [interpreterWindow close];
//      [interpreterWindow makeKeyAndOrderFront:nil];
      if (self == [Distributor globalDistributor]) {
        servicesProvider=[[FSServicesProvider alloc] initWithFScriptInterpreterViewProvider:self];
        [servicesProvider registerServicesProvider];
        [servicesProvider registerServerConnection:@"Rubato"];
      }
    }
    return interpreterView;
}

- (id)interpreterWindow;
{
  //id view=
  [self interpreterView];
  return interpreterWindow;
}

- (id)interpreter;
{
  id theInterpreter;
  [self interpreterView];
  theInterpreter=[interpreterView interpreter];
  return theInterpreter;
}
@end

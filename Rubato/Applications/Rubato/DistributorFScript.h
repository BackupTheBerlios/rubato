//
//  DistributorFScript.h
//  RubatoFrameworks
//
//  Created by jg on Wed Dec 05 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Rubato/Distributor.h>
// overrides empty interpreterView implementation of Distributor.
// installs a Serviceprovider and 
@interface Distributor (FScript)
- (id)interpreter;
- (id)interpreterView;
- (id)interpreterWindow;
@end


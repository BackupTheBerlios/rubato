//
//  JGNXCompatibleUnarchiver.h
//  RubatoFrameworks
//
//  Created by jg on Thu Oct 18 2001.
//  Copyright (c) 2001 __CompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// substute NSMutableArray for all Nextstep 3.3. List objects
@interface ListReader : NSObject
{
@public
    id          *dataPtr;       /* data of the List object */
    unsigned    numElements;    /* Actual number of elements */
    unsigned    maxElements;    /* Total allocated elements */
}
@end

// return an NSMutableDictionary upon decoding.
@interface HashTableReader : NSObject
{
}
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

@interface JGNXCompatibleUnarchiver : NSUnarchiver
{
}
-(id)initForReadingWithData:(NSData *)data;
@end

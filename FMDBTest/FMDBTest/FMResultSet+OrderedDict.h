//
//  FMResultSet+OrderedDict.h
//  FMDBTest
//
//  Created by Daniel Nestor Corbatta Barreto on 20/11/13.
//  Copyright (c) 2013 Daniel Nestor Corbatta Barreto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"
#import "OrderedDictionary.h"
@interface FMResultSet(OrderedDict)
- (OrderedDictionary*)resultOrderDictionary;
@end

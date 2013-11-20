//
//  DHInet.h
//  InetTest
//
//  Created by Daniel Nestor Corbatta Barreto on 20/11/13.
//  Copyright (c) 2013 Daniel Nestor Corbatta Barreto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHInet : NSObject


- (NSArray *) getTCPConnections;
- (NSArray *) getUDPConnections;
@end

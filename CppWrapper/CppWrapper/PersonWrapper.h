//
//  CppWrapper.h
//  CppWrapper
//
//  Created by Daniel Nestor Corbatta Barreto on 02/12/13.
//  Copyright (c) 2013 Daniel Nestor Corbatta Barreto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonWrapper : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * age;

- (id) initWithName:(NSString *) name andAge:(NSNumber *) age;
- (void) talk;
@end

//
//  CppWrapper.m
//  CppWrapper
//
//  Created by Daniel Nestor Corbatta Barreto on 02/12/13.
//  Copyright (c) 2013 Daniel Nestor Corbatta Barreto. All rights reserved.
//

#import "PersonWrapper.h"
#import "Person.h"

@interface PersonWrapper(){
    Person * person;
}

@end
@implementation PersonWrapper

- (id) initWithName:(NSString *) name andAge:(NSNumber *) age{
    if (self = [super init]) {
        std::string namestr = std::string([name UTF8String]);
        int ageN = [age intValue];
        person = new Person(namestr,ageN);
    }
    return self;
}

- (NSString *) name{
    return [NSString stringWithCString:person->get_name().c_str()
                              encoding:[NSString defaultCStringEncoding]];
}

- (NSNumber *) age{
    return [NSNumber numberWithInt:person->get_age()];
}

- (void) talk{
    person->talk();
}

@end

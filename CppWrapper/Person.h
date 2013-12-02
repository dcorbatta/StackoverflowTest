//
//  Person.h
//  CppWrapper
//
//  Created by Daniel Nestor Corbatta Barreto on 02/12/13.
//  Copyright (c) 2013 Daniel Nestor Corbatta Barreto. All rights reserved.
//

#ifndef __CppWrapper__Person__
#define __CppWrapper__Person__

#include <iostream>
class Person
{
public:								//constructor always have same name as class
	Person();							//constructor with 0 input
	Person(std::string pname, int page);		//constructor with 2 input;
    std::string get_name() const;
	int get_age() const;
    void talk();
private:
    std::string name;
	int age; /* 0 if unknown */
};

#endif /* defined(__CppWrapper__Person__) */

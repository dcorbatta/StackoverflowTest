//
//  Person.cpp
//  CppWrapper
//
//  Created by Daniel Nestor Corbatta Barreto on 02/12/13.
//  Copyright (c) 2013 Daniel Nestor Corbatta Barreto. All rights reserved.
//

#include "Person.h"

Person::Person(std::string pname,int page)
{
	name = pname;
	age = page;
}

std::string Person::get_name() const
{
	return name;
}

int Person::get_age() const
{
	return age;
}

void Person::talk(){
    printf("My name is %s and my age is %d",name.c_str(),age );
}
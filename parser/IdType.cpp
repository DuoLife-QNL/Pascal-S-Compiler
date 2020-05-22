#include "IdType.h"
#include <stdlib.h>
#include <iostream>
#include <stddef.h>
using std::cout;
using std::endl;

id::id(std::string name, TYPE type){
    this->name = name;
    this->type = type;
}

std::string id::get_name(){
    return name;
}

TYPE id::get_type(){
    return type;
}

basic_type_id::basic_type_id(std::string name, TYPE type)
:id(name, type){}

array_id::array_id(std::string name, TYPE et, int dim, int *prd)
:id(name, ARRAY){
    element_type = et;
    this->prd = new period[dim];
    for (int i = 0; i < dim; i += 2) {
        (this->prd + i)->start = *(prd + i);
        (this->prd + i)->end = *(prd + i + 1);
    }
}

array_id::~array_id(){
    delete prd;
    prd = NULL;
}

int array_id::get_dim(){
    return dim;
}

period array_id::get_period(int dim){
    return *(prd + dim);
}

parameter::parameter(std::string name, TYPE type, bool is_var)
:basic_type_id(name, type){
    this->is_var = is_var;
}

block::block(std::string name, TYPE type, std::vector<parameter> pl)
:id(name, type){
    this->pl = pl;
}

procedure_id::procedure_id(std::string name, std::vector<parameter> pl)
:block(name, PROCEDURE, pl){}

function_id::function_id(std::string name, std::vector<parameter> pl, TYPE ret_type)
:block(name, FUNCTION, pl){
    this->ret_type = ret_type;
}
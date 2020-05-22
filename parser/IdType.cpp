#include "IdType.h"
#include <stdlib.h>
#include <iostream>
#include <stddef.h>
using std::cout;
using std::endl;

Id::Id(std::string name, TYPE type){
    this->name = name;
    this->type = type;
}

std::string Id::get_name(){
    return name;
}

TYPE Id::get_type(){
    return type;
}

BasicTypeId::BasicTypeId(std::string name, TYPE type)
:Id(name, type){}

ArrayId::ArrayId(std::string name, int dim, int *prd)
:Id(name, ARRAY){
    element_type = et;
    this->prd = new period[dim];
    for (int i = 0; i < dim; i += 2) {
        (this->prd + i)->start = *(prd + i);
        (this->prd + i)->end = *(prd + i + 1);
    }
}

ArrayId::~ArrayId(){
    delete prd;
    prd = NULL;
}

int ArrayId::get_dim(){
    return dim;
}

period ArrayId::get_period(int dim){
    return *(prd + dim);
}

Prameter::Prameter(std::string name, TYPE type, bool is_var)
:BasicTypeId(name, type){
    is_var_ = is_var;
}

bool Prameter::is_var(){
    return is_var_;
}

Block::Block(std::string name, TYPE type, std::vector<Prameter> pl)
:id(name, type){
    this->pl = pl;
}

std::vector<Prameter> Block::get_par_list(){
    return pl;
}

ProcedureId::ProcedureId(std::string name, std::vector<Prameter> pl)
:Block(name, PROCEDURE, pl){}

FunctionId::FunctionId(std::string name, std::vector<Prameter> pl, TYPE ret_type)
:Block(name, FUNCTION, pl){
    this->ret_type = ret_type;
}

TYPE FunctionId::get_ret_type(){
    return ret_type;
}
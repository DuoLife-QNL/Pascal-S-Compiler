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

BasicTypeId::BasicTypeId(std::string name, TYPE type, bool is_const)
:Id(name, type){
    this->is_const_ = is_const;
}

bool BasicTypeId::is_const(){
    return is_const_;
}

ArrayId::ArrayId(std::string name, TYPE et, int dim, period *prd)
:Id(name, _ARRAY){
    element_type = et;
    this->prd = prd;
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

Parameter::Parameter(std::string name, TYPE type, bool is_var)
:BasicTypeId(name, type){
    is_var_ = is_var;
}

bool Parameter::is_var(){
    return is_var_;
}

Block::Block(std::string name, TYPE type, std::vector<Parameter> pl)
:Id(name, type){
    this->pl = pl;
}

std::vector<Parameter> Block::get_par_list(){
    return pl;
}

ProcedureId::ProcedureId(std::string name, std::vector<Parameter> pl)
:Block(name, _PROCEDURE, pl){}

FunctionId::FunctionId(std::string name, std::vector<Parameter> pl, TYPE ret_type)
:Block(name, _FUNCTION, pl){
    this->ret_type = ret_type;
}

TYPE FunctionId::get_ret_type(){
    return ret_type;
}

period *init_period(){
    period *p = new period;
    p->next = NULL;
    return p;
}

void append_period(period *target_period, period *new_period){
    period *tmp = target_period;
    while (!tmp->next){
        tmp++;
    }
    tmp->next = new_period;
}
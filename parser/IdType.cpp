#include <utility>

#include <utility>

#include <utility>

#include <utility>

#include <utility>

#include <utility>

#include <utility>

#include "IdType.h"
#include <cstdlib>
#include <iostream>
#include <cstddef>
using std::cout;
using std::endl;

Id::Id(std::string name, TYPE type) {
    this->name = std::move(name);
    this->type = type;
}

std::string Id::get_name() {
    return name;
}

TYPE Id::get_type() {
    return type;
}

BasicTypeId::BasicTypeId(std::string name, TYPE type, bool is_const)
    : Id(std::move(name), type) {
    this->is_const = is_const;
}

ArrayId::ArrayId(std::string name, TYPE et, int dim, period *prd)
    : Id(std::move(name), _ARRAY) {
    this->dim = dim;
    this->element_type = et;
    this->prd = prd;
}

ArrayId::~ArrayId() {
    delete prd;
    prd = nullptr;
}

int ArrayId::get_dim() {
    return dim;
}

period ArrayId::get_period(int dim) {
    return *(prd + dim);
}

Parameter::Parameter(std::string name, TYPE type, bool is_var)
    : BasicTypeId(std::move(name), type, false) {
    this->is_var = is_var;
}

bool Parameter::get_is_var() {
    return this->is_var;
}

Block::Block(std::string name,
             TYPE type,
             std::vector<Parameter> pl,
             TYPE ret_type)
    : Id(std::move(name), type) {
    this->ret_type = ret_type;
    this->pl = std::move(pl);
}

std::vector<Parameter> Block::get_par_list() {
    return pl;
}
TYPE Block::get_ret_type() {
    return ret_type;
}

ProcedureId::ProcedureId(std::string name, std::vector<Parameter> pl)
    : Block(std::move(name), _PROCEDURE, std::move(pl), _VOID) {}

FunctionId::FunctionId(std::string name,
                       std::vector<Parameter> pl,
                       TYPE ret_type)
    : Block(std::move(name), _FUNCTION, std::move(pl), ret_type) {}

period *init_period() {
    auto *p = new period;
    p->next = nullptr;
    return p;
}

void append_period(period *target_period, period *new_period) {
    period *tmp = target_period;
    while (tmp->next!=nullptr) {
        tmp=tmp->next;
    }
    tmp->next = new_period;
}
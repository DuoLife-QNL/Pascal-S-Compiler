#include "DataType.h"

symbol::symbol(std::string name, TYPE type){
    this->name = name;
    this->type = type;
}

std::string symbol::get_name(){
    return name;
}

TYPE symbol::get_type(){
    return type;
}


basic_type_symbol::basic_type_symbol(std::string name, TYPE type)
:symbol(name, type){}
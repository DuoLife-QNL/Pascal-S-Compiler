#include "DataType.h"

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
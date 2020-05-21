#include "DataType.h"
#include<stdlib.h>

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

array_id::array_id(std::string name, int dim, int *prd)
:id(name, ARRAY){
    this->prd = (period *)malloc(sizeof(period) * dim);
    for (int i = 0; i < dim; i += 2) {
        (this->prd + i)->start = *(prd + i);
        (this->prd + i)->end = *(prd + i + 1);
    }
}

int array_id::get_dim(){
    return dim;
}

period array_id::get_period(int dim){
    return *(prd + dim);
}
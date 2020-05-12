#include "parser/DataType.h"
#include <iostream>
#include <parser/SymbolTable.h>
#include <iostream>

static symbol_table st;

int main(){
    symbol_table s;
    s.enter("book",1);
    symbol_e_t temp;
    s.find("book",temp);
    std::cout << temp.to_string();
    return 0;
}
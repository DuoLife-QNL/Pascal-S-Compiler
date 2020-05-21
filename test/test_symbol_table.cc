#include <iostream>
#include <string>
#include "../parser/DataType.h"
#include "../parser/SymbolTable.h"

using namespace std;

int main(){
    basic_type_symbol e((string)"test", REAL);
    cout << e.get_type() << endl;
}
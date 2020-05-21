#include <iostream>
#include <string>
#include "../parser/DataType.h"
#include "../parser/SymbolTable.h"

using namespace std;

int main(){
    int a[6] = {1, 2, 3, 4, 0, 5};
    array_id e("test", 3, a);
    cout << e.get_period(2).start << endl;
}
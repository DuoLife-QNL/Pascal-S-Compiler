#include <iostream>
#include <string>
#include "../parser/IdType.h"
#include "../parser/IdTable.h"

using namespace std;

int main(){
    int a[6] = {1, 2, 3, 4, 0, 5};
    array_id *id = new array_id("test", INTEGER, 3, a);
    cout << id->get_period(2).start << endl;
    cout << "here" << endl;
    delete id;
}
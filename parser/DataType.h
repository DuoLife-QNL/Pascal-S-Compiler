#ifndef STRUCT_DEF_H
#define STRUCT_DEF_H

#include <stack>
#include <string>

#define error_report(s) fprintf(stderr, s)

typedef struct {
    std::string name;
    int type;

    std::string to_string(){
      return "{" + name + "," + std::to_string(type) + "}";
    }
}symbol_e_t;

void enter(std::string name, int type);


#endif // STRUCT_DEF_H
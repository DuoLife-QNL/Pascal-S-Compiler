#ifndef STRUCT_DEF_H
#define STRUCT_DEF_H

#include <stack>
#include <string>

#define error_report(s) fprintf(stderr, s)

typedef struct parameter_list{
  std::string name;
  int type;
  bool isVAR;
  parameter_list * next_element;
}parameter_list;

typedef struct parameter_list_head{
  parameter_list * pl;
  int ret_type;
}parameter_list_head;

typedef struct {
    std::string name;
    bool isFunction;
    int type;
    parameter_list_head *plh;

    std::string to_string(){
      return "{" + name + "," + std::to_string(type) + "}";
    }
}symbol_e_t;

void enter(std::string name, int type);



#endif // STRUCT_DEF_H
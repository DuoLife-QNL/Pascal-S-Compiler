#ifndef STRUCT_DEF_H
#define STRUCT_DEF_H

#include <stack>
#include <string>

// #define error_report(s) fprintf(stderr, s)

typedef enum TYPE {
  ARRAY,
  INTEGER,
  REAL,
  BOOLEAN,
  CHAR,
  PROCEDURE,
  FUNCTION
}TYPE;

class symbol {
  private:
    TYPE type;
    std::string name;

  public:
    symbol(std::string name, TYPE type);
    std::string get_name();
    TYPE get_type();
};

class basic_type_symbol: public symbol {
  public:
    basic_type_symbol(std::string name, TYPE type);
};
typedef struct parameter_list{
  std::string name;
  int type;
  /*
   * @isVAR: is var_parameter
   * false if value_parameter
   */
  bool isVAR;
  parameter_list * next_element;
}parameter_list;

typedef struct parameter_list_head{
  parameter_list * pl;
  int ret_type;
}parameter_list_head;

/* an element in symbol table */
typedef struct {
    std::string name;
    TYPE type;
    parameter_list_head *plh;

   /*  std::string to_string(){
      return "{" + name + "," + std::to_string(type) + "}";
    } */
}symbol_e_t;

void enter(std::string name, int type);



#endif // STRUCT_DEF_H
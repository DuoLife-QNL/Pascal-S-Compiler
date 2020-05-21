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

class id {
  private:
    TYPE type;
    std::string name;

  public:
    id(std::string name, TYPE type);
    std::string get_name();
    TYPE get_type();
};

class basic_type_id: public id {
  public:
    basic_type_id(std::string name, TYPE type);
};

/* the start num and end num of a dimension of an array */
typedef struct period{
  int start;
  int end;
}period;
class array_id: public id {
  private:
    /* dimension */
    int dim;
    period *prd;
    TYPE element_type;
  
  public:
    /* 
     * @prd is an array of int:
     * [s0, e0, s1, e1......]
     * in which s0 indicates the start num of 1st dimension,
     * and e0 indicates the end num of 1st dimension
     * NOTE THAT it starts from index 0
     */
    array_id(std::string name, TYPE et, int dim, int *prd);
    int get_dim();
    period get_period(int dim);
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
#ifndef STRUCT_DEF_H
#define STRUCT_DEF_H

#include <iostream>
#include <stack>
#include <string>
#include <vector>

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

/* 
 * according to PPT, basic type include:
 * integer, real, boolean, char
 */
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
    ~array_id();
    int get_dim();
    period get_period(int dim);
};


class parameter: public basic_type_id{
  private:
    /*
    * @isVAR: is var_parameter
    * false if value_parameter
    */
    bool is_var_;
  
  public:
    parameter(std::string name, TYPE type, bool is_var);
    bool is_var();

};

/* function and procedure are inherited from block */
class block: public id {
  private:
    /* parameter list */
    std::vector<parameter>pl; 
  public:
    block(std::string name, TYPE type, std::vector<parameter> pl);
    /* get parameter list */
    std::vector<parameter> get_par_list();
};

class procedure_id: public block {
  public:
    procedure_id(std::string name, std::vector<parameter> pl);
};

class function_id: public block {
  private:
    /* return type */
    TYPE ret_type;
  public:
    function_id(std::string name, std::vector<parameter> pl, TYPE ret_type);
    TYPE get_ret_type();
};


#endif // STRUCT_DEF_H
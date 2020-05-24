#ifndef STRUCT_DEF_H
#define STRUCT_DEF_H

#include <iostream>
#include <stack>
#include <string>
#include <vector>

// #define error_report(s) fprintf(stderr, s)

typedef enum TYPE {
  INTEGER,
  REAL,
  BOOLEAN,
  CHAR,
  ARRAY,
  PROCEDURE,
  FUNCTION
}TYPE;

class Id {
  private:
    TYPE type;
    std::string name;

  public:
    Id(std::string name, TYPE type);
    std::string get_name();
    TYPE get_type();
};

/* 
 * according to PPT, basic type include:
 * integer, real, boolean, char
 */
class BasicTypeId: public Id {
  public:
    BasicTypeId(std::string name, TYPE type);
};

/* struct period stores the start num and end num of a dimension of an array */
typedef struct period{
  int start;
  int end;
  period *next;
}period;
/* initiate a new period, and return the pointer */
period *init_period();
/* append a new period to the existed period list */
void append_period(period *target_period, period *new_period);

class ArrayId: public Id {
  private:
    /* dimension */
    int dim;
    period *prd;
    TYPE element_type;
  
  public:
    /* Constructor:
     * @et: type of elements in this array
     * @prd is an pointer to the array period list 
     */
    ArrayId(std::string name, TYPE et, int dim, period *prd);
    ~ArrayId();
    int get_dim();
    period get_period(int dim);
};


class Parameter: public BasicTypeId{
  private:
    /*
    * @isVAR: is var_Parameter
    * false if value_Parameter
    */
    bool is_var_;
  
  public:
    Parameter(std::string name, TYPE type, bool is_var);
    bool is_var();

};

/* function and procedure are inherited from Block */
class Block: public Id {
  private:
    /* Parameter list */
    std::vector<Parameter>pl; 
  public:
    Block(std::string name, TYPE type, std::vector<Parameter> pl);
    /* get Parameter list */
    std::vector<Parameter> get_par_list();
};

class ProcedureId: public Block {
  public:
    ProcedureId(std::string name, std::vector<Parameter> pl);
};

class FunctionId: public Block {
  private:
    /* return type */
    TYPE ret_type;
  public:
    FunctionId(std::string name, std::vector<Parameter> pl, TYPE ret_type);
    TYPE get_ret_type();
};


#endif // STRUCT_DEF_H
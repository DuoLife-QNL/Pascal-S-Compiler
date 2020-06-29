#ifndef STRUCT_DEF_H
#define STRUCT_DEF_H

#include <iostream>
#include <stack>
#include <string>
#include <vector>

/*
 * We add '_' before each type because they have
 * been declared as tokens in parser.y
 */
typedef enum TYPE {
  _DEFAULT,
  _VOID,
  _INTEGER,
  _REAL,
  _BOOLEAN,
  _CHAR,
  _ARRAY,
  _PROCEDURE,
  _FUNCTION
<<<<<<< HEAD
}TYPE;
=======
} TYPE;
>>>>>>> a1246c25b3866e0a0e58f009c7554ce5d4bc428a

class Id {
 private:
  TYPE type;
  std::string name;

 public:
  Id(std::string name, TYPE type);

  TYPE get_type();
  std::string get_name();
};

/*
 * according to PPT, basic type include:
 * integer, real, boolean, char
 */
class BasicTypeId : public Id {
 public:
  bool is_const;
  BasicTypeId(std::string name, TYPE type, bool is_const);
};

/* struct period stores the start num and end num of a dimension of an array */
typedef struct period {
  int start;
  int end;
  period *next;
} period;
/* initiate a new period, and return the pointer */
period *init_period();
/* append a new period to the existed period list */
void append_period(period *target_period, period *new_period);

<<<<<<< HEAD
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
    Block(std::string name, TYPE type, std::vector<Parameter> pl, TYPE ret_type);
    /* get Parameter list */
    std::vector<Parameter> get_par_list();
=======
// multi-dimension array
class ArrayId : public Id {
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

class Parameter : public BasicTypeId {
 public:
  /*
  * @isVAR: is var_Parameter
  * false if value_Parameter
  */
  bool is_var;
  Parameter(std::string name, TYPE type, bool is_var);
};

/* function and procedure are inherited from Block */
class Block : public Id {
 private:
  TYPE ret_type;
  /* Parameter list */
  std::vector<Parameter> pl;
 public:

  Block(std::string name, TYPE type, std::vector<Parameter> pl, TYPE ret_type);
  /* get Parameter list */
  std::vector<Parameter> get_par_list();

  TYPE get_ret_type();
>>>>>>> a1246c25b3866e0a0e58f009c7554ce5d4bc428a
};

class ProcedureId : public Block {
 public:
  ProcedureId(std::string name, std::vector<Parameter> pl);
};

class FunctionId : public Block {
 public:
  FunctionId(std::string name, std::vector<Parameter> pl, TYPE ret_type);
};

#endif // STRUCT_DEF_H

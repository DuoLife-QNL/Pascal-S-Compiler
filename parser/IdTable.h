// // Created by 侯崴瀛 on 2020-05-10. //

#ifndef ID_TABLE_H_
#define ID_TABLE_H_

#include <vector>
#include "IdType.h"

#define array(a,b,c,d)
class IdTable {
private:
  std::vector<Id*> table;
  /* block index table */
  std::stack<int> index;

 /* locate: 
  * should be invoked immediately after putting
  * the block_id(procedure or function) into 
  * the id table
  */
  void locate();
  void relocate();

public:
  IdTable();

  /* enter_id:
   * Enter an id into the IdTable.
   * If the id is a procedure or function, 
   * locate() should be called.
   * NOTE That locate() is considered to be a private
   * function
   */
  void enter_id(Id *symbol);

  /* 
   * We need to know whether the symbol is in current scope,
   * so the function should return the index of the symbol
   * if it's found. Otherwise return -1.
   * @name: the name of the symbol to find
   */
  int find_id(std::string name);

  /* 
   * end_block:
   * When a block(procedure or function) reaches the end,
   * revoke this function to pop all the id in id table 
   * and relocate the id index table.
   * NOTE That relocate() is considered to be a private 
   * function, and the parser should only call end_block().
   */
  void end_block();

  /* 
   * judge whether a given id index is in current scope
   * @i: the index of the id
   */
  bool in_cur_scope(int i);  

  /* 
   * return id instance by index
   * @i: the index of the id
   */
  Id* get_id(int i);

};

#endif //PASCAL_S_COMPLIER_PARSER_SYMBOLTABLE_H_

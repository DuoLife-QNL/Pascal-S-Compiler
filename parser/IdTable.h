// // Created by 侯崴瀛 on 2020-05-10. //

#ifndef ID_TABLE_H_
#define ID_TABLE_H_

#include <vector>
#include "IdType.h"

#define array(a,b,c,d)
class id_table {
private:
  std::vector<id> table;
  /* block index table */
  std::stack<int> index;

  void relocate();

public:
  id_table();

  /* enter_id:
   * enter an id into the id_table
   * If the id is a procedure or function, 
   * locate() should be called
   */
  void enter_id(id symbol);

  /* 
   * We need to know whether the symbol is in current scope,
   * so the function should return the index of the symbol
   * if it's found. Otherwise return -1
   * @name: the name of the symbol to find
   */
  int find_id(std::string name);

  /* locate: 
   * should be invoked immediately after putting
   * the block_id(procedure or function) into 
   * the id table
   */
  void locate();

  /* 
   * end_block:
   * When a block(procedure or function) reaches the end,
   * revoke this function to pop all the id in id table 
   * and relocate the id index table.
   * NOTE That relocate() is considered to be a
   * private function, and the parser should only call
   * end_block().
   */
  void end_block();

  /* 
   * judge whether a given id index is in current scope
   * @i: the index of the id
   */
  bool in_cur_scope(int i);  

};

#endif //PASCAL_S_COMPLIER_PARSER_SYMBOLTABLE_H_

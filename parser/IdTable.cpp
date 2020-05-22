// Created by 侯崴瀛 on 2020-05-10.
//

#include "IdTable.h"
#include <stdlib.h>
#include <string>

id_table::id_table(){
  index.push(0);
}

void id_table::enter_id(id symbol){
  table.push_back(symbol);
  TYPE s_type = symbol.get_type();
  if (s_type == PROCEDURE || s_type == FUNCTION)
    locate();
}

int id_table::find_id(std::string name) { 
  if (table.empty()){
    return -1;
  }

  for(int i = table.size() - 1; i >= 0; i--){
    if (table.at(i).get_name() == name){
      return i;
    }
  }
  return -1;
}

void id_table::locate() {
  index.push(table.size());
}

void id_table::relocate() {
  index.pop();
}

void id_table::end_block(){
  table.erase(table.begin() + index.top(), table.end());
  relocate();
}

inline bool id_table::in_cur_scope(int i){
  return i >= index.top();
}
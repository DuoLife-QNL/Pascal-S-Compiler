// Created by 侯崴瀛 on 2020-05-10.
//

#include "IdTable.h"
#include <stdlib.h>
#include <string>

IdTable::IdTable(){
  index.push(0);
}

void IdTable::enter_id(Id *symbol){
  table.push_back(symbol);
  TYPE s_type = symbol->get_type();
  if (s_type == _PROCEDURE || s_type == _FUNCTION)
    locate();
}

int IdTable::find_id(std::string name) { 
  if (table.empty()){
    return -1;
  }

  for(int i = table.size() - 1; i >= 0; i--){
    if (table.at(i)->get_name() == name){
      return i;
    }
  }
  return -1;
}

void IdTable::locate() {
  index.push(table.size());
}

void IdTable::relocate() {
  index.pop();
}

void IdTable::end_block(){
  table.erase(table.begin() + index.top(), table.end());
  relocate();
}

bool IdTable::in_cur_scope(int i){
  return i >= index.top();
}

Id* IdTable::get_id(int i) {
  return table.at(i);
}
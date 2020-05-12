//
// Created by 侯崴瀛 on 2020-05-10.
//

#include "SymbolTable.h"
symbol_table::symbol_table() {}

void symbol_table::enter(std::string name, int type) {
//  检查同名变量
  symbol_e_t temp;
  if(find(name, temp)){
    error_report("重名");
    exit(-1);
  }
//  symbol_e_t entry{name, type};

}

bool symbol_table::find(std::string name, symbol_e_t &entry) {
//  i >= index_.top() &&
  if (table_.empty()){
    return false;
  }
  for(int i = table_.size() - 1; i >= -1; i--){
    if (table_.at(i).name == name){
      entry.name = name;
      entry.type = table_.at(i).type;
      return true;
    }
  }
  return false;
}
void symbol_table::locate() {
  index_.push(table_.size());
}

void symbol_table::relocate() {
  table_.erase(table_.begin() + index_.top(), table_.end());
  index_.pop();
}
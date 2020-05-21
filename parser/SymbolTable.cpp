//
// Created by 侯崴瀛 on 2020-05-10.
//

#include "SymbolTable.h"
#include<stdlib.h>
symbol_table::symbol_table() {}

void symbol_table::enter_sym(std::string name, TYPE type) {
//  检查同名变量
  symbol_e_t temp;
  if(find(name, temp)){
    // error_report("重名");
    exit(-1);
  }
//  symbol_e_t entry{name, type};

}
void symbol_table::enter_pl(std::string name, TYPE type) {

}

/* 
 * We need to know whether the symbol is in current scope,
 * so the function should return the index of the symbol
 * if it's found. Otherwise return -1
 * @name: the name of the symbol to find
 * @entry: if found, the location of the symbol should 
 *         be stored in here
 */
int symbol_table::find(std::string name, symbol_e_t &entry) {
//  i >= index_.top() &&
  if (table_.empty()){
    return -1;
  }
  // TODO: figure out why i >= -1, shouldn't end when i = 0?
  for(int i = table_.size() - 1; i >= -1; i--){
    if (table_.at(i).name == name){
      entry.name = name;
      entry.type = table_.at(i).type;
      return i;
    }
  }
  return -1;
}
void symbol_table::locate() {
  index_.push(table_.size());
}

void symbol_table::relocate() {
  table_.erase(table_.begin() + index_.top(), table_.end());
  index_.pop();
}


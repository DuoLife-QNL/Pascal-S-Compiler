//
// Created by 侯崴瀛 on 2020-05-10.
//

#ifndef PASCAL_S_COMPLIER_PARSER_SYMBOLTABLE_H_
#define PASCAL_S_COMPLIER_PARSER_SYMBOLTABLE_H_

#include <vector>
#include "DataType.h"

class symbol_table {
private:
  std::vector<symbol_e_t> table_;
  std::stack<int> index_;

  void add_entry();

public:
  symbol_table();
//  插入
  void enter(std::string name, int type);
//  检索
  bool find(std::string name, symbol_e_t &entry);
//  定位 声明语句第一个变量前调用
  void locate();
//  重定位
  void relocate();

};



#endif //PASCAL_S_COMPLIER_PARSER_SYMBOLTABLE_H_

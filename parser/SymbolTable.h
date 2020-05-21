//
// Created by 侯崴瀛 on 2020-05-10.
//

#ifndef PASCAL_S_COMPLIER_PARSER_SYMBOLTABLE_H_
#define PASCAL_S_COMPLIER_PARSER_SYMBOLTABLE_H_

#include <vector>
#include "DataType.h"

#define array(a,b,c,d)
class symbol_table {
private:
  std::vector<symbol_e_t> table_;
  /* block index table */
  std::stack<int> index_;

public:
  symbol_table();
//  插入符号表
  void enter_sym(std::string name, TYPE type);
//  插入块索引表top -1 指向的函数/过程的参数表
  void enter_pl(std::string name, TYPE type);
//  检索
  int find(std::string name, symbol_e_t &entry);
//  定位 声明语句第一个变量前调用
  void locate();
//  重定位
  void relocate();
//  添加过程/函数（创建子表）
  void enterproc(std::string name, TYPE type);
};

#endif //PASCAL_S_COMPLIER_PARSER_SYMBOLTABLE_H_

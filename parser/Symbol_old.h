//
// Created by 侯崴瀛 on 2020-05-21.
//

#ifndef PASCAL_S_COMPLIER_PARSER_SYMBOL_H_
#define PASCAL_S_COMPLIER_PARSER_SYMBOL_H_

#include "Symbol_old.h"
Symbol::Symbol(bool is_token) : isToken(is_token) {}
Symbol::~Symbol() {}
std::string Symbol::toString() const {
  if (isToken)
    return "Token";
  else
    return "NonToken";
}

#endif // PASCAL_S_COMPLIER_PARSER_SYMBOL_H_

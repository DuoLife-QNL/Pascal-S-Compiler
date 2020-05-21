//
// Created by 侯崴瀛 on 2020-05-21.
//

#include "Symbol_old.h"

Symbol::Symbol(bool is_token) : isToken(is_token) {}
Symbol::~Symbol() {}
std::string Symbol::toString() const {
  if (isToken)
    return "Token";
  else
    return "NonToken";
}

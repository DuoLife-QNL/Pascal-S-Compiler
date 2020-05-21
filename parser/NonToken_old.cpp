//
// Created by 侯崴瀛 on 2020-05-21.
//

#include "NonToken_old.h"

#include "NonToken_old.h"
NonToken::NonToken(std::string l) : Symbol(false), label(std::move(l)) {
  if (label == ".") {
    type = NonTokenType::DOT;
  } else if (label == "E") {
    type = NonTokenType ::START;
  } else {
    type = NonTokenType ::NONTERMINALORSTART;
  }
}

std::string NonToken::toString() const {
  if (type == NonTokenType ::DOT) {
    return "{DOT}";
  } else {
    return label;
  }
}
const std::string &NonToken::getLabel() const { return label; }
NonTokenType NonToken::getType() const { return type; }


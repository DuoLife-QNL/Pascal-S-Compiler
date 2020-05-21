//
// Created by 侯崴瀛 on 2020-05-21.
//

#include "Token_old.h"

Token::Token(TokenType t, std::string a) : Symbol(true) {
  type = t;
  attr = std::move(a);
  genLabelFromType();
}
Token::Token() : Symbol(true) {
  type = TokenType::UNKNOWN;
  attr = "";
}
void Token::setToken(TokenType t, std::string a) {
  type = t;
  attr = std::move(a);
  switch (t) {
  case TokenType ::CONST:
    label = typeToName(t);
    break;
  case TokenType ::EPSILON:
    label = typeToName(t);
    break;
  case TokenType ::PUNCT:
    label = attr;
    break;
  case TokenType ::END:
    label = "$";
    break;
  default:
    label = typeToName(t);
    break;
  }
}
std::string itos(int num) {
  std::stringstream ss;
  ss << num;
  return ss.str();
}
std::string Token::typeToName(TokenType t) const {
  std::string ret;
  switch (t) {
  case TokenType::KW:
    ret = "KW";
    break;
  case TokenType::ID:
    ret = "ID";
    break;
  case TokenType::CONST:
    ret = "CONST";
    break;
  case TokenType::STR:
    ret = "STR";
    break;
  case TokenType::COMMENT:
    ret = "COMMENT";
    break;
  case TokenType::PUNCT:
    ret = "PUNCT";
    break;
  case TokenType::EPSILON:
    ret = "EPSILON";
    break;
  case TokenType::END:
    ret = "END";
    break;
  case TokenType::UNKNOWN:
    ret = "UNKNOWN";
    break;
  default:
    break;
  }
  return ret;
}
std::string Token::toString() const {
  //    return "{\"type\":" + typeToName(type) + ", \"attr\":" + attr + "}";
  if (type == TokenType::CONST) {
    return "{C}";
  } else if (type == TokenType::EPSILON) {
    return "{e}";
  } else if (type == TokenType::UNKNOWN) {
    return "";
  }
  return label;
}

void Token::setType(TokenType t) { Token::type = t; }
Token::Token(Token const &t) : Symbol(true) {
  type = t.getType();
  attr = t.getAttr();
  genLabelFromType();
}

bool Token::operator==(const Token &t) const {
  return this->toString() == t.toString();
}
bool Token::operator<(const Token &t) const { return false; }
bool Token::operator>(const Token &t) const { return false; }
void Token::genLabelFromType() {
  switch (type) {
  case TokenType ::CONST:
    label = typeToName(type);
    break;
  case TokenType ::PUNCT:
    label = attr;
    break;
  case TokenType ::END:
    label = "$";
    break;
  default:
    label = typeToName(type);
    break;
  }
}
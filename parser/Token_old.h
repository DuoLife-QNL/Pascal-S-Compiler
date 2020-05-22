//
// Created by 侯崴瀛 on 2020-05-21.
//

#ifndef PASCAL_S_COMPLIER_PARSER_TOKEN_H_
#define PASCAL_S_COMPLIER_PARSER_TOKEN_H_

#if 0
#include "Symbol_old.h"
#include <sstream>
#include <string>
std::string itos(int num);
enum class TokenType {
  KW,
  ID,
  CONST,
  STR,
  COMMENT,
  PUNCT,
  EPSILON,
  END = 8,
  UNKNOWN = 9
};

class Token : public Symbol {
private:
  TokenType type;
  std::string attr;
  std::string label;
  void setType(TokenType t);
  void setAttr(std::string a) { Token::attr = std::move(a); }
  void genLabelFromType();

public:
  Token();
  Token(TokenType t, std::string a);
  Token(Token const &t);
  void setToken(TokenType, std::string);
  TokenType getType() const { return type; }

  const std::string &getAttr() const { return attr; }

  std::string toString() const override;
  std::string typeToName(TokenType t) const;

  bool operator==(const Token &t) const;
  bool operator<(const Token &t) const;
  bool operator>(const Token &t) const;
};

#endif
#endif //PASCAL_S_COMPLIER_PARSER_TOKEN_H_

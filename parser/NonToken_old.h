//
// Created by 侯崴瀛 on 2020-05-21.
//

#ifndef PASCAL_S_COMPLIER_PARSER_NONTOKEN_H_
#define PASCAL_S_COMPLIER_PARSER_NONTOKEN_H_

#include "Symbol_old.h"

enum class NonTokenType {
  // 一般非终结符：非终结、非开始
      NONTERMINALORSTART,
  // 开始符号 默认E
      START,
  // 项目中的 点
      DOT
};

class NonToken : public Symbol {
private:
  std::string label;
  NonTokenType type;

public:
  explicit NonToken(std::string label);
  NonTokenType getType() const;
  const std::string &getLabel() const;

  std::string toString() const override;
};

#endif // PASCAL_S_COMPLIER_PARSER_NONTOKEN_H_

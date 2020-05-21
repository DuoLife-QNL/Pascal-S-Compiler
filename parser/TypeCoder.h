//
// Created by 侯崴瀛 on 2020-05-12.
//

#ifndef PASCAL_S_COMPLIER_PARSER_TYPECODE_H_
#define PASCAL_S_COMPLIER_PARSER_TYPECODE_H_

enum Type {
  INTEGER,
  BOOLEAN,
  CHAR,
  ARRAY
};

typedef struct {
  enum Type code;
  int *size;
}type_dspt;

class TypeCode {
private:
  static int array_cnt;
public:
  static int encode_array(int index, int *size);
  static type_dspt decode(int type_code);
};



#endif //PASCAL_S_COMPLIER_PARSER_TYPECODE_H_

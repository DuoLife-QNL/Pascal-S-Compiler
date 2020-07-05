
Program block_errors(input, output);

Var 
  x,y : integer;
  bool: boolean;
  c: real;
  ch: char;
  // 块声明时的错误
Function foo1(Var a, 12, c: bean): integer;
Begin
  a := 1;
  c := 1.2;
  // 类型不匹配
  c := 'a';
  foo1 := 0;
End;

Procedure foo2(Var c: integer);
Begin
End;

Procedure foo3(a:integer);
Begin
End;

Begin
  // 语法错误
  foo1(...);
  // 过程无法引用返回值
  x := foo3(x);
  // var类型实参表达式只能为左值
  foo2(x + y);
  // 参数类型不匹配
  foo3(ch);
  // 参数个数不匹配
  foo3(x, y)
End.

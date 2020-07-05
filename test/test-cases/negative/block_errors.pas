
Program block_errors(input, output);

Var 
  x,y : integer;
  bool: boolean;
  c: real;
  d: real;
  ch: char;
  // 块声明时的错误
Function foo1(Var a, 12, c: bean): double;
Begin
  a := 1;
  // c foo1参数中 c 未定义，默认类型设为int
  // 类型不一致
  c := 1.2;
  // 类型不匹配
  d := ch;
  foo1 := 0;
End;

Procedure foo2(Var c: integer);
Begin
End;

Procedure foo3(a:integer);
Begin
End;

  // 参数列表缺失
procedure foo4();
  // 过程体声明错误
start
end;

  // 参数列表错误
procedure foo5(...);
begin
end;

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

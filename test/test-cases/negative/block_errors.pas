
Program block_errors(input, output);

Var 
  x,y : integer;
  bool: boolean;
  c: real;
Function foo1(var a, 12, c: bean): integer;
Begin
  a := 1;
  c := 1.2;
  c := 2;
  d := 3;
  foo1 := 0;
End;

Procedure foo2(Var c: integer);
Begin
End;

Procedure foo3(a:integer);
Begin
End;

Begin
  foo1(...);
  x := foo3(x);
  foo2(x + y);
  foo3(c);
  foo3(x, y)
End.

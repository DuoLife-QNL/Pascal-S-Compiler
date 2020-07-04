
Program block_errors(input, output);

Var 
  x,y : integer;
  bool: boolean;
  c: char;
Function foo1(a: bean): integer;
Begin
  foo1 := 0;
End;

Procedure foo2(Var c: integer);
Begin
End;

Procedure foo3(a:integer);
Begin
End;

Begin
  x := foo3(x);
  foo2(x + y);
  foo3(c);
  foo3(x, y)
End.

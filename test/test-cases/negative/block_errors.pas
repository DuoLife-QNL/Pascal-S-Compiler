Program block_errors(input, output);

Var
  x : integer;
  y : real;
  bool: boolean;
  c: char;
Function foo1(a: bean; 123: char): integer;
Begin
  a := 0;
End;

Procedure foo2(a, b: integer; Var c: integer);
Begin
End;

Procedure foo3(a: integer)
Begin
End;

Begin
  x := foo3(x);
  foo3(c)
End.
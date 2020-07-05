
Program var_procedure(input, output);

Var x,y : integer;
Procedure exchange(Var x,y:integer);

Var tmp : integer;
Begin
  tmp := x;
  x := y;
  y := tmp
End;
Begin
  read(x, y);
  exchange(x,y);
  write(x, y)
End.

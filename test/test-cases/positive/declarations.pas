
Program declarations(input, output);

Const c = +10;
      ch = '#';

Var x,y,sum1, sum2, sum3: integer;
  z: array[1..2] Of integer;
Function sum(a, b:integer): integer;

Begin
  sum := a+b;
End;
Begin
  read(x, y);
  z[1] := 3;
  z[2] := 4;
  sum1 := sum(x, y);
  sum2 := sum(z[1], z[2]);
  write(ch);
  write(c);
  write(ch);
  write(sum(sum1, sum2));
End.

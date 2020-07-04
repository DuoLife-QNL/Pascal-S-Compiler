
Program test(input, output);

Var x,y: integer;
    z1: array[9..1] Of integer;
    z2: array[1..9, 2..10] of integer;
Function gcd(a,b: integer): integer;

Var f: integer;
Begin
  If b = 0 Then gcd := a
  Else gcd := gcd(b, a Mod b)
End;
Begin
  z2[10, 2.3] := 1;
  z2[1, 2, 3] := 1;
  read(x, y);
  write(gcd(x, y))
End.

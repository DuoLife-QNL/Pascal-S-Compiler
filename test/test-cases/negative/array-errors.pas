
Program test(input, output);

Var x,y: integer;
  z,z1,z2,z3,z4: array[9..1] Of integer;
Function gcd(a,b: integer): integer;

Var f: integer;
Begin
  If b = 0 Then gcd := a
  Else gcd := gcd(b, a Mod b)
End;
Begin
  read(x, y);
  writ e(gcd(x, y))
End.

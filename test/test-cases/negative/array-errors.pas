Program id-errors(input, output);

Var x,y: integer;
  z,z1,z2,z3,z4: array[9..1] Of integer;
  a: array[1...10] of integer;
  b: array[] of integer;
  c: array[1..10] of cccc;
  d: char
[10];

Function gcd(a,b: integer): integer;

Var f: integer;
Begin
  If b = 0 Then gcd := a
  Else gcd := gcd(b, a Mod b)
End;
Begin
  read(x, y);
  write(gcd(x, y))
End.

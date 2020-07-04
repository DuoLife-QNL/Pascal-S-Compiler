
Program const_errors(input, output);

Const 
  b = 1;
  a = 3;
Begin
  read(b);
  For b := 1 To 3 Do
    Begin
      a := 4;
      b := 3;
    End;
End.

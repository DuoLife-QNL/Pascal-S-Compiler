
Program type_errors(input, output);

Var int: integer;
  bool : boolean;
Begin
  If bool = int Then
    int := 1
  Else
    Begin
      int := int + bool;
      int := bool;
      int := 2
    End;
  For bool := 1 To 2.3 Do Begin
    if 1 + 2 Then
      int := 3
  End
End.

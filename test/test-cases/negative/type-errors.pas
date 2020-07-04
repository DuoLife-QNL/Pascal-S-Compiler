Program array_errors(input, output);

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
    End
End.

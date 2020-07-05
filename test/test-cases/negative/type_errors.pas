
Program type_errors(input, output);

Var int: integer;
  bool : boolean;
  r: real;
Begin
  // 类型不一致
  r := int;
  // 类型不一致
  r := 3;
  // 运算表达式类型不匹配
  If bool = int Then
    int := 1
  Else
    Begin
      // 运算表达式类型不匹配
      int := int + bool;
      // 赋值表达式左右类型不匹配
      int := bool;
      int := 2
    End;
  // for 循环变量必须为整型
  For bool := 1 To 2.3 Do
    Begin
      // if 循环判断条件必须为布尔类型
      If 1 + 2 Then
        int := 3
    End;
  //  for循环初值和终值必须为整型 
  For int := 1.1 To 2.3 Do
    Begin
      int := 2
    End
End.

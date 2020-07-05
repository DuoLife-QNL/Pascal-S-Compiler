
Program const_errors(input, output);

Const
  b = 1;
  // 常量无效
  d = b;
  c = 111;
  // 重复定义
  b = 123;
  // 常量定义错误
  12 = a;
  // 忽略，直到下一个正确的产生式开头（恢复策略）
  a = 12;
  f = 12;
Begin
  // 不能对常量写入
  read(b);
  // 不能对常量赋值
  For b := 1 To 3 Do
    Begin
      // 未声明变量
      a := 4;
      // 不能对常量赋值
      b := 3;
      // 语法错误
      :=4;
      // 不能对常量赋值
      c := 10;
    End;
End.


Program array_errors(input, output);

Var x,y: integer;
  // 数组下界必须小于上界
  z1: array[9..1] Of integer;
  z2: array[1..9, 2..10] Of integer;
  // 数组边界必须为常数
  a: array[ab..10] Of integer;
  // 数组边界缺失
  b: array[] Of integer;
  // 元素类型未定义
  c: array[1..10] Of int;
  d: integer;
  e: real;


Function gcd(a,b: integer): integer;

Var f: integer;
Begin
  If b = 0 Then gcd := a
  Else gcd := gcd(b, a Mod b)
End;
Begin
  //数组越界
  z2[10, 2] := 1;
  // 数组下标必须为整型
  z2[9, 2.3] := 1;
  // 数组维度不匹配
  z2[1, 2, 3] := 1;
  z2[] := 2;
  d := 10;
  read(x, y);
  write(gcd(x, y))
End.

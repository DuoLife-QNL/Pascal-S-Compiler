
Program quick_sort(input, output);

Var a: array[1..101] Of integer;
  k,
  m,tempOut: integer;
Function partition(low,high: integer): integer;

Var i, j, temp: integer;
Begin
  i := low - 1;
  For j:=low To (high - 1) Do
    Begin
      If a[j] <= a[high] Then
        Begin
          i := i + 1;
          temp := a[i];
          a[i] := a[j];
          a[j] := temp
        End;
    End ;
  i := i + 1;
  temp := a[i];
  a[i] := a[high];
  a[high] := temp;
  partition := i
End;
Procedure qs(low,high: integer);

Var pivot: integer;
Begin
  pivot := 0;
  If low <= high Then
    Begin
      pivot := partition(low, high);
      qs(low, pivot - 1);
      qs(pivot + 1, high)
    End
End;
Begin
  read(m);
  For k:=1 To m Do
    Begin
      read(tempOut);
      a[k] := tempOut;
    End;
  qs(1, m);
  For k:=1 To m Do
    Begin
      write(a[k]);
    End
End.